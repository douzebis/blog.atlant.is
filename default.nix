# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

# Development shell: `nix-shell --run 'hugo server'` for a local preview.
{
  pkgs ? import ./nix/nixpkgs.nix,
}:

let
  # An MCP server that lets a coding assistant talk to Lean's language
  # server (goals at a position, diagnostics, lemma search):
  # github.com/oOo0oOo/lean-lsp-mcp, release 0.33.0, built from its own
  # flake at a fixed revision.  Left out where Nix has no flakes.
  leanLspMcp = pkgs.lib.optional (builtins ? getFlake) (builtins.getFlake
    "github:oOo0oOo/lean-lsp-mcp/7932203d79db213852db215835bd79c943bb99b0"
  ).packages.${pkgs.stdenv.hostPlatform.system}.default;
in
pkgs.mkShell {
  packages = leanLspMcp ++ [
    pkgs.hugo
    pkgs.nodejs
    pkgs.pandoc
    pkgs.python3
    pkgs.pyright
    pkgs.ruff
    pkgs.reuse
    # elan installs the Lean version that each project under formal/ names
    # in its `lean-toolchain` file; editors' Lean plugins start Lean through it.
    pkgs.elan
    # Used by lean-lsp-mcp for searches in the Lean sources.
    pkgs.ripgrep
  ];

  NIXSHELL_REPO = toString ./.;
}
