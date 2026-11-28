<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# The game of hats: tracks to explore

A list kept up to date, with what each track could give and what it
costs. State on 2026-11-28. Done tracks move to the end with their
outcome; the results themselves are in `stock-2026-11-28.md`.

## Open

| # | Track | Could give | Cost | Source of the idea |
|---|---|---|---|---|
| 1 | **Five players and more.** Symmetric tables on 3 or 4 hats for 5 to 12 players, by the search that worked for 3 and 4; the limit formula is proved for every number of players | new lower bounds for `V_5` to `V_12` (those of Buhler et al. come from Latin squares on lowest black hats, not from a search) | small: a table is indexed by multisets of stacks | our Theorem 7; the bounds list of Buhler et al. |
| 2 | **Resets that overlap.** Start again on hats that overlap the block just read (Velleman and Wagon, even case; S1 of Buhler et al.) | better limits for 3 and 4 players from the tables we have; a theorem for overlapping resets | small for the experiment | the book of Velleman and Wagon |
| 3 | **Other rules to go up**, and tables made for them: a rule is a table over the kinds (white, black, mixed) of the stacks seen; about two million rules with one hat added | a better recursion than the reset for 3 players | small to try, medium to exploit | proofs of `wins3_reset` and `wins3_sub` side by side |
| 4 | **Biased coins.** Is `V(p)` the white-reset bound for small `p`? Best strategies on 3 to 5 hats at fixed `p`; three players with biased coins | a conjecture with evidence; maybe a better bound near 1/2 | small | `val_sub` |
| 5 | **Lean counts of larger tables** (seven hats, three players), by counting each multiset of stacks once | the bound 0.279603 with nothing trusted | small | `decide +kernel` on 262,144 placements |
| 6 | **Strategies that read the lowest black hats only**, or machines that read hats from the bottom, for 3 players | strategies on infinite stacks with a description; Reyes's matrices give 0.2617 | medium | `carter_cut`; Wagon's notes |
| 7 | **Stromquist's hand proof that 89 is best on four hats**, and his Hamming-distance form of upper bounds | a Lean proof without a compiled search; a second road to upper bounds | unknown: the argument is not published | Wagon's notes |
| 8 | **The hint game as equations**: prove that the expected number of equations given up is at least `2^d / 20` | the conjecture `V = 7/20` | large; a long shot | `hint_lines.py` |
| 9 | **One more hat gains at most a constant** (`h(n+1) <= 4 h(n) + c`) | `V <= 0.3503` from five hats | unknown; no route found | brainstorm of 2026-11-28 |
| 10 | **Six hats, two players**: is 1,433 best, also for two different strategies (Wagon's second question)? | a certified best score, or a counterexample to the conjecture | large by search; `H_5` would settle it | Wagon's notes; Proposition 17 |
| 11 | **A certified search on five hats** | Proposition 13 for four hats added, in Lean | medium to large | the one loose end of the Lean front |
| 12 | **Ask Wagon or Roche** about "64/225 with the reset strategy" for three players | removes a doubt on our three-player bound | an email | Wagon's notes |

## Done on 2026-11-27 and 28

Substitution; the twisted double shift; resets for any number of
players; bounds for three and four players; white resets for biased
coins; the hint game read by lines; the literature check; the Lean
front. See the stock document.
