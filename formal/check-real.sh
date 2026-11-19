#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

# Checks the Lean project that uses Mathlib: check-real.sh
#
# Run inside `nix-shell formal/shell.nix`.  Needs the network the first
# time: Lean, Mathlib and Mathlib's prebuilt files are fetched, in the
# versions pinned by `lean-toolchain` and `lake-manifest.json`.  Then the
# same rules as for the first project apply (check.sh).
set -eu -o pipefail

here=$(cd "$(dirname "$0")" && pwd)
cd "$here/jane-s-rosary-real"
lake exe cache get > cache.log 2>&1 || { tail -20 cache.log; exit 1; }
rm -f cache.log
exec bash "$here/check.sh" "$here/jane-s-rosary-real"
