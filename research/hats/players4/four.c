/*
 * SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
 *
 * SPDX-License-Identifier: MIT
 */

/* The game of hats with four players: symmetric tables.

   usage: four score T < TABLE
          four reset T < TABLE          the table on T + 1 hats (see below)
          four climb T SECONDS SEED OUT [START [HOT COLD]]

   Four players, each with a stack of T hats (a number below 2^T, the
   bottom hat is the units digit, black is 1).  Each sees the three other
   stacks and points at a position of their own; they win when the four
   hats pointed at are black.  The four players use one table s[u][v][w],
   which does not depend on the order of u, v, w.  A table is written as
   4^T lines of 2^T digits: line u * 2^T + v, column w.

   score: the wins, out of 16^T, by a full count.

   reset: the reset of Buhler et al. by one hat.  A player who sees a
   stack that is all white on its T lowest hats, or three stacks that are
   all black there, points at the hat T; any other player plays the table
   on the T lowest hats.

   climb: simulated annealing from START (a file; random without it, or
   with "-").  A move changes one entry and its five reorderings.  The
   temperature goes from HOT down to COLD again and again (defaults 3 and
   0.15).  The best table is written to OUT at each improvement that has
   lasted a minute, and at the end; progress goes to the standard error
   output.  The program reads nothing else and writes nothing else. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>

#define MAXT 6
static int T, S;
static unsigned char *s; /* S^3 entries */
#define AT(u, v, w) s[((u) * S + (v)) * S + (w)]

static unsigned long long rng_state;
static unsigned long long rnd(void) {
    rng_state ^= rng_state << 13; rng_state ^= rng_state >> 7; rng_state ^= rng_state << 17;
    return rng_state;
}
static double uniform(void) { return (rnd() >> 11) * (1.0 / 9007199254740992.0); }

static int win(int a, int b, int c, int d) {
    return ((a >> AT(b, c, d)) & 1) & ((b >> AT(a, c, d)) & 1)
         & ((c >> AT(a, b, d)) & 1) & ((d >> AT(a, b, c)) & 1);
}

static long long count(void) {
    long long total = 0;
    for (int a = 0; a < S; a++)
        for (int b = 0; b < S; b++)
            for (int c = 0; c < S; c++)
                for (int d = 0; d < S; d++) total += win(a, b, c, d);
    return total;
}

/* the number of orders of four stacks */
static int orders(int a, int b, int c, int d) {
    int v[4] = {a, b, c, d}, n = 24;
    for (int i = 0; i < 4; i++) {
        int first = 1, same = 0;
        for (int j = 0; j < 4; j++) {
            if (v[j] == v[i]) { if (j < i) first = 0; same++; }
        }
        if (first) for (int k = 2; k <= same; k++) n /= k;
    }
    return n;
}

/* the wins that depend on the entry {u, v, w} */
static long long around(int u, int v, int w) {
    long long total = 0;
    for (int x = 0; x < S; x++)
        if (win(x, u, v, w)) total += orders(x, u, v, w);
    return total;
}

static void set(int u, int v, int w, int p) {
    AT(u, v, w) = AT(u, w, v) = AT(v, u, w) = AT(v, w, u) = AT(w, u, v) = AT(w, v, u) =
        (unsigned char)p;
}

static int read_table(FILE *f) {
    for (long i = 0; i < (long)S * S * S; i++) {
        int ch;
        do ch = fgetc(f); while (ch == '\n' || ch == ' ' || ch == '\r');
        if (ch < '0' || ch >= '0' + T) return 0;
        s[i] = (unsigned char)(ch - '0');
    }
    return 1;
}

static void write_table(FILE *f, const unsigned char *t, int size) {
    for (long i = 0; i < (long)size * size; i++) {
        for (int w = 0; w < size; w++) fputc('0' + t[i * size + w], f);
        fputc('\n', f);
    }
}

static int symmetric(void) {
    for (int u = 0; u < S; u++)
        for (int v = 0; v < S; v++)
            for (int w = 0; w < S; w++)
                if (AT(u, v, w) != AT(v, u, w) || AT(u, v, w) != AT(u, w, v)) return 0;
    return 1;
}

static void save(const char *path, const unsigned char *t) {
    char tmp[4096];
    snprintf(tmp, sizeof tmp, "%s.tmp", path);
    FILE *f = fopen(tmp, "w");
    if (!f) { perror(tmp); exit(1); }
    write_table(f, t, S);
    fclose(f);
    rename(tmp, path);
}

int main(int argc, char **argv) {
    if (argc < 3) { fprintf(stderr, "usage: four score|reset|climb T ...\n"); return 1; }
    T = atoi(argv[2]);
    if (T < 1 || T > MAXT) return 1;
    S = 1 << T;
    s = malloc((size_t)S * S * S);
    if (!strcmp(argv[1], "score") || !strcmp(argv[1], "reset")) {
        if (!read_table(stdin)) { fprintf(stderr, "not a table on %d hats\n", T); return 1; }
        if (!symmetric()) { fprintf(stderr, "the table is not symmetric\n"); return 1; }
        if (!strcmp(argv[1], "score")) { printf("%lld\n", count()); return 0; }
        int S2 = 2 * S, black = S - 1;
        unsigned char *out = malloc((size_t)S2 * S2 * S2);
        for (int u = 0; u < S2; u++)
            for (int v = 0; v < S2; v++)
                for (int w = 0; w < S2; w++) {
                    int lu = u % S, lv = v % S, lw = w % S;
                    int up = lu == 0 || lv == 0 || lw == 0
                          || (lu == black && lv == black && lw == black);
                    out[((long)u * S2 + v) * S2 + w] = up ? (unsigned char)T : AT(lu, lv, lw);
                }
        write_table(stdout, out, S2);
        return 0;
    }
    if (strcmp(argv[1], "climb") || argc < 6) return 1;
    double seconds = atof(argv[3]);
    rng_state = 0x9E3779B97F4A7C15ULL ^ (unsigned long long)atoll(argv[4]) * 0xD1B54A32D192ED03ULL;
    const char *out_path = argv[5];
    double hot = argc > 8 ? atof(argv[7]) : 3.0, cold = argc > 8 ? atof(argv[8]) : 0.15;
    if (argc > 6 && strcmp(argv[6], "-")) {
        FILE *f = fopen(argv[6], "r");
        if (!f || !read_table(f) || !symmetric()) { fprintf(stderr, "START is not a symmetric table\n"); return 1; }
        fclose(f);
    } else {
        for (int u = 0; u < S; u++)
            for (int v = u; v < S; v++)
                for (int w = v; w < S; w++) set(u, v, w, (int)(rnd() % T));
    }
    long long current = count(), best = current;
    unsigned char *best_s = malloc((size_t)S * S * S);
    memcpy(best_s, s, (size_t)S * S * S);
    fprintf(stderr, "start: %lld wins\n", current);
    time_t begin = time(NULL), saved = begin;
    int dirty = 1;
    const unsigned long long cycle = 4000000ULL;
    for (unsigned long long step = 0;; step++) {
        if ((step & 4095) == 0) {
            time_t now = time(NULL);
            if (dirty && now - saved >= 60) { save(out_path, best_s); saved = now; dirty = 0; }
            if (difftime(now, begin) >= seconds) break;
        }
        double phase = (double)(step % cycle) / (double)cycle;
        double temperature = hot * pow(cold / hot, phase);
        int u = rnd() % S, v = rnd() % S, w = rnd() % S;
        int old = AT(u, v, w), new_ = (old + 1 + (int)(rnd() % (T - 1))) % T;
        long long before = around(u, v, w);
        set(u, v, w, new_);
        long long delta = around(u, v, w) - before;
        if (delta >= 0 || uniform() < exp((double)delta / temperature)) {
            current += delta;
            if (current > best) {
                best = current;
                memcpy(best_s, s, (size_t)S * S * S);
                dirty = 1;
                fprintf(stderr, "%6.0fs step %llu: %lld wins\n", difftime(time(NULL), begin), step, best);
            }
        } else {
            set(u, v, w, old);
        }
    }
    memcpy(s, best_s, (size_t)S * S * S);
    long long recount = count();
    fprintf(stderr, "best: %lld wins out of %lld (recount %lld)\n", best, 1LL << (4 * T), recount);
    save(out_path, best_s);
    return recount == best ? 0 : 2;
}
