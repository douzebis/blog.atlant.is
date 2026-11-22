<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# The arXiv version of *Jane's infinite rosary*

```sh
nix-build arxiv/jane-s-rosary 2>&1 | tee /tmp/rosary-arxiv-build.log
```

gives `result/paper.pdf` and `result/arxiv-source.tar.gz` (what arXiv asks
for: `paper.tex` and the figures).

The build fails if the page has changed in a way the paper does not take:
a passage that `build.py` rewords is gone, a table has no widths, a line is
overfull, a reference is undefined. The `paper` job of
`.github/workflows/pages.yml` runs it at each push. It does not judge where
the figures land: that still takes reading the pages.

The text is not kept twice. `build.py` reads the source of the web page
(`content/posts/2022-12-02-jane-s-infinite-rosary/index.md`) and gives it
the form of a paper:

- an abstract, subject classes and keywords (in `build.py`);
- an introduction heading, and a paragraph on related work (`related.md`);
- numbered parts and sections, a table of contents;
- theorems, lemmas and proofs as LaTeX environments, with the numbers of
  the web page;
- a subtitle; three section titles and six sentences reworded for a
  paper; of the six quotations under the headings, only Bartleby's is
  kept;
- tables a size smaller, with column widths of their own where pandoc's
  guess does not fit; nearly square pictures narrower than the page;
- the figures with their captions; the links to the interactive figures,
  and the wording that only makes sense on the web, are removed;
- the history of the page as a list of versions. The declaration on the use
  of AI tools is a section of the page itself, reviewed by the author, and
  reaches the paper with the rest of the text.

`build.py` stops with an error when a passage it adapts is no longer in
the page, so a change of the page cannot silently leave the paper behind.

`to-port.md` keeps what a build does not settle: the choices left to the
author and the rules for the text written for the paper only.

Proposed arXiv categories: math.CO (primary), math.NT, math.DS.
