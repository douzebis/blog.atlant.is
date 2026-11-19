# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

# The tools for the Lean projects that use Mathlib:
# `nix-shell formal/shell.nix`.
#
# elan installs the Lean version named in a project's `lean-toolchain`
# file; Lean's build tool then fetches Mathlib as pinned in the project's
# `lake-manifest.json`.  Both come from the network, which is why these
# projects are checked outside the Nix sandbox.
{
  pkgs ? import ../nix/nixpkgs.nix,
}:

pkgs.mkShell {
  packages = [
    pkgs.elan
    pkgs.git
    pkgs.curl
    pkgs.cacert
  ];
}
