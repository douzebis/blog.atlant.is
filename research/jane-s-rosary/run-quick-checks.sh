#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

# Run all the quick checks of this directory (about half a minute).
# usage: nix-shell --run research/jane-s-rosary/run-quick-checks.sh
set -euo pipefail
cd "$(dirname "$0")"
for program in check_renumbering.py check_shortest.py check_reluctant.py check_onyx.py check_paper_code.py; do
  echo "== $program"
  python "$program"
done
echo "all quick checks passed"
