# Interactive figures for "Jane's infinite rosary"

Imported from <https://github.com/douzebis/jane-s-rosary> at commit
`947bd74582e5ae7309160c69ef2521e4180de533` (2023-01-05), then changed here;
`git log -- figures/jane-s-rosary` shows the changes. The original
repository is left as it was.

The site build copies this directory to `/figures/jane-s-rosary/` and puts
the libraries the pages use next to it, in `/figures/lib/`, at versions
fixed in `site.nix` (vis-network, jQuery, uPlot). The pages therefore do
not work when opened straight from a checkout: build the site and serve it
(see the README at the root).

## Pages

Used by the paper, with `janestreet.js`:

| Page | Shows | Parameters |
|---|---|---|
| `rosary.html` | the rosary as a row of beads | `n`, `labels`, `arrows`, `below`, `end`, `string`, `colors`, `interactive` |
| `deconstructed.html` | the rosary as a grid, one up-chain per row | `n`, `width`, `height`, `ordering`, `label`, `color`, `arrows`, `below`, `columns`, `ink`, `hide`, `interactive` |
| `height-plot.html` | plot of the heights of beads | `n` |
| `irrational-log2-3.html` | multiples of log2(3) on the circle | `n`, `interactive` |
| `onyx-ordering.html` | the tree of the onyx ordering | `n`, `interactive` |
| `lattice.html` | up-chains on a logarithmic scale | `l`, `b` |

Older pages, used by the first version of the post, with `rosary-lib.js`:
`rosary-labels.html`, `telling-the-rosary.html`, `the-height-of.html`,
`reluctant-recitation.html`, and `unit-tests.html`, which shows several of
them.

## Numbering

The pages of the first group number the beads from 0 by default, as the
paper did until November 2026. `first=1` in the address shifts every
position displayed (and the numbers of the onyx tree) by one, as the
paper does since. The default must stay 0: the earlier versions of the
paper, which are never modified, link to these pages without the parameter
(a test in `tools/test_checks.py` checks the default).

## Themes

The pages of the first group have a light and a dark variant. `theme=light`
or `theme=dark` in the address chooses one; without it the reader's system
setting decides. The colors are defined once, in `THEME` at the top of
`janestreet.js`; the backgrounds are those of the blog's pages.

The older pages are light only.
