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

# The search program, compiled, and what it finds (Hats/SearchProgram.lean
# proves that these numbers are the most hits of a strategy).
cd "$here/hats"
lake build hats-search > /dev/null
[ "$(.lake/build/bin/hats-search 3 | head -1)" = "3 hats: the best strategies have 22 hits out of 64" ]
[ "$(.lake/build/bin/hats-search 4 4 | head -1)" = "4 hats: the best strategies have 89 hits out of 256" ]
echo "check: the search program finds 22 and 89"
