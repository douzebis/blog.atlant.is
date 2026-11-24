#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

# Checks the Lean project of the hats article: check-hats.sh
#
# Run inside `nix-shell formal/shell.nix` (or the shell of the repository).
# The project uses the Mathlib of the rosary project
# (formal/jane-s-rosary-real), which is fetched first if it is not there.
# Then the rules of check.sh apply.
set -eu -o pipefail

here=$(cd "$(dirname "$0")" && pwd)
( cd "$here/jane-s-rosary-real"
  lake exe cache get > cache.log 2>&1 || { tail -20 cache.log; exit 1; }
  rm -f cache.log )
bash "$here/check.sh" "$here/hats"
