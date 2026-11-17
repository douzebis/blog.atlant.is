<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# 0001 — The build is offline and reproducible

**Spec:** `docs/specs/0001-static-site.md`

## Guarantee

Building the site makes no network access, and its output depends only on
the repository and on the inputs pinned in it: the nixpkgs revision
(`nix/nixpkgs.nix`) and the two MathJax archives with their hashes
(`site.nix`). Two builds of the same commit for the same address give the
same files, byte for byte.

## Why it holds

- `site.nix` is a plain Nix derivation. With the Nix sandbox enabled (the
  default on Linux, and on the GitHub runner) a derivation has no network.
- Everything fetched is a fixed-output derivation with a hash.
- Hugo runs without Git information (`enableGitInfo = false`) and writes
  no build date into the pages.

## Regression test

The Pages workflow builds the site, then builds it again with
`nix-build --check`, which fails when the second output differs from the
first (`.github/workflows/pages.yml`, step "Build it again and compare").

By hand:

```sh
nix-build site.nix && nix-build site.nix --check
```

## Limits

Without the sandbox (a machine configured with `sandbox = false`) Nix does
not prevent network access; nothing in the build uses it, but the
guarantee is then not enforced.
