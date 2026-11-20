<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# 0004 — Jane's infinite rosary: proofs checked by a proof assistant

**Status:** in-progress (plan approved 2026-11-19; steps 0 to 4 done, except Corollaries 2 and 3 and the logarithmic bound of Proposition 1)
**App:** blog.atlant.is (paper *Jane's infinite rosary*)
**Implemented in:** <!-- YYYY-MM-DD, fill after implementation -->

## Problem

The proofs of the paper have been read by their author and by Claude, and
its statements have been tested by programs on finitely many beads
(`research/jane-s-rosary`, "Checked by computer" in the paper). Neither is
a verification:

- a test on 60 000 beads says nothing about the others;
- the proofs were written, rewritten for the numbering from 1, and
  reread by the same two readers. Theorem 1 has an induction with four
  beads and two cases; Theorem 2 carries two invariants at once; Theorem 6
  counts blocks and moves. A slip there would not show in the tests.

A proof assistant checks every step of a proof mechanically. The author
has never used one.

## Goals

- The results of the paper that can reasonably be formalized are stated
  and proved in Lean 4, in `formal/jane-s-rosary/`, and one command checks
  them all.
- For each formalized statement, a reader of the paper can find the Lean
  statement and convince themselves that both say the same thing, without
  reading any proof.
- The paper says, statement by statement, what is formally verified, what
  is verified under a stated hypothesis, and what is not.
- The author can follow the work: the directory has a guide for a reader
  new to proof assistants, and each step is explained when it is
  delivered.
- If the formalization finds an error or a gap in the paper, the paper is
  corrected and the correction is recorded in its history.

## Non-goals

- Formalizing Baker's theorem or Rhin's irrationality measure of
  $\log_2 3$. Results that need them are proved under an explicit
  hypothesis (see step 6).
- The conjectures and questions of Section 12, and the numerical data.
- Verifying the programs of `research/jane-s-rosary` or the Python
  listings of the paper.
- Contributing to Mathlib.
- Following the paper's proofs line by line. The Lean proof of a
  statement may take another route when that is simpler; what must match
  is the statement.
- A second formalization in Rocq.

## Specification

### The tool

Lean 4, from the pinned nixpkgs (`nix/nixpkgs.nix`, Lean 4.29.1 today).

Reasons for Lean over Rocq: Theorems 3 and 5 need real logarithms and the
rotation of the circle, and Lean's mathematical library, Mathlib, is the
larger and the more uniform for that; one system for the whole paper is
better than two. For Part I alone the two would be equivalent.

Steps 0 to 3 use Lean alone, without any library. Step 4 onward needs
Mathlib (see Open questions for how to obtain it under Nix).

### Layout

```
formal/jane-s-rosary/
  README.md          the guide, with the table paper <-> Lean
  default.nix        the check
  lakefile.toml      the Lean project
  Rosary.lean        imports everything
  Rosary/Basic.lean      the definitions
  Rosary/Examples.lean   the paper's examples, computed
  Rosary/Fact1.lean, Lemma1.lean, Parity.lean, ...   one file per result or group
  Rosary/Audit.lean      the axioms behind each theorem
```

### Rules

1. **Definitions are few, in one place, and tested.** All the names of
   the paper are defined in `Basic.lean` (later definitions, such as the
   height or the reluctant recitation, in the file of the part that
   introduces them, and listed in the README). Each definition is
   followed, in `Examples.lean`, by the examples that the paper gives for
   it, computed by Lean.
2. **Statements mirror the paper.** Each theorem carries, as its comment,
   the statement of the paper. Where the Lean statement differs in form
   (hypothesis `1 ≤ n`, "there is" for "call it", "after every step there
   is a later one" for "infinitely often"), the README says how.
3. **No unfinished proof.** `sorry` is rejected by the check.
4. **No hidden assumption.** `Audit.lean` prints the axioms behind every
   theorem named in the README table; the check accepts only `propext`,
   `Classical.choice` and `Quot.sound`. A result proved under a
   mathematical hypothesis takes it as an explicit argument of the
   theorem, never as an `axiom`.
5. **One command.** `nix-build formal/jane-s-rosary` checks everything.
   It is run by the GitHub workflow of the site from step 1 on.
6. **The paper is the reference.** The Lean files follow the current
   text (beads counted from 1). When a statement of the paper changes,
   its Lean statement changes with it.

### Steps

Each step ends with the check passing, the README table extended, a
commit, and an explanation to the author of what was stated and how to
read it. The author's go-ahead is needed between steps.

| Step | Content | Needs | Size (guess) |
|---|---|---|---|
| 0 | Warm-up: definitions, Fact 1, Lemma 1, Lemmas 6 and 7; the guide; the check | Lean alone | done, 250 lines |
| 1 | Part I: height, Lemma 2, Corollary 1, Theorem 1, Proposition 1 (first two bounds); the fast algorithm computes the height | Lean alone | done 2026-11-19, 900 lines |
| 2 | Theorem 2: the reluctant recitation, Lemma 3, never stuck, injective, no gap | Lean alone | done 2026-11-19, 230 lines |
| 3 | Part III: Proposition 2, Lemma 8, Theorem 4, Corollaries 2 and 3 (Corollary 3 after step 4) | Lean alone, or Mathlib for infinite sets | Proposition 2, Lemma 8 and Theorem 4 done 2026-11-19, 300 lines, Lean alone; the corollaries remain |
| 4 | Theorem 3: every bead is told | Mathlib | done 2026-11-19, 330 lines, Lean alone, by another proof (see below); Lemmas 4 and 5 are not needed by it and are not formalized |
| 5 | Theorem 5, part 1, and $E = o(t)$ (part 2 without the square root) | Mathlib | 500 to 1 000 lines |
| 6 | Lemma 9, the square root of Theorem 5, Theorem 6, all under the hypothesis "$\mu_0$ is an irrationality exponent of $\log_2 3$" | Mathlib; the three-distance theorem or a cruder substitute | uncertain |

Notes on the steps:

- **Step 1** is the one with the best return: Theorem 1 is the most
  intricate elementary proof of the paper. The height is defined from the
  relation "bead $n$ is reached from bead 1 in $k$ moves", so that
  nothing in its definition presupposes the results. The logarithmic
  bound of Proposition 1 needs real logarithms and waits for step 4.
- **Step 2** defines $\rho$ as a function that is total by construction
  (when no fresh bead is below, move up) and proves that the up move is
  always to a fresh bead; this is how "well defined" is expressed.
- **Step 4** needs: $\log_2 3$ is irrational (immediate, $2^a \ne 3^b$);
  the estimates of Lemma 5; and a uniform covering time for the rotation
  by $\alpha$ (the integer $J$ of the proof). Whether Mathlib has the
  last one ready is to be checked at the start of the step; if not, it is
  proved by the pigeonhole principle.
- **Step 6** may be cut down or dropped after step 5. The three-distance
  theorem was formalized in Coq (Mayero, 2000) but, as far as we know, is
  not in Mathlib; Lemma 9 can be replaced by a covering time with a worse
  exponent, in which case the Lean theorem would have a different
  exponent than the paper's Theorem 6 and the paper would say so.

The sizes are guesses by someone who has not yet done the work; step 0
took 250 lines for results that the paper proves in 40.

### In the paper

From step 1 on, the section "Checked by computer" gains a paragraph and a
table "Checked by a proof assistant": statement, Lean name with a link,
and the hypothesis if any. The history of the paper gets one entry when
the first theorem is verified, not one per step.

## Invariants

- `docs/invariants/0004-formal-proofs-are-complete.md`: the check accepts
  no unfinished proof, no declared axiom and no theorem resting on an
  axiom beyond the three standard ones. Regression tests:
  `formal/test-check.sh`, run by every check.

## As implemented

- **Step 1.** Proposition 2 is about the onyx predecessor, which Part III
  defines; it moved to step 3. Theorem 1 is proved by the paper's
  argument, organized differently: one lemma (`ladder_step`) walks the two
  ladders rung by rung, by induction on the bead, inside the induction on
  the height. No error was found in the paper's proofs of Part I.
- **Step 2.** The proof of Theorem 2 is the paper's, with the same
  invariant (a new bead at each move; no gap at all earlier times). No
  error was found.
- **Step 3.** Proposition 2 is proved without `e` and `q`, by following
  the two neighbors back as in part 3 of Theorem 1. Lemma 8 is stated as
  a bound on the steps at which the two chains are neighbors, and its
  count (`1 + v2(a + 1)`) as `gap_one_iff`. Theorem 4 is the paper's
  proof. Corollary 2 (the address is a bijection onto finite sequences)
  is not done: it needs the ranks of the covers and lists, about as much
  text as Theorem 4, for a statement the paper proves in one line.
  Corollary 3 needs Theorem 3. No error was found.
- **Step 4.** Mathlib could not be installed: the shared host had 6 GB of
  free disk when the step started, less than Mathlib needs. Looking for a
  way without real numbers led to a different proof of Theorem 3, which
  uses integers only: the beads never told are closed under doubling and
  tripling of intervals, and the intervals `[m s, (m + 1) s)` with
  `s = 2^e 3^j` cover all large integers (`Rosary/Theorem3.lean`, and the
  README). It is shorter than the plan expected, needs no library, and
  has no error terms. It gives no bound on the time at which a bead is
  told, so it does not replace the paper's proof as the starting point of
  Part IV. What remains (the logarithmic bound of Proposition 1, Lemmas 4
  and 5, Theorems 5 and 6) does need real logarithms, hence Mathlib.
- **Mathlib (2026-11-19).** The author added disk space and asked for
  the paper's own proof of Theorem 3 to be verified too, not only the
  integer one. Mathlib is installed in a second project,
  `formal/jane-s-rosary-real/`, which depends on the first (by path) and
  on Mathlib, pinned in its `lake-manifest.json` (at first at tag `v4.29.1`; see below). Lean
  comes from `elan` for that project, in the version named by its
  `lean-toolchain` file, the same 4.29.1 as the Nix one, so that
  Mathlib's prebuilt files are used and nothing is compiled. Tools:
  `nix-shell formal/shell.nix`. The first project stays free of any
  library and keeps its pure Nix check.
- **Theorem 3, the paper's proof (2026-11-19).** Verified in the second
  project: Lemma 5 (with Lemma 4 inside its second part), the
  irrationality of log2 3, the uniform covering time of the rotation
  (from Dirichlet's approximation theorem, which Mathlib has), Steps 1
  to 4. One device differs from the paper's wording: instead of naming
  Jane's positions "right after her j-th up move", the proof keeps, at
  every time, the bead she reached by her last up move and the number of
  up moves so far (`phase_track`). No error was found. The errors of
  Lemma 5 are stated with "at most" where the paper has "less than".
  Check: `nix-shell formal/shell.nix --run "bash formal/check-real.sh"`;
  a job of the workflow runs it.
- **Proposition 1, the logarithmic bound (2026-11-19)**: `height_log`,
  in the second project, by the paper's induction on `n - 7`.
- **Theorem 5, part 1 (2026-11-19)**: `theorem5_part1`, by the paper's
  proof. The sum of 1/rho(s) over t different times is bounded by the
  harmonic sum (`sum_inv_le`), which is the paper's "since rho is
  injective".
- **Lean 4.34.1 for the Mathlib project (2026-11-19).** The second
  project moved from Lean 4.29.1 to 4.34.1 and to Mathlib revision
  `d13f23b7`, the versions used by an external Lean proof that the
  irrationality exponent of log 3 / log 2 is at most 3
  (github.com/rohitkrjha/log23-measure), so that one project can use both.
  Nothing had to be changed in the proofs. The first project is still
  checked by Nix with Lean 4.29.1, and is also compiled by the second with
  4.34.1: its files must compile under both. Under 4.34.1 they give
  deprecation warnings for `if_pos`, `if_neg` and `dif_pos`, names kept
  because the replacements do not exist in 4.29.1.
- **Lemma 9 and Theorem 6 (2026-11-20)**, in conditional form: the
  hypothesis "mu0 is an irrationality exponent of log2 3, with constant
  c" is an argument of the theorems (`IrrationalityExponent`,
  `BadlyApproximable`), not an axiom. `theorem6_exponent` has the paper's
  exponent 2 mu0 - 1. Lemma 9 is proved without the three-distance
  theorem and without continued fractions: a fraction P/Q in lowest
  terms close to alpha (Dirichlet), the points i alpha for i < Q are
  within 1/Q of the multiples of 1/Q, and Q is large because alpha is
  badly approximable. This gives J <= (4/w)^nu / c + 1, with the paper's
  exponent and a constant 4 where the paper has 2. Theorem 6 follows the
  paper (excursions above N, counting the visits below N); its constant
  differs: i <= 4 (N + 1)(J + 1). The bound on F(t) is not done.
- **Theorem 6 without a hypothesis (2026-11-20).** A third project,
  `formal/jane-s-rosary-log23/`, depends on the second and on Rohit Kumar
  Jha's formalization of the bound 3 on the irrationality exponent of
  log 3 / log 2, fetched from the fork `github.com/douzebis/log23-measure`
  at a pinned commit (the upstream commit plus a two-line change of
  `lakefile.toml` without which a clean clone does not build). The fork
  also keeps a copy of that work. The project contains only the bridge
  (`irrationalityExponent_log23`: every mu > 3 is an irrationality
  exponent of log2 3, for some constant) and `theorem6_log23`: every bead
  m is told within kappa m^(5 + 2 eps) moves. The bound on log 3 / log 2
  is Jha's result. Check: `nix-shell formal/shell.nix --run "bash
  formal/check-log23.sh"`, and the workflow `formal-log23`, run on demand
  (about an hour). Record of the reproduction of the external proof:
  `docs/papers/jane-s-rosary/log23-reproduction.md`.
- **Attestations.** The formal jobs of the workflows upload the log of
  the check and ask GitHub to sign that the run, at its commit, produced
  that log (`gh attestation verify`).
- `formal/check.sh` reads axiom lists that are printed over several
  lines (Lean wraps long names); a regression test covers it.
- **The three-distance theorem (2026-11-20)**, at the author's request,
  for its own sake: `ThreeDistance.three_distance` in the second project,
  for an irrational alpha and N >= 2 points. With A the smallest step
  forward (at k = a) and B the smallest step backward (at k = b) among
  1 <= k < N: a + b >= N, and the arc that starts at the point i alpha
  has length A if i + a < N, B if b <= i, and A + B otherwise. The proof
  is elementary (adding two steps, four comparisons). Lemma 9 does not
  use it yet: getting the paper's constant 2 from it also needs the fact
  that the denominators of the convergents are best approximations,
  which Mathlib does not seem to have.
- **Lemma 9 by the paper's proof (2026-11-20)**: `lemma9_three`, with
  the paper's bound J <= (2/w)^nu / c, from the three-distance theorem.
  One point differs from the paper's wording. The paper takes "the
  denominators q_k of the convergents of alpha" and uses that they are
  best approximations. The Lean proof takes the best approximations
  themselves (q such that ||q alpha|| < ||k alpha|| for 1 <= k < q) and
  never mentions convergents; that the two families coincide is the
  classical theorem, which is not formalized here and not needed. Steps:
  `ThreeDistance.best_approx_gaps` (for a best approximation q, the q
  points leave arcs of two lengths, at most ||k alpha|| + ||q alpha||);
  the first best approximation q >= 2/w exists and is at most
  (2/w)^nu / c (Dirichlet, twice, and bad approximability);
  `cover_of_gaps`. Theorem 6 now uses this lemma; `lemma9`, the shorter
  proof with the constant 4, is kept as a second proof.
- The check and its tests are shared scripts, `formal/check.sh` and
  `formal/test-check.sh`, so that another paper can use them.

## Decisions

Approved by the author on 2026-11-19, as proposed:

- **Publication.** The Lean files are public, in the repository of the
  site (`formal/jane-s-rosary/`), so that anyone can review the statements
  and rerun the check.
- **Review of statements.** Lean cannot check that a Lean statement says
  what the paper says. At each step the author reads the new definitions
  and statements (not the proofs), with the explanation provided, and
  says whether they match.
- **Mathlib under Nix.** Mathlib is large and is normally fetched prebuilt
  from the network, while the site's build is offline
  (`docs/invariants/0001-build-is-reproducible-and-offline.md`). The
  formal check stays outside `site.nix`; Mathlib is pinned by commit in
  the Lake manifest. The details are settled when Mathlib first comes in
  (step 4, or step 3 if its vocabulary for infinite sets is wanted there).
- **How far to go.** Review after step 4; steps 5 and 6 are decided then.

## Open questions

- None at this stage.

## References

- `formal/jane-s-rosary/README.md`: the guide and the state of the work.
- The paper: `content/posts/2022-12-02-jane-s-infinite-rosary/index.md`.
- `docs/papers/jane-s-rosary/statements.md`: the statements and the
  programs that test them.
- Lean: <https://lean-lang.org>; Mathlib:
  <https://leanprover-community.github.io>.
- M. Mayero, *The Three Gap Theorem (Steinhaus conjecture)*, TYPES 1999,
  LNCS 1956 (2000).
