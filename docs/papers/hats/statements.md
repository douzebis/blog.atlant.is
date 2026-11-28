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
| Proposition 2 | 2 | Renaming the positions keeps the number of hits | `hits_swapStrat` (two positions exchanged), `hits_renamed` (any chain of exchanges) | the same strategies, a random permutation each |
| Proposition 3 | 2 | A proper strategy and its dual have the same number of hits | `hits_dual` | the same strategies |
| Proposition 4 | 2 | A proper strategy played on stacks of `k` more hats has `4^k` times its hits | `hits_emb` | the same strategies, `k` = 2 |
| Theorem 1 | 3 | Hits of the white, black and double reset: `4^n H(a) + H(b)` twice, `4^n H(a) + 4 H(b) - 4^n`; `a` proper, and `b` too except for the white reset | `hits_lr`, `hits_rr`, `hits_dr`; `rate_lr`, `rate_rr`, `rate_dr` | strategies on 1 to 3 hats by strategies on 1 to 3 hats; the two examples where a condition fails |
| Proposition 5 | 3 | The white and the black reset are associative | `lr_assoc`, `rr_assoc` | strategies on 1, 2 and 2 hats |
| Theorem 2 | 4 | Hits of the white and the black shift, `4 H(s) + 1`, and of the double shift, `16 H(s) + 6`; `s` proper | `hits_ls`, `hits_rs`, `hits_ds`; `rate_ls`, `rate_rs`, `rate_ds` | all proper strategies on 1 and 2 hats, random ones on 3 and 4 |
| Proposition 6 | 4 | The other order of the single shifts, with one choice changed, is the double shift with its two new positions exchanged; so is the dual of the double shift of the dual | `sibling_eq` (the two descriptions agree), `sibling_eq_swap` (the renaming), `hits_sibling` | the same strategies |
| Proposition 7 | 4 | Resets and shifts of equivalent strategies are equivalent | `lr_swap_low`, `lr_swap_high`, `rr_swap_low`, `rr_swap_high`, `dr_swap_low`, `dr_swap_high`, `ls_swap`, `rs_swap`, `ds_swap` (one exchange of two positions); `ls_renamed`, `rs_renamed`, `ds_renamed`, `lr_renamed_low`, `lr_renamed_high` and the same for `rr`, `dr` (any chain) | random strategies and renamings, on 1 to 3 hats by 2 or 3 hats |
| Proposition 8 | 5 | The lowest black hat and the lowest white hat have `(4^n - 1) / 3` hits | `hits_lowBlack`, `hits_lowWhite`, `rate_lowBlack`, `rate_lowWhite` | 1 to 8 hats |
| Theorem 3 | 5 | The Carter strategy on `n` hats has `7 * 4^n / 20` hits, rounded down | `hits_carterOdd`, `hits_carterEven`, `hits_carter`, `rate_carterOdd`, `rate_carterEven` | 1 to 8 hats; the rule in words: `carterOdd_words`, `carterEven_words`, `carter_words`; the cut: `carter_cut` |
| Proposition 9 | 5 | The Reyes strategy on `3j` hats has win rate `7/20 - 1/(10 * 16^j)` | `hits_reyes`, `rate_reyes` | `j` = 1, 2, 3 |
| Proposition 10 | 6 | A proper strategy on `n` hats has the same win rate on infinite stacks | `rateInf_lift` | |
| Theorem 4 | 6 | The win rate of a limit of strategies: within `2 A_k / 2^(n_k)` of each of them, and their limit | `abs_rateInf_sub_rate_le`, `rateInf_limitOf`; `measurable_limitOf`, `measurableSet_hitSet` | |
| Theorem 5 | 6 | The limits of the lowest black hat (1/3), of the Carter and of the Reyes strategies (7/20), and what they do | `rateInf_lowBlackInf`, `rateInf_carterInf`, `rateInf_reyesInf`, `lowBlackInf_spec`, `reyesInf_spec` | the counts of undecided stacks |
| Proposition 11 | 6 | Each limit is computed by a machine that reads the hats one at a time | `lowBlackReader_outputs`, `carterReader_outputs`, `reyesReader_outputs`, and the three `_computable` | the three machines as written in the article agree with the strategies on 7 and 9 hats wherever they stop |
| Proposition 12 | 8 | `V = 7/20` exactly when no plan on any number of hats beats the Carter strategy | `conjecture_iff` | the remainders of `7 * 4^n` by 20 |
| Proposition 13 | 8 | An operation that adds `k` hats gains at most 1, 6, 25, 102 for `k` = 1 to 4 | `hits_sub_le`, `hits_sub_two_le`, `hits_sub_three_le`; `hits_sub_four_le` (compiler trusted); four hats added: not in Lean (best score on five hats by solvers) | the hits of shifts in a row |
| Proposition 14 | 8 | The win rate of a scheme, `(A + c) / (4^m - Z^2)` | `hits_sr`, `tendsto_rate_schemeChain` | `generalized_resets.py` uses it |
| Proposition 15 | 8 | Double resets of the Carter strategy on `n` hats forever: 7/20 for odd `n`, less for even `n` | `tendsto_rate_drChain`, `tendsto_rate_drChain_carterOdd`, `tendsto_rate_drChain_carterEven`, `carterEven_limit_lt` | the formula for `n` = 2 to 7 |
| Proposition 16 | 8 | `A + c` is at most `2^(m-1) (2^m - Z)`; a scheme with `7 Z >= 6 * 2^(m-1)` does not beat 7/20 | `schemeScore_le`, `schemeScore_le_seven_twentieths` | |
| Proposition 17 | 8 | The wins of any two strategies on `d + 1` hats are at most `2^d + 2^n (2^n - 2) H_d`, with `H_d` the value of the affine hint game | `hitsTwo_le_hintWins`, `hitsTwo_le_of_hint_le`; `hitsTwo_four_le`, `hitsTwo_five_le` (89 and 358, given the hint values) | `hint_carter.py`: the Carter strategies give equality for `d` = 1 to 6 against the known or estimated `H_d` |

Not numbered: the strategy that always points at the same hat has
`4^(n-1)` hits (`hits_const`).

Section 3, not numbered: the black reset is the dual of the white reset
of the duals (`rr_eq_dual_lr`); the difference between the two nestings
of the double reset, `12 (H(c) - 4^(k-1))` (`hits_dr_nestings`).

Section 8, results of programs (not statements with a proof): no scheme
on blocks of at most five hats beats 7/20 (`generalized_resets.py`,
`reset-schemes/`, `reset_schemes_lp.py`, `reset_schemes_split.py`,
`reset-search/`); no better strategy near the Carter strategies
(`local-search/`).

Section 8, `H_4 = 57/160` and `V <= 57/160`: a result of programs
(`research/hats/hint-search/hint4.c`, logs in its `results/`), which
agrees with the note [Ya26] on the value, on the 11 classes and on the
250,880 optimal sortings.

Section 8, Theorem 6 (substitution): `hits_sub` in
`formal/hats/Hats/Substitute.lean`, stated as
`hits (n + k) (sub n m s) + 4 ^ k = 4 ^ k * hits n s + hits (k + 1) m`;
`substitute` in `check_article.py` checks the formula on samples and
that the shifts, the double shift, the twisted double shift and the
resets are substitutions. Section 4, the twisted double shift:
`hits_tds` (`Hats/TwistedShift.lean`). That each operation is a
substitution: `ls_eq_sub`, `rs_eq_sub`, `ds_eq_sub`, `tds_eq_sub`,
`lr_eq_sub`, `rr_eq_sub`, `dr_eq_sub` (`Hats/Instances.lean`).

Section 9 (added 2026-11-28). Theorem 7, resets for any number of
players: `winsN_reset`, `resetCard_add`, `tendsto_rateN`, `limitN_eq`
(`Hats/Players.lean`, `PlayersLimit.lean`); for three players also
`wins3_reset`, `wins3_sub`, `tendsto_rate3`. Theorem 8, the bounds for
three and four players: `tendsto_six` (`Three6.lean`), `tendsto_four3`,
`tendsto_four4` (`Four.lean`, `Four4.lean`), the counts by the kernel;
the tables on seven and eight hats and on five hats for four players are
counted by `research/hats/players/compose.py --bound`, the Rust program
`players score`, `players4/four score` and `players4/score4.py`.
Proposition 18, the exchange of the colors: `val_dual`. Theorem 9, the
white resets: `val_lr`, `val_c3`, `val_whiteChain`, `tendsto_whiteChain`
(`Hats/Biased.lean`); the substitution with a biased coin: `val_sub`
(`BiasedSub.lean`); the table of values and the comparison with the
published strategies: `research/hats/biased.py`.

