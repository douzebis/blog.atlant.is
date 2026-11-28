<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# Best symmetric tables found, three players

One file per table: `t<hats>-<wins>.txt`, 2^T lines of 2^T digits (line
`u`, column `v`: the position to point at when seeing the stacks `u` and
`v`). The wins are recounted by `players score T < file` and, for small
T, by `score.py T < file`.

| File | Hats | Wins | Out of | Found by |
|---|---|---|---|---|
| `t4-1126.txt` | 4 | 1,126 | 4,096 | `players climb 4 1800 1`, 2026-11-27 |
| `t5-9094.txt` | 5 | 9,094 | 32,768 | `players climb 5 1800 1`, 2026-11-27 |
| `t5-9108.txt` | 5 | 9,108 | 32,768 | `players climb 5 3600 16 - 4 0.1`, 2026-11-27 |
| `t5-9120.txt` | 5 | 9,120 | 32,768 | `players climb 5 5400 32 - 5 0.12` (two runs of eight reached it, none passed it; equals the score of the 2014 table of Buhler et al.), 2026-11-27 |
| `t5-9116.txt` | 5 | 9,116 | 32,768 | `players climb 5 3600 27 - 5 0.12`, 2026-11-27 |
| `t8-4690902.txt` | 8 | 4,690,902 | 16,777,216 | `players climb 8 5400 82 START 1.5 0.2` from `t7-586263.txt` reset by one hat (4,690,482 wins), 2026-11-28; the resets tend to 4690901/16776446 = 0.279612 |
| `t7-586263.txt` | 7 | 586,263 | 2,097,152 | `players climb 7 5400 72 START 1.5 0.2` from `t6-73224.txt` reset by one hat (585,978 wins), 2026-11-28; `compose.py --bound 7`: the resets tend to 6817/24381 = 0.279603 |
| `t6-73226.txt` | 6 | 73,226 | 262,144 | `players climb 6 5400 64 t6-73224b.txt 1.5 0.15`, 2026-11-28: 90 minutes for two more wins |
| `t6-73224.txt` | 6 | 73,224 | 262,144 | `players climb 6 2400 58 t6-73050.txt 2.5 0.2`, 2026-11-28; recounted by `compose.py --bound 6`: the resets of this table tend to 73223/261950 = 0.279530, above the 9119/32670 = 0.279124 of Buhler et al. |
| `t6-73224b.txt` | 6 | 73,224 | 262,144 | the same with seed 56 and temperatures `1.5 0.2`: another table |
| `t6-73050.txt` | 6 | 73,050 | 262,144 | `compose.py 5 t5-9120.txt 1`: the table on five hats reset by one hat, 2026-11-28 |
| `t6-72950.txt` | 6 | 72,950 | 262,144 | `players climb 6 2400 41 t6-72900.txt 1.5 0.2` (annealing from the table with 8 states), 2026-11-27 |
| `t6-72900.txt` | 6 | 72,900 | 262,144 | `players factor 6 8 1200 1` (8 states), 2026-11-27 |
| `t6-71819.txt` | 6 | 71,819 | 262,144 | `players climb 6 1800 1`, 2026-11-27 |

For comparison: Buhler et al. report a symmetric table on 5 hats with
9,120 wins (found by hill climbing in 2014; the table is not in the
paper).

Runs on 5 hats so far (2026-11-27), 19 hours of one core in all: four of
30 minutes (9,036 to 9,094), eight of one hour (8,983 to 9,108), eight of
one hour with wider temperature ranges (9,104 to 9,116).
