<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# The game of hats, checked by Lean

The statements of the hats article about finite stacks, proved in Lean 4
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
| `Hats/DoubleShift.lean` | the double shift (`ds`, `hits_ds`); changing one choice of a strategy (`hits_update`) |
| `Hats/Families.lean` | constant strategies, lowest black, lowest white, Carter (`hits_carter`), Reyes (`hits_reyes`), a strategy on a taller stack (`hits_emb`) |
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

The closed form of the Carter strategies:

```lean
theorem hits_carter {n : ℕ} (hn : 1 ≤ n) : hits n (carter n) = 7 * 4 ^ n / 20
```

(`/` is the division of natural numbers: the integer part.)

## Working with an assistant

The shell of the repository provides `lean-lsp-mcp`, a server that lets a
coding assistant ask Lean's language server for the goal at a line, the
diagnostics of a file, or a lemma by name or shape, without a full build.
With Claude Code, once, from the root of the repository:

```sh
claude mcp add lean-lsp lean-lsp-mcp
```

Its search tools (`lean_leansearch`, `lean_loogle`, `lean_leanfinder`,
`lean_hammer_premise`) send the query to services on the Internet; the
others work on the local files.
