# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

# Development shell: `nix-shell --run 'hugo server'` for a local preview.
{
  pkgs ? import ./nix/nixpkgs.nix,
}:

pkgs.mkShell {
  packages = [
    pkgs.hugo
    pkgs.nodejs
    pkgs.pandoc
    pkgs.python3
    pkgs.pyright
    pkgs.ruff
    pkgs.reuse
  ];

  NIXSHELL_REPO = toString ./.;
}
