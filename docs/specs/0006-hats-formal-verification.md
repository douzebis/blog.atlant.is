<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# 0006 — The game of hats: proofs checked by a proof assistant

**Status:** in-progress
**App:** blog.atlant.is (the hats article, spec 0005)
**Implemented in:** <!-- YYYY-MM-DD, fill after implementation -->

## Problem

The hats articles state six formulas for the win rate of a strategy built
from others (three resets, three shifts), and derive from them the win
rates of five families of strategies. Spec 0005 lists what a first reading
and a recomputation found: three formulas stated without the condition
they need (D1), a wrong stack in a proof (D7), several wrong values. The
proofs sum the entries of matrices with dotted rows; a slip there does not
show.

The author decided on 2026-11-24 that the statements of the revised
article are to be proved in Lean, as those of the rosary paper are (spec
0004), and that this starts before the article is rewritten: the proofs
by cases that the article needs (spec 0005, Section 6, point 1) and the
Lean proofs are written together.

## Goals

- The statements of the article about finite stacks are stated and proved
  in Lean 4, in `formal/hats/`, and one command checks them all.
- For each, a reader of the article can find the Lean statement and see
  that both say the same thing, without reading a proof.
- A statement that needs a condition (a proper strategy) says so in Lean,
  and Lean has an example showing that the condition cannot be dropped.
- The article says, statement by statement, what is verified.
- If the formalization finds an error, the article is corrected (it is
  being rewritten anyway) and the finding is recorded in spec 0005.

## Non-goals

- The optimality results (2 to 5 hats) and the six-hat bound of
  `levine-hats`: they are computations, a separate matter.
- The literature (what was known in 2014, the bounds of others).
- The calculator: its code is not verified. Lean recomputes examples
  independently.
- Following the article's proofs line by line (as in spec 0004: what must
  match is the statement).

## Specification

### Project

`formal/hats/`, Lean 4.34.1 with Mathlib at the revision of
`formal/jane-s-rosary-real` (sums over finite sets come from Mathlib).
Mathlib is not fetched twice: the project reads the packages of the
rosary project (`packagesDir` in `lakefile.toml`). `formal/check-hats.sh`
checks it with the rules of invariant 0004 (no `sorry`, no axiom beyond
Lean's three, an audit that prints what each theorem rests on); the
`formal-real` job of the workflow runs it after the rosary check.

### Definitions

Chosen to be read against the article, and close to the calculator:

- a stack of `n` hats is a natural number below `2 ^ n`; the hat at
  position `p` is black when the binary digit of weight `2 ^ p` is `1`
  (`hat t p`, which is `0` for a position outside the stack, negative
  ones included). Black is the color to point at (spec 0005, Section 8);
- a strategy is a function from natural numbers to integers. Lean
  functions are total: only its values below `2 ^ n` matter, which is a
  theorem (`hits_congr`), not a convention;
- `hits n s` counts the pairs of stacks on which both players point at a
  black hat. The win rate is `hits n s / 4 ^ n`; statements are about
  `hits`, in natural numbers, so that no division is involved;
- `Proper n s`: the strategy points inside the stack;
- operations are named as in the calculator (`lr`, `rr`, `dr`, `ls`, `rs`,
  `ds`) until the notation of the article is settled (spec 0005,
  Section 3); the Lean names need not follow the symbols.

### Steps

| Step | Content | Status |
|---|---|---|
| 1 | Definitions; `hits_congr`; left reset: `hits (m + n) (lr m a b) = 4 ^ n * hits m a + hits n b` for `a` proper | done 2026-11-24 |
| 2 | Right reset (both proper) and double reset (`hits + 4 ^ n = 4 ^ n * hits a + 4 * hits b`) | done 2026-11-24 |
| 3 | Two strategies that differ only at the all-white stack have the same hits; two proper strategies that differ only at the all-black stack too | done 2026-11-24 |
| 4 | Left and right shift (`4 * hits s + 1`), double shift (`16 * hits s + 6`) | done 2026-11-24 |
| 5 | The families: a constant strategy (`4 ^ (n - 1)`), lowest black and lowest white (`3 * hits + 1 = 4 ^ n`), Carter (`hits n (carter n) = 7 * 4 ^ n / 20`, spec 0005, M1), Reyes (`20 * hits + 2 * 4 ^ j = 7 * 64 ^ j` on `3 j` hats) | done 2026-11-24 |
| 6 | Embedding: a proper strategy keeps its win rate on a taller stack | done 2026-11-24 |
| 7 | Counterexamples for the conditions (spec 0005, D1), and the examples of the article computed by Lean | done 2026-11-24 (left reset, left shift, embedding; D12, D13; the tuples of the first Carter strategies) |
| 8 | Infinite stacks (post 3): the measure on stacks and on pairs; a strategy on `n` hats has the same win rate on infinite stacks; a limit of finite strategies has the limit of their win rates; `1/3` for the lowest black hat, `7/20` for the Carter and the Reyes limits | done 2026-11-24 |
| 9 | The article's table of what is verified; a guide in `formal/hats/README.md` | README done; the table waits for the article |
| 10 | The rest of post 1: associativity of the left and right resets; equivalent strategies; what the families choose (top, lowest black, lowest white); win rates as real numbers with the six formulas and the limits | done 2026-11-24 |
| 11 | Post 2: exchanging two positions keeps the hits; crushed strategies are enough (`exists_crushed`); the counts of the two searches | done 2026-11-24 |
| 12 | Optimality on one and two hats (`hits_one_le`, `hits_two_le`) | done 2026-11-24; three hats and more are searches by computer, not redone (Non-goals) |
| 13 | Remarks of post 3: cardinalities, an infinite stack as the limit of its finite parts, continuity of finite strategies, the Carter strategies on the all-white and all-black stacks | done 2026-11-24 |

| 14 | The hit sets of the three limit strategies are measurable (`measurableSet_hitSet`, `measurable_limitOf`) | done 2026-11-24 |
| 15 | The limit strategies computed by machines that read the hats one at a time (`Hats/Readers.lean`): on every stack where the strategy is defined, the reader stops with what the strategy chooses | done 2026-11-24 |
| 16 | The search of post 2 as Lean functions, with its reductions (`best`, `bestFast`), proved to return the most hits of any strategy; run by the kernel for three hats (`hits_three_le`: at most 22) | done 2026-11-24 |
| 17 | The fast search program (`HatsSearch/Program.lean`: machine words, parallel tasks, the executable `hats-search`), proved to return `best n` for `n` from 2 to 4 (`search_toNat`, `search_spec`) | done 2026-11-24 |
| 18 | Four hats: at most 89 hits (`Hats/SearchNative.lean`), by having Lean run the fast program; rests on the extra axiom `Lean.ofReduceBool` and is outside the audit | done 2026-11-24 |
| 19 | Generalized resets (`Hats/Schemes.lean`): the score of a scheme, and the bound `schemeScore_le`: at most `2 ^ (m - 1) * (2 ^ m - |Z|)`; so a scheme with `7 |Z| >= 6 * 2 ^ (m - 1)` has a score of at most 7/20 of `4 ^ m - |Z| ^ 2` | done 2026-11-26; that the win rate is the score divided by `4 ^ m - |Z| ^ 2` is not proved |
| 20 | Exchanging the colors (`Hats/Dual.lean`): the dual of a strategy; a proper strategy and its dual have the same hits (`hits_dual`); the sibling of the double shift, defined as the dual of the double shift of the dual, has `16 * hits s + 6` hits (`hits_sibling`) and is the black shift of the white shift except for the stack `2 ^ n - 1`, which points at `n + 1` (`sibling_eq`) | done 2026-11-27 |
| 21 | Equivalent strategies (`Hats/Equivalent.lean`): the resets and the shifts respect the exchange of two positions, in the lower part (`lr_swap_low`, `rr_swap_low`, `dr_swap_low`, `ls_swap`, `rs_swap`, `ds_swap`) and in the upper part of a reset (`lr_swap_high`, `rr_swap_high`, `dr_swap_high`); the second double shift is the first with its two new positions exchanged (`sibling_eq_swap`) | done 2026-11-27; stated for one exchange, every renaming being a chain of exchanges (that chain is not formalized) |
| 22 | Hints (`Hats/Hints.lean`): the winning pairs of two strategies (`hitsTwo`), the hint game of dimension `d` of Buhler et al. with its affine functions (`hintWins`), and Proposition 17 of the article: the game on `d + 1` hats is inside it (`hitsTwo_le_hintWins`), so a bound on the hint games bounds the best score (`hitsTwo_le_of_hint_le`; `hitsTwo_four_le` and `hitsTwo_five_le` for 89 and 358) | done 2026-11-27; the bounds 81/224 and 57/160 on the hint games themselves are hypotheses of these theorems: they are computations (`research/hats/hint-search/`), not Lean proofs |
| 23 | The twisted double shift (`Hats/TwistedShift.lean`): its definition `tds`, and `hits_tds`: `16 * hits s + 6` hits for a proper `s`, proved through the black reset by a strategy on two hats and one changed choice | done 2026-11-27; that it is not equivalent to the double shift is checked by program only |
| 24 | Substitution (`Hats/Substitute.lean`): `sub`, and `hits_sub`: `hits (sub n m s) + 4 ^ k = 4 ^ k * hits s + hits m` for proper `s` on `n` hats and `m` on `k + 1`; `sub_proper`. `Hats/Instances.lean`: `tds_eq_sub`, the twisted double shift is a substitution, and `hits_tds_of_sub`, its hits again | done 2026-11-28, with `ls_eq_sub`, `rs_eq_sub`, `ds_eq_sub`, `lr_eq_sub`, `rr_eq_sub`, `dr_eq_sub` and second proofs of the hits of the shifts |
| 25 | Three players (`Hats/Three.lean`, `Hats/ThreeSub.lean`): `term3`, `wins3`, `Proper3`; the reset `reset3` and `wins3_reset`: `wins3 (reset3 n S M) + 8 ^ k = 8 ^ k * wins3 S + (3 * 2 ^ n + 2) * wins3 M`; the substitution `sub3` and `wins3_sub`: `wins3 (sub3 n M S) + 8 ^ k = 8 ^ k * wins3 S + wins3 M`. The tables need not be symmetric | done 2026-11-28, with the limit of repeated resets: `tendsto_rate3` in `Hats/ThreeLimit.lean`, the win rates of a proper table on `T >= 2` hats reset by itself again and again tend to `(W - 1) / (8 ^ T - (3 * 2 ^ T + 2))` |
| 26 | Any number of players (`Hats/Players.lean`, `Hats/PlayersLimit.lean`): players indexed by a finite type with at least two elements, strategies that may differ between players and do not use the player's own stack (`Blind`); `winsN_reset`: the reset of `S` by `M` has `(2^k)^n (W_S - 1) + resetCard * W_M` wins; `resetCard_add`: `resetCard = P^n - (P-1)^n - n (P-1)^(n-1) + n + 1`; `tendsto_rateN` and `limitN_eq`: the win rates of `S` on `T >= 2` hats reset by itself tend to `(W - 1) / ((P-1)^n + n (P-1)^(n-1) - (n+1))`, the formula of Buhler et al. | done 2026-11-28 |
| 27 | Hats black with probability `p` (`Hats/Biased.lean`): `wt`, `val`; `val_lr`: a white reset adds values, `val a + (1 - p)^(2m) val b`; `val_c3`: the value of `01002120` is `3p^2 - 6p^3 + 8p^4 - 6p^5 + 2p^6`; `val_whiteChain` and `tendsto_whiteChain`: its white resets by itself have values that tend to `val c3 / (1 - (1 - p)^6)` for `0 < p <= 1`; `val_dual`: the dual of a proper strategy at `1 - p` has the value `val + 1 - 2p` | done 2026-11-28, with the gain of a substitution with a biased coin: `val_sub` in `Hats/BiasedSub.lean` (the formula of `research/hats/biased.py`) |
| 28 | Bounds checked from the table to the limit, the counts by the kernel (`decide +kernel`, no compiler trusted): `Hats/Three6.lean`, `wins3_six` (262,144 placements, 73,226 wins) and `tendsto_six`: three players, limit `73225/261950`; `Hats/Four.lean` and `Hats/Four4.lean`, `winsN_four3` (886 of 4,096), `winsN_four4` (15,192 of 65,536), `tendsto_four3`, `tendsto_four4`: four players, limits `885/3768` and `15191/64120`. `Hats/Conjecture.lean`: `conjecture_iff` (Proposition 12), `hits_sub_le` and its cases for one and two hats added (Proposition 13), `tendsto_rate_drChain` and `tendsto_rate_drChain_carterOdd` (Proposition 15) | done 2026-11-28. `Hats/TwistedNew.lean`: `tds_not_renamed_ds`, on two hats no renaming of the positions turns a double shift into the twisted one. Still owed: the rule in words of the Carter strategies, the cut of a Carter strategy, Proposition 14 |
| 29 | No loose end among the statements of the article. `Hats/CarterRule.lean`: `carterOdd_words`, `carterEven_words`, the Carter strategies are the rule in words; `Hats/CarterCut.lean`: `carter_words`, `carter_cut`, the cut of a Carter strategy is a Carter strategy; `Hats/SchemeRate.lean`: `hits_sr`, `tendsto_rate_schemeChain` (Proposition 14); `Hats/Renamed.lean`: `Renamed` (any chain of exchanges), `hits_renamed` (Proposition 2), `ls_renamed` ... `dr_renamed_high` (Proposition 7); `Hats/Loose.lean`: `rr_eq_dual_lr`, `hits_dr_nestings` (the two remarks of Section 3); `Hats/Conjecture.lean`: `tendsto_rate_drChain_carterEven`, `carterEven_limit_lt` (Proposition 15 for an even number of hats); `Hats/Gains4.lean`: `hits_sub_four_le` (Proposition 13 for three hats added; outside the audit, it trusts the compiler like `hits_four_le`) | done 2026-11-28. Not provable in Lean as things stand: Proposition 13 for four hats added (it needs the best score on five hats, known by solvers only), and the results of programs of Sections 7 and 8 |

Each step is committed when the check passes.

### What step 1 showed

- The left-reset formula holds when `a` is proper, with no condition on
  `b`: a `b` that points below its stack lands on a white hat of the part
  below, and one that points above lands outside.
- Lean confirms the counterexample of D1: `(1, 1)` on one hat, left-reset
  by `[00]`, has 4 hits out of 16 where the formula gives 1.

### What steps 2 to 4 showed

- The right reset and the double reset need both strategies proper, as
  the article of 2020 says.
- The left shift and the right shift are proved from the resets, as in
  the article: the left shift has the hits of the left reset by the
  one-hat strategy (they differ at the all-white stack only), the right
  shift those of the right reset (they differ at the all-black stack
  only).
- Lean computes that the left shift of `(1, 1)` has 4 hits where the
  formula gives 1 (the third case of D1), and that the two ways of
  double-resetting `[1010]` twice by `[00]` differ.

### What the double shift and the families showed

- The double shift is proved by changing one choice of "the left shift of
  the right shift" and counting what the pairs of that one stack gain: one
  hit. The stacks that matter are the three that the proof of 2020 should
  have named (spec 0005, D7).
- The closed form of the Carter strategies is a theorem:
  `hits n (carter n) = 7 * 4 ^ n / 20`, with the division of natural
  numbers, for every `n` from 1 on.
- The top strategy needs no reset: any strategy that always points at the
  same hat has `4 ^ (n - 1)` hits.
- "Lowest black" needs no condition; "lowest white" is built from one hat
  up, because the right reset needs proper strategies.

### What the infinite stacks showed

- The three win rates of post 3 are theorems: `rateInf lowBlackInf = 1/3`,
  `rateInf carterInf = 7/20`, `rateInf reyesInf = 7/20`.
- One argument serves the three (`rateInf_limitOf`): a strategy on
  infinite stacks that agrees with a finite strategy except on the stacks
  whose lowest hats fall in a set `A` has a win rate within
  `2 * card A / 2 ^ n` of it. This replaces the three "squeeze" sketches
  of post 3 (spec 0005, D37).
- The limit strategies are defined as limits: for each stack, what the
  first finite strategy that has settled chooses (`limitOf`), with the
  proof that all later ones choose the same (`limitOf_eq`).
- The sequences of post 3 are confirmed as spec 0005, D33, reads them:
  the Carter strategies on `2k + 1` hats, the Reyes strategies on `3j`
  hats.

### Limits of what is proved

- "Computable" is proved in this sense: each limit strategy is computed
  by a reader, a machine with a state that reads the hats from the bottom
  up and stops with an output (`Reader`), and what a reader has done after
  a list of hats is a computable function of the list, in the sense of
  recursion theory (Mathlib's `Computable`; the steps are primitive
  recursive). The three readers have finitely many kinds of states and one
  counter, like the automata drawn in post 3; the Carter reader has the
  states and the transitions of the picture.
- The readers show that post 3 is right to call them automata with a
  counter, and wrong to call them finite (spec 0005, D36).
- Optimality is proved on one, two and three hats with the three standard
  axioms, and on four hats with the compiler trusted (step 18). Five hats
  are out of reach of an enumeration.

## Invariants

`docs/invariants/0004-formal-proofs-are-complete.md` covers this project
through `formal/check-hats.sh`.

## Open questions

- Whether to also state the results with a stack type (`Fin n → Bool`)
  for readers who prefer it to numbers, as an outer layer.

## References

- `docs/specs/0005-hats-articles-revision.md`.
- `docs/specs/0004-rosary-formal-verification.md`.
- `docs/invariants/0004-formal-proofs-are-complete.md`.
