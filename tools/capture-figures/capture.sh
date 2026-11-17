#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

# Take pictures of the interactive figures, for use as images in a post.
#
# The figures are those of this repository (./figures), so the pictures
# are taken from a local build of the site:
#
#   nix-build site.nix --argstr baseURL http://127.0.0.1:8000/
#   (cd result && python3 -m http.server 8000 --bind 127.0.0.1) &
#   nix-shell tools/capture-figures/shell.nix --run \
#     'tools/capture-figures/capture.sh http://127.0.0.1:8000/figures/ \
#        tools/capture-figures/jane-s-rosary.tsv \
#        content/posts/2022-12-02-jane-s-infinite-rosary/images'
#
# usage: capture.sh BASE LIST.tsv OUTDIR
#
# LIST.tsv has one figure per line: number, address relative to BASE, pixel
# scale (tab separated).  Each figure is opened in a headless browser 760
# CSS pixels wide, once per theme, captured at the given scale (2 for most
# figures, more for very wide ones), trimmed to its content with a small
# margin, and written as OUTDIR/figure-NN.png (light) and
# OUTDIR/figure-NN-dark.png (dark).
#
# This is a one-off tool, not part of the site build.
set -euo pipefail

base=$1
list=$2
out=$3
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

while IFS=$'\t' read -r number address scale; do
  for theme in light dark; do
    case $theme in
      light) suffix="" ;;
      dark) suffix="-dark" ;;
    esac
    case $address in
      *\?*) url="$base$address&theme=$theme" ;;
      *) url="$base$address?theme=$theme" ;;
    esac
    name=$(printf 'figure-%02d%s.png' "$number" "$suffix")
    chromium --headless=new --no-sandbox --disable-gpu --hide-scrollbars \
      --force-device-scale-factor="$scale" --window-size=760,760 \
      --virtual-time-budget=15000 --screenshot="$work/raw.png" "$url" \
      >/dev/null 2>&1
    # The margin takes the color of the figure's own background (its
    # top-left pixel), which is the background of the blog's pages.
    background=$(magick "$work/raw.png" -format '%[pixel:p{0,0}]' info:)
    magick "$work/raw.png" -trim +repage -bordercolor "$background" \
      -border $((8 * scale)) -strip "$work/trimmed.png"
    pngquant --force --quality 80-98 --strip --output "$out/$name" "$work/trimmed.png"
    echo "$name $(magick identify -format '%wx%h' "$out/$name")"
  done
done < "$list"
