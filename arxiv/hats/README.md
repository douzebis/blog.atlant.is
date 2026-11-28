<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# The paper on the game of hats

```sh
nix-build arxiv/hats 2>&1 | tee /tmp/hats-arxiv-build.log
```

gives `result/paper.pdf` and `result/arxiv-source.tar.gz` (`paper.tex`
and, in `anc/`, the tables of the bounds). The build fails on an overfull
line or an undefined reference.

Unlike the rosary paper, this one is written by hand, apart from the web
article (`docs/specs/0009-hats-paper.md`): when a result changes, both
have to be updated.
