<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# Five players and more

`many.c` (build: `gcc -O3 -Wall -o many many.c -lm`) counts the wins of a
symmetric table for N players on T hats and looks for better tables by
annealing; a table gives a position for each multiset of N - 1 stacks
seen, so it stays small. `scoren.py` is an independent plain scorer.
`winkler.py` writes the starting tables of the recipe of Buhler et al.
(lowest black hats combined bit by bit, or added).

Checks (2026-11-28): `many` and `scoren.py` agree with the programs for
three and four players (1,126 and 886 wins are found again);
`winkler.py N 4 xor` has exactly the wins behind the bounds of Buhler et
al. for 5 to 8 players (205,448; 2,984,605; 43,930,664; 651,583,633).

Results: `docs/papers/hats/three-players.md`, section on five players
and more, and `results/`.
