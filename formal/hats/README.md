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
| `Hats/Assoc.lean` | the left and the right reset are associative |
| `Hats/Describe.lean` | equivalent strategies; what the top, lowest-black and lowest-white strategies choose |
| `Hats/Rates.lean` | win rates as real numbers: the six formulas as the article states them, the families, their limits |
| `Hats/Crush.lean` | exchanging two positions; crushed strategies (`exists_crushed`) |
| `Hats/Infinite.lean` | infinite stacks, their measure, the hit set and the win rate of a strategy (`rateInf`); a strategy on `n` hats keeps its win rate (`rateInf_lift`) |
| `Hats/Limit.lean` | close strategies have close win rates; the win rate of a limit |
| `Hats/LimitStrategies.lean` | the limit of a sequence of strategies (`limitOf`); the lowest black hat (`rateInf_lowBlackInf`), Carter (`rateInf_carterInf`), Reyes (`rateInf_reyesInf`) |
| `Hats/Topology.lean` | cardinalities, limits of finite stacks, continuity of finite strategies |
| `Hats/Search.lean` | the search of the second article with its reductions (`best`), proved right: no strategy has more hits than `best n` |
| `Hats/SearchFast.lean` | the search that counts as it goes (`bestFast`), proved equal to `best` |
| `Hats/SearchRun.lean` | the search run by Lean's kernel: no strategy on three hats has more than 22 hits |
| `HatsSearch/Program.lean` | the fast search program, on machine words and in parallel tasks; it needs no library and compiles to the executable `hats-search` |
| `Hats/SearchProgram.lean` | the fast program is correct (`search_toNat`, `search_spec`) |
| `Hats/SearchNative.lean` | the fast program run inside Lean on four hats: no strategy has more than 89 hits. Not built by default: see below |
| `Hats/Measurable.lean` | the hit sets of measurable strategies, and of the three limits, are measurable |
| `Hats/Readers.lean` | machines that read the hats one at a time and compute the three limit strategies |
| `Hats/Optimal.lean` | no strategy does better than 1 hit on one hat, 5 on two |
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

The three results on infinite stacks:

```lean
theorem rateInf_lowBlackInf : rateInf lowBlackInf = 1 / 3
theorem rateInf_carterInf : rateInf carterInf = 7 / 20
theorem rateInf_reyesInf : rateInf reyesInf = 7 / 20
```

## The search program

```sh
cd formal/hats
lake build hats-search 2>&1 | tee /tmp/hats-search-build.log
.lake/build/bin/hats-search 4        # one task
.lake/build/bin/hats-search 4 4      # the choices of 4 stacks shared out to tasks
```

It is the search of the calculator (`figures/hats/hats.js`, command
`search`): every crushed strategy on `n` hats, `n` from 2 to 4. The counts
that the score needs are kept in four machine words, one per chosen
position, each cut into fields of 8 bits; the search is cut into tasks
that run on all the cores. Lean gives no access to SIMD instructions;
packing several counters in one word is the same idea within a register.

`Hats/SearchProgram.lean` proves that what it returns is the most hits of
any strategy on `n` hats, whatever the number of tasks:

```lean
theorem search_spec {n : ℕ} (hn2 : 2 ≤ n) (hn4 : n ≤ 4) (depth : ℕ) :
    (∀ s : ℕ → ℤ, hits n s ≤ (HatsSearch.search n depth).toNat)
    ∧ ∃ s : ℕ → ℤ, hits n s = (HatsSearch.search n depth).toNat
```

Indicative timings for four hats (100,663,296 strategies) on the shared
12-core host of 2026-11-24: about 0.5 s in one task and 0.1 s in 96
tasks, against 0.6 to 1.0 s for the calculator's generated JavaScript
under Node 24.

What the proof covers and what it does not: the theorem is about the
function `HatsSearch.search`. That the executable computes this function
relies on the Lean compiler and on the C compiler, as for any compiled
program. `Hats/SearchNative.lean` (`lake build Hats.SearchNative`, about
three minutes) has Lean itself run the program on four hats and concludes
that no strategy has more than 89 hits; that theorem rests on one more
axiom than the others (`Lean.ofReduceBool`: the Lean compiler is right)
and is kept out of the audit.

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
