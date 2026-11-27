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
| Generalized resets on blocks of 1 to 3 hats, every scheme | `generalized_resets.py` | see its header | best win rates 1/3, 1/3, 7/20 |
| Generalized resets on blocks of 4 hats, every scheme | `reset-schemes/` | see its README | best win rate 7/20 |
| Generalized resets on blocks of 5 hats: no scheme beats 7/20, by the number of skipped stacks | `reset_schemes_lp.py`, `reset_schemes_split.py` (the solver SCIP), `reset-search/` (a direct search) | see their headers | `docs/papers/hats/open-questions.md`, question 4, has the table and the times |
| No better strategy near the Carter strategies on 6, 7, 8 hats | `local-search/` | see the header of `hats_local.c` | `open-questions.md`, question 1 |
| The trees and automata of the section on infinite stacks | `diagrams/` | see its README | |

`check_article.py` has a table `quoted`, with one line per number of the
article: a number enters the article with its line.
