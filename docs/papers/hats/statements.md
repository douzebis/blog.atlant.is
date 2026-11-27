<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# The game of hats: statements

Every numbered statement of the article
(`content/posts/2020-08-30-the-game-of-hats/`), with what checks it. The
Lean names are in `formal/hats/Hats/`; the program is
`research/hats/check_article.py`, which also recomputes the examples and
the numbers quoted near each statement.

| Statement | Section | Says | Lean | Program |
|---|---|---|---|---|
| Proposition 1 | 2 | The choice for the all-white stack does not matter; nor, for proper strategies, the choice for the all-black stack | `hits_congr_white`, `hits_congr_black` | all proper strategies on 1 and 2 hats, random ones on 3 and 4 |
| Proposition 2 | 2 | Renaming the positions keeps the number of hits | `hits_swapStrat` (two positions exchanged) | the same strategies, a random permutation each |
| Proposition 3 | 2 | A proper strategy and its dual have the same number of hits | `hits_dual` | the same strategies |
| Proposition 4 | 2 | A proper strategy played on stacks of `k` more hats has `4^k` times its hits | `hits_emb` | the same strategies, `k` = 2 |
| Theorem 1 | 3 | Hits of the white, black and double reset: `4^n H(a) + H(b)` twice, `4^n H(a) + 4 H(b) - 4^n`; `a` proper, and `b` too except for the white reset | `hits_lr`, `hits_rr`, `hits_dr`; `rate_lr`, `rate_rr`, `rate_dr` | strategies on 1 to 3 hats by strategies on 1 to 3 hats; the two examples where a condition fails |
| Proposition 5 | 3 | The white and the black reset are associative | `lr_assoc`, `rr_assoc` | strategies on 1, 2 and 2 hats |

Not numbered: the strategy that always points at the same hat has
`4^(n-1)` hits (`hits_const`).

Section 3, not numbered: the black reset is the dual of the white reset
of the duals (program; the article's proof of the black reset uses it,
Lean proves `hits_rr` directly); the difference between the two nestings
of the double reset, `12 (H(c) - 4^(k-1))` (program; it follows from
Theorem 1).
