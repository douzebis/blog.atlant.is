<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# blog.atlant.is

Sources of the blog *Atlantis*, built as a static site with
[Hugo](https://gohugo.io/) and [MathJax](https://www.mathjax.org/).

## Build

```sh
nix-build site.nix 2>&1 | tee /tmp/site-build.log   # the site, in ./result
nix-shell --run 'hugo server'                      # local preview (see below)
```

`site.nix` takes the address the site is served from:

```sh
nix-build site.nix --argstr baseURL https://douzebis.github.io/blog.atlant.is/
```

The build runs without network access, from a pinned nixpkgs revision
(`nix/nixpkgs.nix`), and checks the result: links and images, requests to
other hosts, every formula (with MathJax), and conversion of the posts with
formulas to LaTeX (with Pandoc).

`hugo server` shows the pages without MathJax, which only the Nix build
copies into the site. To see the formulas rendered, serve a build:

```sh
nix-build site.nix --argstr baseURL http://127.0.0.1:8000/
(cd result && python3 -m http.server 8000 --bind 127.0.0.1)
```

## Layout

- `content/posts/YYYY-MM-DD-slug/index.md`: one directory per post, with
  its images next to the text.
- `layouts/`, `assets/`: the site's own templates and style sheet.
- `data/mathjax.json`: MathJax's TeX settings, shared by the pages and by
  the formula check.
- `tools/`: the build checks and their tests; `tools/capture-figures/`
  takes the pictures of interactive figures.
- `docs/specs/`, `docs/invariants/`: specifications and guarantees.

## Writing a post

Front matter: `title`, `date`, `language` (`en` or `fr`), and optionally
`revised`, `math: true`, `categories`, `draft`.

Formulas go between `$...$` and `$$...$$`, in plain LaTeX with the AMS
packages; see "Rules for mathematics" in
`docs/specs/0001-static-site.md`.

## Licenses

Code and templates: MIT. Texts and the author's own figures: CC BY 4.0.
Each file states its license ([REUSE](https://reuse.software/)).
