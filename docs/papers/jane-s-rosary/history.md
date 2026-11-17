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

## 2022-12 — the original post

- Published on the WordPress blog on 2022-12-02 and worked on in the
  following weeks. The text kept here is the one of the Markdown export
  (`douzebis/blog.atlant.is-import`, committed on 2022-12-20).
- Kept as `content/versions/jane-s-infinite-rosary/2022-12/`, imported on
  2026-11-17. The import repairs the export and improves nothing:
  - the export's escaping of Markdown characters is undone;
  - display formulas written without delimiters (`align`, `CD`) are put
    between `$$`; two diagrams that stood side by side are one display;
  - the two code listings get their fences back;
  - the eleven embedded figures use the `frame` shortcode and the site's
    copy of the figure pages; `reluctant-chant.html`, which the post
    names, no longer exists and is replaced by its later name,
    `reluctant-recitation.html`;
  - the WordPress footnote becomes a Markdown footnote; the table of
    contents shortcode and the MathJax 2 configuration line are dropped;
  - captions get the anchors that the text links to.
- Not repaired: the post's own slips (for example `nu()` written without
  backslash) and its unfinished last section, in French.
- Content: the height and its exploration algorithm; shortest recitations
  ending in a white or a black bead, with 20 commutative diagrams;
  Conjecture 1 (the larger lambex wins) and the fast algorithm that depends
  on it; the reluctant recitation never stops (proof by diagrams);
  Conjecture 2 (it tells every bead); Conjecture 3 (seeds of neighbors of
  black beads).

## 2023-01 — the post as it stands on the WordPress site (not kept here)

- The post went on changing until January 2023; that text is the one
  still served by the WordPress site (`blog.douzeb.is/?p=6271`) and the
  one the 2026 revision started from. It is not in the Markdown export.
- With respect to the 2022-12 text it has: Theorem 1 and Theorem 2 in
  place of Conjecture 1 and of the proof by cases; "Conjecture 3: Jane's
  reluctant recitation tells all beads" with two lemmas; the onyx rosary
  with Theorem 4 and the canonical onyx mapping; a list of references;
  the newer figure pages (`deconstructed.html`, `height-plot.html`,
  `irrational-log2-3.html`, `onyx-ordering.html`).
- Importing it would mean converting the WordPress page (HTML) to
  Markdown. Not done.

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

- Step 1 (2026-11-17): the 2022-12 and 2026-11-17 versions frozen; comparison page;
  `tools/compare_statements.py`; this history; `statements.md`;
  `research/jane-s-rosary/` (programs rewritten from the working scripts
  and rerun; same results).

Statements compared with the 2026-11-17 version
(`python tools/compare_statements.py content/versions/jane-s-infinite-rosary/2026-11-17/index.md content/posts/2022-12-02-jane-s-infinite-rosary/index.md`):
28 before, 28 after, 0 differences.
