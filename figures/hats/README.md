# Hats Calculator

This is a toy JavaScript application for evaluating strategies for the _game of n hat_, as explained in this [blog article](https://blog.atlant.is/posts/2020-08-30-the-game-of-hats/).

Imported from <https://github.com/douzebis/hats> at commit
a7d108a7d603a9c75485b422d3fcdbd5f78fac03 (2022-11-11). Changes since:

- the link of `hats.html` to the article points into this site;
- `tikz([...])` draws the tree of the choices of a list of strategies as a
  LaTeX picture (written again in 2026; the version of 2020, which made
  the trees of the third article, was never published);
- `R3` is C3 double-reset by `R2`, as the first article defines it. It was
  `R2` double-reset by C3, another strategy, with win rate
  91672/262144 instead of 91744/262144.
- 2026-11-27, with the article "The game of hats"
  (`docs/specs/0007-hats-article.md`): black is the digit 1 and the color
  to point at, so nothing changes in what is computed, and the names
  follow: `wr`, `br`, `ws`, `bs` for the white and black resets and shifts
  (`lr`, `rr`, `ls`, `rs` still work), `B<n>` for the lowest black hat and
  `W<n>` for the lowest white hat (the two were exchanged); new: `sd`,
  the sibling double shift, and `dual`; the output says `w =` instead of
  `mu =`; `eval help` shows the help; the page has a title, a character
  set, a dark variant, and starts with the query `eval C3`.
- `research/hats/check_calculator.py` compares the calculator, run under
  Node.js, with the definitions of `research/hats/check_article.py`.
