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
   (300,000 steps on six and seven hats, 100,000 on eight, from the
   variants with the other double shift too) find no gain either; on
   eight hats they go as far as 21 choices from the start. Strategies
   with the same hits are many: on eight hats, 14.9 million differ from
   the Carter strategy in exactly 6 choices.
2. **Can two players with different strategies do better?** Open in
   general. Five hats: one solver run in `levine-hats` says no,
   unconfirmed.
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
5. **Are all optimal strategies composed?** The search finds 2, 4 and 102
   optimal crushed strategies on 2, 3 and 4 hats. Is each obtained from
   one-hat strategies by resets and shifts, up to the symmetries
   (permuting the positions, changing the choices that do not matter)? Is
   there a pattern in 2, 4, 102?
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
