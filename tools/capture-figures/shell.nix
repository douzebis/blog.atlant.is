# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

# Tools and fonts for capture.sh.  The fonts matter: the figures use arrow
# symbols that a bare machine may not have.
with import ../../nix/nixpkgs.nix;
mkShell {
  packages = [
    chromium
    imagemagick
    pngquant
  ];
  FONTCONFIG_FILE = makeFontsConf {
    fontDirectories = [
      dejavu_fonts
      noto-fonts
      liberation_ttf
    ];
  };
}
