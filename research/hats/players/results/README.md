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
| `t5-9116.txt` | 5 | 9,116 | 32,768 | `players climb 5 3600 27 - 5 0.12`, 2026-11-27 |
| `t6-71819.txt` | 6 | 71,819 | 262,144 | `players climb 6 1800 1`, 2026-11-27 |

For comparison: Buhler et al. report a symmetric table on 5 hats with
9,120 wins (found by hill climbing in 2014; the table is not in the
paper).

Runs on 5 hats so far (2026-11-27), 19 hours of one core in all: four of
30 minutes (9,036 to 9,094), eight of one hour (8,983 to 9,108), eight of
one hour with wider temperature ranges (9,104 to 9,116).
