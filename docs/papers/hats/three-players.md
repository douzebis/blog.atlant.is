<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# Three players: record of results

Working notes for `docs/specs/0008-hats-learned-strategies.md`. Programs
and tables are in `research/hats/players/`.

## The game and the known bound

Three players, each sees the two other stacks and points at a hat of
their own; they win when the three hats are black. `V_3` is the best
win rate. Buhler, Freiling, Graham, Kariv, Roche, Tiefenbruck, Van
Alten, Yeroshkin (arXiv:1407.4711v8, Section on best lower bounds and
its appendix): a symmetric table on 5 hats with 9,120 wins out of
32,768, found by hill climbing (Reyes and Carter, 2014, adapted since
to 3, 4, 5 and 6 hats), and with white and black resets

    V_3 >= 9119/32670 = 0.279124...

The upper bound of the same paper is `V_3 <= 89/256`.

## Two formulas (2026-11-28), proved in Lean

For proper tables `S` on `n` hats with `W_S` wins and `M` with `W_M`
wins (no symmetry needed):

- reset (a player who sees a stack all white below, or two stacks all
  black below, plays `M` on the hats above; `M` on `k` hats):
  `8^k (W_S - 1) + (3 2^n + 2) W_M` wins. `wins3_reset`,
  `formal/hats/Hats/Three.lean`.
- substitution (`S` in the place of the bottom hat of `M`, on `k + 1`
  hats): `8^k (W_S - 1) + W_M` wins. `wins3_sub`,
  `formal/hats/Hats/ThreeSub.lean`.
- a table on `T >= 2` hats with `W` wins, reset by itself again and
  again: win rates tend to `(W - 1) / (8^T - 3 2^T - 2)`.
  `tendsto_rate3`, `formal/hats/Hats/ThreeLimit.lean`. For `T = 5`,
  `W = 9120` this is the bound of the paper.

## A better bound (2026-11-28)

    V_3 >= 73223/261950 = 0.279530...

from a symmetric table on 6 hats with 73,224 wins out of 262,144,
`research/hats/players/results/t6-73224.txt` (a second, different one:
`t6-73224b.txt`).

How it was found: the table on five hats with 9,120 wins
(`t5-9120.txt`, our own, found by annealing on 2026-11-27) reset by one
hat gives 73,050 wins on six hats (`t6-73050.txt`). Annealing from
that table, 40 minutes on one core, eight runs: 73,183 (twice), 73,198
(twice), 73,221 (twice), 73,224 (twice). A table needs 73,117 wins on
six hats to pass the bound of the paper.

Earlier searches on six hats that started from random tables, or from
tables with few states, stayed at 71,819 to 72,950: below the 73,050
of the reset. The paper reports that the search of 2014 was also tried
on 6 hats, without a better bound.

How it is checked:

- `python3 compose.py --bound 6 results/t6-73224.txt` (in
  `research/hats/players/`) recounts the wins with the plain scorer
  `score.py`, checks the table is proper, and prints the bound;
- `players score 6 < results/t6-73224.txt` (Rust) gives the same count;
- the step from the count to the bound is `tendsto_rate3`.

Not checked by a proof assistant: the count 73,224 itself (262,144
triples, by two programs).

Literature looked at on 2026-11-28 for a better `V_3`: arXiv:1407.4711v8
(the bound above), arXiv:2508.01737 (two players only),
github.com/yangsong97/levine-hat-bounds (two players only), and web
searches. Nothing above 0.279124 found. Not a guarantee.

## Next

- Longer annealing from the new tables; seven hats from the six-hat
  table reset by one hat (needs `(W - 1) / (8^7 - 386)` above 0.279530:
  586,112 wins).
- Four players: the paper has `V_4 >= 14844/64120` from a table on 4
  hats; the same route (a table on 5 hats started from the reset) is
  open.
- What the new tables look like; whether they are symmetric in a
  stronger sense or built from smaller ones.
