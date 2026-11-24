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
- Optimality beyond two hats is not proved.

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
