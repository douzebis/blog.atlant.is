# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

# Checks the formal proofs: `nix-build formal/jane-s-rosary`.
#
# The build first runs the regression tests of the check
# (../test-check.sh), then the check itself (../check.sh): it fails if a
# proof is not accepted, if a proof is unfinished (`sorry`), if a file
# declares an axiom, or if a theorem depends on an axiom other than the
# three standard ones.  The result is the log of the check.
{
  pkgs ? import ../../nix/nixpkgs.nix,
}:

pkgs.runCommand "rosary-formal"
  {
    nativeBuildInputs = [ pkgs.lean4 ];
    src = pkgs.lib.cleanSourceWith {
      src = ./.;
      filter =
        path: _type:
        !(builtins.elem (baseNameOf path) [
          ".lake"
          "lake-manifest.json"
          "check.log"
        ]);
    };
    check = ../check.sh;
    testCheck = ../test-check.sh;
  }
  ''
    export HOME=$TMPDIR
    mkdir tools
    cp $check tools/check.sh
    cp $testCheck tools/test-check.sh
    bash tools/test-check.sh
    cp -r $src work
    chmod -R u+w work
    bash tools/check.sh work
    mkdir $out
    cp work/check.log $out/
  ''
