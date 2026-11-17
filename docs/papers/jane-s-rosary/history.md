<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# Jane's infinite rosary: history

What was done to the paper, version by version. The reader-level summary
shown on the site is the `history` list in the paper's front matter; this
file is the detailed account. Earlier versions are kept, unmodified, under
`content/versions/jane-s-infinite-rosary/` and listed with their digests in
`docs/papers/frozen-versions.sha256`.

## 2023-01 — the original post

- Published on the WordPress blog on 2022-12-02 and worked on until
  January 2023. The text kept is the one the WordPress site still served
  on 2026-11-17 (`blog.douzeb.is/?p=6271`). Its date, 2023-01-05, is the
  date of the last change to the figures it embeds; the date of the last
  edit of the text itself is not known.
- Kept as `content/versions/jane-s-infinite-rosary/2023-01/`, converted
  on 2026-11-17 from the page served by WordPress (HTML) with Pandoc. The
  conversion repairs what WordPress and its plugins did to the text and
  improves nothing:
  - the page title, the table of contents (a plugin) and what the author
    had commented out are left out;
  - formulas: line-break tags removed; `align` and `equation` displays
    written without delimiters are put between `$$`; dashes and curly
    quotes that WordPress put inside formulas are turned back;
  - the 26 commutative diagrams were written with `xymatrix` and drawn by
    MathJax 3.2 with the XyJax 3.0.1 extension, which the site's MathJax 4
    does not have. They are kept as pictures (SVG, a light and a dark
    variant), drawn once with that same setup in a headless browser; their
    sources are in `diagrams-2023-01.md`;
  - the rows of columns (a label and a diagram each) are kept as rows;
  - the 12 embedded figures use the `frame` shortcode, with their
    proportions and the link that covered each of them, on the site's copy
    of the figure pages (which now have themes);
  - the two footnotes (a plugin) become Markdown footnotes; the one
    citation (a plugin that fills it in the browser) is written
    "(Caruso, 2012)" and its reference is copied from the page;
  - the four code listings get their fences back; blocks that the text
    links to keep their anchors.
- Not repaired: the text's own slips.
- Content: the height and its exploration algorithm; shortest recitations
  ending in a white or a black bead; Theorem 1 (the predecessor with the
  larger lambex) with the fast algorithm; Theorem 2 (the reluctant
  recitation never halts); "Conjecture 3: Jane's reluctant recitation
  tells all beads", with two lemmas; the onyx rosary with Theorem 4 and
  the canonical onyx mapping; a "work in progress" part with the onyx
  sequences and the foraging sequence.
- An earlier state of the post (20 December 2022, from the Markdown
  export `douzebis/blog.atlant.is-import`, with Conjectures 1 to 3 and 20
  `CD` diagrams) was imported first and shown on the preview for about an
  hour on 2026-11-17; it was replaced by this one at the author's request
  (three versions are kept: this one, the 2026 revision, the current
  paper). The export remains in its repository.

## 2026-11-17 — the revision with complete proofs

- Written in November 2026 (front matter: revised 2026-11-14), published
  as the first page of the static site.
- Kept as `content/versions/jane-s-infinite-rosary/2026-11-17/`.
- Mathematics: Conjectures 1, 2 and 3 become Theorem 1, Theorem 3 and a
  remark; new Theorems 4 (onyx covers), 5 (frequency of up moves) and 6
  (polynomial time); postfix notation; numerical data to 2^27 moves; open
  questions A to G. The paper's own appendix lists the changes with
  respect to the January 2023 text.
- On the site (2026-11-17, before freezing):
  - the eleven figures as pictures, in light and dark variants, linking to
    live versions served by the site;
  - commutative diagrams restored: Lemma 1 (two general, six concrete, in
    place of a table), Corollary 1 (two), proof of Theorem 1 (two
    ladders); a pointer to Lemma 1's diagrams in the proof of Theorem 2.
- Checks: `research/jane-s-rosary/` (see `statements.md`).

## Current — presentation overhaul (spec 0002)

In progress. Steps done:

- Step 1 (2026-11-17): the 2023-01 and 2026-11-17 versions frozen; comparison page;
  `tools/compare_statements.py`; this history; `statements.md`;
  `research/jane-s-rosary/` (programs rewritten from the working scripts
  and rerun; same results).

Statements compared with the 2026-11-17 version
(`python tools/compare_statements.py content/versions/jane-s-infinite-rosary/2026-11-17/index.md content/posts/2022-12-02-jane-s-infinite-rosary/index.md`):
28 before, 28 after, 0 differences.
