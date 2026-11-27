/*
 * SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
 *
 * SPDX-License-Identifier: MIT
 */

/*
 * The value of the affine hint game of dimension 4: an upper bound on V.
 *
 * usage: hint4 [NUM DEN [CHECKPOINT]]     the default is 171 16
 *        hint4 --selftest
 *        hint4 --orbits < LOG     sorts the partitions that a run printed
 *                                 ("equal ... blocks: ...") into orbits
 *                                 under the symmetries
 *
 * With a file CHECKPOINT, each finished part of the search is written to
 * it as it ends, and a run that finds the file goes on from there: the
 * parts already written are not done again.
 *
 * To estimate the cost of a search without doing it: with the environment
 * variable HINT4_SAMPLE=K, one task in K is done, nothing is claimed, and
 * the partitions found are counted but not printed.
 *
 * The game (Buhler et al., arXiv 1407.4711, Section 3, with the 16 x 30
 * matrix).  The labels are the 30 non-constant affine functions
 * (a, b): x -> a.x + b on 4 bits (a = 1..15, b = 0, 1).  Bob sorts the
 * labels into blocks.  Each block is kept or not by the toss of a fair
 * coin.  Alice, who sees which blocks are kept, picks a point x; the
 * score is the number of kept labels with value 1 at x.  E(P) is the
 * expected score for the partition P.  Every P gives E(P) / 30 as the win
 * rate of a game that the players of the game of hats could only lose
 * by ignoring a hint, so V <= max over P of E(P) / 30.
 *
 * This program proves a statement "E(P) <= NUM / DEN for every partition
 * P", by a search over the partitions, and reports the partitions that
 * reach NUM / DEN if there are some.  With 171 / 16 this is
 * V <= 171 / 480 = 57 / 160.
 *
 * The bound that makes the search possible ("frames").  A frame is one of
 * the 15 subspaces W of dimension 3 of the vectors a.  The labels with a
 * in W, 14 of them, make the game of dimension 3, whose score only
 * depends on the point x through 3 bits.  Each a is in 7 frames, and a
 * maximum of a sum is at most the sum of the maxima, so
 *
 *     E(P)  <=  (1/7)  sum over the 15 frames W of  E3(P restricted to W).
 *
 * (The constant parts agree: 15 * 7/2 / 7 = 15/2.)  E3 is known for
 * every partition of 14 labels: the program computes the table of all
 * 190,899,322 of them first.  The labels are taken in the order of a,
 * then b; the labels of a frame, in that order, are those of the game of
 * dimension 3 in its own order (a subspace in reduced echelon form is
 * numbered in increasing order).  So when the first j labels are placed,
 * each frame knows the blocks of its first labels, and the table gives
 * the best E3 over all the ways to go on.  The search drops a partial
 * partition as soon as the sum of these 15 bests is at most 7 NUM / DEN.
 *
 * Symmetries.  The affine maps of the 4 bits (322,560) and the exchange
 * of b = 0 and b = 1 permute the labels and keep E.  When the first j
 * labels are those of a = 1..j/2 and a symmetry maps this set of labels
 * to itself, a partial partition whose image comes earlier in the order
 * of the search is dropped.  Beyond the first 14 labels (those of the
 * frame a = 1..7), the symmetries that keep the partition of these 14
 * labels as it is are used at every second label: the image of the
 * partial partition is compared with it label by label, as far as the
 * image is known, and the partial partition is dropped if the image comes
 * earlier.  Among these symmetries are the 16 that do not move any of the
 * first 14 labels.
 *
 * Complete partitions that survive are scored exactly, over all the
 * subsets of their blocks.
 *
 * Checks (--selftest): the game of dimension 3 has the maximum 81/16
 * (that is 81/224 per label, the bound of the paper) reached by 3,920
 * partitions, as the paper says; the inequality above on random
 * partitions; E of a partition and of its images under random symmetries.
 */

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

/* ---- the game of dimension 3: all partitions of 14 labels ---- */

#define L3 14
static uint32_t *base3[L3];     /* first child of a node, level by level */
static uint8_t *blocks3[L3];    /* number of blocks of a node */
static uint32_t *best3[L3 + 1]; /* best 2^14 E3 below a node; level 14: 2^14 E3 */
static uint64_t count3[L3 + 1]; /* nodes at each level (Bell numbers) */

static int parity(unsigned v) { return __builtin_popcount(v) & 1; }

/* the labels of dimension d in order: index 2 (a - 1) + b */
static int covers(int a, int b, int x) { return parity(a & x) ^ b; }

/* 2^14 E3 of a partition of the 14 labels given by its block numbers */
static uint32_t score3(const uint8_t *block, int nblocks) {
    uint64_t vec[L3]; /* per block: for each of the 8 points, a byte count */
    memset(vec, 0, sizeof vec);
    for (int l = 0; l < L3; l++) {
        int a = l / 2 + 1, b = l & 1;
        for (int x = 0; x < 8; x++)
            if (covers(a, b, x)) vec[block[l]] += (uint64_t)1 << (8 * x);
    }
    uint64_t sum = 0, total = 0;
    for (uint32_t g = 0;; g++) { /* Gray code over the subsets of blocks */
        unsigned best = 0;
        for (int x = 0; x < 8; x++) {
            unsigned c = (sum >> (8 * x)) & 255;
            if (c > best) best = c;
        }
        total += best;
        if (g + 1 == (uint32_t)1 << nblocks) break;
        int bit = __builtin_ctz(g + 1);
        uint32_t gray = (g + 1) ^ ((g + 1) >> 1);
        if (gray >> bit & 1) sum += vec[bit]; else sum -= vec[bit];
    }
    return (uint32_t)(total << (L3 - nblocks));
}

static void build_table3(void) {
    /* the numbers of nodes: count3[t] = Bell(t); nodes of a level are in
       the order of the search, the children of a node are contiguous */
    blocks3[0] = malloc(1);
    blocks3[0][0] = 0;
    count3[0] = 1;
    for (int t = 0; t < L3; t++) {
        base3[t] = malloc(count3[t] * sizeof(uint32_t));
        uint64_t next = 0;
        for (uint64_t i = 0; i < count3[t]; i++) {
            base3[t][i] = (uint32_t)next;
            next += blocks3[t][i] + 1;
        }
        count3[t + 1] = next;
        if (t + 1 < L3) {
            blocks3[t + 1] = malloc(next);
            for (uint64_t i = 0; i < count3[t]; i++)
                for (int c = 0; c <= blocks3[t][i]; c++)
                    blocks3[t + 1][base3[t][i] + c] =
                        (uint8_t)(blocks3[t][i] + (c == blocks3[t][i]));
        }
    }
    for (int t = 0; t <= L3; t++) best3[t] = malloc(count3[t] * sizeof(uint32_t));

    /* the leaves, in parallel over the nodes of level 9 */
    int top = 9;
    #pragma omp parallel for schedule(dynamic, 16)
    for (uint64_t root = 0; root < count3[top]; root++) {
        /* rebuild the partition of the node `root` of level `top` */
        uint8_t block[L3];
        uint64_t node = root;
        for (int t = top; t > 0; t--) {
            /* the parent is the last node of level t - 1 with base <= node */
            uint64_t lo = 0, hi = count3[t - 1] - 1;
            while (lo < hi) {
                uint64_t mid = (lo + hi + 1) / 2;
                if (base3[t - 1][mid] <= node) lo = mid; else hi = mid - 1;
            }
            block[t - 1] = (uint8_t)(node - base3[t - 1][lo]);
            node = lo;
        }
        /* walk the subtree */
        uint64_t idx[L3 + 1];
        int nb[L3 + 1];
        idx[top] = root;
        nb[top] = blocks3[top][root];
        int t = top;
        int choice[L3 + 1];
        choice[top] = 0;
        for (;;) {
            if (t == L3) {
                best3[L3][idx[t]] = score3(block, nb[t]);
                t--;
                if (t < top) break;
                choice[t]++;
                continue;
            }
            if (choice[t] > nb[t]) {
                t--;
                if (t < top) break;
                choice[t]++;
                continue;
            }
            block[t] = (uint8_t)choice[t];
            idx[t + 1] = base3[t][idx[t]] + choice[t];
            nb[t + 1] = nb[t] + (choice[t] == nb[t]);
            t++;
            choice[t] = 0;
        }
    }
    for (int t = L3 - 1; t >= 0; t--) {
        #pragma omp parallel for schedule(static)
        for (uint64_t i = 0; i < count3[t]; i++) {
            uint32_t best = 0;
            for (int c = 0; c <= blocks3[t][i]; c++) {
                uint32_t v = best3[t + 1][base3[t][i] + c];
                if (v > best) best = v;
            }
            best3[t][i] = best;
        }
    }
}

/* ---- dimension 4 ---- */

#define L4 30
static int frame_of[L4][7];   /* the 7 frames of each label */
static int nframes_of[L4];

/* 2^K E of a complete partition with K blocks */
static uint64_t score4(const uint8_t *block, int nblocks) {
    uint64_t lo[L4], hi[L4];
    memset(lo, 0, sizeof lo);
    memset(hi, 0, sizeof hi);
    for (int l = 0; l < L4; l++) {
        int a = l / 2 + 1, b = l & 1;
        for (int x = 0; x < 16; x++)
            if (covers(a, b, x)) {
                if (x < 8) lo[block[l]] += (uint64_t)1 << (8 * x);
                else hi[block[l]] += (uint64_t)1 << (8 * (x - 8));
            }
    }
    uint64_t slo = 0, shi = 0, total = 0;
    for (uint64_t g = 0;; g++) {
        unsigned best = 0;
        for (int x = 0; x < 8; x++) {
            unsigned c = (slo >> (8 * x)) & 255, d = (shi >> (8 * x)) & 255;
            if (c > best) best = c;
            if (d > best) best = d;
        }
        total += best;
        if (g + 1 == (uint64_t)1 << nblocks) break;
        int bit = __builtin_ctzll(g + 1);
        uint64_t gray = (g + 1) ^ ((g + 1) >> 1);
        if (gray >> bit & 1) { slo += lo[bit]; shi += hi[bit]; }
        else { slo -= lo[bit]; shi -= hi[bit]; }
    }
    return total;
}

/* the symmetries, as permutations of the 30 labels */
static uint8_t (*sym)[L4];
static int nsym;
static uint8_t (*stab[L4 + 1])[L4]; /* those that keep the first j labels */
static int nstab[L4 + 1];

static void build_symmetries(void) {
    sym = malloc((size_t)645120 * L4);
    nsym = 0;
    for (int m = 0; m < 65536; m++) {
        int img[4] = {m & 15, m >> 4 & 15, m >> 8 & 15, m >> 12 & 15};
        int image[16], seen = 0, ok = 1;
        for (int a = 0; a < 16; a++) {
            int v = 0;
            for (int i = 0; i < 4; i++)
                if (a >> i & 1) v ^= img[i];
            image[a] = v;
            if (seen >> v & 1) ok = 0;
            seen |= 1 << v;
        }
        if (!ok) continue; /* not invertible */
        for (int c = 0; c < 16; c++)
            for (int flip = 0; flip < 2; flip++) {
                for (int l = 0; l < L4; l++) {
                    int a = l / 2 + 1, b = l & 1;
                    sym[nsym][l] =
                        (uint8_t)(2 * (image[a] - 1) + (b ^ parity(a & c) ^ flip));
                }
                nsym++;
            }
    }
    for (int j = 2; j <= L4; j += 2) {
        int n = 0;
        for (int pass = 0; pass < 2; pass++) {
            n = 0;
            for (int s = 0; s < nsym; s++) {
                int keep = 1;
                for (int l = 0; l < j; l++)
                    if (sym[s][l] >= j) { keep = 0; break; }
                if (!keep) continue;
                if (pass) memcpy(stab[j][n], sym[s], L4);
                n++;
            }
            if (!pass) stab[j] = malloc((size_t)n * L4);
        }
        nstab[j] = n;
    }
}

/* the symmetries that keep the first 14 labels as a set, inverted:
   inv14[s][l] is the label that the symmetry stab[14][s] sends to l */
static uint8_t (*inv14)[L4];

static void build_inverses(void) {
    inv14 = malloc((size_t)nstab[14] * L4);
    for (int s = 0; s < nstab[14]; s++)
        for (int l = 0; l < L4; l++) inv14[s][stab[14][s][l]] = (uint8_t)l;
}

/* The symmetries of stab[14] that keep the partition of the first 14
   labels: their numbers, into `list`; returns how many. */
static int automorphisms(const uint8_t *block, int *list) {
    int n = 0;
    for (int s = 0; s < nstab[14]; s++) {
        const uint8_t *g = stab[14][s];
        uint8_t image[14], rename[L4 + 1];
        for (int l = 0; l < 14; l++) image[g[l]] = block[l];
        memset(rename, 255, sizeof rename);
        int next = 0, same = 1;
        for (int l = 0; l < 14 && same; l++) {
            if (rename[image[l]] == 255) rename[image[l]] = (uint8_t)next++;
            same = rename[image[l]] == block[l];
        }
        if (same) list[n++] = s;
    }
    return n;
}

/* With the first j labels placed (j > 14): does some symmetry of `list`
   send the partial partition to one that comes earlier?  The image is
   followed label by label from label 14 on, as long as it is known. */
static int image_is_earlier(const uint8_t *block, int j, int nblocks14, const int *list,
                            int n) {
    for (int k = 0; k < n; k++) {
        const uint8_t *inv = inv14[list[k]];
        uint8_t rename[L4 + 1];
        /* the blocks of the first 14 labels keep their numbers */
        memset(rename, 255, sizeof rename);
        for (int l = 0; l < 14; l++) rename[block[inv[l]]] = block[l];
        int next = nblocks14;
        for (int l = 14; l < j; l++) {
            int from = inv[l];
            if (from >= j) break; /* the image is not known there */
            if (rename[block[from]] == 255) rename[block[from]] = (uint8_t)next++;
            int v = rename[block[from]];
            if (v < block[l]) return 1;
            if (v > block[l]) break;
        }
    }
    return 0;
}

/* is the partial partition (first j labels) the first of its images? */
static int is_first(const uint8_t *block, int j) {
    for (int s = 0; s < nstab[j]; s++) {
        const uint8_t *g = stab[j][s];
        uint8_t image[L4], rename[L4 + 1];
        for (int l = 0; l < j; l++) image[g[l]] = block[l];
        memset(rename, 255, sizeof rename);
        int next = 0;
        for (int l = 0; l < j; l++) {
            if (rename[image[l]] == 255) rename[image[l]] = (uint8_t)next++;
            int v = rename[image[l]];
            if (v < block[l]) return 0;
            if (v > block[l]) break;
        }
    }
    return 1;
}

static void build_frames(void) {
    for (int h = 1; h < 16; h++) /* the frame of the a with a.h = 0 */
        for (int a = 1; a < 16; a++)
            if (!parity(a & h))
                for (int b = 0; b < 2; b++) {
                    int l = 2 * (a - 1) + b;
                    frame_of[l][nframes_of[l]++] = h - 1;
                }
}

/* the state of the search */
typedef struct {
    uint8_t block[L4];
    int nblocks;
    int level[15];       /* labels of the frame placed so far */
    uint32_t node[15];   /* its node in the table */
    int8_t local[15][L4 + 1]; /* block of the partition -> block in the frame */
    uint64_t bound;      /* sum over the frames of best3 */
} state;

static uint64_t threshold;            /* drop when bound <= threshold */
static uint64_t target_num, target_den;
static uint64_t nodes_at[L4 + 1]; /* while the tasks are collected */

/* what one task of the search counts */
typedef struct {
    uint64_t nodes, leaves, equal, above;
} counts;
static int lex_depth = 14;
static int sample; /* do one task in `sample`, to estimate (0: all) */

static void init_state(state *s) {
    memset(s, 0, sizeof *s);
    memset(s->local, -1, sizeof s->local);
    s->bound = 15 * (uint64_t)best3[0][0];
}

/* place label j in block c; returns 0 if the bound drops the node */
static void place(state *s, int j, int c) {
    s->block[j] = (uint8_t)c;
    if (c == s->nblocks) s->nblocks++;
    for (int k = 0; k < nframes_of[j]; k++) {
        int w = frame_of[j][k];
        int t = s->level[w];
        int lc = s->local[w][c];
        if (lc < 0) {
            lc = blocks3[t][s->node[w]];
            s->local[w][c] = (int8_t)lc;
        }
        s->bound -= best3[t][s->node[w]];
        s->node[w] = base3[t][s->node[w]] + (uint32_t)lc;
        s->level[w] = t + 1;
        s->bound += best3[t + 1][s->node[w]];
    }
}

static void report_leaf(const state *s, counts *n) {
    uint64_t total = score4(s->block, s->nblocks); /* 2^K E */
    /* compare total / 2^K with num / den */
    __uint128_t left = (__uint128_t)total * target_den;
    __uint128_t right = (__uint128_t)target_num << s->nblocks;
    n->leaves++;
    n->equal += left == right;
    n->above += left > right;
    if (left >= right && !sample) {
        #pragma omp critical
        {
            printf("%s %llu/2^%d blocks:", left > right ? "ABOVE" : "equal",
                   (unsigned long long)total, s->nblocks);
            for (int l = 0; l < L4; l++) printf(" %d", s->block[l]);
            printf("\n");
        }
    }
}

static int auto_step = 2; /* the automorphisms are used every `auto_step` labels */

typedef struct {
    const int *list; /* the automorphisms of the first 14 labels */
    int n;
    int nblocks14;
} autos;

static void search(state *s, int j, counts *n, const autos *au) {
    n->nodes++;
    if (j == L4) {
        report_leaf(s, n);
        return;
    }
    for (int c = 0; c <= s->nblocks; c++) {
        /* save what `place` changes */
        int nblocks = s->nblocks;
        uint64_t bound = s->bound;
        int level[7];
        uint32_t node[7];
        int8_t local[7];
        for (int k = 0; k < nframes_of[j]; k++) {
            int w = frame_of[j][k];
            level[k] = s->level[w];
            node[k] = s->node[w];
            local[k] = s->local[w][c];
        }
        place(s, j, c);
        if (s->bound > threshold &&
            (((j + 1) & 1) || j + 1 > lex_depth || is_first(s->block, j + 1)) &&
            !(auto_step && (j + 1) % auto_step == 0 &&
              image_is_earlier(s->block, j + 1, au->nblocks14, au->list, au->n)))
            search(s, j + 1, n, au);
        s->nblocks = nblocks;
        s->bound = bound;
        for (int k = 0; k < nframes_of[j]; k++) {
            int w = frame_of[j][k];
            s->level[w] = level[k];
            s->node[w] = node[k];
            s->local[w][c] = local[k];
        }
    }
}

/* the partial partitions at depth `depth` that survive, as tasks */
static uint8_t (*tasks)[L4];
static int ntasks, captasks;

static void collect(state *s, int j, int depth) {
    nodes_at[j]++;
    if (j == depth) {
        if (ntasks == captasks) {
            captasks = captasks ? 2 * captasks : 1024;
            tasks = realloc(tasks, (size_t)captasks * L4);
        }
        memcpy(tasks[ntasks++], s->block, L4);
        return;
    }
    for (int c = 0; c <= s->nblocks; c++) {
        state copy = *s;
        place(&copy, j, c);
        if (copy.bound > threshold &&
            (((j + 1) & 1) || j + 1 > lex_depth || is_first(copy.block, j + 1)))
            collect(&copy, j + 1, depth);
    }
}

static uint64_t rng_state = 88172645463325252ULL;
static uint32_t rng(void) {
    rng_state ^= rng_state << 13;
    rng_state ^= rng_state >> 7;
    rng_state ^= rng_state << 17;
    return (uint32_t)(rng_state >> 16);
}

static int selftest(void) {
    int failures = 0;
    /* dimension 3: the maximum and the number of partitions that reach it */
    uint32_t top = best3[0][0];
    uint64_t reach = 0;
    for (uint64_t i = 0; i < count3[L3]; i++) reach += best3[L3][i] == top;
    printf("dimension 3: %llu partitions, maximum %u/16384 = %g, reached by %llu\n",
           (unsigned long long)count3[L3], top, top / 16384.0, (unsigned long long)reach);
    failures += top != 81 * 1024 || reach != 3920 || count3[L3] != 190899322;
    /* the frame inequality and the symmetries, on random partitions */
    int bad_frame = 0, bad_sym = 0, bad_table = 0;
    for (int trial = 0; trial < 3000; trial++) {
        /* at most 10 blocks, so that the direct counts stay short */
        state s;
        init_state(&s);
        int maxblocks = 2 + rng() % 9;
        for (int j = 0; j < L4; j++) {
            int c = rng() % (s.nblocks + 1);
            if (c >= maxblocks) c = rng() % maxblocks;
            place(&s, j, c);
        }
        uint64_t total = score4(s.block, s.nblocks);
        /* each frame: the table against a direct count over the 16 points */
        for (int h = 1; h < 16; h++) {
            uint8_t renumber[L4 + 1];
            int members[L3], nb = 0, n = 0;
            memset(renumber, 255, sizeof renumber);
            for (int l = 0; l < L4; l++)
                if (!parity((l / 2 + 1) & h)) {
                    if (renumber[s.block[l]] == 255) renumber[s.block[l]] = (uint8_t)nb++;
                    members[n++] = l;
                }
            uint64_t direct = 0;
            for (int subset = 0; subset < 1 << nb; subset++) {
                int best = 0;
                for (int x = 0; x < 16; x++) {
                    int count = 0;
                    for (int i = 0; i < n; i++) {
                        int l = members[i];
                        if ((subset >> renumber[s.block[l]] & 1) && covers(l / 2 + 1, l & 1, x))
                            count++;
                    }
                    if (count > best) best = count;
                }
                direct += (uint64_t)best;
            }
            if (direct << (L3 - nb) != best3[L3][s.node[h - 1]]) bad_table++;
        }
        /* E <= (1/7) sum of the frames: total / 2^K <= bound / (7 * 2^14) */
        if ((__uint128_t)total * 7 * 16384 > ((__uint128_t)s.bound << s.nblocks)) bad_frame++;
        const uint8_t *g = sym[rng() % nsym];
        uint8_t image[L4];
        for (int l = 0; l < L4; l++) image[g[l]] = s.block[l];
        if (score4(image, s.nblocks) != total) bad_sym++;
    }
    printf("frame inequality: %d failures; symmetries: %d; frames against a direct count: %d "
           "(3000 partitions)\n",
           bad_frame, bad_sym, bad_table);
    printf("symmetries: %d; keeping the first 2, 4, ..., 14 labels:", nsym);
    for (int j = 2; j <= 14; j += 2) printf(" %d", nstab[j]);
    printf("\n");
    failures += bad_frame + bad_sym + bad_table + (nsym != 645120);
    printf(failures ? "selftest: FAILED\n" : "selftest: ok\n");
    return failures != 0;
}

/* The partitions printed by a run, up to the symmetries: the number of
   orbits, and of partitions in them. */
static int orbits(void) {
    static char line[1024];
    uint8_t (*canon)[L4] = NULL;
    uint64_t *size = NULL;
    int *nb = NULL;
    int norbits = 0, read = 0;
    while (fgets(line, sizeof line, stdin)) {
        char *p = strstr(line, "blocks:");
        if (!p) continue;
        uint8_t block[L4], best[L4];
        p += 7;
        int ok = 1, nblocks = 0;
        for (int l = 0; l < L4; l++) {
            char *end;
            long v = strtol(p, &end, 10);
            if (end == p) { ok = 0; break; }
            block[l] = (uint8_t)v;
            if (v + 1 > nblocks) nblocks = (int)v + 1;
            p = end;
        }
        if (!ok) continue;
        read++;
        memset(best, 255, sizeof best);
        uint64_t fixed = 0; /* the symmetries that keep the partition */
        for (int s = 0; s < nsym; s++) {
            uint8_t image[L4], rename[L4 + 1], rgs[L4];
            for (int l = 0; l < L4; l++) image[sym[s][l]] = block[l];
            memset(rename, 255, sizeof rename);
            int next = 0;
            for (int l = 0; l < L4; l++) {
                if (rename[image[l]] == 255) rename[image[l]] = (uint8_t)next++;
                rgs[l] = rename[image[l]];
            }
            int cmp = memcmp(rgs, best, L4);
            if (cmp < 0) memcpy(best, rgs, L4);
            /* is the image the partition itself? (block is already numbered
               in the order of the labels) */
            fixed += memcmp(rgs, block, L4) == 0;
        }
        int found = -1;
        for (int o = 0; o < norbits; o++)
            if (!memcmp(canon[o], best, L4)) found = o;
        if (found < 0) {
            canon = realloc(canon, (size_t)(norbits + 1) * L4);
            size = realloc(size, (size_t)(norbits + 1) * sizeof *size);
            nb = realloc(nb, (size_t)(norbits + 1) * sizeof *nb);
            memcpy(canon[norbits], best, L4);
            size[norbits] = (uint64_t)nsym / fixed;
            nb[norbits] = nblocks;
            norbits++;
        }
    }
    uint64_t total = 0;
    for (int o = 0; o < norbits; o++) {
        total += size[o];
        printf("orbit of %llu partitions, %d blocks:", (unsigned long long)size[o], nb[o]);
        for (int l = 0; l < L4; l++) printf(" %d", canon[o][l]);
        printf("\n");
    }
    printf("%d partitions read, %d orbits, %llu partitions in all\n", read, norbits,
           (unsigned long long)total);
    return 0;
}

int main(int argc, char **argv) {
    setvbuf(stdout, NULL, _IOLBF, 0);
    build_frames();
    build_symmetries();
    build_inverses();
    if (argc > 1 && !strcmp(argv[1], "--orbits")) return orbits();
    build_table3();
    if (argc > 1 && !strcmp(argv[1], "--selftest")) return selftest();
    target_num = argc > 2 ? strtoull(argv[1], NULL, 10) : 171;
    target_den = argc > 2 ? strtoull(argv[2], NULL, 10) : 16;
    /* bound in units of 2^-14 per frame: drop when bound / 7 <= num / den */
    threshold = 7 * 16384 * target_num / target_den;
    printf("target %llu/%llu; a partial partition is dropped when its frames sum to at most %llu/16384\n",
           (unsigned long long)target_num, (unsigned long long)target_den,
           (unsigned long long)threshold);
    state s;
    init_state(&s);
    int depth = 14;
    collect(&s, 0, depth);
    printf("%d partial partitions of the first %d labels survive\n", ntasks, depth);
    /* the tasks already done, from the checkpoint */
    const char *checkpoint = argc > 3 ? argv[3] : NULL;
    counts *done = calloc((size_t)ntasks, sizeof(counts));
    char *is_done = calloc((size_t)ntasks, 1);
    int ndone = 0;
    FILE *out = NULL;
    if (checkpoint) {
        FILE *in = fopen(checkpoint, "r");
        if (in) {
            unsigned long long num, den, total, i, a, b, c, d;
            if (fscanf(in, "target %llu %llu tasks %llu", &num, &den, &total) != 3 ||
                num != target_num || den != target_den || total != (unsigned long long)ntasks) {
                fprintf(stderr, "the checkpoint is for another search\n");
                return 2;
            }
            while (fscanf(in, " task %llu %llu %llu %llu %llu", &i, &a, &b, &c, &d) == 5)
                if (i < (unsigned long long)ntasks && !is_done[i]) {
                    is_done[i] = 1;
                    done[i] = (counts){a, b, c, d};
                    ndone++;
                }
            fclose(in);
            out = fopen(checkpoint, "a");
        } else {
            out = fopen(checkpoint, "w");
            fprintf(out, "target %llu %llu tasks %d\n", (unsigned long long)target_num,
                    (unsigned long long)target_den, ntasks);
        }
        printf("checkpoint %s: %d tasks already done\n", checkpoint, ndone);
    }
    if (getenv("HINT4_SAMPLE")) sample = atoi(getenv("HINT4_SAMPLE"));
    if (getenv("HINT4_LEX")) lex_depth = atoi(getenv("HINT4_LEX"));
    if (getenv("HINT4_AUTO")) auto_step = atoi(getenv("HINT4_AUTO"));
    printf("symmetries are used while the first %d labels are placed; those that keep the "
           "first 16, 18, ..., 30 labels:", lex_depth);
    for (int j = 16; j <= L4; j += 2) printf(" %d", nstab[j]);
    printf("\n");
    time_t begin = time(NULL);
    int finished = ndone;
    #pragma omp parallel for schedule(dynamic, 1)
    for (int i = 0; i < ntasks; i++) {
        if (is_done[i] || (sample && i % sample)) continue;
        state t;
        init_state(&t);
        for (int j = 0; j < depth; j++) place(&t, j, tasks[i][j]);
        counts n = {0, 0, 0, 0};
        int *list = malloc((size_t)nstab[14] * sizeof(int));
        autos au = {list, automorphisms(tasks[i], list), t.nblocks};
        search(&t, depth, &n, &au);
        free(list);
        #pragma omp critical
        {
            done[i] = n;
            finished++;
            if (out) {
                fprintf(out, "task %d %llu %llu %llu %llu\n", i, (unsigned long long)n.nodes,
                        (unsigned long long)n.leaves, (unsigned long long)n.equal,
                        (unsigned long long)n.above);
                fflush(out);
            }
            if (finished % 500 == 0)
                fprintf(stderr, "%d of %d tasks done, %ld s\n", finished, ntasks,
                        (long)(time(NULL) - begin));
        }
    }
    if (out) fclose(out);
    counts all = {0, 0, 0, 0};
    for (int i = 0; i < ntasks; i++) {
        all.nodes += done[i].nodes;
        all.leaves += done[i].leaves;
        all.equal += done[i].equal;
        all.above += done[i].above;
    }
    printf("nodes while the first %d labels were placed:", depth);
    for (int j = 0; j <= depth; j++) printf(" %llu", (unsigned long long)nodes_at[j]);
    printf("\nnodes after that: %llu\n", (unsigned long long)all.nodes);
    printf("complete partitions scored: %llu; equal to the target: %llu; above: %llu\n",
           (unsigned long long)all.leaves, (unsigned long long)all.equal,
           (unsigned long long)all.above);
    if (sample)
        printf("one task in %d was done, in %ld s: nothing is proved\n", sample,
               (long)(time(NULL) - begin));
    else if (all.above == 0)
        printf("PROVED: E(P) <= %llu/%llu for every partition, so V <= %llu/%llu\n",
               (unsigned long long)target_num, (unsigned long long)target_den,
               (unsigned long long)target_num, (unsigned long long)(30 * target_den));
    return all.above != 0;
}
