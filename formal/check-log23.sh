#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

# Checks the third Lean project, which uses an external formalization:
# check-log23.sh
#
# Run inside `nix-shell formal/shell.nix`.  Fetches Lean, Mathlib and the
# pinned fork of github.com/rohitkrjha/log23-measure, compiles the 916
# modules of that formalization (about an hour on a clean machine), then
# applies the rules of check.sh.
set -eu -o pipefail

here=$(cd "$(dirname "$0")" && pwd)
cd "$here/jane-s-rosary-log23"
lake exe cache get > cache.log 2>&1 || { tail -20 cache.log; exit 1; }
rm -f cache.log
exec bash "$here/check.sh" "$here/jane-s-rosary-log23"
