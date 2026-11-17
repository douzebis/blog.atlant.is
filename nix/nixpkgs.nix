# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

# The package set, pinned to one nixpkgs revision so that every build uses
# the same tools wherever it runs.
import (fetchTarball {
  name = "source";
  url = "https://github.com/NixOS/nixpkgs/archive/c508844df6c28fa6dabc1b6af70f3ccbd65c5201.tar.gz";
  sha256 = "sha256-6e4Na3z008XpdVyOXgfasXIn1aN+z8AXFG+jXdQSyuI=";
}) { }
