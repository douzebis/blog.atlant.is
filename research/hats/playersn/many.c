/*
 * SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
 *
 * SPDX-License-Identifier: MIT
 */

/* The game of hats with N players: symmetric tables on T hats.

   usage: many score N T < TABLE
          many climb N T SECONDS SEED OUT [START [HOT COLD]]

   N players (3 to 12), each with a stack of T hats (a number below 2^T,
   the bottom hat is the units digit, black is 1).  Each sees the stacks
   of the others and points at a position of their own; they win when all
   the hats pointed at are black.  All the players use one table, which
   gives a position for each multiset of N - 1 stacks seen.

   A table is written as a line "N T" and a line of digits: the position
   for each multiset, the multisets a_1 <= ... <= a_(N-1) being taken in
   the order of the numbers sum_i C(a_i + i - 1, i).

   score: the wins, out of 2^(N T), counted over the multisets of N
   stacks with the number of ways to deal each, and the limit of the win
   rates when the table is reset by itself again and again in the way of
   Buhler et al. (formal/hats/Hats/PlayersLimit.lean, tendsto_rateN):
   (W - 1) / ((P - 1)^N + N (P - 1)^(N - 1) - (N + 1)) with P = 2^T.

   climb: simulated annealing from START (a file; a random table without
   it, or with "-").  A move changes one entry.  The temperature goes
   from HOT down to COLD again and again (defaults 3 and 0.15).  The best
   table is written to OUT at each improvement that has lasted a minute,
   and at the end; progress goes to the standard error output.  The
   program reads nothing else and writes nothing else. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>

#define MAXN 12
static int N, T, S, R;          /* R = N - 1 */
static long long binom[64][MAXN + 2];
static long entries;
static unsigned char *tab;
static double fact[MAXN + 1];

static unsigned long long rng_state;
static unsigned long long rnd(void) {
    rng_state ^= rng_state << 13; rng_state ^= rng_state >> 7; rng_state ^= rng_state << 17;
    return rng_state;
}
static double uniform(void) { return (rnd() >> 11) * (1.0 / 9007199254740992.0); }

/* the rank of a sorted multiset a[0] <= ... <= a[r-1] */
static long rank(const int *a, int r) {
    long x = 0;
    for (int i = 0; i < r; i++) x += (long)binom[a[i] + i][i + 1];
    return x;
}

/* does the placement c[0] <= ... <= c[N-1] win? */
static int win(const int *c) {
    int others[MAXN];
    for (int i = 0; i < N; i++) {
        if (i > 0 && c[i] == c[i - 1]) continue; /* same stack, same answer */
        int k = 0;
        for (int j = 0; j < N; j++) if (j != i) others[k++] = c[j];
        if (!((c[i] >> tab[rank(others, R)]) & 1)) return 0;
    }
    return 1;
}

/* the number of ways to deal the multiset c to N players */
static double ways(const int *c) {
    double w = fact[N];
    int run = 1;
    for (int i = 1; i <= N; i++) {
        if (i < N && c[i] == c[i - 1]) run++;
        else { w /= fact[run]; run = 1; }
    }
    return w;
}

static double count_from(int *c, int depth, int from) {
    if (depth == N) return win(c) ? ways(c) : 0.0;
    double total = 0;
    for (int v = from; v < S; v++) { c[depth] = v; total += count_from(c, depth + 1, v); }
    return total;
}
static double count(void) { int c[MAXN]; return count_from(c, 0, 0); }

/* the wins that depend on the entry of the multiset k (sorted, R stacks) */
static double around(const int *k) {
    int c[MAXN] = {0};
    double total = 0;
    for (int x = 0; x < S; x++) {
        int i = 0, j = 0, placed = 0;
        while (j < N) {
            if (!placed && (i == R || x <= k[i])) { c[j++] = x; placed = 1; }
            else c[j++] = k[i++];
        }
        if (win(c)) total += ways(c);
    }
    return total;
}

static void unrank_random(int *k) {
    for (int i = 0; i < R; i++) k[i] = (int)(rnd() % S);
    for (int i = 1; i < R; i++) {           /* insertion sort */
        int v = k[i], j = i - 1;
        while (j >= 0 && k[j] > v) { k[j + 1] = k[j]; j--; }
        k[j + 1] = v;
    }
}

static int read_table(FILE *f) {
    int n, t;
    if (fscanf(f, "%d %d", &n, &t) != 2 || n != N || t != T) return 0;
    for (long i = 0; i < entries; i++) {
        int ch;
        do ch = fgetc(f); while (ch == '\n' || ch == ' ' || ch == '\r');
        if (ch < '0' || ch >= '0' + T) return 0;
        tab[i] = (unsigned char)(ch - '0');
    }
    return 1;
}

static void save(const char *path, const unsigned char *t) {
    char tmp[4096];
    snprintf(tmp, sizeof tmp, "%s.tmp", path);
    FILE *f = fopen(tmp, "w");
    if (!f) { perror(tmp); exit(1); }
    fprintf(f, "%d %d\n", N, T);
    for (long i = 0; i < entries; i++) fputc('0' + t[i], f);
    fputc('\n', f);
    fclose(f);
    rename(tmp, path);
}

int main(int argc, char **argv) {
    if (argc < 4) { fprintf(stderr, "usage: many score|climb N T ...\n"); return 1; }
    N = atoi(argv[2]); T = atoi(argv[3]);
    if (N < 3 || N > MAXN || T < 1 || T > 5) return 1;
    S = 1 << T; R = N - 1;
    for (int n = 0; n < 64; n++)
        for (int k = 0; k <= MAXN + 1; k++)
            binom[n][k] = k == 0 ? 1 : (n == 0 ? 0 : binom[n - 1][k - 1] + binom[n - 1][k]);
    fact[0] = 1;
    for (int i = 1; i <= MAXN; i++) fact[i] = fact[i - 1] * i;
    entries = (long)binom[S + R - 1][R];
    tab = malloc((size_t)entries);
    double all = pow(2.0, (double)N * T);
    double P1 = S - 1;
    double denom = pow(P1, N) + N * pow(P1, N - 1) - (N + 1);
    if (!strcmp(argv[1], "score")) {
        if (!read_table(stdin)) { fprintf(stderr, "not a table for %d players on %d hats\n", N, T); return 1; }
        double w = count();
        printf("%.0f wins out of %.0f; limit of the resets: %.0f/%.0f = %.6f\n",
               w, all, w - 1, denom, (w - 1) / denom);
        return 0;
    }
    if (strcmp(argv[1], "climb") || argc < 7) return 1;
    double seconds = atof(argv[4]);
    rng_state = 0x9E3779B97F4A7C15ULL ^ (unsigned long long)atoll(argv[5]) * 0xD1B54A32D192ED03ULL;
    const char *out_path = argv[6];
    double hot = argc > 9 ? atof(argv[8]) : 3.0, cold = argc > 9 ? atof(argv[9]) : 0.15;
    if (argc > 7 && strcmp(argv[7], "-")) {
        FILE *f = fopen(argv[7], "r");
        if (!f || !read_table(f)) { fprintf(stderr, "START is not a table\n"); return 1; }
        fclose(f);
    } else {
        for (long i = 0; i < entries; i++) tab[i] = (unsigned char)(rnd() % T);
    }
    double current = count(), best = current;
    unsigned char *best_tab = malloc((size_t)entries);
    memcpy(best_tab, tab, (size_t)entries);
    fprintf(stderr, "%ld entries; start: %.0f wins\n", entries, current);
    time_t begin = time(NULL), saved = begin;
    int dirty = 1;
    const unsigned long long cycle = 2000000ULL;
    for (unsigned long long step = 0;; step++) {
        if ((step & 1023) == 0) {
            time_t now = time(NULL);
            if (dirty && now - saved >= 60) { save(out_path, best_tab); saved = now; dirty = 0; }
            if (difftime(now, begin) >= seconds) break;
        }
        double phase = (double)(step % cycle) / (double)cycle;
        double temperature = hot * pow(cold / hot, phase);
        int k[MAXN];
        unrank_random(k);
        long idx = rank(k, R);
        int old = tab[idx], new_ = (old + 1 + (int)(rnd() % (T - 1))) % T;
        double before = around(k);
        tab[idx] = (unsigned char)new_;
        double delta = around(k) - before;
        /* a move is judged by wins per way to deal, so that the scale of
           the temperature does not depend on N */
        if (delta >= 0 || uniform() < exp(delta / (temperature * fact[N] / 24.0))) {
            current += delta;
            if (current > best) {
                best = current;
                memcpy(best_tab, tab, (size_t)entries);
                dirty = 1;
                fprintf(stderr, "%6.0fs step %llu: %.0f wins, limit %.6f\n",
                        difftime(time(NULL), begin), step, best, (best - 1) / denom);
            }
        } else {
            tab[idx] = (unsigned char)old;
        }
    }
    memcpy(tab, best_tab, (size_t)entries);
    double recount = count();
    fprintf(stderr, "best: %.0f wins out of %.0f (recount %.0f); limit %.6f\n",
            best, all, recount, (recount - 1) / denom);
    save(out_path, best_tab);
    return recount == best ? 0 : 2;
}
