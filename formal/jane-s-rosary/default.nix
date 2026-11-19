# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

# Checks the formal proofs: `nix-build formal/jane-s-rosary`.
#
# The build fails if a proof does not check, if a proof is unfinished
# (`sorry`), or if a theorem depends on an axiom other than the three
# standard ones.  The result is the log of the check.
{
  pkgs ? import ../../nix/nixpkgs.nix,
}:

pkgs.runCommand "rosary-formal"
  {
    nativeBuildInputs = [ pkgs.lean4 ];
    src = pkgs.lib.cleanSourceWith {
      src = ./.;
      filter = path: _type: baseNameOf path != ".lake" && baseNameOf path != "lake-manifest.json";
    };
  }
  ''
    set -o pipefail
    export HOME=$TMPDIR
    cp -r $src work
    chmod -R u+w work
    cd work
    lake build 2>&1 | tee check.log
    if grep -n "sorry" check.log; then
      echo "unfinished proof"
      exit 1
    fi
    if ! grep -q "depends on axioms\|does not depend on any axioms" check.log; then
      echo "the audit printed nothing"
      exit 1
    fi
    if grep "depends on axioms" check.log \
        | sed -e 's/propext//g; s/Classical\.choice//g; s/Quot\.sound//g' \
        | grep -v "depends on axioms: \[[, ]*\]$"; then
      echo "a theorem depends on an unexpected axiom"
      exit 1
    fi
    mkdir $out
    cp check.log $out/
  ''
