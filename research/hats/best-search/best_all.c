/*
 * SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
 *
 * SPDX-License-Identifier: MIT
 */

/*
 * All the best strategies on N hats (two players, one shared strategy).
 *
 * usage: best_all N TARGET [DEPTH] > strategies.txt
 *
 * Prints every crushed strategy on N hats with at least TARGET hits, one
 * word per line, and on the standard error the numbers of strategies and
 * of nodes.  "Crushed": seeing stack number t, the strategy points at a
 * position at most t; every strategy is equivalent to a crushed one
 * (formal/hats/Hats/Crush.lean).  The choices for the all-white and the
 * all-black stack, which do not matter, are 0.
 *
 * Search.  The stacks get their choices one by one, those with few black
 * hats first.  With A the stacks that have a choice and U the others, the
 * hits are at most
 *
 *     hits inside A  +  sum over u in U of the best over q of
 *                       ( back[u][q] + open[q] )
 *
 * where back[u][q] is twice the number of stacks t of A that are black at
 * q and point at a black hat of u (the hits of u with A if u chooses q),
 * and open[q] the number of stacks of U that are black at q (a pair of
 * stacks of U is a hit only if the first is black where the second
 * points).  A partial strategy whose bound is below TARGET is dropped.
 *
 * The work is shared between threads at depth DEPTH (5 by default).
 */

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXN 6
#define MAXS (1 << MAXN)

static int n, size, target, nord;
static int order[MAXS];

typedef struct {
    int choice[MAXS];
    char assigned[MAXS];
    int back[MAXS][MAXN];
    int open[MAXN];
    int inside; /* hits inside A */
    uint64_t nodes, found;
} state;

static int bound(const state *s) {
    int total = s->inside;
    for (int i = 0; i < nord; i++) {
        int u = order[i];
        if (s->assigned[u]) continue;
        int best = 0, top = u < n ? u : n - 1;
        for (int q = 0; q <= top; q++) {
            int v = s->back[u][q] + s->open[q];
            if (v > best) best = v;
        }
        total += best;
    }
    return total;
}

static void emit(const state *s) {
    char word[MAXS + 1];
    for (int t = 0; t < size; t++) word[t] = (char)('0' + s->choice[t]);
    word[size] = 0;
    #pragma omp critical
    puts(word);
}

static void place(state *s, int u, int q) {
    /* u joins A with the choice q */
    s->assigned[u] = 1;
    s->choice[u] = q;
    s->inside += s->back[u][q] + (u >> q & 1); /* with A, and the pair (u, u) */
    for (int p = 0; p < n; p++) s->open[p] -= u >> p & 1;
    if (u >> q & 1 || 1) {
        /* for a stack w of U choosing p: u counts if u is black at p and w
           is black at q */
        for (int i = 0; i < nord; i++) {
            int w = order[i];
            if (s->assigned[w] || !(w >> q & 1)) continue;
            for (int p = 0; p < n; p++)
                if (u >> p & 1) s->back[w][p] += 2;
        }
    }
}

static void search(state *s, int depth) {
    s->nodes++;
    if (depth == nord) {
        if (s->inside >= target) {
            s->found++;
            emit(s);
        }
        return;
    }
    int u = order[depth];
    int top = u < n ? u : n - 1;
    for (int q = 0; q <= top; q++) {
        state next = *s;
        uint64_t nodes = s->nodes, found = s->found;
        next.nodes = 0;
        next.found = 0;
        place(&next, u, q);
        if (bound(&next) >= target) search(&next, depth + 1);
        s->nodes = nodes + next.nodes;
        s->found = found + next.found;
    }
}

/* the partial strategies at a given depth that survive */
static state *tasks;
static int ntasks, captasks;

static void collect(state *s, int depth, int stop) {
    if (depth == stop) {
        if (ntasks == captasks) {
            captasks = captasks ? 2 * captasks : 256;
            tasks = realloc(tasks, (size_t)captasks * sizeof(state));
        }
        tasks[ntasks++] = *s;
        return;
    }
    int u = order[depth];
    int top = u < n ? u : n - 1;
    for (int q = 0; q <= top; q++) {
        state next = *s;
        place(&next, u, q);
        if (bound(&next) >= target) collect(&next, depth + 1, stop);
    }
}

static int by_weight(const void *a, const void *b) {
    int x = *(const int *)a, y = *(const int *)b;
    int wx = __builtin_popcount((unsigned)x), wy = __builtin_popcount((unsigned)y);
    return wx != wy ? wx - wy : x - y;
}

int main(int argc, char **argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: best_all N TARGET [DEPTH]\n");
        return 2;
    }
    n = atoi(argv[1]);
    target = atoi(argv[2]);
    int stop = argc > 3 ? atoi(argv[3]) : 5;
    size = 1 << n;
    /* the all-white stack scores nothing; the all-black stack, with the
       choice 0, is placed first: it is in A from the start */
    state start;
    memset(&start, 0, sizeof start);
    nord = 0;
    for (int t = 1; t < size - 1; t++) order[nord++] = t;
    qsort(order, (size_t)nord, sizeof(int), by_weight);
    for (int i = 0; i < nord; i++)
        for (int p = 0; p < n; p++) start.open[p] += order[i] >> p & 1;
    /* the all-black stack b, choice 0: the pair (b, b), and for a stack w
       choosing p: hits with b when w is black at 0 (b is black at p) */
    start.inside = 1;
    for (int i = 0; i < nord; i++)
        if (order[i] & 1)
            for (int p = 0; p < n; p++) start.back[order[i]][p] = 2;
    if (stop > nord) stop = nord;
    collect(&start, 0, stop);
    uint64_t nodes = 0, found = 0;
    #pragma omp parallel for schedule(dynamic, 1) reduction(+ : nodes, found)
    for (int i = 0; i < ntasks; i++) {
        state s = tasks[i];
        s.nodes = 0;
        s.found = 0;
        search(&s, stop);
        nodes += s.nodes;
        found += s.found;
    }
    fprintf(stderr, "%d hats, target %d: %llu strategies, %llu nodes, %d tasks\n", n, target,
            (unsigned long long)found, (unsigned long long)nodes, ntasks);
    return 0;
}
