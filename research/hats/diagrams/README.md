<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# Sources of the diagrams of "Infinitely Many Hats (3/3)"

The pictures of `content/posts/2020-09-26-infinitely-many-hats-3-3/images/`
were made in 2020 with a Makefile like this one: the automata from the
three `.latex` files, the trees with the `tikz` command of the hats
calculator (`figures/hats/hats.js`).

```sh
nix-shell -p nodejs gnumake ghostscript imagemagick \
  'texlive.combine { inherit (texlive) scheme-small standalone preview; }' \
  --run make
```

The `tikz` command of 2020 was lost with the version of the calculator that
had it. The one used here was written again in 2026 from the pictures. What
it gives was compared with them:

- the three automata come out with the same size, to the pixel;
- the six trees have the same nodes, the same numbers and the same gray
  nodes; the labels of the edges sit a little differently and the pictures
  are about 2% less high.

The pictures in the post are still the ones of 2020, taken from the
WordPress blog.
