<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# 0001 — Static site for the blog, starting with Jane's rosary

**Status:** in-progress
**App:** site
**Implemented in:** <!-- YYYY-MM-DD, fill after implementation -->

## Problem

The blog at `blog.douzeb.is` runs on WordPress. Its content exists as a
Markdown export (`douzebis/blog.atlant.is-import`: 80 posts, one directory
per post with an `index.md` and its attachments), and the interactive
figures live in separate repositories that are already served by GitHub
Pages (`douzebis/jane-s-rosary`, `douzebis/hats`).

There is no way to build the blog from sources kept in Git, and the revised
paper *Jane's infinite rosary* (`jane-s-infinite-rosary.md`, 957 lines, 29
display equations, 5 tables, 8 links to interactive figures, one image)
exists only as a Markdown file that no site publishes.

## Goals

- A static site, built from sources committed to Git. Its final home is
  `blog.atlant.is`, self-hosted. Until then it is published on GitHub
  Pages as a preview.
- The built site is a plain directory of files that any web server can
  serve from any address: the address is a build argument, and nothing in
  the sources depends on GitHub Pages.
- One command builds the whole site with Nix, without network access
  during the build, from a pinned nixpkgs revision. The same sources and
  revision give the same output.
- Mathematics rendered with MathJax, served from the site itself (no
  third-party CDN at view time).
- First content: the revised *Jane's infinite rosary*, complete: formulas,
  equation tags, tables, image, links to the interactive figures,
  references, appendix.
- The source of a post stays readable Markdown: it renders acceptably on
  GitHub's own Markdown view, and does not depend on generator-specific
  markup for its mathematical content.
- A layout and a set of features into which the other exported posts can
  be moved later without restructuring. The features they need are listed
  under "What the other posts need"; this spec provides the ones marked
  "now" and reserves the others.
- The source of a paper stays convertible to LaTeX (with Pandoc), so that
  an arXiv version of the rosary and hats papers can be produced from the
  same file later.
- A failed formula or a broken internal link fails the build, not the
  reader.

## Non-goals

- Importing the other posts. This spec only makes sure the layout allows
  it. Imports are done by hand, post by post, as a one-off that also
  cleans and improves the source (see "Import policy").
- Producing the arXiv versions (LaTeX, PDF). This spec only keeps the
  sources convertible.
- Comments, search, newsletter.
- A tracking script in the pages. View statistics: see "Open questions".
- Changing what the interactive figures show. Their code is kept in this
  repository and gets a light and a dark theme (see "Figures").
- Decommissioning WordPress, setting up the self-hosted server and
  switching the domain.
- PDF output of the papers.

## Specification

### Repository

The site lives in the repository `douzebis/blog.atlant.is` (public, empty
before this work). Layout:

```
default.nix            # nix-shell (hugo, linters, reuse) and NIXSHELL_REPO
site.nix               # derivation that builds the site
nix/nixpkgs.nix        # the pinned package set
hugo.toml
data/mathjax.json      # MathJax's TeX settings (pages and formula check)
tools/                 # build checks and their tests, figure capture
figures/               # code of the interactive figures
content/
  posts/
    2022-12-02-jane-s-infinite-rosary/
      index.md
      images/reluctant-jane-1024x422.png
layouts/               # the site's own templates, no external theme
assets/                # style sheet
static/                # files copied as is
docs/specs/, docs/invariants/
```

The post directories keep the names of the export
(`YYYY-MM-DD-slug/index.md`), which is Hugo's "page bundle" layout:
attachments sit next to the text and are referenced by relative path.

### Generator

Hugo (extended edition), the version of the pinned nixpkgs revision, at
least 0.132. Reasons: the export is already in Hugo's layout and front
matter; one binary packaged in nixpkgs; taxonomies, feeds and several
languages are built in, and the blog has posts in French and in English.

Templates are written for this site and kept in `layouts/` (a few files:
base, single post, list, partials for head and math). No theme is fetched
at build time and no Git submodule is used.

### Source format

CommonMark as implemented by Hugo's Goldmark, with these extensions and no
others:

- front matter in YAML: `title`, `date`, `language` (`en` or `fr`), and
  optionally `categories`, `revised`, `math`, `diagrams`, `draft`,
  `wordpress_id`
  (the key cannot be `lang`, which Hugo reserves);
- pipe tables, footnotes, heading identifiers;
- mathematics between `$...$` (inline) and `$$...$$` (display), protected
  from Markdown processing by Goldmark's "passthrough" extension, so that
  underscores, backslashes and asterisks inside formulas reach MathJax
  unchanged.

Raw HTML in Markdown is allowed (Hugo's `unsafe` renderer option), because
the export uses it.

Shortcodes are allowed for presentation only (for example an embedded
figure), never for mathematical content. A post that uses none is the
normal case; the rosary paper uses none.

Rules for mathematics, so that the same source works with MathJax and
with LaTeX:

- only commands of LaTeX with `amsmath`, `amssymb`, `amsthm` and `amscd`
  (commutative diagrams, `\begin{CD}`); no MathJax-only extension and no
  `\require`;
- macros of a post are defined once, in a block that both MathJax and
  Pandoc read (`\newcommand` in a math block at the top of the post);
- an equation that is referred to is written as an `equation` or `align`
  environment with a `\label` and cited with `\eqref`, so that numbering
  is automatic; hand-written `\tag` numbers are not used for this (a
  `\tag{$\ast$}` mark for a reference within one proof is fine);
- no Unicode symbols inside formulas where a LaTeX command exists.

### Mathematics

- MathJax 4, loaded only on pages whose front matter has `math: true`.
- The MathJax files are part of the site: fetched by Nix as a fixed-hash
  source and copied into the output. Pages make no request to another
  host for them.
- Configuration: TeX input with the `ams` package and `tags: 'ams'`, so
  that `equation` and `align` environments are numbered and `\label`,
  `\ref`, `\eqref` work (the first hats post has 34 `equation`
  environments, 9 labels and 10 references), while `$$...$$` stays
  unnumbered unless it carries an explicit `\tag` (the rosary paper).
  Inline delimiters `$...$` and `\(...\)`, display delimiters `$$...$$`
  and `\[...\]`; LaTeX environments are written inside `$$...$$`. CHTML
  output with the fonts served from the site.
- In the page a formula is ordinary text: the template for formulas
  (`layouts/_markup/render-passthrough.html`) escapes its `<`, `>` and
  `&`, and writes it between `\(...\)` or `\[...\]`. Without the
  escaping, a formula such as `a<b` would be cut by the browser.
- A displayed formula wider than the text is broken across lines by
  MathJax (`displayOverflow: linebreak`); a formula inside a paragraph may
  break at its operators; a formula in a table cell never breaks.
- A table wider than the text scrolls inside its own box. A table that
  does not fit the text width on a desktop screen should be reworked in
  the source (in the rosary paper, the table of Lemma 1 became
  commutative diagrams).
- A page with `math: true` shows a short notice when JavaScript is off.

### Build

- `nix-build site.nix` produces the site in `./result`. The build runs
  `hugo` with the address given as an argument (`baseURL`), then the
  checks below. Build logs are teed to `/tmp` when run by hand. The HTML
  is not minified: the formula check needs complete HTML, and readable
  pages are easier to debug.
- `nix-shell --run 'hugo server'` gives a local preview of the text
  (without MathJax, which only the Nix build copies into the site).
- Checks, run inside the build:
  1. every formula of every page with `math: true` is found and read by
     MathJax (Node, same MathJax version and settings as the pages) and
     must convert without error; unknown commands, references to
     undefined labels, `\require`, and TeX left in the text outside any
     formula are errors (`tools/check_math.cjs`);
  2. every internal link and every referenced image resolves to a file of
     the output, fragments included, and no page or style sheet loads
     anything from another host (`tools/check_site.py`);
  3. Hugo runs with warnings treated as errors where it supports it
     (`--panicOnWarning`);
  4. every post with `math: true` is converted by Pandoc to LaTeX without
     warning (conversion only; nothing is compiled;
     `tools/check_latex.py`).
- The checks have their own tests (`tools/test_checks.py`), run at the
  start of every build.
- nixpkgs is pinned by revision and hash in `default.nix`, as in
  `levine-hats`.

### Figures

- A figure is a picture in the post's directory, written in plain
  Markdown as an image that links to the live version, followed by its
  caption:
  `[![Figure 1](images/figure-01.png)](https://blog.atlant.is/figures/...)`.
  The source therefore works on GitHub and converts to LaTeX as a picture.
- The code of the interactive figures lives in this repository, under
  `figures/<name>/` (HTML and JavaScript; `figures/jane-s-rosary/` was
  imported from `douzebis/jane-s-rosary`, which is left as it was). The
  build copies `figures/` into the site, so the live versions are served
  at `/figures/<name>/`.
- The libraries the figures use are not in the repository. The build
  fetches them at fixed versions, each with a hash (`site.nix`), and puts
  them in `/figures/lib/`, where the figure pages load them: vis-network
  10.1.5 (654 kB), jQuery 3.6.1 (90 kB), uPlot 1.6.7 (38 kB).
- The posts name a figure by its address on the final site
  (`https://blog.atlant.is/figures/...`); the link template rewrites it to
  the copy in the site being built (`hugo.toml`, `params.localCopies`).
  Until the final site exists, these links only work in a build.
- Themes. The figure pages have a light and a dark variant, chosen by
  `theme=light` or `theme=dark` in the address, else by the reader's
  system setting; their backgrounds are those of the site's pages. Each
  picture exists in both variants (`figure-01.png`,
  `figure-01-dark.png`) and the image template shows the one that suits
  the reader's theme (any image `name.ext` with a sibling
  `name-dark.ext`). An image on a white background without a dark
  variant can be listed in the post's `diagrams` front matter; it is then
  dimmed in dark mode.
- Pictures are taken once from a local build with
  `tools/capture-figures/capture.sh` (headless browser, both themes, twice
  the screen resolution, fonts provided by its `shell.nix`) and committed.
  The list of figures of a post is kept next to the tool
  (`tools/capture-figures/jane-s-rosary.tsv`).
- Not done, possible later: showing a live figure in the page itself when
  the reader clicks its picture, for the figures where zooming matters
  (the plot of heights, the onyx ordering).

### Languages

Each post states its language in `language`. The page's `<html lang>`
attribute, hyphenation and the date format follow it. There is one list of
posts and one feed for the whole site; the few interface words (dates,
"revised on", navigation) follow the language of the page shown, and the
home page is in English. No `/fr/` and `/en/` trees.

### Publication

Preview: a GitHub Actions workflow on the default branch installs Nix,
runs `nix-build site.nix` with the preview address, and publishes
`./result` with the official Pages actions (`upload-pages-artifact`,
`deploy-pages`). No built file is committed to the repository.

Final hosting (outside this spec): `site.nix` takes the address as an
argument, so a NixOS web server can use the derivation's output directly
as the document root of `blog.atlant.is`.

### The rosary paper

- `jane-s-infinite-rosary.md` becomes
  `content/posts/2022-12-02-jane-s-infinite-rosary/index.md`, with
  `math: true` and `language: en` added to the front matter, and the changes
  that the rules for mathematics require, if any (its two `\tag{$\ast$}`
  marks are local to a proof and stay). Any other change to the text is
  listed in the commit message.
- Its image is added to the bundle (`images/reluctant-jane-1024x422.png`,
  taken from the export repository).
- Its eleven figures are pictures, each linking to its live version (see
  "Figures").
- Acceptance: the built page is compared by eye with GitHub's rendering of
  the same file, section by section; all 29 display equations, both
  `\tag`s and the five tables render; the page is readable at phone width
  without horizontal scrolling of the text (wide tables and formulas may
  scroll inside their own box).

### What the other posts need

From a survey of the 79 exported posts (2026-11-17). "Now" means provided
by this spec; "import" means left to the spec that imports those posts.

| Need | Where | When |
|---|---|---|
| `$` math, `equation`/`align` with numbers, `\label`/`\ref` | 9 posts, mainly hats 1/3 (437 inline formulas) | now (MathJax settings) |
| Formulas un-escaped: the export wrote `\\mathbb`, `\_`, `\[` inside math | all posts with math | import (one-time conversion) |
| Images downloaded into the post's directory | 113 files, referenced at `blog.atlant.is/wp-content/...`; retrievable today from `blog.douzeb.is` | import |
| Caption under an image (a plain paragraph in the export) | most posts | import (figure shortcode, reserved) |
| Embedded page (`[auto-iframe]`, 6 uses; target host renamed to `douzebis.github.io`) | hats calculator, 15-puzzle, rosary (old version) | import (shortcode, reserved) |
| Citations and bibliography (`[zotpressInText]`, `[zotpressInTextBib]`, Zotero keys) | 4 posts | import (resolved once into a written reference list) |
| Footnotes (`[efn_note]`) | 15-puzzle | import (Markdown footnotes, enabled now) |
| Embedded PDF (`[pdfjs-viewer]`, 4 uses) | few posts | import (link to the file) |
| Links between posts (`blog.atlant.is/?p=1183#Operations_on_strategies`) | hats series and others | import (`wordpress_id` in the front matter is reserved for this and for redirects) |
| Language of the post (not recorded in the export) | all | import |
| Diagram sources (`.drawio`, `.latex` with a Makefile) | 15-puzzle, hats 3/3 | import (rendered images committed next to their sources) |
| `$` as a currency sign | 15-puzzle | import (escaped) |

The remaining posts (about 65) are short texts with one image and links,
24 of them linking to videos; they need nothing beyond plain Markdown.

### Import policy (for the later imports)

- Imports are manual and done once per post; there is no conversion
  program to maintain.
- At import a post is sanitized (export escapes removed, WordPress
  shortcodes replaced, images brought into its directory), cleaned up, and
  improved where it helps: spelling, automatic equation numbering, the
  rules for mathematics above, the known errors (for the hats posts, the
  list in `levine-hats/NOTES.md`, Section 1.2).
- Changes of substance are listed in the commit message of the import, so
  that the difference with the WordPress version stays traceable.

### Licensing

REUSE-compliant. Code and templates: MIT. Texts and the author's own
figures: CC BY 4.0, stated in the footer of every page. Images from third
parties are not covered; they are recorded as such in `REUSE.toml` when
imported. MathJax (Apache-2.0) is not vendored in the repository; it is a
build input.

## Invariants

- The build makes no network access and its output depends only on the
  repository and the pinned inputs
  (`docs/invariants/0001-build-is-reproducible-and-offline.md`; test: the
  workflow builds twice and compares with `nix-build --check`).
- A published page loads nothing from a third-party host
  (`docs/invariants/0002-no-third-party-requests.md`; tests in
  `tools/test_checks.py`, and the check runs on every build).

## Decisions (2026-11-17)

- Repository `douzebis/blog.atlant.is`; final address `blog.atlant.is`,
  self-hosted; GitHub Pages only as a preview.
- Hugo, with client-side MathJax served from the site.
- Theorems, proofs and references stay plain Markdown conventions, as in
  the rosary paper.
- Figures are pictures linking to live versions served by the site; the
  figure code is kept in this repository, with light and dark themes, and
  its libraries are pinned in the build (2026-11-17).
- One site with a language per post, no separate language trees.
- Old WordPress links (`?p=1183`) are a matter for the final server, which
  can redirect them; the front matter keeps the WordPress identifier.
- Texts under CC BY 4.0, code under MIT.
- Imports are manual, one-off, and include cleanup and improvement.
- arXiv versions of the rosary and hats papers are intended: sources stay
  LaTeX-compatible.

## State of the implementation (2026-11-17)

Done: repository skeleton, Nix build with the four checks and their tests,
templates and style sheet, the rosary paper as first post, workflow file
for the preview, both invariant documents.

Remaining before the status becomes `implemented`:

- (done 2026-11-17: first push, Pages source set to "GitHub Actions";
  the workflow built the site twice with identical output and published
  it at <https://douzebis.github.io/blog.atlant.is/>, where the page, its
  image, MathJax and the fonts are served and the formulas render;)
- the author's reading of the rendered paper against the source (a few
  regions were compared by eye on screenshots at 900 px and 390 px wide,
  not the whole page).

The header image is the author's own (confirmed 2026-11-17).

## Open questions

1. View statistics. Leaning: GoAccess on the server logs, possibly
   GoatCounter (which counts views but not time on page). Candidates: analysis of the web server's logs at the
   final host (GoAccess: no script, no cookie, nothing added to the
   pages); a small self-hosted counter on the same domain (GoatCounter,
   Plausible, Umami); the existing Matomo. Nothing is possible on the
   GitHub Pages preview without a third-party script.
2. Pre-rendering the formulas at build time, so that pages need no
   JavaScript (not planned; the build already checks every formula).

## References

- Export of the blog: <https://github.com/douzebis/blog.atlant.is-import>
- Interactive figures: <https://github.com/douzebis/jane-s-rosary>,
  <https://github.com/douzebis/hats>
- Hugo, mathematics in Markdown:
  <https://gohugo.io/content-management/mathematics/>
- MathJax documentation: <https://docs.mathjax.org/>
- GitHub Pages with a custom workflow:
  <https://docs.github.com/pages>
