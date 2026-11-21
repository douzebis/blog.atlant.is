<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# Changes of the web page still to carry to the arXiv version

The arXiv version is built from the web page (see `README.md`), so most
changes of the page reach it at the next build. This file lists what a
build does not settle by itself: things to check in the PDF, and choices
that are specific to a paper. Remove an entry once it is dealt with.

The PDF was last built before the first entry below.

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
  (the sentence after "Can Jane tell every bead of her rosary?"; its
  wording is under discussion on 2026-11-21).

## To do later, on the page's side (decided 2026-11-21, not started)

The numbers of statements, figures and sections stay typed by hand, on
the page as in the paper: they are quoted outside the page (Lean files,
comparison of versions, annex) and must not move silently. Two tools are
to be written instead of automatic numbering:

- [ ] A build check on the numbers as typed: statements, figures and
      sections each run 1, 2, 3, ... without gap or repeat, and every
      "Theorem n", "Lemma n", "Figure n", "Section n" in the text points
      at something that exists.
- [ ] A renumbering script, for the day a number must change (most
      likely a figure, if one is inserted): it shifts the numbers in the
      page and lists the places outside the page to update.
