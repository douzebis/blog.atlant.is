<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# 0007 — The game of hats: one article, then a paper

**Status:** in-progress
**App:** blog.atlant.is (the hats article)
**Implemented in:** <!-- YYYY-MM-DD, fill after implementation -->

## Problem

The three posts of 2020 on Levine's hat game were imported as they stood
(2026-11-24). Spec 0005 lists what is wrong with them: 40 defects of the
texts, 7 of the calculator, a notation that clashes with itself, a post 3
whose results are stated without proofs. Since then the work has moved
ahead of the texts:

- every statement of the three posts is proved in Lean (spec 0006), with
  the conditions that the posts forgot;
- the colors, the word "stack" and the notation of the resets and shifts
  are decided (spec 0005, Sections 3 and 8);
- there are results that the posts do not have: the closed form of the
  Carter scores, the optimum on up to five hats, the second double shift,
  the generalized resets and their bound, the search around the Carter
  strategies (`docs/papers/hats/open-questions.md`).

Correcting three posts one defect at a time would keep their plan, which
is the main defect (spec 0005, P2 to P4). The author decided on 2026-11-24
that there will be one article and one blog entry, and possibly a paper
for arXiv, as for Jane's rosary.

## Goals

- One article on the site (`douzebis.github.io/blog.atlant.is`), written
  anew from the three posts, with their results, the corrections of spec
  0005 and the new material.
- Every statement is numbered, has a proof in the article or a reference,
  and says what checks it: a Lean theorem, a program, or nothing.
- The three posts of 2020 stay readable as earlier versions.
- The calculator, the pictures and the diagrams follow the decisions on
  colors, words and notation.
- A paper for arXiv is built from the same source, as for the rosary
  paper (`arxiv/jane-s-rosary/`), once the article is stable.

## Non-goals

- New mathematics as a condition for publishing: the six-hat run, blocks
  of six hats, a proof of optimality on five hats are welcome but the
  article does not wait for them.
- Keeping the plan, the sentences or the formulas of 2020. What is kept
  is the results, the playful tone and the pictures.
- A Lean proof of every new result before the article is written; the
  article says what is proved, what is computed and what is conjectured.

## Specification

### Where things go

The layout of the rosary paper (spec 0002), with the names of this one:

```
content/posts/2020-08-30-the-game-of-hats/   the article
content/versions/the-game-of-hats/2020/...  the three posts of 2020, frozen
docs/papers/hats/
  history.md                        one entry per version
  statements.md                     every statement: where proved, what
                                    checks it (Lean name, program)
  open-questions.md                 exists
  related.md                        what the literature has, read in full
research/hats/
  README.md                         statement -> program -> command ->
                                    expected output and time
  check_article.py                  recomputes every number of the article
  <the programs that exist>         reset_schemes_lp.py, ..., reset-search/,
                                    local-search/, diagrams/
figures/hats/                       the calculator
formal/hats/                        the Lean project
arxiv/hats/                         the build of the paper
```

### The article: plan

Working title: "The game of hats". Sections, with what each takes from
the posts of 2020 (P1, P2, P3) and what is new. Numbers such as D7, M1
refer to spec 0005.

1. **The game.** Two players, a stack of hats each, one position each;
   they win when both point at a black hat. The game on `n` hats and the
   game on infinite stacks. Where it comes from (Levine, Khovanova 2011),
   what is known (7/20 in 2014 by two groups; Buhler et al. 2021: between
   7/20 and 0.3616; Bouquet et al. 2025). What this article does, in one
   paragraph, with the table of the Carter strategies as the goal (P3 of
   spec 0005). What is new here and what is not (M6).
2. **Stacks, strategies, hits.** A stack is a number, a strategy a word
   of digits (the tuple), the hits a count of pairs. Proper strategies.
   Three facts used all along: the choices for the all-white and the
   all-black stack do not matter; permuting the positions keeps the hits;
   exchanging the colors keeps the hits. From P1, with D1.
3. **Resets.** The white, the black and the double reset; one formula
   each, proved by cases (spec 0005, Section 6, point 1); the conditions
   and why they are needed; chains and associativity. From P1.
4. **Shifts.** The white and the black shift; the double shift and its
   dual; formulas. From P1, with D7. (The "sibling" double shift of
   2026-11-26 is the double shift with its two new positions exchanged,
   found on 2026-11-27: there is one double shift, and Section 4 says
   so in Proposition 6.)
5. **Five families.** Always the same hat; the lowest black hat and the
   lowest white hat (1/3); the Carter strategies, with the closed form
   `7 * 4^n / 20` rounded down (M1); the Reyes strategies; why the last
   two have the same win rate on `2n + 1` and `3n` hats, and what each is
   good for. The table of win rates. From P1 and P3.
6. **Infinite stacks.** The measure; a strategy on `n` hats plays infinite
   stacks; limits of strategies and their win rates, by one lemma
   (`rateInf_limitOf`); 1/3 and 7/20; measurable, and computed by a
   machine with a counter that reads the hats one at a time. The trees
   and the automata. From P3, which states these without proof (D36,
   D37).
7. **The calculator and the best strategies on few hats.** The calculator
   as a figure, with examples one can click. The search and its
   reductions. The best scores: 1, 5, 22, 89, 358 on one to five hats,
   with what establishes each (Lean; Lean with the compiler trusted; a
   solver), and the bound on six hats (M4, M5). From P2.
8. **Can 7/20 be beaten?** One more hit on any number of hats would do
   it, and conversely (M2). Generalized resets: the bound, and no scheme
   on blocks of at most five hats beats 7/20. The neighborhood of the
   Carter strategies. What Bouquet et al. prove about the rate of
   convergence, against the Carter values (M3). New.
9. **Open questions.** From `open-questions.md`.

Then: a table "What is checked, and by what" (Lean theorem or program for
each statement); the notation of 2020 and of the literature against this
one; the history of the article.

### Rules for the text

- The form of the rosary paper: "**Proposition 2.**", "*Proof.*",
  statements numbered by the site, the checks of `site.nix`.
- Definitions before examples; one example for each operation, drawn as
  stacks, then as tuples.
- Each formula is stated for hits (whole numbers) and then as a win rate.
- A statement says what it rests on: "proved (Lean: `hits_dr`)",
  "computed (program, time)", "conjectured".
- The pictures of *Team Fortress 2* stay, with their credit. They do not
  go into the arXiv paper.
- American spelling; the tone of 2020, where it does not get in the way.

### Steps

Each step is one or a few commits that name this spec. The author reads
each section of step 5 before the next is written.

| Step | Content | Status |
|---|---|---|
| 1 | Freeze the three imported posts as earlier versions (spec 0005, K2); the page of the article, unlisted until it is complete | done 2026-11-27 |
| 2 | `research/hats/check_article.py`: every tuple, score and win rate that the article will quote, recomputed from the definitions (K1) | started 2026-11-27: definitions, formulas, families; the quoted numbers enter with each section |
| 3 | The macros of the notation (`data/mathjax.json`): `\hatb`, `\hatw` (small marks), `\wreset`, `\breset`, `\dreset`, `\wshift`, `\bshift`, `\dshift`, `\dshiftbw`, `\dshiftwb`, `\dual`, `\str` | done 2026-11-27 for the site; the LaTeX side comes with step 11 |
| 4 | The calculator: colors exchanged, names of the operations, the sibling double shift, a default query, the help (spec 0005, Section 2) | done 2026-11-27: `wr`, `br`, `ws`, `bs`, `sd`, `dual`; `B<n>` and `W<n>` exchanged; tested by `research/hats/check_calculator.py` (C3, C5, C7; C4 unchanged: groups of 8) |
| 5 | The article, section by section (1 to 9), each with its numbers in `check_article.py` and its entries in `statements.md` | |
| 6 | Lean: the color exchange keeps the hits; the sibling double shift; names that follow the notation; the table of what is verified | the first two done 2026-11-27 (`Hats/Dual.lean`) |
| 7 | The diagrams of Section 6 as vector drawings, with a dark variant (K3) | |
| 8 | The programs of `levine-hats` that the article relies on, brought into `research/hats/` | |
| 9 | The literature read in full (Buhler et al. version 8, Bouquet et al. version 2), `related.md`, and the claims of novelty checked against it | |
| 10 | The three old addresses: a notice that points to the article | |
| 11 | The paper for arXiv: `arxiv/hats/`, built from the article | |

Steps 2 to 4 and 6 to 9 do not depend on each other; step 5 needs 3, and
its Sections 7 and 8 need 8 and 9.

## Invariants

- `docs/invariants/0003` (frozen versions are not edited) applies to the
  three posts once step 1 is done.
- `docs/invariants/0004` (formal proofs are complete) covers
  `formal/hats/`.

## Open questions

- Decided on 2026-11-27: the title is "The game of hats", at the date of
  the first post (2020-08-30), with "revised" set when it is published.
  The three posts are one earlier version, "2020", in three parts.
  R_1 = C_3. The notation table of spec 0005 stands, with `w(s)` for the
  win rate, an overline for the strategy with the colors exchanged and `V`,
  `V_n` for the best win rates on infinite stacks and on `n` hats. The first picture is captioned
  "stack 3" (it was number 4 with the colors of 2020: two dark hats under
  a light one). No picture of Valve in the arXiv paper.
- Whether Section 7 keeps the calculator's commands in the text or moves
  them to its help.
- Two players with different strategies: the hits of this work are those
  of two players with the same strategy. What the article says about the
  other case depends on step 8 (M4).

## References

- `docs/specs/0005-hats-articles-revision.md` (defects, notation,
  decisions).
- `docs/specs/0006-hats-formal-verification.md`.
- `docs/specs/0002-rosary-presentation-overhaul.md` (versions, history,
  statements).
- `docs/papers/hats/open-questions.md`.
