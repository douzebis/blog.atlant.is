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
   above. The double reset is `Z` = {all white, all black}. The win rate is

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

   For `m` = 5 the schemes are too many to try one by one. The question
   "does a scheme with `Z` of a given size beat 7/20?" is an integer
   program (`research/hats/reset_schemes_lp.py`, checked against the
   enumerations for `m` = 3 and 4). First run of 2026-11-24, the solver
   SCIP, 4 minutes per size: no scheme beats 7/20 for the sizes 0 and 26
   to 31; the sizes 1 to 25 are undecided (no scheme found, none ruled
   out).

   Open: `m` = 5, sizes 1 to 25 (Bouquet et al. have a scheme at 7/20 with
   `Z` = {all white, all black}) and beyond; schemes with several continuations
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
