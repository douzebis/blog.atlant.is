<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# 0004 — A formal proof that passes the check is complete

**Spec:** `docs/specs/0004-rosary-formal-verification.md`

## Guarantee

When `nix-build formal/jane-s-rosary` succeeds, every theorem of the Lean
project is proved from its stated hypotheses and from Lean's three
standard axioms (`propext`, `Classical.choice`, `Quot.sound`), and from
nothing else. In particular no proof is left unfinished and no assumption
is slipped in as an axiom.

## Why it holds

`formal/check.sh` builds the project and fails when:

- Lean rejects a proof;
- the build log mentions `sorry`, which Lean reports for every
  declaration that uses it;
- a `.lean` file declares an `axiom`;
- a theorem listed by `#print axioms` (file `Rosary/Audit.lean`) depends
  on an axiom other than the three standard ones, or nothing is listed at
  all.

## Regression test

`formal/test-check.sh`, run by `formal/jane-s-rosary/default.nix` before
the check itself: five tiny projects, of which the check must accept one
(a correct proof) and refuse four (an unfinished proof, a declared axiom,
a wrong proof, a project without audit).

## Limits

- The check says nothing about whether a Lean statement means what the
  paper says. That is reviewed by a human, statement by statement
  (`formal/jane-s-rosary/README.md`).
- `Audit.lean` lists the theorems named in the README table, by hand. A
  theorem missing from the list is still covered by the three other
  rules.
- Lean itself, and its kernel, are trusted.
