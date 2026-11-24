<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# Generalized resets on blocks of four hats

```sh
cd research/hats/reset-schemes
lake build 2>&1 | tee /tmp/reset-schemes-build.log
.lake/build/bin/reset-schemes | tee /tmp/reset-schemes-run.log
```

Question 4 of `docs/papers/hats/open-questions.md`. A scheme is a set `Z`
of stacks of four hats and a proper strategy `a` on the other stacks:
outside `Z` play `a` on the lowest block of four hats, in `Z` skip the
block and start again above. For every `Z` (3983 of them, up to the
permutations of the four positions) the program finds the best `a`, about
1.5e11 schemes in all, and prints the best win rates. It takes under a
minute on 12 cores.

It is a program, not a proof. `../generalized_resets.py` does the same,
plainly, for blocks of 1, 2 and 3 hats.

## Result (2026-11-24)

| Size of `Z` | Best win rate |
|---|---|
| 0 | 89/256 (the best strategy on four hats) |
| 1 | 89/255 |
| 2 | 88/252 (`Z` = {all white, all black}) |
| 3 | 86/247 |
| 4 | **84/240 = 7/20** |
| 5 to 15 | at most 1/3 |

The best is 7/20, for one `Z` up to the permutations: stacks 0, 7, 8 and
15, those whose three lowest hats are all white or all black. That is the
scheme on three hats (skip a block that is all white or all black, else
play the Carter strategy on three hats) with a fourth hat that is
ignored. No scheme on blocks of four hats beats 7/20.
