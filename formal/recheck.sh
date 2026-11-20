#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

# Replays compiled modules through Lean's kernel: recheck.sh PROJECT LIBDIR...
#
# Each LIBDIR is a directory of compiled modules (.../.lake/build/lib/lean).
# Every module found there is replayed with `leanchecker`, the kernel
# replay tool that comes with Lean, one module per call, run from PROJECT.
# Succeeds only if every module is accepted.  The list of results is left
# in PROJECT/recheck.log.  Mathlib is not replayed unless its directory is
# given.  Run inside `nix-shell formal/shell.nix`, after the build.
#
# RECHECK_SKIP may list modules to leave out, separated by spaces.  It is
# for the root modules that only import the others and declare nothing:
# on such a module leanchecker replays everything it imports, Mathlib
# included, and runs out of memory.
set -u

proj=$1
shift
mods=$(for d in "$@"; do
    (cd "$d" && find . -name '*.olean' | sed 's|^\./||; s|\.olean$||; s|/|.|g')
done | sort -u)
for skip in ${RECHECK_SKIP:-}; do
    mods=$(printf '%s\n' "$mods" | grep -vx "$skip")
done
n=$(printf '%s\n' "$mods" | grep -c .)

cd "$proj" || exit 2
printf '%s\n' "$mods" | xargs -P "$(nproc)" -I{} sh -c \
    'if lake env leanchecker "$1" > /dev/null 2>&1; then echo "ok $1"; else echo "FAIL $1"; fi' _ {} \
    | sort > recheck.log
ok=$(grep -c '^ok ' recheck.log)
fail=$(grep -c '^FAIL ' recheck.log)
echo "recheck: $ok of $n modules replayed by the kernel, $fail failed" | tee -a recheck.log
[ "$fail" -eq 0 ] && [ "$ok" -eq "$n" ]
