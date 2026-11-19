#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

# Checks a Lean project: check.sh DIR
#
# Succeeds only if every proof of the project is accepted by Lean, no proof
# is unfinished (`sorry`), no file declares an axiom, and the theorems
# listed by `#print axioms` rest on nothing but Lean's three standard
# axioms.  The log is left in DIR/check.log.
# (docs/invariants/0004-formal-proofs-are-complete.md)
set -u -o pipefail

cd "$1" || exit 2

if grep -rnE --include='*.lean' --exclude-dir=.lake '^[[:space:]]*(private |protected )?axiom[[:space:]]' .; then
    echo "check: a file declares an axiom"
    exit 1
fi

if ! lake build 2>&1 | tee check.log; then
    echo "check: a proof was not accepted"
    exit 1
fi

if grep -n "sorry" check.log; then
    echo "check: unfinished proof"
    exit 1
fi

if ! grep -q "depends on axioms\|does not depend on any axioms" check.log; then
    echo "check: the audit printed nothing"
    exit 1
fi

if grep "depends on axioms" check.log \
    | sed -e 's/propext//g; s/Classical\.choice//g; s/Quot\.sound//g' \
    | grep -v "depends on axioms: \[[, ]*\]$"; then
    echo "check: a theorem depends on an unexpected axiom"
    exit 1
fi

echo "check: ok"
