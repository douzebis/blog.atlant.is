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
   `u`. First result (`research/hats/generalized_resets.py`, every scheme
   tried): for `m` = 1, 2, 3 the best win rates are 1/3, 1/3 and 7/20, and
   for `m` = 3 only `Z` = {all white, all black} reaches 7/20, with 6
   block strategies (the Carter strategy on three hats and its images
   under the permutations of the positions). Open: `m` = 4 and 5; schemes
   with several continuations (a different strategy after each kind of
   skipped block); blocks of unequal sizes.
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
