<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# The game of hats: the literature, checked on 2026-11-28

How: the lists of citing papers of Semantic Scholar and OpenAlex for each
paper on the game (queries by arXiv number and by title), web searches,
the bibliographies of the papers, and the web pages they cite. Sources
were downloaded and searched for bounds and for mentions of three or
more players and of biased coins.

## Papers and notes on the game itself

| Work | Retrieved | Read for |
|---|---|---|
| Buhler, Freiling, Graham, Kariv, Roche, Tiefenbruck, Van Alten, Yeroshkin, *On Levine's notorious hat puzzle*, arXiv:1407.4711v8; Integers 21A (2021) A8; also a De Gruyter volume (2022) | source (arXiv), PDF (Integers) | everything |
| its first version: Kariv and Yeroshkin, *On a certain cooperative hat game*, arXiv:1407.4711v1 (2014) | PDF | skimmed |
| Friedgut, Kalai, Kindler, arXiv:2103.01541 | source | bounds: none explicit |
| Alon, Friedgut, Kalai, Kindler, arXiv:2208.06858; SIAM J. Discrete Math. (2023) | source (arXiv) | bounds: none explicit |
| Heilman and Tamuz, arXiv:2503.09042 | source | upper bound, two players |
| Bouquet, Chikhi, Charles, Zhou, Wang, arXiv:2508.01737v2 | source | recursive strategies, finite stacks, `p != 1/2` |
| Yang Song, github.com/yangsong97/levine-hat-bounds (2026) | text of the note and of the earlier write-up | upper bounds, two players |
| Khovanova, blog post (2011) and its comments | page | comments have 0.276205 for three players, by a sum of lowest hats |
| Wagon, Problem of the Week 1179 (2014) | page (the statement) | nothing more |
| A hint sheet of a Cornell course, Physics 7653 (2024), "A hint for Lionel Levine's hat puzzle" | PDF | the strategy by lowest hats; no bound |

## Papers that cite them and are not on the game

Alon, *Hitting all maximum independent sets*, arXiv:2103.05998 (source
retrieved); Lei Yu, *On average distance, level-1 Fourier weight, and
Chang's lemma*, arXiv:2504.02593 (source retrieved; cites Heilman and
Tamuz for the lemma); three graph theory papers of 2024 to 2026 that
cite Alon et al. (tight stable graphs, the Bollobas-Erdos-Tuza
conjecture, hitting maximum independent sets in dense graphs): not
retrieved, not needed.

## Received from the author on 2026-11-28, and read

| Work | What it has |
|---|---|
| Velleman and Wagon, *Bicycle or Unicycle?* (MAA Press, 2020), Problem 76, Matching Hats (pp. 35, 214-216) | the game with "same color" in place of "both black" (twice the win rate); the triple-jump strategy with 7/10; **Theorem 76.2: a strategy on every number n of hats with the Carter scores**, with a sketch of proof (odd n: Carter, Reyes, Rosenberg, Tiefenbruck; even n: Wagon and Zimmermann, by a reset that overlaps by one hat); Yeroshkin's remark that these scores are the largest below 7/10, so best if the conjecture holds; Freiling's bound |
| Wagon, solution notes of Problem 1179 (1 April 2014) | the history of the strategies; **the reset on all white only**, with 22/63 for three hats (Roche), 89/255, 358/1023, 1433/4095; the words of the strategies for t = 3 to 8; the recursion 4x + 1, 4x + 2, or 16x + 6; bounds of Stromquist (15/40; 89 by hand; 1496 on six hats); 89 best also for two different strategies and 358 best for one, by integer programs; two questions: 358 for two different strategies, 1433 on six hats. For three players: a table on four hats with 1,125 wins, said to give 64/225 with resets (see below); Reyes's three matrices on lowest black hats, 0.2617 |
| Kalai, blog post of 12 December 2020, with comments | the conjecture for many players; a comment of Roche: an upper bound 89/256 for three players (December 2014), as in [BFGKRTVY] |
| *Emissary*, Spring 2014, Puzzles Column | no hat puzzle in this issue: the column cited by [BFGKRTVY] must be in another one |
| Burke, Gustafson, Kendall (EuroGP 2002) | Ebert's three-hat problem, another game |

What this changes in our claims (2026-11-28):

- The Carter strategies on every number of hats, with their scores, and
  the remark that they are best if the conjecture holds, are in the book
  of 2020 (with a sketch of proof). Ours: complete proofs, in Lean; the
  rule in words; the substitution theorem that gives them in one line.
- The reset on white only is on Wagon's page (2014) for fair coins. Ours:
  its value for biased coins and the comparison with S1 to S5.
- Wagon's first question (is 358 best on five hats for two different
  strategies?) is answered yes by Proposition 17 with H_4 = 57/160.
- "64/225 = 0.2844 for three players" on Wagon's page is above our
  bound. With the reset of [BFGKRTVY] a table with 1,125 wins on four
  hats gives 1124/4046 = 0.2778 (Theorem 7), and [BFGKRTVY], later and
  by the same people, gives 0.279124 as the best known. We take it for a
  slip; it should be said in the paper.

## Not retrieved

1. Berlekamp and Buhler, Puzzles Column, *Emissary* with the hat puzzle:
   not the Spring 2014 issue.
2. The email of Reyes and Carter (2014) with the tables for three and
   four players, and Winkler's message of 2010: not published.

## What the check found

No bound for three or four players other than those of Buhler et al.; no
strategy for `p != 1/2` other than S1 to S4 of Buhler et al. and S5 of
Bouquet et al.; no statement of the substitution theorem; upper bounds
as listed in the stock document. Limits of the check: Google Scholar
could not be queried; forums (MathOverflow, Reddit) were not searched
one by one; items 1 to 5 above could hold something.
