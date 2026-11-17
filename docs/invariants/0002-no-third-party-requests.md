<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# 0002 — Pages load nothing from another host

**Spec:** `docs/specs/0001-static-site.md`

## Guarantee

Opening a page of the site makes the browser fetch files from the site's
own address only: no script, style sheet, font, image, frame or media from
another host. Ordinary links to other sites are not concerned; they load
nothing until the reader follows them.

## Why it holds

- The templates reference only files of the site.
- MathJax and its font are copied into the site by the build, and the page
  points MathJax at that copy (`layouts/_partials/math.html`: the script
  address and the `fonts` path).
- `tools/check_site.py`, run by every build, rejects any page or style
  sheet that loads something from another host.
- The interactive figures (`figures/`) load their libraries from
  `/figures/lib/`, where the build puts pinned copies (`site.nix`). The
  figure pages are pages of the site, so the check above covers them: a
  figure page that names another host makes the build fail.

## Regression tests

- `tools/test_checks.py`, class `CheckSite`, run by every build: a script,
  a protocol-relative script, an image, a style sheet, a font in CSS and a
  CSS import from another host each make the check fail.
- The check itself runs on the built site in `site.nix`.

## Limits

- The MathJax scripts are not scanned: they contain addresses of a public
  CDN as defaults, which the page's settings replace. That the settings
  are complete was verified by hand on 2026-11-17 with MathJax 4.1.3: a
  headless Chromium loading the rosary paper requested 25 files, all from
  the site (script, one TeX extension, 13 fonts, 2 font tables, the speech
  files). This must be repeated when MathJax is upgraded or when a post
  uses a MathJax feature that loads further files.
- Same manual verification for the figures on 2026-11-17: a headless
  Chromium loading a live figure from a local build requested files from
  the site only.
- A post that embeds a frame or a video from another host needs an
  explicit decision; the check will refuse it until then.
