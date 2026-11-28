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

## Not retrieved

1. Kalai's blog post on the problem (2019), cited by Buhler et al.: the
   search page of the blog answers, the post itself was not located.
2. Berlekamp and Buhler, Puzzles Column, *Emissary* (2014): the site of
   MSRI did not answer.
3. Velleman and Wagon, *Bicycle or Unicycle*, MAA Press (2020): a book.
4. The email of Reyes and Carter (2014) with the tables for three and
   four players, and Winkler's message of 2010: not published.
5. The solution page of Wagon's Problem 1179 (only the statement was
   found).
6. Burke, Gustafson, Kendall, *A puzzle to challenge genetic
   programming* (Springer, 2002): another hat game; behind a paywall.

## What the check found

No bound for three or four players other than those of Buhler et al.; no
strategy for `p != 1/2` other than S1 to S4 of Buhler et al. and S5 of
Bouquet et al.; no statement of the substitution theorem; upper bounds
as listed in the stock document. Limits of the check: Google Scholar
could not be queried; forums (MathOverflow, Reddit) were not searched
one by one; items 1 to 5 above could hold something.
