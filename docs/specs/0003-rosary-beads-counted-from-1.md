<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# 0003 — Jane's infinite rosary: beads counted from 1

**Status:** implemented
**App:** jane-s-rosary
**Implemented in:** 2026-11-18

## Problem

The paper numbers the beads from $0$. With this numbering the black beads
are the multiples of $3$, but the binary structure of the rosary is hidden
behind a shift: a down move is $\lceil n/2 \rceil - 1$, the two beads above
$n$ are $2n+1$ and $2n+2$, the phase is $\log_2(n+1)$. The paper therefore
introduces "heap coordinates" $x = n + 1$ and switches to them in Section 8,
in Part IV and in the coda, each time with a sentence of warning.

Counting the beads from $1$ removes the shift everywhere: down is
$\lfloor n/2 \rfloor$, up is $\lceil 3n/2 \rceil$, the beads above $n$ are
$2n$ and $2n+1$. The cost is that black beads become the beads
$n \equiv 1 \pmod 3$.

Part III (the onyx rosary), which depends most on "black bead $3n$", was
rewritten as a trial on 2026-11-18
(`content/drafts/jane-s-rosary-part-3-counted-from-1.md`). It reads at
least as well as the original, with three devices found on the way.

## Goals

- The paper uses one numbering, from $1$, from the first line to the last.
  The letter $x$ and the words "heap coordinates" are gone, except for one
  remark that the rosary is the binary tree in heap order.
- No mathematical content changes: every statement of the new version is
  the statement of the previous version with every position increased by
  one, and this is checked.
- Every number printed in the paper (examples, tables, sequences, code) is
  checked by a program of `research/jane-s-rosary/`.
- Figures, captions and text agree.
- Earlier versions and their live figures are unchanged.

## Non-goals

- New results, new sections, changes of tone or structure.
- Changing the OEIS entries. The paper says where its sequences differ by
  one from them.
- Renumbering the theorems, lemmas and sections.
- The arXiv version.

## Specification

### Conventions of the new version

| Notion | Today | New |
|---|---|---|
| Beads | $n \geq 0$ | $n \geq 1$; the end of the rosary is bead $1$ |
| Label | $1 + \lfloor n/2 \rfloor$ | $\lceil n/2 \rceil$ |
| Up, down | $\lfloor 3n/2 \rfloor + 1$, $\lceil n/2 \rceil - 1$ | $\lceil 3n/2 \rceil$, $\lfloor n/2 \rfloor$ |
| $\lambda$, $\mu$, $\nu$ | $\lfloor 2n/3 \rfloor$, $2n+1$, $2n+2$ | $\lfloor 2n/3 \rfloor$, $2n$, $2n+1$ |
| Black beads | $3n$ | $n \equiv 1 \pmod 3$ |
| Height | $h(0) = 0$ | $h(1) = 0$ |
| Running example | bead $7$ | bead $8$ |
| Time (index of a recitation) | from $0$ | from $0$: it counts moves |

Devices from the trial page, all adopted:

- **The bullet.** $\boldsymbol{n}^\bullet = 3\boldsymbol{n} - 2$ is the black
  bead number $\boldsymbol{n}$. It is a map written after its argument, like
  $U$ and $\lambda$.
- **Onyx as a noun.** The beads of the onyx rosary are called onyxes: onyx
  $\boldsymbol{n}$ is bead $\boldsymbol{n}^\bullet$. "Bead" always goes with a
  position in the rosary.
- **Bold.** A bold number or letter is the number of an onyx; the names of
  the onyx maps stay bold. Bold never carries the meaning alone: the text
  says "onyx" wherever it matters. Ranks of covers are plain numbers and
  start at $1$.
- **Letters.** The canonical recitation becomes plain $C(n)$ (it is about
  beads). The canonical onyx mapping becomes $\boldsymbol{\tau}(\boldsymbol{n})$,
  "the address of an onyx".
- **Definitions with an example first**, as for the onyx predecessor on the
  trial page (the canonical recitation to bead $10$, which differs from the
  reluctant recitation).

Statements whose form changes beyond the shift (content unchanged):

- Theorem 1: $2\boldsymbol{n} - 1 = 3^e q$, $b_i = 2^i 3^{e+1-i} q$,
  $a_i = b_i - 1$; "$\mu$ wins" when $b_{e+1}$ is black.
- Proposition 1: the three cases and the bounds, restated for $n \geq 2$.
- Proposition 2: $\boldsymbol{\pi}(\boldsymbol{n}) \leq (8\boldsymbol{n}+1)/9$.
- Lemma 4, Lemma 5, Theorems 5 and 6: $\log_2 n$ in place of $\log_2(n+1)$.
- Lemma 6: "$nUD$ is black". Lemma 7: $2^r \mid n$ and $2^r \mid n + 1$.
  Lemma 8: $1 + v_2(a+1)$.
- Section 4: the bijection $\gamma$ is onto pairs (onyx, lambex).

### Figures

- The live figures get a parameter `first` (the number of the first bead):
  `first=0` is the default and draws exactly what is drawn today, so the
  links of the earlier versions keep showing the earlier numbering;
  `first=1` shifts every label that is a position or the number of an onyx.
  Heights, labels of moves and colors do not change.
- The links of the new version carry `first=1`; the pictures (light and
  dark) are captured again with `tools/capture-figures/capture.sh`, and the
  two drawn pictures (Figures 10 and 13) with `draw_figures.py`.
- Captions are rewritten where they quote positions.

### Research code

- `rosary.py` and the `check_*.py` programs count from $1$, like the paper.
- A new program, `check_renumbering.py`, keeps the previous definitions
  (counted from $0$) and checks that each function of `rosary.py` is the
  previous one shifted by one: moves, seed, lambex, height, onyx
  predecessor, reluctant recitation, foraging sequence. This is the check
  behind the goal "no mathematical content changes".
- `walk.c` and its kept result are for statistics that do not depend on the
  numbering, except for printed positions; the note in `README.md` says
  which numbering each kept result uses. Long runs are not redone.

### Steps

Each step ends with a build that passes, a commit and a push.

1. **Freeze.** The current text becomes a kept version, the fourth.
   History entry.
2. **Research code.** Convert, add `check_renumbering.py`, run all quick
   checks.
3. **Figures.** Parameter `first`, new pictures. The paper still shows the
   old ones until its links are changed in step 4.
4. **Text**, in four commits, each with its numbers checked by program
   before it is written:
   a. opening, "How to read this paper", Part I;
   b. Part II;
   c. Part III, from the trial page;
   d. Part IV, coda, "Checked by computer", "Names at a glance", appendix,
      references (a line on the OEIS entries).
   Between a. and d. the paper mixes two numberings; a notice at its top
   says so, and is removed in d.
5. **Record.** `tools/compare_statements.py` against the frozen version:
   every difference explained, by group, in `history.md`; the statements
   file updated; the trial page and `content/drafts/` removed if empty;
   history entry on the page; this spec set to `implemented`.

### Checks

- `check_renumbering.py` (above) and the existing quick checks.
- `check_paper_code.py` runs the code printed in the paper.
- Every example, table and sequence quoted in the text is asserted in a
  `check_*.py` program; the examples added on the way are added there.
- A search of the final text for what must be gone: `n + 1` inside
  $\log_2$, `heap coordinates`, `3n`, bead $0$, `x =`. Each remaining hit
  is read.
- The build's own checks (links, formulas, LaTeX, frozen versions).

### As implemented (2026-11-18)

Deviations from the plan above, all recorded in
`docs/papers/jane-s-rosary/history.md`:

- `walk.c` was run again (20 seconds) so that its kept result gives the
  frontier in the new numbering; only that column changed.
- The pictures were put in the paper with the text of each part (steps 4a
  to 4c), not in step 3, so that text and pictures always agreed.
- Proposition 1 states its logarithmic bound with $\ln n$, where the exact
  shift would be $\ln(n - 1)$: a slightly weaker and simpler statement.
- The bullet and the bold count of black beads are introduced in Section 1,
  since Theorem 1 needs them; the word "onyx" waits for Part III.
- `content/drafts/` is removed with the trial page; the base layout keeps
  its support for a `noindex` parameter.

## Invariants

- No new invariant. `docs/invariants/0003-frozen-versions.md` applies to
  the version frozen in step 1; the default `first=0` of the figures is
  what keeps the live figures of earlier versions unchanged, and a test in
  `tools/test_checks.py` checks that the figure code still has this
  default.

## Decisions (2026-11-18)

- Go for the whole paper; Part III follows the trial page.
- The position is called $n$ and starts at $1$; time starts at $0$; ranks
  of covers start at $1$.
- $C$ for the canonical recitation, $\boldsymbol{\tau}$ for the address of
  an onyx.
- The trial page is removed once the paper has absorbed it.
- Four versions are kept: January 2023, 17 November 2026 (complete proofs,
  before the overhaul), the overhauled paper counted from $0$ (frozen in
  step 1), and the current one. This replaces the "three versions" of
  spec 0002: the 17 November version is the only record of the text before
  the overhaul, and the version of step 1 is the reference for the check
  of step 5.
- Spec 0002 is closed (2026-11-18). The author reads the overhauled paper
  as it stands; what the reading brings is applied to the current text.

## References

- `docs/specs/0002-rosary-presentation-overhaul.md`
- `content/drafts/jane-s-rosary-part-3-counted-from-1.md` (the trial)
- `docs/papers/jane-s-rosary/history.md`
