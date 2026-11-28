<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# Strategies with a symmetry, and what the best ones on six hats are made of

`symsearch.c` looks for two-player strategies by simulated annealing,
optionally among those that a renaming of the positions leaves unchanged.
`classify.py` tests whether the strategies found are substitutions
(Theorem 6 of the article), as they stand or after loose choices.

Build: `gcc -O3 -o symsearch symsearch.c -lm`.

## Why (2026-11-28)

On four hats, the best strategies that are not built from smaller ones
are one strategy up to the colors and two loose choices,
`0010303022112230`. Read by pairs of hats, A (positions 0, 1) and B
(positions 2, 3), it says:

- B all white: point at a black hat of A;
- B all black: point in B, at the place where A has its black hat;
- B mixed, with its black hat at place j: if A is black at place j, point
  there; otherwise point at the white hat of B.

It is unchanged by the renaming `(01)(23)`, up to its loose choices. The
question was whether strategies with such a symmetry do well on six hats.

## Results

Four minutes for each run, six hats, Carter score 1,433.

| Symmetry | Best found |
|---|---|
| none | 1,433 |
| `(01)(23)` | 1,430 |
| `(01)(23)(45)` | 1,429 |
| `(03)(14)(25)` | 1,429 |
| `(012)(345)` | 1,387 |
| `(024)(135)` | 1,387 |

Without symmetry (`results/six-plain-*.log`, four runs of five minutes,
`symsearch 6 300 SEED "" 1433`): 2,392 restarts, 1,971 of them reached
1,433 hits, none 1,434, and the 1,971 strategies are all different.

`python3 classify.py 6 1433 results/six-plain-*.log`: 248 of them are
substitutions as they stand, and the other 1,723 become substitutions of
a strategy on three hats into a strategy on four after loose choices
(each one recounted). So the search found no best strategy on six hats
that is not built from smaller ones.

Limits: annealing finds what is easy to reach; this is a sample, not a
proof that 1,433 is best nor that every strategy with 1,433 hits is a
substitution.
