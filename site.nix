# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

# Builds the site: `nix-build site.nix` gives it in ./result.
#
# baseURL is the address the site will be served from.  For the GitHub Pages
# preview:
#   nix-build site.nix --argstr baseURL https://douzebis.github.io/blog.atlant.is/
{
  pkgs ? import ./nix/nixpkgs.nix,
  baseURL ? "https://blog.atlant.is/",
}:

let
  lib = pkgs.lib;

  # MathJax and its default font, as published on the npm registry.  They
  # are build inputs with fixed hashes; the site serves its own copy.
  mathjaxVersion = "4.1.3";
  mathjax = pkgs.fetchurl {
    url = "https://registry.npmjs.org/mathjax/-/mathjax-${mathjaxVersion}.tgz";
    hash = "sha256-txCfUW89hC3mK5XWU+NfoJdtwiNwaip3RA5/dyPwxU0=";
  };
  mathjaxFont = pkgs.fetchurl {
    url = "https://registry.npmjs.org/@mathjax/mathjax-newcm-font/-/mathjax-newcm-font-${mathjaxVersion}.tgz";
    hash = "sha256-h9e4acaiphadmlOsxOq2yEapy+EXUnOCJkYbtQcMi4g=";
  };

  # The libraries used by the interactive figures (./figures).  The figure
  # pages load them from ../lib/, where the build puts the versions below,
  # so that the site serves everything itself.  The figures were written
  # against "the latest" vis-network; 10.1.5 is the version their pictures
  # in the posts were taken with (2026-11-17).  Only the one file needed is
  # fetched (the full package is 85 MB).
  visNetworkVersion = "10.1.5";
  visNetwork = pkgs.fetchurl {
    url = "https://unpkg.com/vis-network@${visNetworkVersion}/standalone/umd/vis-network.min.js";
    hash = "sha256-tCcyKtlT1wq3XRt5jruDSYY1AvJE4C3j4SpKt9/t3yw=";
  };
  jqueryVersion = "3.6.1";
  jquery = pkgs.fetchurl {
    url = "https://registry.npmjs.org/jquery/-/jquery-${jqueryVersion}.tgz";
    hash = "sha256-Br4Dr6VI3rz+9PV3OwRO0qms51QbTUIqjCjLs0mOkA8=";
  };
  uplotVersion = "1.6.7";
  uplot = pkgs.fetchurl {
    url = "https://registry.npmjs.org/uplot/-/uplot-${uplotVersion}.tgz";
    hash = "sha256-o9UNxA8+WascO0xeyRLJ+eVOU47uguw5oWX7I68a3fQ=";
  };
in
pkgs.stdenvNoCC.mkDerivation {
  name = "blog-atlant-is";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./hugo.toml
      ./content
      ./layouts
      ./assets
      ./data
      ./tools
      ./figures
      ./docs/papers/frozen-versions.sha256
    ];
  };

  nativeBuildInputs = [
    pkgs.hugo
    pkgs.nodejs
    pkgs.pandoc
    pkgs.python3
  ];

  buildPhase = ''
    runHook preBuild
    export HOME=$TMPDIR
    export HUGO_CACHEDIR=$TMPDIR/hugo-cache

    # MathJax laid out as node modules, for the formula check.
    mkdir -p vendor/node_modules/mathjax vendor/node_modules/@mathjax/mathjax-newcm-font
    tar -xzf ${mathjax} -C vendor/node_modules/mathjax --strip-components=1
    tar -xzf ${mathjaxFont} -C vendor/node_modules/@mathjax/mathjax-newcm-font --strip-components=1

    # No --minify: the pages stay readable, and the formula check below
    # needs HTML with all its tags.
    # The checks are tested before they are trusted.
    MATHJAX_MODULES=$PWD/vendor/node_modules python3 -m unittest tools/test_checks.py

    hugo --panicOnWarning --baseURL ${lib.escapeShellArg baseURL} --destination public

    # The files a browser needs, served by the site itself.
    mkdir -p public/mathjax public/mathjax-fonts/mathjax-newcm-font
    ( cd vendor/node_modules/mathjax
      cp -r LICENSE tex-chtml.js input output a11y sre ui "$OLDPWD/public/mathjax/" )
    ( cd vendor/node_modules/@mathjax/mathjax-newcm-font
      cp -r chtml.js chtml "$OLDPWD/public/mathjax-fonts/mathjax-newcm-font/" )

    # The interactive figures and their libraries (see the comment above).
    mkdir -p public/figures/lib vendor/jquery vendor/uplot
    cp -r figures/. public/figures/
    tar -xzf ${jquery} -C vendor/jquery --strip-components=1
    tar -xzf ${uplot} -C vendor/uplot --strip-components=1
    cp ${visNetwork} public/figures/lib/vis-network.min.js
    cp vendor/jquery/dist/jquery.min.js public/figures/lib/jquery.min.js
    cp vendor/jquery/LICENSE.txt public/figures/lib/jquery-LICENSE.txt
    cp vendor/uplot/dist/uPlot.iife.min.js public/figures/lib/uPlot.iife.min.js
    cp vendor/uplot/dist/uPlot.min.css public/figures/lib/uPlot.min.css
    cp vendor/uplot/LICENSE public/figures/lib/uPlot-LICENSE.txt
    printf '%s\n' \
      'vis-network ${visNetworkVersion}' 'jQuery ${jqueryVersion}' 'uPlot ${uplotVersion}' \
      > public/figures/lib/VERSIONS.txt

    python3 tools/check_site.py --base-url ${lib.escapeShellArg baseURL} public
    node tools/check_math.cjs vendor/node_modules data/mathjax.json public
    python3 tools/check_latex.py content
    python3 tools/check_numbers.py content
    python3 tools/check_frozen.py docs/papers/frozen-versions.sha256
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    cp -r public $out
    runHook postInstall
  '';

  # The output is a tree of files for a web server: nothing to patch.
  dontFixup = true;
}
