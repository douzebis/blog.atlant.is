/*
 * SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
 *
 * SPDX-License-Identifier: MIT
 */

// The reluctant recitation over 2^LG moves: the numerical table of the
// paper (Section "How reluctant is Jane?") and the numbers quoted with
// Conjectures A and B and Question C.
//
// usage:  cc -O2 -o walk walk.c -lm && ./walk 27
//         (2^27 moves: about 20 s and 2 GB of memory; results/walk-27.log)
//
// Beads are handled in heap coordinates x = n + 1, where a down move is
// x -> floor(x/2) and an up move is x -> floor((3x + 1)/2).  The told
// beads are kept in an open-addressing hash table of 2^(LG+1) entries.
//
// One line is printed at each power of two t:
//   lg        log2 t
//   t         number of moves
//   F(bead)   the frontier F(t): the smallest bead not told yet
//   t/F       t / F(t)
//   Flog2t/t  F(t) log2(t + 1) / t        (Conjecture A)
//   ups/t     u(t) / t, to compare with log_3 2 = 0.630930   (Theorem 5)
//   (u-t*c)   u(t) - t log_3 2
//   lg(max)   log2 of the largest heap coordinate reached     (Conjecture B)
// and at the end the proportions p_r of down moves preceded by exactly r up
// moves (Question C).  The program stops with "HALT" if Jane is ever stuck
// (Theorem 2 says she is not) and with "overflow" beyond 2^62.

#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

static uint64_t *table;
static uint64_t mask;

static inline int has(uint64_t x) {
  uint64_t h = (x * 0x9E3779B97F4A7C15ULL) >> 20;
  for (;;) {
    uint64_t v = table[h & mask];
    if (v == x) return 1;
    if (!v) return 0;
    h++;
  }
}

static inline void add(uint64_t x) {
  uint64_t h = (x * 0x9E3779B97F4A7C15ULL) >> 20;
  for (;;) {
    if (!table[h & mask]) {
      table[h & mask] = x;
      return;
    }
    h++;
  }
}

int main(int argc, char **argv) {
  if (argc != 2) {
    fprintf(stderr, "usage: walk LG   (runs 2^LG moves)\n");
    return 2;
  }
  int lg = atoi(argv[1]);
  uint64_t moves = 1ULL << lg;
  mask = (1ULL << (lg + 1)) - 1;
  table = calloc(mask + 1, 8);
  if (!table) {
    puts("not enough memory");
    return 1;
  }
  uint64_t x = 1, front = 2, largest = 1, ups = 0, checkpoint = 1, run = 0;
  uint64_t runs[64] = {0}, downs = 0;
  add(1);
  printf("%3s %12s %12s %8s %9s %9s %10s %7s\n", "lg", "t", "F(bead)", "t/F",
         "Flog2t/t", "ups/t", "(u-t*c)", "lg(max)");
  for (uint64_t t = 1; t <= moves; t++) {
    uint64_t below = x >> 1;
    if (x > 1 && !has(below)) {
      x = below;
      downs++;
      if (run < 64) runs[run]++;
      run = 0;
    } else {
      if (x > (1ULL << 62)) {
        puts("overflow");
        return 1;
      }
      x = (3 * x + 1) >> 1;
      ups++;
      run++;
      if (has(x)) {
        printf("HALT at %llu\n", (unsigned long long)t);
        return 1;
      }
    }
    add(x);
    if (x > largest) largest = x;
    while (has(front)) front++;
    if (t == checkpoint) {
      double c = log(2) / log(3);
      printf("%3d %12llu %12llu %8.3f %9.4f %9.6f %10.1f %7.2f\n",
             (int)log2((double)t), (unsigned long long)t,
             (unsigned long long)(front - 1), (double)t / (front - 1),
             (front - 1) * log2((double)t + 1) / t, (double)ups / t,
             (double)ups - t * c, log2((double)largest));
      fflush(stdout);
      checkpoint <<= 1;
    }
  }
  printf("runs:");
  for (int i = 0; i < 40; i++)
    if (runs[i]) printf(" %d:%.5f", i, (double)runs[i] / downs);
  puts("");
  return 0;
}
