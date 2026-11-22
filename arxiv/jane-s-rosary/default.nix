# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

# The LaTeX version of the paper and its PDF: `nix-build arxiv/jane-s-rosary`.
#
# The result holds paper.pdf, and arxiv-source.tar.gz with what arXiv needs
# (paper.tex and the figures).
#
# The build fails if a line is overfull or a reference is undefined, and the
# `paper` job of .github/workflows/pages.yml runs it at each push.
{
  pkgs ? import ../../nix/nixpkgs.nix,
}:

pkgs.runCommand "jane-s-rosary-arxiv"
  {
    nativeBuildInputs = [
      pkgs.python3
      pkgs.pandoc
      pkgs.librsvg
      pkgs.texlive.combined.scheme-medium
    ];
    post = ../../content/posts/2022-12-02-jane-s-infinite-rosary;
    builder_py = ./build.py;
    related = ./related.md;
  }
  ''
    export HOME=$TMPDIR
    # build.py finds related.md next to itself in the repository layout
    mkdir -p repo/content/posts repo/arxiv/jane-s-rosary
    cp -r $post repo/content/posts/2022-12-02-jane-s-infinite-rosary
    cp $related repo/arxiv/jane-s-rosary/related.md
    python3 $builder_py repo/content/posts/2022-12-02-jane-s-infinite-rosary src
    cd src
    for pass in 1 2 3; do
      pdflatex -interaction=nonstopmode -halt-on-error paper.tex > pdflatex.log \
        || { tail -40 pdflatex.log; exit 1; }
    done
    # A line that sticks out of the page, or a reference that leads nowhere,
    # stops the build: the page changed in a way the paper does not take.
    if grep -E "Overfull|undefined" pdflatex.log; then
      echo "paper: the lines above must be fixed"
      exit 1
    fi
    echo "paper: no overfull line, no undefined reference"
    mkdir $out
    cp paper.pdf $out/
    rm -f paper.aux paper.log paper.out pdflatex.log paper.pdf
    tar czf $out/arxiv-source.tar.gz .
  ''
