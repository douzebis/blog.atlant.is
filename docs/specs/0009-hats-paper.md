<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# 0009 — The hats paper for HAL and arXiv

**Status:** in-progress
**App:** arxiv/hats
**Implemented in:** <!-- YYYY-MM-DD, fill after implementation -->

## Problem

The results on the game of hats obtained in November 2026 (substitution,
bounds for three and four players, biased coins) are in a long web
article that tells the story of 2020 first. They need a paper of their
own, short, in the order a referee expects, to be deposited on HAL, then
on arXiv, then possibly submitted to a journal.

## Goals

- `arxiv/hats/paper.tex`: a paper written by hand in LaTeX, apart from
  the web article (both are kept alive; the article is not generated
  from the paper nor the paper from the article).
- `nix-build arxiv/hats` gives `paper.pdf` and `arxiv-source.tar.gz`,
  and fails on an overfull line or an undefined reference.
- Every statement of the paper names the Lean theorem that checks it, or
  says that it is the result of a program, and which.
- The tables of the bounds are given as ancillary files, with their
  checksums in the paper.
- A declaration on the use of AI tools, to be reviewed and reworded by
  the author.

## Non-goals

- The story of the posts of 2020, the calculator, the machines that read
  infinite stacks: they stay in the web article, which the paper cites.
- A journal style file: chosen at submission time.

## Specification

Title (proposed): *Substitutions and resets in Levine's hat game: a
structure theorem and new lower bounds for two, three and four players*.

Sections: 1 Introduction and results; 2 The game, strategies, hits;
3 Substitution (two players) and its consequences (shifts, resets, the
Carter strategies, the conjecture one number of hats at a time, a second
operation that adds two hats); 4 Biased coins; 5 Any number of players
and the new bounds; 6 Remarks on upper bounds (hint games and the Carter
numbers); 7 What programs say of the best strategies on few hats;
8 Formal verification, data and code; 9 Open questions; declaration;
references.

Decisions for the author:

1. the title, and one paper or two (two players apart from more players);
2. the author line (affiliation, address);
3. the license of the deposit (CC BY 4.0, as the web article);
4. MSC classes (proposed: 91A12 primary; 05A05, 60C05, 68V20 secondary)
   and arXiv categories (math.CO primary; math.PR, cs.LO);
5. the wording of the declaration on AI tools.

## Open questions

- Which journal: Integers published Buhler et al.; the Electronic
  Journal of Combinatorics and the Journal of Integer Sequences are
  alternatives.
