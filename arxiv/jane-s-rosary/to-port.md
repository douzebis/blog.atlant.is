<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# The arXiv version against the web page

The arXiv version is built from the web page (see `README.md`), so the
text, the statements, the figures and their captions reach it at each
build. This file keeps what a build does not settle by itself: choices
that are specific to a paper, and things to look at in the PDF. Remove an
entry once it is dealt with.

## State on 2026-11-22

The PDF was built and read page by page against the page as it stood that
day (45 pages, no overfull line). Everything logged here on 2026-11-21 and
2026-11-22 was found in it as on the page: the redrawn Figures 1 to 12,
Proposition 1 with the constant 4, the compact Theorem 1, the sets T_i,
the two proofs of Theorem 3, "Which exponent?" with Rhin's explicit bound,
the appendix of proofs, the open questions without a section number, the
bead marks in the diagrams, "lambda exponent", "octave", the declaration.

What was changed for the paper alone, in `build.py`:

- tables are set a size smaller, four of them get column widths of their
  own (`TABLE_WIDTHS`), and the SHA-256 sums are cut in four so that they
  fit their column;
- a picture that is nearly square (Figures 5 to 8) takes 72% of the width
  instead of all of it, and a large figure shares its page with text;
- a statement that starts with a list (Theorem 5) has its head on a line
  of its own;
- the abstract says that the black beads "form a tree", as the page does.

## 2026-11-22, Figure 8

- Figure 8 shows the two moves that cross the edge of the picture (21,
  from bead 80 up to bead 40, and 23, from bead 60 back to bead 30) as
  arrows that fade out; the caption says that beads 40 and 60 belong to
  T_31 and sit outside the picture. New parameter `stubs=yes` of
  `figures/jane-s-rosary/deconstructed.html`. Read in the PDF.

## Left to the author

- [ ] **Colors.** Several captions lean on color (Figure 2: "the color of
      an arrow tells its length"; Figure 7: "from red to green"; Figures
      6, 10, 11). They read well on screen. If the paper must also read in
      gray, these captions need a paper wording, or the figures a second
      rendering.
- [ ] **The opening by ear.** The paper keeps the paragraph "Why she
      tells every bead, by ear" and the "Music" paragraph of the coda as
      they are on the page. Say so if the paper should be more sober
      there.
- [ ] **Order of the back matter.** As on the page: appendix of proofs,
      the two sections on checks, the annex, the declaration, the names,
      the numerical data, the references, the versions. A journal would
      put the references last or before the appendices.
- [ ] **Links to statements.** Every reference to a statement is a link
      (black, so invisible in print). Nothing to do unless they are
      unwanted.
- [ ] **The declaration** says that the correspondence between the Lean
      statements and the text rests "on the usual reading": the author's
      reading of the Lean statements against the text should take place
      before submission.
- [ ] **History.** The front matter of the page (and so the list of
      versions of the paper) and `docs/papers/jane-s-rosary/history.md`
      have no entry yet for this round: Proposition 1 and Theorem 1
      restated, two proofs of Theorem 3, the explicit Theorem 6, the
      appendix. To write when the author's reading ends, with a fresh run
      of the Lean checks and the annex table that quotes it.
- [ ] **Part III** has not been read by the author yet; its proofs
      (Theorem 4, Lemmas 6 to 8) are still in the main text.

## Rules to keep in text written for the paper only

The abstract, the related-work paragraph (`related.md`) and the
rewordings of `build.py` follow the page's vocabulary:

- "a black bead", without a number, states a color; with a plain number
  write "bead 4", "bead 4, which is black" or "the (black) bead 4"; the
  rank among the black beads is "onyx **n**", never "black bead number n";
- "lambda exponent", not "lambdex"; "octave" for floor(log2 n), "height"
  only for the number of moves from bead 1;
- positions are counted from 1; logarithms of heights are in base 2.

`build.py` stops with an error when a sentence it rewords, a table it
resizes or a quotation it drops is no longer on the page.

## Tools on the page's side

- `tools/link_statements.py` (references to statements are links),
  `tools/check_numbers.py` (numbers of statements, figures, sections),
  `tools/renumber_figures.py` (renumbering of figures). The numbers stay
  typed by hand because they are quoted outside the page.
