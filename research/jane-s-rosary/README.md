<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# Programs and notes behind "Jane's infinite rosary"

What the paper says was checked by computer is checked by the programs of
this directory. The table goes from a statement of the paper to the
program, the command, and what to expect. Run them in the repository's
shell (`nix-shell` at the root); none needs anything beyond Python, except
`walk.c`, which needs a C compiler.

All quick checks at once (about half a minute):

```sh
nix-shell --run research/jane-s-rosary/run-quick-checks.sh
```

Each check prints one line per item, ending with `ok`, and exits with an
error if one fails.

## From statements to programs

| Statement of the paper | Program | Command | Range checked |
|---|---|---|---|
| The renumbering of November 2026 (beads from 1 instead of 0) changed no mathematics | `check_renumbering.py` | `python check_renumbering.py` | 200,000 beads, 300,000 moves, 60,000 onyxes |
| Height: exploration and logarithmic algorithm agree | `check_shortest.py` | `python check_shortest.py` | beads below 60,000 |
| Proposition 1 (bounds on the height, the cases of its proof) | `check_shortest.py` | same | beads up to 10^6 |
| Question H (the record streaks of equal heights it quotes) | `check_shortest.py` | same | beads up to 10^6 |
| Fact 1, the six diagrams of Lemma 1, Lemma 2, Corollary 1 | `check_shortest.py` | same | beads below 60,000 |
| Theorem 1 (its rule, parts 1 to 3) and the chains of its proof | `check_shortest.py` | same | black beads below 60,000 |
| Remark on seeds of neighbors of black beads | `check_shortest.py` | same | black beads below 60,000 |
| First beads of the reluctant recitation, examples of Part II | `check_reluctant.py` | `python check_reluctant.py` | 14 beads |
| Theorem 2 (never stuck, injective, no gap) | `check_reluctant.py` | same | 300,000 moves |
| Theorem 2 (never stuck), Theorem 3 (frontier) | `walk.c` | `cc -O2 -o walk walk.c -lm && ./walk 27` | 2^27 moves; every bead up to 10,801,813 told |
| Lemma 4 (binary prefixes) | `check_reluctant.py` | same as above | beads below 5,000 |
| Lemma 5 (phases) | `check_reluctant.py` | same | beads below 20,000 |
| The numbers in the caption of Figure 10 (smallest bead and largest blur of its three stretches) | `check_reluctant.py` | same | three stretches of 20 up moves |
| Theorem 5 (1) | `check_reluctant.py` | same | 300,000 moves |
| Lemma 9 (the fact on convergents it rests on) | `check_reluctant.py` | same | 8 denominators |
| The table that follows Lemma 9 (the J of the lemma with Rhin's exponent, and the smallest J that works) | `check_reluctant.py` | same | four lengths of arc |
| Proposition 2 | `check_onyx.py` | `python check_onyx.py` | onyxes below 20,000 |
| Examples of Part III, covers quoted, table of v(n), the value iota(39) | `check_onyx.py` | same | as printed in the paper |
| Lemmas 6 and 7 | `check_onyx.py` | same | beads below 20,000 |
| Lemma 8 (the computation it rests on) | `check_onyx.py` | same | a below 3,000 |
| Foraging sequence, first values | `check_onyx.py` | same | 24 values |
| The four listings printed in the paper | `check_paper_code.py` | `python check_paper_code.py` | see the program |
| Numerical table; Conjectures A, B; Question C | `walk.c` | as above | 2^27 moves; kept in `results/walk-27.log` |
| Conjecture D, Question E (observations) | `height_statistics.py` | `python height_statistics.py` | prints the numbers quoted |

Not checked by computation: Theorems 3, 4 and 6 and Corollaries 2 and 3 as
such (they are statements about all beads; the programs check instances
and the lemmas they rest on).

## Files

- `rosary.py`: the moves and the notions of the paper as plain functions;
  every other program imports it. Beads are numbered from 1, as in the
  paper since November 2026 (`check_renumbering.py` holds the earlier
  definitions, numbered from 0, and compares).
- `check_*.py`: the checks of the table. A check fails loudly.
- `height_statistics.py`: observations quoted with the open questions;
  nothing is asserted.
- `walk.c`: the long run; `results/walk-27.log` is its output for 2^27
  moves (about 20 seconds and 2 GB of memory). The log was produced again
  on 2026-11-18 with the new numbering: its frontier column is one more
  than before, the other columns did not change.
- `draw_figures.py`: draws Figures 10 and 13 of the paper (SVG, light and
  dark) into the paper's `images` directory:
  `python draw_figures.py ../../content/posts/2022-12-02-jane-s-infinite-rosary/images`.
- `run-quick-checks.sh`: all the checks but the long run.
- `notes.md`: working notes from the revision of November 2026, as they
  were written (they name the programs by their earlier names,
  `checks.py`, `bounds.py`, `final.py`, and number the beads from 0).

## A caution about heights

`rosary.heights_by_exploration` explores the beads up to a bound, so what
it finds are lengths of recitations that stay below the bound: upper
bounds for the heights. The logarithmic algorithm also produces the length
of an actual recitation. That the two agree is strong evidence, not a
proof that both are the height; the proof is in the paper (Lemma 2 and
Theorem 1).
