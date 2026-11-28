/*
 * SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
 *
 * SPDX-License-Identifier: MIT
 */

/* Search for two-player strategies with a prescribed symmetry.

   usage: symsearch N SECONDS SEED [CYCLES [KEEP]]

   N hats (at most 8).  CYCLES is a renaming of the positions written as
   cycles, for instance "(01)(23)(45)"; the group it generates acts on the
   stacks and on the positions.  The search only visits strategies s with
   s(g t) = g(s(t)) for every g of the group, for the stacks t that no g
   other than the identity fixes; the other stacks are free.  Simulated
   annealing with restarts; prints each new best number of hits and, at
   the end, the best strategy as a word.  With KEEP, also prints, for
   each restart that reaches KEEP hits, a line "found" with the best
   strategy of that restart.

   No input is read; the output is text on the standard output. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>

#define MAXN 8
#define MAXS (1 << MAXN)
#define MAXG 64

static int N, S;
static int G, perm[MAXG][MAXN];      /* the group */
static int act[MAXG][MAXS];          /* its action on the stacks */
static int s[MAXS], best_s[MAXS], local_s[MAXS];
static int nunits, unit_of[MAXS], rep[MAXS], rep_g[MAXS]; /* stack = act[rep_g][rep] */
static int unit_rep[MAXS], unit_size[MAXS], unit_members[MAXS][MAXG], unit_g[MAXS][MAXG];

static unsigned long long rng_state;
static unsigned long long rnd(void) {
    rng_state ^= rng_state << 13; rng_state ^= rng_state >> 7; rng_state ^= rng_state << 17;
    return rng_state;
}
static double uniform(void) { return (rnd() >> 11) * (1.0 / 9007199254740992.0); }

static int hits(const int *w) {
    int h = 0;
    for (int t = 0; t < S; t++)
        for (int u = 0; u < S; u++)
            h += ((t >> w[u]) & 1) & ((u >> w[t]) & 1);
    return h;
}

/* hits that involve stack t, counted so that summing over a set of
   changed stacks is right when handled one stack at a time */
static int row(int t) {
    int h = 0;
    for (int u = 0; u < S; u++)
        if (u != t) h += ((t >> s[u]) & 1) & ((u >> s[t]) & 1);
    return 2 * h + ((t >> s[t]) & 1);
}

static void parse(const char *text) {
    int g[MAXN];
    for (int i = 0; i < N; i++) g[i] = i;
    for (const char *p = text; *p; p++) {
        if (*p != '(') continue;
        int cyc[MAXN], k = 0;
        for (p++; *p && *p != ')'; p++)
            if (*p >= '0' && *p < '0' + N && k < MAXN) cyc[k++] = *p - '0';
        for (int i = 0; i < k; i++) g[cyc[i]] = cyc[(i + 1) % k];
        if (!*p) break;
    }
    /* powers of g */
    int cur[MAXN];
    for (int i = 0; i < N; i++) cur[i] = i;
    G = 0;
    do {
        if (G == MAXG) { fprintf(stderr, "group too large\n"); exit(1); }
        memcpy(perm[G++], cur, sizeof cur);
        int nxt[MAXN];
        for (int i = 0; i < N; i++) nxt[i] = g[cur[i]];
        memcpy(cur, nxt, sizeof cur);
        int id = 1;
        for (int i = 0; i < N; i++) if (cur[i] != i) id = 0;
        if (id) break;
    } while (1);
}

int main(int argc, char **argv) {
    if (argc < 4) { fprintf(stderr, "usage: symsearch N SECONDS SEED [CYCLES]\n"); return 1; }
    N = atoi(argv[1]);
    double seconds = atof(argv[2]);
    rng_state = 0x9E3779B97F4A7C15ULL ^ (unsigned long long)atoll(argv[3]) * 0xD1B54A32D192ED03ULL;
    if (N < 1 || N > MAXN) return 1;
    S = 1 << N;
    parse(argc > 4 ? argv[4] : "");
    int keep = argc > 5 ? atoi(argv[5]) : 0;
    for (int g = 0; g < G; g++)
        for (int t = 0; t < S; t++) {
            int u = 0;
            for (int p = 0; p < N; p++) if ((t >> p) & 1) u |= 1 << perm[g][p];
            act[g][t] = u;
        }
    /* units: full orbits where the group acts freely, single stacks elsewhere */
    for (int t = 0; t < S; t++) unit_of[t] = -1;
    for (int t = 0; t < S; t++) {
        if (unit_of[t] >= 0) continue;
        int is_free = 1;
        for (int g = 1; g < G; g++) if (act[g][t] == t) is_free = 0;
        int k = nunits++;
        unit_rep[k] = t; unit_size[k] = 0;
        if (is_free) {
            for (int g = 0; g < G; g++) {
                unit_members[k][unit_size[k]] = act[g][t];
                unit_g[k][unit_size[k]++] = g;
                unit_of[act[g][t]] = k;
            }
        } else {
            unit_members[k][0] = t; unit_g[k][0] = 0; unit_size[k] = 1; unit_of[t] = k;
        }
    }
    printf("N = %d, group of order %d, %d units\n", N, G, nunits);
    int best = -1;
    clock_t start = clock();
    long restarts = 0, reached = 0;
    while ((double)(clock() - start) / CLOCKS_PER_SEC < seconds) {
        restarts++;
        for (int k = 0; k < nunits; k++) {
            int p = rnd() % N;
            for (int i = 0; i < unit_size[k]; i++) s[unit_members[k][i]] = perm[unit_g[k][i]][p];
        }
        int h = hits(s), local = h;
        memcpy(local_s, s, sizeof s);
        double T = 3.0;
        long steps = 400000L * (N >= 6 ? 4 : 1);
        for (long step = 0; step < steps; step++, T *= 0.99999 - (N < 6) * 0.00003) {
            int k = rnd() % nunits, p = rnd() % N;
            int old = 0, new_ = 0, saved[MAXG];
            for (int i = 0; i < unit_size[k]; i++) {
                int t = unit_members[k][i];
                old += row(t); saved[i] = s[t];
            }
            /* pairs inside the unit are counted twice in the sum of rows: correct */
            for (int i = 0; i < unit_size[k]; i++)
                for (int j = 0; j < unit_size[k]; j++) if (i != j) {
                    int t = unit_members[k][i], u = unit_members[k][j];
                    old -= ((t >> s[u]) & 1) & ((u >> s[t]) & 1);
                }
            for (int i = 0; i < unit_size[k]; i++) s[unit_members[k][i]] = perm[unit_g[k][i]][p];
            for (int i = 0; i < unit_size[k]; i++) new_ += row(unit_members[k][i]);
            for (int i = 0; i < unit_size[k]; i++)
                for (int j = 0; j < unit_size[k]; j++) if (i != j) {
                    int t = unit_members[k][i], u = unit_members[k][j];
                    new_ -= ((t >> s[u]) & 1) & ((u >> s[t]) & 1);
                }
            int d = new_ - old;
            if (d >= 0 || uniform() < exp(d / T)) {
                h += d;
                if (h > local) { local = h; if (keep && h >= keep) memcpy(local_s, s, sizeof s); }
                if (h > best) {
                    best = h; memcpy(best_s, s, sizeof s);
                    printf("%8.1fs restart %ld: %d hits\n",
                           (double)(clock() - start) / CLOCKS_PER_SEC, restarts, best);
                    fflush(stdout);
                }
            } else {
                for (int i = 0; i < unit_size[k]; i++) s[unit_members[k][i]] = saved[i];
            }
        }
        if (local == best) reached++;
        if (keep && local >= keep) {
            printf("found %d ", local);
            for (int t = 0; t < S; t++) printf("%d", local_s[t]);
            printf("\n");
        }
    }
    printf("best: %d hits (recount %d), %ld restarts, %ld of them reached it\nword: ",
           best, hits(best_s), restarts, reached);
    for (int t = 0; t < S; t++) printf("%d", best_s[t]);
    printf("\n");
    return 0;
}
