<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# The game of hats: open questions

Recorded on 2026-11-24, after the import of the three articles and their
formalization in Lean (`formal/hats/`). "Known" means that the question is
in the literature; "ours" that it came up in this work and has not been
checked against the literature.

Conventions: players point at a black hat, black is the digit 1; `V_2` is
the best win rate of two players with infinite stacks.

## Known, and what this work adds

1. **Is `V_2 = 7/20`?** (Buhler et al., Conjecture 2.) It is equivalent to
   an exact statement for each height: the best score on `n` hats is
   `floor(7 * 4^n / 20)`, the score of the Carter strategy
   (`Hats.hits_carter`). Scores are integers over `4^n`, so if nothing
   beats 7/20, nothing beats the floor; and the Carter scores tend to
   7/20. Confirmed for 1 to 5 hats (1, 5, 22, 89, 358); 1433 for six hats
   is the next case.

   A search around the Carter strategies (2026-11-27,
   `research/hats/local-search/`; a program, not a proof) finds nothing
   better. No strategy that differs from the Carter strategy in at most
   `r` choices has more hits, for `r` = 8 on six hats, 7 on seven hats
   and 6 on eight hats. Walks through strategies with the same hits
   (300,000 steps on six and seven hats, 100,000 on eight) find no gain
   either; on
   eight hats they go as far as 21 choices from the start. Strategies
   with the same hits are many: on eight hats, 14.9 million differ from
   the Carter strategy in exactly 6 choices.
2. **Can two players with different strategies do better?** Open in
   general. No on 1 to 3 hats (enumeration) and on 4 hats (SCIP). Five
   hats: no, by SCIP on two models written separately (`levine-hats`,
   and `research/hats/two_strategies.py` on 2026-11-27: 358, 384 s,
   9,734 nodes); one solver only, and the question is listed as open on
   Wagon's page.
3. **Does the win rate tend to 0 with the number of players?** (Levine.)
   Our calculus has two players. Is there one, with proved formulas, for
   three?

## Ours, from the calculus of resets and shifts

4. **Which recursive schemes reach 7/20, and can one exceed it?** A scheme
   is a block strategy `a` on `m` hats and a set `Z` of stacks of `m` hats:
   outside `Z` play `a` on the lowest block, in `Z` skip it and start again
   above. The double reset is `Z` = {all white, all black}. Bouquet et al.
   call these *recursive strategies*, given by the *stopping set*, the
   complement of `Z`. The win rate is

       x = (A + c) / (4^m - |Z|^2)

   with `A` the pairs outside `Z` that `a` wins and `c` the pairs
   `(t, u)`, `t` in `Z`, `u` outside, with `t` black where `a` points for
   `u`. A scheme on `m` hats is also one on `m + 1` hats (ignore one hat),
   so the best win rate cannot decrease with `m`.

   Results of 2026-11-24, every scheme tried
   (`research/hats/generalized_resets.py` for `m` up to 3,
   `research/hats/reset-schemes/` for `m` = 4; programs, not proofs):

   | `m` | Schemes | Best win rate | Reached by |
   |---|---|---|---|
   | 1 | 3 | 1/3 | `Z` = {all white} or {all black} |
   | 2 | 80 | 1/3 | 22 schemes, `Z` of 1 or 2 stacks |
   | 3 | 65,535 | 7/20 | `Z` = {all white, all black} only, with the Carter strategy on three hats and its 5 images under the permutations of the positions |
   | 4 | 5^16, about 1.5e11 | 7/20 | one `Z` up to the permutations: the stacks whose three lowest hats are all white or all black. It is the scheme of `m` = 3 with a fourth hat that is ignored |

   For `m` = 4 the best win rates by size of `Z` are 89/256, 89/255,
   88/252, 86/247, 84/240 for sizes 0 to 4, and at most 1/3 beyond. So no
   scheme on blocks of at most four hats beats 7/20, and none reaches it
   except the double reset of the Carter strategy on three hats.

   A bound that needs no computer (2026-11-25). Among the pairs `(t, u)`
   with `u` outside `Z`, count those where `t` is black where `a` points
   for `u`: there are `2^(m-1)` of them for each `u`, and `A + c` counts a
   part of them. So `A + c <= 2^(m-1) (2^m - |Z|)`, and

       x <= 2^(m-1) / (2^m + |Z|).

   This bound is proved in Lean (`schemeScore_le` and
   `schemeScore_le_seven_twentieths` in `formal/hats/Hats/Schemes.lean`).
   A scheme with `|Z| >= (6/7) 2^(m-1)` cannot beat 7/20: on blocks of
   five hats, no scheme with 14 skipped stacks or more. What `A + c`
   misses are the pairs of stacks outside `Z` where one player points at
   a black hat and the other does not; a scheme beats 7/20 only if these
   are few, which gives a direct search for the larger `Z`.

   For `m` = 5 the schemes are too many to try one by one. **No scheme on
   blocks of five hats beats 7/20** (2026-11-25), by the size of `Z`:

   | Size of `Z` | No scheme beats 7/20, by |
   |---|---|
   | 0 to 5 | one run of the solver SCIP 10 per size on an integer program (`research/hats/reset_schemes_lp.py`); 99 s for size 0, which is the optimality of 358 hits on five hats, up to 2 h 45 for size 5 |
   | 6, 7 | one run of SCIP per set `Z`, one `Z` in each class under the permutations of the positions: 10,195 and 34,230 runs (`research/hats/reset_schemes_split.py`) |
   | 4 to 13 | a direct search that counts the pairs where one player points at a black hat and the other does not (`research/hats/reset-search/`): 57 thousand nodes for size 13, 4.6e9 for size 8, 3.3e11 for size 4 |
   | 14 to 31 | the bound above (SCIP agrees for 22 to 31) |

   The three programs are checked against the enumerations for `m` = 3
   and 4, and the sizes 4 to 7 are settled by two of them. These are
   answers of programs, not proofs.

   Open: which schemes on five hats reach 7/20 (Bouquet et al. have one
   with `Z` = {all white, all black}); `m` = 6 and beyond, where the bound
   leaves the sizes below 28; schemes with several continuations
   (a different strategy after each kind of skipped block); a proof in
   Lean of the formula and of the enumerations.
5. **Are all optimal strategies composed?** No, on four hats
   (2026-11-27, `research/hats/best_classes.py`; a program, not a
   proof). The search finds 2, 4 and 102 optimal crushed strategies on
   2, 3 and 4 hats. Up to the renamings of the positions and the two
   choices that do not matter, these are 2, 1 and 10 classes (1, 1 and 5
   when a strategy and its dual are put together). The classes that hold
   a strategy built from the one-hat strategy with the resets, the
   shifts and the double shift number 2, 1 and 6: four classes on four
   hats are not built, for instance that of `0010303022112230`. What
   remains open: what these four are (another operation?), and whether
   on every number of hats some optimal strategy is built.
6. **Why do the Reyes strategy on `3n` hats and the Carter strategy on
   `2n + 1` hats have the same win rate,** `7/20 - 1/(10 * 16^n)`? Both
   formulas are proved (`rate_reyes`, `rate_carterOdd`); no map between
   the two families is known to us.

## Ours, on the upper bound

7. **The count-matrix view.** The hits of a strategy are `trace(N^2)`,
   where `N[p][q]` counts the stacks that choose `p` and are black at `q`.
   What is the set of the matrices that a strategy realizes? Does a convex
   relaxation of it (spectral, semidefinite) give an upper bound better
   than the known 0.3616?

8a. **The hint bounds are the Carter win rates** (2026-11-27;
   `research/hats/hint_carter.py`, `research/hats/hint_games.py`). The
   upper bounds on `V` of Buhler et al. come from a hint: Alice's stack
   is one of the `2 (2^d - 1)` non-constant affine functions on `d` bits.
   Write `H_d` for the best value of that game (81/224 for `d` = 3).
   Restricting Alice to the points `0, e_1, ..., e_d` gives the game on
   `n = d + 1` hats with her stack not of a single color, so for any
   pair of strategies on `n` hats

       hits <= 2^d + 2^n (2^n - 2) H_d.

   This is a short argument, written in the header of
   `hint_carter.py`; it is not in Lean and was not found in the sources.
   With the Carter strategy on `d + 1` hats the two sides are equal for
   every `d` for which `H_d` is known or estimated: 3/8, 3/8, 81/224
   (the paper), 57/160 (claimed exact in
   `github.com/yangsong97/levine-hat-bounds`, November 2026, a
   computer-assisted note that nobody has reviewed), 1401/3968 and
   45/128 (best found there for `d` = 5, 6). In closed form, with
   `m = 2 (2^d - 1)`: `7/20 + (1/5 - c / 2^d) / m`, `c` = 1/5 for even
   `d` and 3/10 for odd `d`; about `7/20 + 1 / (10 * 2^d)`.

   What follows. (a) The affine hint of dimension `d` cannot prove a
   bound on `V` below that value, so this family of hints goes to 7/20
   no faster than `2^-d`. (b) An exact value of `H_d` is a proof that
   the Carter strategy is optimal on `d + 1` hats, also against two
   different strategies: 81/224 gives 89 on four hats, 57/160 would
   give 358 on five. (c) The same repository claims `H_5 <= 17/48`,
   hence `V <= 17/48 = 0.354167`; with the inequality above this would
   give at most 1,437 hits on six hats, against our 1,448. (d) Is `H_d`
   always that Carter value? If so `V = 7/20`. Open: an independent
   check of 57/160 and 17/48; why Alice gains nothing from the other
   points (the sums of an odd number of her `d + 1` hats), nor Bob from
   more than `d + 1` hats.

## Ours, on infinite stacks

8. **Is the best value attained, and by what kind of strategy?** If
   `V_2 = 7/20`, the Carter and the Reyes limits attain it; they are
   measurable and computed by a reader with a counter
   (`Hats/Readers.lean`). Is every optimal strategy of that kind, almost
   everywhere? Is 7/20 the best win rate of a machine that reads finitely
   many hats and stops?

## Ours, on method

9. **Can five or six hats be certified?** The solver results are
   floating-point. A bound of integer programming can be exported as an
   exact certificate (inequalities combined with rational weights) that
   Lean checks by arithmetic. For six hats this would make "1433 is
   optimal" a theorem with the standard axioms. The size of the
   certificate is the unknown.

## Smaller remarks

- The best search-free bound of Bouquet et al. for `V_{2,h}` approaches
  the rate `1/4^h`; the Carter strategies have it exactly
  (`7/20 - V_{2,h} <= 3/(5 * 4^h)`), see spec 0005, M3.
- Crushing uses part of the symmetry between positions; a canonical form
  for the whole group would cut the search on four hats by up to 9 more.
