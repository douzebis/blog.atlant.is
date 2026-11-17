#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

# Take pictures of interactive figures, for use as static images in a post.
#
# usage: nix-shell tools/capture-figures/shell.nix --run \
#          'tools/capture-figures/capture.sh LIST.tsv OUTDIR'
#
# LIST.tsv has one figure per line: number, address, pixel scale (tab
# separated).  Each figure is opened in a headless browser 760 CSS pixels
# wide, captured at the given scale (2 for most figures, more for very
# wide ones), trimmed to its content with a small white margin, and
# written as OUTDIR/figure-NN.png.
#
# This is a one-off tool, not part of the site build: it needs network
# access when the addresses are remote.
set -euo pipefail

list=$1
out=$2
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

while IFS=$'\t' read -r number url scale; do
  name=$(printf 'figure-%02d.png' "$number")
  chromium --headless=new --no-sandbox --disable-gpu --hide-scrollbars \
    --force-device-scale-factor="$scale" --window-size=760,760 \
    --virtual-time-budget=15000 --screenshot="$work/raw.png" "$url" \
    >/dev/null 2>&1
  magick "$work/raw.png" -trim +repage -bordercolor white \
    -border $((8 * scale)) -strip "$work/trimmed.png"
  pngquant --force --quality 80-98 --strip --output "$out/$name" "$work/trimmed.png"
  echo "$name $(magick identify -format '%wx%h' "$out/$name")"
done < "$list"
