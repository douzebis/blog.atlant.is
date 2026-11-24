<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# The game of hats, checked by Lean

The statements of the hats article about finite towers, proved in Lean 4
(spec `docs/specs/0006-hats-formal-verification.md`, which lists what is
done and what is not).

```sh
bash formal/check-hats.sh      # from the shell of the repository
```

prints `check: ok` when every proof is accepted, none is unfinished and
none rests on more than Lean's three standard axioms.

Mathlib is not fetched for this project: `lakefile.toml` points at the
copy of `formal/jane-s-rosary-real`.

## Reading the statements

| File | Content |
|---|---|
| `Hats/Basic.lean` | stacks, the color of a hat (`hat`), the number of hits of a strategy (`hits`), proper strategies |
| `Hats/Sums.lean` | tools for the sums over stacks |
| `Hats/Reset.lean` | the left reset (`lr`) and its hits (`hits_lr`) |
| `Hats/Reset2.lean` | the right reset (`rr`, `hits_rr`) and the double reset (`dr`, `hits_dr`) |
| `Hats/Shift.lean` | the left shift (`ls`, `hits_ls`) and the right shift (`rs`, `hits_rs`); strategies that differ at one stack (`hits_congr_white`, `hits_congr_black`) |
| `Hats/Examples.lean` | examples computed by Lean |
| `Hats/Audit.lean` | what each theorem rests on |

A stack of `n` hats is a number below `2 ^ n`, read in binary from the
bottom hat, black being the digit 1; a strategy gives, for the stack one
sees, the position one points at. The names `lr`, `rr`, `dr`, `ls`, `rs`,
`ds` are those of the calculator: "left" is the all-white stack (the
first entry of a tuple), "right" the all-black one (the last). Results are stated on the number of hits, out of `4 ^ n`, so
that no division is involved: "the win rate of the left reset is that of
`a` plus that of `b` over `4 ^ m`" reads

```lean
theorem hits_lr {m : ℕ} (n : ℕ) {a : ℕ → ℤ} (b : ℕ → ℤ) (ha : Proper m a) :
    hits (m + n) (lr m a b) = 4 ^ n * hits m a + hits n b
```
