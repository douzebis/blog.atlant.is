/*
 * SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
 *
 * SPDX-License-Identifier: MIT
 */

/*
 * Generalized resets on blocks of m hats: a direct search.
 *
 * usage: reset_search M Z [SLACK [DEPTH]]
 * build: gcc -O3 -mpopcnt -fopenmp -o reset_search reset_search.c
 *        (OMP_NUM_THREADS sets the number of threads)
 *
 * Question 4 of docs/papers/hats/open-questions.md.  A scheme gives every
 * stack of m hats either a position to point at or the order to skip the
 * block; Z is the number of skipped stacks.  Its win rate is
 * (A + c) / (4^m - Z^2).
 *
 * Call a pair of stacks that point "broken" when one of the two players
 * points at a black hat and the other does not.  Then
 *
 *     A + c = 2^(m-1) (2^m - Z) - (number of broken pairs),
 *
 * so the scheme beats 7/20 exactly when its broken pairs are at most
 *
 *     budget = 2^(m-1) (2^m - Z) - (7 (4^m - Z^2) / 20 + 1),
 *
 * the division rounded down.  The search decides the stacks one after the
 * other and gives up a branch when the broken pairs exceed the budget.  It
 * also counts, for each stack still to decide, the pairs it would break at
 * least with the stacks that point already; the stacks that must still
 * point cost at least the sum of the smallest of these counts.
 *
 * Stack number t (t < m - 1) does not point above position t: permuting
 * the positions gives such a scheme (exists_crushed in
 * formal/hats/Hats/Crush.lean).
 *
 * SLACK is added to the budget: with the right value the search must find
 * the known schemes, which is a check.  The stacks are first decided down
 * to DEPTH (default 6) and what remains is searched in parallel.
 *
 * Output: the number of nodes, and "none" or the schemes found, one per
 * line: the choice of each stack from 0 on, a position or "-" for a skip.
 */

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXM 5
#define MAXN 32

static int m, n, z, k, budget;
static uint32_t black_at[MAXM]; /* the stacks that are black at a position */
static int order[MAXN];         /* the order in which stacks are decided */
static int top[MAXN];           /* stack t points below position top[t] */

typedef struct {
    uint32_t out;           /* the stacks that point */
    uint32_t points[MAXM];  /* the stacks that point at each position */
    int nout;               /* how many stacks point */
    int broken;             /* broken pairs so far */
    int depth;              /* stacks decided */
} state;

/* The pairs that stack v breaks with the stacks that point, if it points at q. */
static inline int cost(const state *s, uint32_t seen_black, int q) {
    return __builtin_popcount((s->out & black_at[q]) ^ seen_black);
}

/* The stacks that point at a black hat of v. */
static inline uint32_t seen(const state *s, int v) {
    uint32_t y = 0;
    for (int q = 0; q < m; q++)
        if (v >> q & 1) y |= s->points[q];
    return y;
}

/* A lower bound on the pairs that the stacks still to decide will break. */
static int bound(const state *s) {
    int need = k - s->nout;
    if (need <= 0) return 0;
    int hist[MAXN + 1] = {0};
    for (int i = s->depth; i < n; i++) {
        int v = order[i];
        uint32_t y = seen(s, v);
        int best = MAXN;
        for (int q = 0; q < top[v]; q++) {
            int c = cost(s, y, q);
            if (c < best) best = c;
        }
        hist[best]++;
    }
    int total = 0;
    for (int c = 0; need > 0; c++) {
        int take = hist[c] < need ? hist[c] : need;
        total += take * c;
        need -= take;
    }
    return total;
}

static void print_scheme(const state *s) {
    char line[2 * MAXN + 2];
    int len = 0;
    for (int t = 0; t < n; t++) {
        char ch = '-';
        for (int q = 0; q < m; q++)
            if (s->points[q] >> t & 1) ch = (char)('0' + q);
        line[len++] = ch;
        line[len++] = ' ';
    }
    line[len] = 0;
    #pragma omp critical
    printf("scheme: %s(broken pairs: %d)\n", line, s->broken);
}

/* Searches below s; stops at depth `until` and stores the states there. */
static uint64_t go(state *s, int until, state *store, size_t *stored, uint64_t *found) {
    uint64_t nodes = 1;
    if (s->depth == n) {
        (*found)++;
        print_scheme(s);
        return nodes;
    }
    if (s->broken + bound(s) > budget) return nodes;
    if (s->depth == until) {
        store[(*stored)++] = *s;
        return nodes;
    }
    int u = order[s->depth];
    int need = k - s->nout;
    s->depth++;
    if (n - (s->depth - 1) > need) /* u is skipped */
        nodes += go(s, until, store, stored, found);
    if (need > 0) {
        uint32_t y = seen(s, u);
        for (int p = 0; p < top[u]; p++) {
            int c = cost(s, y, p);
            if (s->broken + c > budget) continue;
            s->points[p] |= 1u << u;
            s->out |= 1u << u;
            s->nout++;
            s->broken += c;
            nodes += go(s, until, store, stored, found);
            s->broken -= c;
            s->nout--;
            s->out &= ~(1u << u);
            s->points[p] &= ~(1u << u);
        }
    }
    s->depth--;
    return nodes;
}

static int popcount_key(int t) {
    int d = 2 * __builtin_popcount((unsigned)t) - m;
    return d < 0 ? -d : d;
}

int main(int argc, char **argv) {
    if (argc < 3) {
        fprintf(stderr, "usage: reset_search M Z [SLACK [DEPTH]]\n");
        return 2;
    }
    m = atoi(argv[1]);
    z = atoi(argv[2]);
    int slack = argc > 3 ? atoi(argv[3]) : 0;
    int depth = argc > 4 ? atoi(argv[4]) : 6;
    if (m < 1 || m > MAXM || z < 0 || z > (1 << m)) {
        fprintf(stderr, "M from 1 to %d, Z from 0 to 2^M\n", MAXM);
        return 2;
    }
    n = 1 << m;
    k = n - z;
    budget = (n / 2) * k - (7 * (n * n - z * z) / 20 + 1) + slack;
    if (depth > n) depth = n;
    for (int q = 0; q < m; q++)
        for (int t = 0; t < n; t++)
            if (t >> q & 1) black_at[q] |= 1u << t;
    for (int t = 0; t < n; t++) top[t] = t < m - 1 ? t + 1 : m;
    /* the stacks with the most hats of one color first */
    int count = 0;
    for (int key = m; key >= 0; key--)
        for (int t = 0; t < n; t++)
            if (popcount_key(t) == key) order[count++] = t;

    size_t room = 1;
    for (int i = 0; i < depth; i++) room *= (size_t)(m + 1);
    state *store = malloc(room * sizeof *store);
    if (!store) return 1;
    size_t stored = 0;
    uint64_t found = 0;
    state start;
    memset(&start, 0, sizeof start);
    uint64_t nodes = go(&start, depth, store, &stored, &found);

    #pragma omp parallel for schedule(dynamic, 1) reduction(+ : nodes, found)
    for (size_t i = 0; i < stored; i++) {
        state s = store[i];
        size_t unused = 0;
        nodes += go(&s, -1, NULL, &unused, &found) - 1;
    }
    free(store);
    printf("m=%d z=%d budget=%d nodes=%llu -> %s\n", m, z, budget,
           (unsigned long long)nodes, found ? "found" : "none");
    return 0;
}
