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

## Seven hats (2026-11-28)

    V_3 >= 6817/24381 = 586262/2096766 = 0.279603...

from a symmetric table on 7 hats with 586,263 wins out of 2,097,152
(`t7-586263.txt`), found by annealing from the six-hat table reset by
one hat (585,978 wins); 586,112 were needed to pass the six-hat bound.
Four runs of 90 minutes: 586,185, 586,197, 586,242, 586,263. Recounted
by `compose.py --bound 7`. On six hats, four more runs of 90 minutes
from the tables with 73,224 wins gave 73,224 three times and 73,226
once: that search is near its end.

## Four players (2026-11-28)

Buhler et al.: a symmetric table on 4 hats with 14,845 wins out of
65,536 (Reyes and Carter, 2014), and with resets
`V_4 >= 14844/64120 = 0.231503`. Their formula for `n` players and a
table on `t` hats with `W` wins:
`(W - 1) / ((2^t - 1)^n + n (2^t - 1)^(n - 1) - (n + 1))`.

Ours, with `research/hats/players4/` (`four.c`, `score4.py`):

    V_4 >= 15191/64120 = 0.236915...

from a symmetric table on 4 hats with 15,192 wins
(`players4/results/t4-15192.txt`; annealing from a random table, 20
minutes; three other runs: 15,088, 15,119, 15,169). A table on 3 hats
with 886 wins out of 4,096 (`t3-886.txt`, ten seconds) already gives
885/3768 = 0.234873, above the bound of the paper.

Checked: both tables recounted by `score4.py` (proper, symmetric). The
reset formula for four players, `16^k (W_S - 1) + R W_M` with
`R = 16^t - ((2^t - 1)^4 + 4 (2^t - 1)^3 - 5)`, is the paper's; it was
compared with full counts on five pairs of small tables (random ones
too), and proved in Lean for any number of players the same day:
`winsN_reset`, `resetCard_add`, `tendsto_rateN`, `limitN_eq` in
`formal/hats/Hats/Players.lean` and `PlayersLimit.lean`. There the
players may use different strategies, as long as nobody uses their own
stack; one table for all is a special case.

## Eight hats, and what is in Lean (2026-11-28, later)

Eight hats, three runs of 90 minutes from the seven-hat table reset by
one hat (4,690,482 wins): 4,690,710, 4,690,817, 4,690,902. So

    V_3 >= 4690901/16776446 = 0.279612...

(`t8-4690902.txt`, recounted by `compose.py --bound 8`). Four players on
five hats, from the four-hat table reset by one hat (244,472): 246,459 at
best (`players4/results/t5-246459.txt`), which gives 0.236370, below the
four-hat bound; four hats again: nothing above 15,192.

Checked entirely in Lean, the count of the table included (the kernel
counts every placement; no compiled program is trusted):

- three players: `V_3 >= 73225/261950 = 0.279538` from the six-hat table
  with 73,226 wins (`tendsto_six`, `formal/hats/Hats/Three6.lean`);
- four players: `V_4 >= 15191/64120 = 0.236915` from the four-hat table
  (`tendsto_four4`, `Hats/Four4.lean`), and `885/3768` from the
  three-hat table (`tendsto_four3`, `Hats/Four.lean`).

The bounds from seven and eight hats (0.279603, 0.279612) rest on counts
by two programs.

## Next

- Longer annealing from the new tables; seven hats from the six-hat
  table reset by one hat (needs `(W - 1) / (8^7 - 386)` above 0.279530:
  586,112 wins).
- Four players: the paper has `V_4 >= 14844/64120` from a table on 4
  hats; the same route (a table on 5 hats started from the reset) is
  open.
- What the new tables look like; whether they are symmetric in a
  stronger sense or built from smaller ones.
