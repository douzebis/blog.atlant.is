<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# Four players

`four.c` (build: `gcc -O3 -o four four.c -lm`) counts the wins of a
symmetric table for four players, builds its reset by one hat, and looks
for better tables by annealing. `score4.py` is a plain, slow scorer that
also prints the bound a table gives. Record of results:
`docs/papers/hats/three-players.md` (section on four players).

| File | Hats | Wins | Out of | Limit of the resets | Found by |
|---|---|---|---|---|---|
| `results/t3-886.txt` | 3 | 886 | 4,096 | 885/3768 = 0.234873 | `four climb 3 10 1 OUT`, 2026-11-28 |
| `results/t4-15192.txt` | 4 | 15,192 | 65,536 | 15191/64120 = 0.236915 | `four climb 4 1200 4 OUT - 4 0.2` (from a random table), 2026-11-28 |

For comparison, Buhler et al. (arXiv:1407.4711v8, appendix): a table on
4 hats with 14,845 wins (Reyes and Carter, 2014), and
`V_4 >= 14844/64120 = 0.231503`.
