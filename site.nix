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

    python3 tools/check_site.py --base-url ${lib.escapeShellArg baseURL} public
    node tools/check_math.cjs vendor/node_modules data/mathjax.json public
    python3 tools/check_latex.py content
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
