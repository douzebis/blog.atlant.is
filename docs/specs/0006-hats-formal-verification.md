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
they need (D1), a wrong tower in a proof (D7), several wrong values. The
proofs sum the entries of matrices with dotted rows; a slip there does not
show.

The author decided on 2026-11-24 that the statements of the revised
article are to be proved in Lean, as those of the rosary paper are (spec
0004), and that this starts before the article is rewritten: the proofs
by cases that the article needs (spec 0005, Section 6, point 1) and the
Lean proofs are written together.

## Goals

- The statements of the article about finite towers are stated and proved
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

- a tower of `n` hats is a natural number below `2 ^ n`; the hat at
  position `p` is white when the binary digit of weight `2 ^ p` is `1`
  (`hat t p`, which is `0` for a position outside the tower, negative
  ones included);
- a strategy is a function from natural numbers to integers. Lean
  functions are total: only its values below `2 ^ n` matter, which is a
  theorem (`hits_congr`), not a convention;
- `hits n s` counts the pairs of towers on which both players point at a
  white hat. The win rate is `hits n s / 4 ^ n`; statements are about
  `hits`, in natural numbers, so that no division is involved;
- `Proper n s`: the strategy points inside the tower;
- operations are named as in the calculator (`lr`, `rr`, `dr`, `ls`, `rs`,
  `ds`) until the notation of the article is settled (spec 0005,
  Section 3); the Lean names need not follow the symbols.

### Steps

| Step | Content | Status |
|---|---|---|
| 1 | Definitions; `hits_congr`; left reset: `hits (m + n) (lr m a b) = 4 ^ n * hits m a + hits n b` for `a` proper | done 2026-11-24 |
| 2 | Right reset (both proper) and double reset (`hits + 4 ^ n = 4 ^ n * hits a + 4 * hits b`) | |
| 3 | Two strategies that differ only at the all-black tower have the same hits; two proper strategies that differ only at the all-white tower too | |
| 4 | Left and right shift (`4 * hits s + 1`), double shift (`16 * hits s + 6`) | |
| 5 | The families: top, lowest white, lowest black (`3 * hits + 1 = 4 ^ n`), Carter, Reyes, with their closed forms; the Carter strategy on `n` hats has `floor(7 * 4 ^ n / 20)` hits (spec 0005, M1) | |
| 6 | Embedding: a proper strategy keeps its win rate on a taller tower | |
| 7 | Counterexamples for the conditions (spec 0005, D1), and the examples of the article computed by Lean | started (left reset) |
| 8 | Infinite towers (post 3): the win rates 1/3 and 7/20 of the limit strategies. To be specified once the article says how it defines them | |
| 9 | The article's table of what is verified; a guide in `formal/hats/README.md` | README started |

Each step is committed when the check passes.

### What step 1 showed

- The left-reset formula holds when `a` is proper, with no condition on
  `b`: a `b` that points below its tower lands on a black hat of the part
  below, and one that points above lands outside.
- Lean confirms the counterexample of D1: `(1, 1)` on one hat, left-reset
  by `[00]`, has 4 hits out of 16 where the formula gives 1.

## Invariants

`docs/invariants/0004-formal-proofs-are-complete.md` covers this project
through `formal/check-hats.sh`.

## Open questions

- Step 8: how far to go with infinite towers (measure on the Cantor
  space, limits of strategies). Mathlib has the product measure; the cost
  is not estimated.
- Whether to also state the results with a tower type (`Fin n → Bool`)
  for readers who prefer it to numbers, as an outer layer.

## References

- `docs/specs/0005-hats-articles-revision.md`.
- `docs/specs/0004-rosary-formal-verification.md`.
- `docs/invariants/0004-formal-proofs-are-complete.md`.
