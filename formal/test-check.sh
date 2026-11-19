#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

# Regression tests of check.sh: test-check.sh
#
# Builds four tiny Lean projects in a temporary directory.  The check must
# accept the first and refuse the three others.
# (docs/invariants/0004-formal-proofs-are-complete.md)
set -u

here=$(cd "$(dirname "$0")" && pwd)
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
failures=0

project() { # project NAME BODY
    mkdir -p "$work/$1"
    printf 'name = "t"\ndefaultTargets = ["T"]\n\n[[lean_lib]]\nname = "T"\n' \
        > "$work/$1/lakefile.toml"
    printf '%s\n' "$2" > "$work/$1/T.lean"
}

expect() { # expect NAME pass|fail
    if bash "$here/check.sh" "$work/$1" > "$work/$1.out" 2>&1; then
        got=pass
    else
        got=fail
    fi
    if [ "$got" = "$2" ]; then
        echo "test-check: $1: ok ($got)"
    else
        echo "test-check: $1: expected $2, got $got"
        cat "$work/$1.out"
        failures=$((failures + 1))
    fi
}

project good 'theorem t (n : Nat) : n + 0 = n := by omega
#print axioms t'
expect good pass

project unfinished 'theorem t (n : Nat) : n + 1 = n := by sorry
#print axioms t'
expect unfinished fail

project axiom 'axiom wish (n : Nat) : n + 1 = n
theorem t (n : Nat) : n + 1 = n := wish n
#print axioms t'
expect axiom fail

project wrong 'theorem t (n : Nat) : n + 1 = n := by omega
#print axioms t'
expect wrong fail

project silent 'theorem t (n : Nat) : n + 0 = n := by omega'
expect silent fail

[ "$failures" -eq 0 ]
