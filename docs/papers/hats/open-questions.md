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
   Cuts (2026-11-27, `research/hats/cuts.py`; a program). The *cut* of
   a strategy to `k` hats points where the strategy points when the `k`
   lowest hats seen are enough to know it, and at the bottom hat
   otherwise. The cut of the Carter strategy on `n` hats to `k` hats is
   the Carter strategy on `k` hats (`n` up to 7). On four hats, the 6
   built classes have a member whose cuts are best strategies on 1, 2
   and 3 hats, and the 4 classes that are not built have none (their
   cuts to 3 hats have at most 20 hits). So on four hats "built" and
   "best at every number of hats below" pick the same classes. Among the
   strategies equivalent to a Carter strategy, those whose cuts are all
   best are 2, 2 and 4 for 3, 4 and 5 hats: one for each choice between
   the two double shifts.

   Five hats (2026-11-27, `research/hats/best-search/best_all.c`, a
   search that lists every crushed strategy with a given number of hits,
   and `research/hats/best_classes5.py`): 1,014 crushed strategies with
   358 hits and none with 359 (a third program for the best score on
   five hats, 53 seconds); 27 classes, 15 up to the colors; 9 classes
   are built and they are the 9 hereditary ones; the 18 others are
   primitive, with cuts of 22 hits on three hats and 88 on four. So
   "built" and "hereditary" agree on four and on five hats. The numbers
   of best crushed strategies are 2, 4, 102, 1,014 and of classes 2, 1,
   10, 27. Open: a proof; what the primitive classes are; six hats.

   The primitive classes on four hats are near the built ones
   (2026-11-27, computed in a scratch script, not kept): each of the 4
   primitive classes has a strategy that differs from a built best
   strategy in 2 or 3 choices. The 240 best strategies on four hats
   (the two free choices aside) fall into 6 groups of 40 when
   strategies that differ in at most 2 choices are joined; the 6 groups
   are images of one another under the renamings, and each holds 4
   strategies of every one of the 10 classes (24 built, 16 primitive).
   With changes of one choice only there are 72 groups of 4 or fewer.
   So, up to renaming, the best strategies on four hats form one
   plateau, in which built and primitive strategies are neighbors; a
   primitive strategy is a built one moved along the plateau, as the
   walks around the Carter strategies on 6 to 8 hats suggested.

   On five hats the picture is sharper (2026-11-27, scratch script). The
   3,240 best strategies (the two free choices aside) make 360 groups
   of exactly 9 when strategies that differ in one choice are joined,
   and changes of two choices join nothing more. In a group, two stacks
   have a choice among three positions each, independently (for the
   Carter strategy: the stacks 2 and 27, positions 0, 3 or 4), and all
   the rest is fixed. A group holds 9 classes: 120 groups hold the 9
   built classes, and 240 hold 9 primitive classes, of two kinds. So,
   up to the renamings and to these choices that do not change the
   hits, **there are exactly three best strategies on five hats: the
   Carter strategy and two primitive ones.** The 9 built classes are the
   Carter strategy with its two loose choices varied.

   **A new operation** (2026-11-27, `twisted_double_shift` in
   `research/hats/check_article.py`). The two primitive strategies on
   five hats are dual to each other, and one of them is `C_3` with two
   hats added by an operation that is not the double shift: play `s` on
   the `n` lowest hats, except that `n` black hats with a white hat just
   above send to the top hat `n + 1`, and `n` hats of one color with a
   black hat just above and a white hat at the top send to `n`. It has
   `16 h + 6` hits for all proper `s` on one and two hats and for random
   ones on three and four; for none of the 16 strategies on two hats is
   it equivalent to the double shift. So up to renamings, colors and
   loose choices there are two best strategies on five hats: `C_3` with
   the double shift, and `C_3` with this one. The formula is proved in
   Lean (`hits_tds` in `formal/hats/Hats/TwistedShift.lean`, the same
   day).

   **Substitution** (2026-11-27, `substitute` in `check_article.py`).
   Every strategy `m` on `k + 1` hats is an operation that adds `k`
   hats: put `s` in the place of the bottom hat of `m` (when the `n`
   lowest hats are of one color, ask `m`; otherwise play `s`). For all
   pairs tried (`k`, `n` from 1 to 3) the hits are
   `4^k h(s) + h(m) - 4^k`. Shifts, the double shift, the twisted one
   and the three resets are all substitutions (checked as equalities of
   words). So the best operations that add `k` hats are exactly the
   best strategies on `k + 1` hats, and the bound of Proposition 13 is
   always reached. Proved on 2026-11-28: Theorem 6 of the article, and
   `hits_sub` in `formal/hats/Hats/Substitute.lean`; `tds_eq_sub` in
   `Hats/Instances.lean` shows the twisted double shift is one. The shifts, the double shift and the three resets are
   substitutions too, proved in Lean the same day (`ls_eq_sub` ...
   `dr_eq_sub`). Open: whether
   every best strategy on `n` hats is, up to renaming and colors, a
   substitution of best strategies on fewer hats. First test
   (scratch, 2026-11-27; a class counts when some renaming of it is a
   substitution of a strategy on at least two hats): on four hats, the
   6 built classes are and the 4 primitive ones are not; on five hats,
   15 of the 27 classes are (the 9 built and 6 others), 12 are not.
   The 12 are loose-choice variants of substitutions, so the exact
   statement on five hats is "a substitution up to the loose choices".
   The 4 primitive classes on four hats remain unexplained.

   **The primitive strategy on four hats, and six hats** (2026-11-28,
   `research/hats/symmetric-search/`). The 4 primitive classes are one
   strategy up to the colors and two loose choices, with a rule by
   pairs of hats and the symmetry `(01)(23)`. Searches among symmetric
   strategies on six hats stay below the Carter score (1,430 at best).
   Plain annealing on six hats: 1,971 different strategies with 1,433
   hits in 2,392 restarts, none with 1,434, and every one is a
   substitution of a strategy on three hats into one on four, as it
   stands or after loose choices. No primitive strategy seen on six
   hats. Open:
   whether there are more operations of this kind (three hats added,
   gain 25; the 4 primitive classes on four hats are not explained by
   this one).
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

   Our own check (2026-11-27, `research/hats/hint-search/hint4.c`, a
   search over all the partitions of the 30 labels with the bound by
   frames and the symmetries; a computation, not a proof checked by
   machine): the game of dimension 3 has the maximum 81/224, reached by
   3,920 partitions, as the paper says; and for dimension 4,
   `V <= 173/480 = 0.36042` (75 seconds) and
   `V <= 172/480 = 43/120 = 0.35833` (2 minutes; 495 million nodes,
   47,764 complete partitions scored, none above). And the exact value:
   **`V <= 171/480 = 57/160 = 0.35625`** (183 minutes on 6 threads,
   8.8e10 nodes, 38,779,772 complete partitions scored exactly, none
   above 171/16). The partitions that reach 171/16 make 11 orbits under
   the symmetries, 250,880 partitions in all, with 5 or 6 blocks: the
   same numbers as in the repository above, which this program was
   written without reading. Logs:
   `research/hats/hint-search/results/`. With the inequality above,
   this is also a second proof by computation that 358 is the best
   score on five hats, for two different strategies too.

   **Are the best sortings games on five hats?** (2026-11-28,
   `research/hats/hint_frames.py`.) Not all. Of the 11 orbits of best
   sortings in dimension 4, seven are games on five hats: some five
   independent points hold a best answer of Alice for every stack of
   Bob. The six of them with five blocks, read as one strategy for both
   players, are best strategies on five hats: three orbits around the
   Carter class, three around the twisted double shift. The four other
   orbits (three with five blocks, one with six) are not: Alice needs
   points that are not independent (four points of a plane), so her
   hats are not fair independent coins. They reach the same value
   171/480. So `H_4` equals the Carter number, but no translation of
   each best sorting into a pair of strategies can prove
   `H_d <= ` (game on `d + 1` hats) in general: a proof must bound the
   value, not transform the solutions.

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

## What is within reach (stock taken on 2026-11-27)

Listed with what each would cost, as far as we can tell, and whether
anyone claims it. "New" means: not found in Buhler et al., Bouquet et
al. or the note of yangsong97, which have not all been read in full.

Two players, results:

1. **The best score on six hats** (is it 1,433?). Open, claimed by
   nobody. Two routes: the direct search of `levine-hats` (estimated
   there at 1,000 to 5,000 core-hours), or the exact value of the hint
   game of dimension 5, `H_5 = 1401/3968`, which gives 1,433 by
   Proposition 17. The note stops at `H_5 <= 17/48`, which gives 1,437.
2. **An independent check of `V <= 17/48`.** Claimed by the note, not
   reviewed. With our search: a list of the sortings of dimension 4
   above 170/16 (700 to 1,000 core-hours after the speed-up of
   2026-11-27), then a second stage that is not written.
3. **All the best strategies on five hats, in classes.** New. A solver
   can list the strategies with 358 hits; then `best_classes.py` and
   `cuts.py` apply. It tests on five hats what holds on four: hereditary
   classes are the built ones.
4. **Why the hint value is the Carter number** (Question J). New. A
   proof for all `d` would prove the conjecture; a proof that the points
   beyond the `d + 1` of Proposition 17 are useless, or that Bob needs
   no more than `d + 1` hats, would already be a result.
5. **Hereditary implies built** (Question K), as a theorem. New.
6. **The four primitive classes on four hats**: a description, an
   operation that builds them, whether they have relatives on five hats.
7. **General resets on blocks of six hats.** New; the counting bound
   leaves the schemes that skip fewer than 28 stacks.
8. **Certificates**: the best score on five hats, or `H_4 = 57/160`, as
   a statement that Lean checks from a certificate produced by a
   program (Question I).

Two players, in Lean, small: the cut of the Carter strategy is the
Carter strategy; the rule in words of the Carter strategies; the win
rate formula of a scheme (Proposition 14); Propositions 12, 13 and 15.

Three players (spec 0008): beat 0.279124, the best win rate known; a
rule in words for a strategy near it; a family in the number of hats
with a formula; resets with proved formulas. All new if obtained. Known
so far: 9,116 of 32,768 on five hats by annealing (the table of 2014
has 9,120); the Carter choices of the two stacks seen, added modulo 3,
give 8,704, and a table of 15 entries on them 8,903.

Not within reach by these means: a proof of `V = 7/20`.

## Three players (2026-11-28)

A new lower bound, `V_3 >= 73223/261950 = 0.279530`, above the
`9119/32670 = 0.279124` of Buhler et al.: see
`docs/papers/hats/three-players.md`. The reset and the substitution for
three players have exact formulas, proved in Lean.
