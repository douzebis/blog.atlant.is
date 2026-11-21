<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# Changes of the web page still to carry to the arXiv version

The arXiv version is built from the web page (see `README.md`), so most
changes of the page reach it at the next build. This file lists what a
build does not settle by itself: things to check in the PDF, and choices
that are specific to a paper. Remove an entry once it is dealt with.

None of the entries below has been read in the PDF yet.

## 2026-11-21: Figures 1, 2 and 3 redrawn

On the page (commits `ae6f86b`, `cb24323`):

- Figure 1: the label is in each bead, the position underneath (`#1`,
  `#2`, ...); the `..` bead is replaced by a dashed piece of string.
- Figure 2: bare labels, the string is drawn, arrows are colored by
  length (the label of the bead they leave), and the up arrows of beads 7
  to 10 fade out to the right.
- Figure 3: all the arrows of Figure 2, dimmed, except the five moves of
  the shortest recitation to bead 4; positions under the beads.
- The three captions changed accordingly.

The pictures and captions are taken from the page, so a rebuild brings
them in. To check in the PDF:

- [ ] Rebuild (`nix-build arxiv/jane-s-rosary -o result-arxiv`) and look
      at the three figures.
- [ ] The caption of Figure 2 says "The color of an arrow tells its
      length". Check that the figure still reads when printed in gray,
      or reword the caption for the paper.
- [ ] The dimmed arrows of Figure 3 and the fading arrows of Figure 2:
      check that they survive in print, neither lost nor too heavy.
- [ ] Figures 2 and 3 are taller than before (ratio about 3.2 to 1
      instead of 4.3 to 1): check the page breaks around them.
- [ ] `#1`, `#2`, ... for positions is a notation of the figures only;
      decide whether the paper needs a word about it beyond the caption
      of Figure 1.

## Passages that `build.py` rewords

`build.py` replaces some sentences of the page by a more sober wording
and stops with an error when the sentence it looks for is gone. When one
of these sentences changes on the page, its entry in `build.py` must
follow:

- "reached from bead $1$. The fun starts with two finer questions."
  (the sentence after "Can Jane tell every bead of her rosary?").

## 2026-11-21: changes to the opening

These reach the paper by a rebuild; listed so that they are read once in
the PDF.

- [ ] "Yes, by a short induction (Proposition 1)" replaces "Yes, and
      easily".
- [ ] "She looks no further than one bead ahead." is dropped.
- [ ] Theorem 3 is no longer in bold in the list of results.
- [ ] The sentence "Theorem 3 was a conjecture in the first version of
      this paper ..." is dropped from the opening, and its rewording is
      removed from `build.py`. The fact stays in the history (the list
      of versions at the end of the paper) and under the statement of
      Theorem 3 in Section 8.
- [ ] The paragraph "Why it works, in one breath" is now "Why she tells
      every bead, by ear": positions heard as frequencies, a down move
      as an octave down, an up move as a fifth up, and no circle before
      Section 8. Decide whether the paper keeps "by ear" or takes a more
      sober title ("the idea"), and whether it keeps the musical picture
      as it is.

- [ ] The "Music" paragraph of the coda now refers back to "the
      octaves and fifths of the opening" and names the Pythagorean
      comma. If the paper changes the musical picture of the opening,
      this sentence must follow.

## 2026-11-21: second batch of changes to the opening and the reading guide

These reach the paper by a rebuild; to read once in the PDF.

- [ ] The black beads "form a tree" (was "carry a tree of their own").
      The abstract in `build.py` still says "carry a tree": align or
      leave.
- [ ] The paragraph on how Jane Street and the OEIS number squares and
      slabs is dropped; its rewording is removed from `build.py`. The
      table keeps the offsets.
- [ ] The open question quoted in the opening says "in the reluctant
      recitation"; its rewording in `build.py` follows.
- [ ] The diagram of the reading guide has no node for Corollary 3 any
      more: I to II to IV on one row, III under I.
- [ ] "Part IV is the only place where the paper uses a result that is
      not elementary, and that it does not prove."

## 2026-11-21: Section 1, and where onyxes get their name

These reach the paper by a rebuild; to read once in the PDF.

- [ ] Up and Down are defined without domain and codomain; Down says
      "for n >= 2: there is no down move from bead 1".
- [ ] "Jane can come down to bead 8 from 16 and from 17" (was "comes
      down ... or").
- [ ] Black beads are called onyxes from Section 1 on: "onyx number n is
      the bead 3n - 2", "a bold number or letter always counts onyxes; a
      plain one counts all the beads". Section 9 no longer introduces
      the word, it refers to Section 1. The table of names follows.
      Check that the paper's abstract and introduction, which say "black
      beads" and "beads congruent to 1 modulo 3", still read well with
      it.

- [ ] Section 1 no longer says "inverse branches" (now: lambda undoes an
      up move, mu and nu are the two ways to undo a down move), nor
      plain "heap order" (now: numbered breadth-first, also known as
      heap order, level by level, children 2n and 2n + 1), and no longer cites Odlyzko and Wilf there: [OW91] is
      cited in Section 4, where its result is used, in the coda and in
      the paper's related-work paragraph.
- [ ] Naming rule fixed on 2026-11-21, to keep in any text written for
      the paper only (abstract, introduction, related work): "a black
      bead", without a number, states a color; with a plain number write
      "bead 4", "bead 4, which is black" or "the (black) bead 4"; the
      rank among the black beads is always "onyx **n**", never "black
      bead number n". An onyx is a black bead seen as a bead of the onyx
      rosary.

## 2026-11-21: Proposition 1 restated

These reach the paper by a rebuild; to read once in the PDF.

- [ ] Proposition 1 states two bounds, in base 2: the lower bound and
      4 + 3 log2 n / log2(9/8) (the constant was 12). The linear bound
      (4n - 1)/3 is no longer in the paper at all (it stays proved in
      Lean as `height_upper`, and checked by `check_shortest.py`).
- [ ] The proof shows h(n) <= 4 + 3 log_{9/8}(n - 7) for n >= 8, with
      equality at 8, starting from a table of the heights of beads 1 to
      11. Check how the table and the displayed chain of inequalities
      sit inside the proof in the PDF. The Lean proof (`height_log`,
      `RosaryReal/Prop1.lean`) was changed to match.
- [ ] The sentence "Numerically, h(n) <= 1 + ..." is gone; tightness is
      addressed in Question E of Section 12.
- [ ] Heights are measured against log2 n everywhere (Section 2,
      Conjecture D, Question E), with the constants recomputed: 1.710,
      17.65, 3.369, 5.3. The two natural logarithms of Part IV (Theorem
      5 and its proof) are left as they were, on purpose for now.
- [ ] The abstract and introduction in `build.py`: check that nothing
      there quotes the old form of Proposition 1 or a constant per ln n.

## 2026-11-21: diagrams of beads

These reach the paper by a rebuild; to look at in the PDF.

- [ ] "How to read the diagrams" is now a list of four rules: arrows,
      larger beads to the right and to the top, a mark under a bead for
      its color (a bullet for black, a small circle for white), and what
      "commutes" means.
- [ ] The marks are four commands, `\blackmark`, `\whitemark`,
      `\blackbead{...}` and `\whitebead{...}`, defined twice: for the
      web in `data/mathjax.json` (discs drawn by `assets/css/main.css`,
      the same in the light and dark themes) and for the paper in the
      preamble of `build.py` (TikZ). Check their size and gray levels in
      print, and keep the two definitions in step.
- [ ] The two diagrams in the sketch of Theorem 1 are mirrored (lambda
      now points left, as in Lemma 1) and no longer show the bead
      n-bullet itself: the right-hand ends are a_0 = n mu over n - 1,
      and b_0 = n nu over n + 1. The sentence after them says "left-hand
      ends".
- [ ] "By induction" replaces "by strong induction" (Lemma 2, Theorem 1).

## 2026-11-21: links to statements, lambda exponent, Question H, Figure 6

These reach the paper by a rebuild; to look at in the PDF.

- [ ] Every reference to a fact, lemma, proposition, corollary, theorem,
      conjecture or question is a link to its statement (206 of them,
      written by `tools/link_statements.py`; a test keeps new references
      linked). In the paper each statement carries the matching label.
      Check how the links look in the PDF (color, boxes) and whether a
      paper wants that many.
- [ ] "Lambda exponent" replaces "lambdex" everywhere; the paper's title
      of Section 4 is now "More names: chains, seeds and lambda
      exponents".
- [ ] Section 12 has an eighth question, Question H (streaks of equal
      heights), with a small table of records; the opening says "eight
      questions". The caption of Figure 4 and the coda point to it.
- [ ] Section 4 says what "grows geometrically" means for an up-chain
      (the ratio to (3/2)^i increases to a limit K, and the bead stays
      within 1 of K (3/2)^i), and cites [OW91] for the chain of bead 1
      only.
- [ ] Figure 6 is redrawn: black and white beads, the height in the
      bead, the position underneath, arrows from a bead back to its
      predecessor. Whether Figure 5 stays is undecided; removing it
      renumbers Figures 6 to 13.

## To do later, on the page's side (decided 2026-11-21, not started)

The numbers of statements, figures and sections stay typed by hand, on
the page as in the paper: they are quoted outside the page (Lean files,
comparison of versions, annex) and must not move silently. Two tools are
to be written instead of automatic numbering:

- [x] References to statements are checked: `tools/link_statements.py
      --check` (run by the tests) fails if a reference is not a link or
      names a statement that does not exist, and the site check fails on
      a link without a target. Figures and sections are not covered yet.
- [ ] A build check on the numbers as typed: statements, figures and
      sections each run 1, 2, 3, ... without gap or repeat, and every
      "Theorem n", "Lemma n", "Figure n", "Section n" in the text points
      at something that exists.
- [ ] A renumbering script, for the day a number must change (most
      likely a figure, if one is inserted): it shifts the numbers in the
      page and lists the places outside the page to update.
