# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

# The paper on the game of hats and its PDF: `nix-build arxiv/hats`.
#
# The result holds paper.pdf, and arxiv-source.tar.gz with what arXiv and
# HAL need (paper.tex and the tables as ancillary files).
#
# The build fails if a line is overfull or a reference is undefined.
{
  pkgs ? import ../../nix/nixpkgs.nix,
}:

pkgs.runCommand "hats-arxiv"
  {
    nativeBuildInputs = [ pkgs.texlive.combined.scheme-medium ];
    paper = ./paper.tex;
    three = ../../research/hats/players/results;
    four = ../../research/hats/players4/results;
  }
  ''
    export HOME=$TMPDIR
    mkdir src
    cp $paper src/paper.tex
    cd src
    for pass in 1 2 3; do
      pdflatex -interaction=nonstopmode -halt-on-error paper.tex > pdflatex.log \
        || { tail -40 pdflatex.log; exit 1; }
    done
    if grep -E "Overfull|undefined" pdflatex.log; then
      echo "paper: the lines above must be fixed"
      exit 1
    fi
    echo "paper: no overfull line, no undefined reference"
    mkdir $out
    cp paper.pdf $out/
    rm -f paper.aux paper.log paper.out pdflatex.log paper.pdf
    mkdir anc
    cp $three/t6-73226.txt anc/three-players-6-hats-73226.txt
    cp $three/t7-586263.txt anc/three-players-7-hats-586263.txt
    cp $three/t8-4690902.txt anc/three-players-8-hats-4690902.txt
    cp $four/t3-886.txt anc/four-players-3-hats-886.txt
    cp $four/t4-15192.txt anc/four-players-4-hats-15192.txt
    tar czf $out/arxiv-source.tar.gz .
  ''
