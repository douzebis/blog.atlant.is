<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# Programs behind "The game of hats"

What the article says was computed is computed by the programs of this
directory. Run them in the repository's shell (`nix-shell` at the root).
The proofs checked by Lean are in `formal/hats/`; what a program says
here is an answer of a program, not a proof.

Conventions of all programs: a stack of `n` hats is a number below
`2^n`, the bottom hat is the units digit, black is 1, and the players
point at black hats.

## From statements to programs

| What | Program | Command | What to expect |
|---|---|---|---|
| Every word, score and win rate quoted in the article; the formulas of the resets and the shifts; the facts of Section 2; the families | `check_article.py` | `python research/hats/check_article.py` | one line, `0 failures`; 2 seconds |
| The calculator (`figures/hats/hats.js`) computes what the definitions say | `check_calculator.py` (needs Node.js) | `python research/hats/check_calculator.py` | one line, `0 failures` |
| The best strategies on 2, 3 and 4 hats, in classes of equivalent strategies, and those built with resets and shifts | `best_classes.py` (needs Node.js) | `python research/hats/best_classes.py` | the three lines of its header, and four classes "not built"; 3 seconds |
| Strategies read from the bottom up, and their cuts to fewer hats: the Carter strategies, the best strategies on 3 and 4 hats | `cuts.py` (needs Node.js) | `python research/hats/cuts.py` | the lines of its header; half a minute |
| Every best strategy on five hats (and that none has 359 hits); their classes, the built ones, the hereditary ones | `best-search/best_all.c`, `best_classes5.py` (needs Node.js) | `gcc -O3 -fopenmp -o best_all best_all.c; ./best_all 5 358 > list.txt`, then `python research/hats/best_classes5.py` | 1,014 strategies in a minute; 27 classes, 9 built and hereditary, 18 primitive, in ten minutes |
| Two players with two different strategies: the best score | `two_strategies.py` | `python research/hats/two_strategies.py 3`; for 4 and 5 hats, `two_strategies.py N --lp > m.lp`, then `scip -c "read m.lp" -c optimize -c quit` | 1, 5, 22 by enumeration; 89 (2 s) and 358 (384 s, 9,734 nodes) with SCIP 10 |
| Upper bounds on `V` by hints (Buhler et al.): the game with a hint to each player, as an integer program | `hint_games.py` | `python research/hats/hint_games.py A3 L4 --lp > m.lp`, then SCIP | 81 hits out of 224 for `A3 L4` (126 s) and 162 out of 448 for `A3 L5`; 3/8 for `I2 L2 --brute` |
| The hint bound of dimension `d` and the Carter strategy on `d + 1` hats | `hint_carter.py` | `python research/hats/hint_carter.py` | six lines, the two fractions equal on each: 3/8, 3/8, 81/224, 57/160, 1401/3968, 45/128; a few seconds |
| Generalized resets on blocks of 1 to 3 hats, every scheme | `generalized_resets.py` | see its header | best win rates 1/3, 1/3, 7/20 |
| Generalized resets on blocks of 4 hats, every scheme | `reset-schemes/` | see its README | best win rate 7/20 |
| Generalized resets on blocks of 5 hats: no scheme beats 7/20, by the number of skipped stacks | `reset_schemes_lp.py`, `reset_schemes_split.py` (the solver SCIP), `reset-search/` (a direct search) | see their headers | `docs/papers/hats/open-questions.md`, question 4, has the table and the times |
| No better strategy near the Carter strategies on 6, 7, 8 hats | `local-search/` | see the header of `hats_local.c` | `open-questions.md`, question 1 |
| The trees and automata of the section on infinite stacks | `diagrams/` | see its README | |

`check_article.py` has a table `quoted`, with one line per number of the
article: a number enters the article with its line.
