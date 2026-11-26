/*
 * SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
 *
 * SPDX-License-Identifier: MIT
 */

/*
 * The game of hats: is there a better strategy near a Carter strategy?
 *
 * usage: hats_local N [RADIUS [STEPS [SEED [VARIANT [DAMAGE]]]]]
 * build: gcc -O3 -mpopcnt -fopenmp -o hats_local hats_local.c
 *        (OMP_NUM_THREADS sets the number of threads)
 *
 * The Carter strategy on N hats has 7 * 4^N / 20 hits, rounded down, and
 * the rounding loses less than one hit.  So a strategy on N hats with one
 * more hit would win more than 7 times in 20, on N hats and on infinite
 * stacks.  This program looks for one near the Carter strategy, in two
 * ways.
 *
 * 1. Everything within RADIUS changes.  A change gives one stack another
 *    position to point at.  The program tries every way of making 1, 2,
 *    ..., RADIUS changes at once, and reports whether one gains and how
 *    many keep the hits.  It leaves out the all-white and the all-black
 *    stack, whose choices do not matter, and the sets of changes that
 *    must lose hits: `gain[t][p]` being what one change gains alone, k
 *    changes gain their sum plus at most 4 for each pair of them.
 *
 * 2. A walk of STEPS steps among the strategies with the same hits: each
 *    step makes one change that keeps the hits, chosen at random (SEED).
 *    At each strategy on the way, the program tries every single change
 *    and every pair of changes.  It stops if one gains.
 *
 * VARIANT chooses the starting point among the Carter strategies: the
 * strategy on N hats is the one-hat strategy double-shifted (N - 1) / 2
 * times, then shifted once if N is even; bit i of VARIANT asks for the
 * sibling double shift at step i (white shift first, see spec 0005).
 * DAMAGE spoils that many choices of the starting point first, at random:
 * the search must then find a gain, which is a check of the program.
 *
 * The hits are those of two players who use the same strategy.
 */

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXN 8
#define MAXR 16             /* changes at once */
#define MAXS 256            /* stacks */
#define WORDS (MAXS / 64)

typedef struct { uint64_t w[WORDS]; } set;

static int n, N, words;
static set black_at[MAXN];  /* the stacks that are black at a position */

typedef struct {
    uint8_t s[MAXS];        /* the position each stack points at */
    set points[MAXN];       /* the stacks that point at each position */
} strategy;

static inline int has(const set *a, int t) { return a->w[t >> 6] >> (t & 63) & 1; }
static inline void put(set *a, int t) { a->w[t >> 6] |= 1ull << (t & 63); }
static inline void drop(set *a, int t) { a->w[t >> 6] &= ~(1ull << (t & 63)); }

static void index_points(strategy *g) {
    memset(g->points, 0, sizeof g->points);
    for (int t = 0; t < N; t++) put(&g->points[g->s[t]], t);
}

/* The other stacks that point at a black hat of t. */
static inline set seen(const strategy *g, int t) {
    set y;
    memset(&y, 0, sizeof y);
    for (int q = 0; q < n; q++)
        if (t >> q & 1)
            for (int i = 0; i < words; i++) y.w[i] |= g->points[q].w[i];
    drop(&y, t);
    return y;
}

/* The hits of the pairs that involve t, if t points at p. */
static inline int pairs_of(const set *y, int t, int p) {
    int c = 0;
    for (int i = 0; i < words; i++) c += __builtin_popcountll(black_at[p].w[i] & y->w[i]);
    return 2 * c + (t >> p & 1);
}

/* The hits, counted pair by pair: a check of the rest. */
static long hits_slow(const strategy *g) {
    long h = 0;
    for (int t = 0; t < N; t++)
        for (int u = 0; u < N; u++)
            h += (t >> g->s[u] & 1) & (u >> g->s[t] & 1);
    return h;
}

/* gain[t][p]: what the hits gain if t alone changes to p. */
static void gains(const strategy *g, int gain[MAXS][MAXN]) {
    for (int t = 0; t < N; t++) {
        set y = seen(g, t);
        int now = pairs_of(&y, t, g->s[t]);
        for (int p = 0; p < n; p++) gain[t][p] = pairs_of(&y, t, p) - now;
    }
}

static void move(strategy *g, int t, int p) {
    drop(&g->points[g->s[t]], t);
    g->s[t] = (uint8_t)p;
    put(&g->points[p], t);
}

/* What two changes gain together, beyond the sum of what each gains alone. */
static inline int together(const strategy *g, int t, int p, int u, int q) {
    int a = g->s[t], b = g->s[u];
    int e = ((u >> p & 1) & (t >> q & 1)) - ((u >> p & 1) & (t >> b & 1))
          - ((u >> a & 1) & (t >> q & 1)) + ((u >> a & 1) & (t >> b & 1));
    return 2 * e;
}

static void print_strategy(const strategy *g) {
    for (int t = 0; t < N; t++) {
        if (t && t % 8 == 0) putchar(t % 64 == 0 ? '\n' : ' ');
        putchar('0' + g->s[t]);
    }
    putchar('\n');
}

/* ---- the Carter strategies ---- */

static void white_shift(strategy *g, int m) { /* from m hats to m + 1 */
    for (int t = (1 << m); t < (2 << m); t++) g->s[t] = g->s[t - (1 << m)];
    g->s[1 << m] = (uint8_t)m;
}

static void black_shift(strategy *g, int m) {
    for (int t = (1 << m); t < (2 << m); t++) g->s[t] = g->s[t - (1 << m)];
    g->s[(1 << m) - 1] = (uint8_t)m;
}

static void double_shift(strategy *g, int m, int sibling) { /* from m hats to m + 2 */
    if (!sibling) {
        black_shift(g, m);
        white_shift(g, m + 1);
        g->s[(2 << m) + (1 << m)] = (uint8_t)(m + 1);
    } else {
        white_shift(g, m);
        black_shift(g, m + 1);
        g->s[(1 << m) - 1] = (uint8_t)(m + 1);
    }
}

static void carter(strategy *g, int variant) {
    memset(g->s, 0, sizeof g->s);
    int m = 1;
    for (int i = 0; m + 2 <= n; i++, m += 2) double_shift(g, m, variant >> i & 1);
    if (m < n) black_shift(g, m);
}

/* ---- everything within a number of changes ---- */

typedef struct { int t, p, gain; } change;

typedef struct {
    long long tried[MAXR + 1], same[MAXR + 1]; /* by number of changes */
    int best[MAXR + 1];
    int found;              /* the largest gain, if positive */
    change how[MAXR];
    int how_many;
} report;

static const strategy *base;
static change *list;
static int listed, radius, most; /* most: the largest gain of one change */

static void extend(report *r, change *chosen, int k, int from, int sum) {
    if (k > 0) {
        r->tried[k]++;
        if (sum == 0) r->same[k]++;
        if (sum > r->best[k]) r->best[k] = sum;
        if (sum > r->found) {
            r->found = sum;
            r->how_many = k;
            memcpy(r->how, chosen, (size_t)k * sizeof *chosen);
        }
    }
    if (k >= radius || k >= MAXR) return;
    for (int i = from; i < listed; i++) {
        change c = list[i];
        if (k > 0 && chosen[k - 1].t == c.t) continue; /* one change per stack */
        int s = sum + c.gain;
        for (int j = 0; j < k; j++)
            s += together(base, chosen[j].t, chosen[j].p, c.t, c.p);
        /* the changes still to come gain at most `most` each, and 4 for
           each pair they form with the others */
        int left = radius - k - 1, reach = s, total = 0;
        for (int more = 1; more <= left; more++) {
            total += most + 4 * (k + more);
            if (s + total > reach) reach = s + total;
        }
        if (reach < 0) continue;
        chosen[k] = c;
        extend(r, chosen, k + 1, i + 1, s);
    }
}

static int by_stack(const void *a, const void *b) {
    const change *x = a, *y = b;
    return x->t != y->t ? x->t - y->t : x->p - y->p;
}

/* Tries every set of at most `radius` changes that can keep or gain hits.
   The counts are of the sets that are tried, not of all sets. */
static void within(const strategy *g, int rad, report *out) {
    static int gain[MAXS][MAXN];
    gains(g, gain);
    base = g;
    radius = rad;
    most = -1000000;
    for (int t = 1; t < N - 1; t++)
        for (int p = 0; p < n; p++)
            if (p != g->s[t] && gain[t][p] > most) most = gain[t][p];
    /* a set of changes that does not lose hits has no change below this:
       the others gain at most `most` each, and each pair at most 4 */
    int floor = -4 * (rad - 1) * rad / 2 - (rad - 1) * (most > 0 ? most : 0);
    list = malloc((size_t)N * (size_t)n * sizeof *list);
    listed = 0;
    for (int t = 1; t < N - 1; t++)
        for (int p = 0; p < n; p++)
            if (p != g->s[t] && gain[t][p] >= floor)
                list[listed++] = (change){t, p, gain[t][p]};
    qsort(list, (size_t)listed, sizeof *list, by_stack);
    memset(out, 0, sizeof *out);
    for (int k = 0; k <= MAXR; k++) out->best[k] = -1000000;
    #pragma omp parallel
    {
        report mine;
        memset(&mine, 0, sizeof mine);
        for (int k = 0; k <= MAXR; k++) mine.best[k] = -1000000;
        change chosen[MAXR + 1];
        #pragma omp for schedule(dynamic, 1) nowait
        for (int i = 0; i < listed; i++) {
            chosen[0] = list[i];
            extend(&mine, chosen, 1, i + 1, list[i].gain);
        }
        #pragma omp critical
        {
            for (int k = 1; k <= rad; k++) {
                out->tried[k] += mine.tried[k];
                out->same[k] += mine.same[k];
                if (mine.best[k] > out->best[k]) out->best[k] = mine.best[k];
            }
            if (mine.found > out->found) {
                out->found = mine.found;
                out->how_many = mine.how_many;
                memcpy(out->how, mine.how, sizeof mine.how);
            }
        }
    }
    free(list);
}

/* ---- a walk among the strategies with the same hits ---- */

static uint64_t rng;
static uint64_t next_random(void) {
    rng ^= rng << 13; rng ^= rng >> 7; rng ^= rng << 17;
    return rng;
}

static uint64_t fingerprint(const strategy *g) {
    uint64_t h = 1469598103934665603ull;
    for (int t = 1; t < N - 1; t++) { h ^= g->s[t]; h *= 1099511628211ull; }
    return h;
}

#define TABLE (1u << 22)
static uint64_t *table;
static int remember(uint64_t h) { /* 1 if new */
    if (h == 0) h = 1;
    for (uint32_t i = (uint32_t)(h & (TABLE - 1));; i = (i + 1) & (TABLE - 1)) {
        if (table[i] == h) return 0;
        if (table[i] == 0) { table[i] = h; return 1; }
    }
}

/* Returns 1 if a strategy with more hits is found; g is then that one. */
static int walk(strategy *g, long steps, const strategy *start) {
    static int gain[MAXS][MAXN];
    static change keeps[MAXS * MAXN], near[MAXS * MAXN];
    table = calloc(TABLE, sizeof *table);
    long distinct = 0, pairs_tried = 0;
    int farthest = 0;
    for (long step = 0; step <= steps; step++) {
        if (remember(fingerprint(g))) distinct++;
        if (distinct > TABLE / 2) { printf("walk: table full, stopping\n"); break; }
        int d = 0;
        for (int t = 1; t < N - 1; t++) d += g->s[t] != start->s[t];
        if (d > farthest) farthest = d;
        gains(g, gain);
        int kept = 0, close = 0;
        for (int t = 1; t < N - 1; t++)
            for (int p = 0; p < n; p++) {
                if (p == g->s[t]) continue;
                if (gain[t][p] > 0) {
                    printf("walk: step %ld, one change gains %d: stack %d to %d\n",
                           step, gain[t][p], t, p);
                    move(g, t, p);
                    return 1;
                }
                if (gain[t][p] == 0) keeps[kept++] = (change){t, p, 0};
                if (gain[t][p] >= -3) near[close++] = (change){t, p, gain[t][p]};
            }
        /* two changes: they gain their sum, plus at most 4 */
        for (int i = 0; i < close; i++)
            for (int j = i + 1; j < close; j++) {
                if (near[i].t == near[j].t) continue;
                pairs_tried++;
                int both = near[i].gain + near[j].gain
                         + together(g, near[i].t, near[i].p, near[j].t, near[j].p);
                if (both > 0) {
                    printf("walk: step %ld, two changes gain %d: stack %d to %d, stack %d to %d\n",
                           step, both, near[i].t, near[i].p, near[j].t, near[j].p);
                    move(g, near[i].t, near[i].p);
                    move(g, near[j].t, near[j].p);
                    return 1;
                }
            }
        if (kept == 0) { printf("walk: step %ld, no change keeps the hits\n", step); break; }
        change c = keeps[next_random() % (uint64_t)kept];
        move(g, c.t, c.p);
    }
    printf("walk: %ld steps, %ld distinct strategies, farthest %d choices from the start, "
           "%ld pairs of changes tried, no gain\n", steps, distinct, farthest, pairs_tried);
    free(table);
    return 0;
}

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: hats_local N [RADIUS [STEPS [SEED [VARIANT [DAMAGE]]]]]\n");
        return 2;
    }
    n = atoi(argv[1]);
    int rad = argc > 2 ? atoi(argv[2]) : 2;
    long steps = argc > 3 ? atol(argv[3]) : 0;
    rng = argc > 4 ? strtoull(argv[4], NULL, 10) * 2654435769ull + 88172645463325252ull : 88172645463325252ull;
    int variant = argc > 5 ? atoi(argv[5]) : 0;
    int damage = argc > 6 ? atoi(argv[6]) : 0;
    if (n < 1 || n > MAXN || rad < 0 || rad > MAXR) {
        fprintf(stderr, "N from 1 to %d, RADIUS from 0 to %d\n", MAXN, MAXR);
        return 2;
    }
    N = 1 << n;
    words = N <= 64 ? 1 : N / 64;
    for (int p = 0; p < n; p++)
        for (int t = 0; t < N; t++)
            if (t >> p & 1) put(&black_at[p], t);

    strategy g;
    carter(&g, variant);
    long target = 7 * ((long)N * N) / 20;
    index_points(&g);
    long h = hits_slow(&g);
    printf("N=%d variant=%d: the Carter strategy has %ld hits (7 * 4^N / 20 rounded down: %ld)\n",
           n, variant, h, target);
    if (h != target) { printf("ERROR: not the expected hits\n"); return 1; }
    for (int i = 0; i < damage; i++) {
        int t = 1 + (int)(next_random() % (uint64_t)(N - 2));
        move(&g, t, (g.s[t] + 1 + (int)(next_random() % (uint64_t)(n - 1))) % n);
    }
    if (damage) printf("after %d random changes: %ld hits\n", damage, hits_slow(&g));
    h = hits_slow(&g);
    strategy start = g;

    if (rad > 0) {
        report r;
        within(&g, rad, &r);
        for (int k = 1; k <= rad; k++)
            printf("%d change%s: %s, %lld keep the hits (%lld sets looked at)\n",
                   k, k > 1 ? "s" : "",
                   r.best[k] > 0 ? "SOME GAIN" : "none gains", r.same[k], r.tried[k]);
        if (r.found) {
            for (int i = 0; i < r.how_many; i++) move(&g, r.how[i].t, r.how[i].p);
            printf("FOUND: %ld hits with %d change%s\n", hits_slow(&g), r.how_many,
                   r.how_many > 1 ? "s" : "");
            print_strategy(&g);
            return 0;
        }
    }
    if (steps > 0 && walk(&g, steps, &start)) {
        printf("FOUND: %ld hits\n", hits_slow(&g));
        print_strategy(&g);
        return 0;
    }
    if (hits_slow(&g) != h) { printf("ERROR: the walk changed the hits\n"); return 1; }
    printf("nothing better than %ld hits\n", h);
    return 0;
}
