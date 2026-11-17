<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# 0002 — Jane's infinite rosary: presentation overhaul

**Status:** in-progress
**App:** jane-s-rosary
**Implemented in:** <!-- YYYY-MM-DD, fill after implementation -->

## Problem

The revised paper (8,100 words, 6 theorems, 9 lemmas, 7 conjectures and
questions) is mathematically complete but hard to enter:

- The headline result — reluctant Jane, who follows a greedy rule with no
  lookahead, tells every bead exactly once, and moves up with frequency
  exactly $\log_3 2$ — is in the middle of a paragraph that lists theorem
  numbers.
- Three "names" sections define about a dozen operators in postfix
  notation before the reader knows what they are for.
- The paper tells three nearly independent stories (minimal recitations,
  the reluctant recitation, the onyx ordering) without saying so.
- The long proofs (Theorems 3, 5, 6) start with their lemmas; the idea
  comes last, or not at all.
- Captions name the figures without saying what to look at; one picture
  (Figure 11) cannot be read; the numerical evidence is a table.
- The paper does not say where it sits: Jane Street's puzzle, the OEIS
  entries, the $3/2$ dynamics of Collatz-type problems.
- The appendix "changes with respect to the January 2023 version" is part
  of the paper, and there is no place that records what was done to the
  paper and why.

## Goals

- A mathematically inclined reader knows after the first screen what is
  proved, why it is surprising, and which part to read.
- Every name is introduced where it is first needed, with a running
  example; one reference table gathers them.
- Every theorem is stated in words and, when its proof is long, preceded
  by a sketch of the idea.
- No statement changes without being listed: the overhaul is about
  presentation. Each theorem, lemma and corollary of the old version is
  found in the new one, with the same content.
- The old and the new version can be read side by side in a browser, on
  the preview, during and after the work.
- What was done to the paper is traceable: which change, why, when, under
  which spec.

## Non-goals

- New mathematics. Errors found on the way are fixed and listed; new
  results go to a later spec.
- The arXiv version (LaTeX, PDF). The overhaul keeps the source
  convertible and makes that later step easier.
- The hats posts.
- Translating the paper.

## Specification

### Versions side by side

- Before any change, the current paper is frozen as a version: a copy of
  its directory (text and pictures) under
  `content/versions/jane-s-infinite-rosary/2026-11-17/`, served at
  `/versions/jane-s-infinite-rosary/2026-11-17/`. A version is recorded
  with `python tools/check_frozen.py docs/papers/frozen-versions.sha256
  --freeze DIRECTORY`.
- A frozen version is never edited afterwards. It carries a banner ("An
  earlier version of this paper, of 17 November 2026. Read the current
  version."), is left out of the home page and the feed, and asks search
  engines not to index it.
- The current paper, at its usual address, lists its earlier versions
  under the title.
- A comparison page, `/compare/jane-s-infinite-rosary/`, shows two
  versions next to each other in two panes of the same window, each with
  its own scrolling and its own table of sections, so that corresponding
  passages can be brought face to face. On a narrow screen the panes are
  stacked.
- The original post is kept as a third version,
  `/versions/jane-s-infinite-rosary/2022-12/`: the text of the WordPress
  export (20 December 2022), with its 20 commutative diagrams, its
  embedded frames replaced by the older figure pages of
  `figures/jane-s-rosary/`. It is imported as it was (export damage
  repaired, nothing improved). The later text of January 2023, which the
  WordPress site still serves, is not in the export and is not kept; see
  `docs/papers/jane-s-rosary/history.md`.
- The overhaul is done in place, at the paper's usual address, in the
  steps below; each step is one or a few commits that name this spec.

### Tracing what was done to a paper

Repository layout (see also "Open questions"):

```
docs/
  specs/                      # one numbered sequence for the whole
                              # repository; "App:" says what a spec is
                              # about: site, jane-s-rosary, hats, ...
  invariants/
  papers/
    jane-s-rosary/
      history.md              # one entry per version: date, what changed
                              # for the reader, the spec, the frozen copy
      statements.md           # every statement of the paper: where it is
                              # proved, what was checked by computer and
                              # with which program
content/
  posts/<date>-<slug>/        # the current version of each paper
  versions/<slug>/<date>/     # frozen versions, never edited
research/
  jane-s-rosary/              # programs and notes behind the paper
    README.md                 # table: statement -> program -> command ->
                              # expected output and running time
    notes.md                  # working notes (today NOTES.md)
    <one program per purpose, named after what it checks>
    results/                  # kept outputs of the long runs
```

`research/<paper>/` is organized by what is claimed, not by how the
programs came about: its README is a table with one line per checked
statement (the statement as numbered in the paper, the program, the exact
command, what it prints when the check passes, how long it takes), and
each program's name and first lines say which statement it supports.
`docs/papers/<paper>/statements.md` points to these lines. The programs
run in the repository's nix-shell; a single command runs all the quick
checks.

- A spec per editorial campaign (this one), not per paragraph. Its
  "Specification" lists the steps; each step is ticked with its date when
  done.
- `history.md` replaces the appendix "changes with respect to the January
  2023 version", which leaves the paper. The paper keeps one line under
  its title: first published, last revised, link to the history.
- `tools/compare_statements.py OLD.md NEW.md` extracts the statements
  (paragraphs that start with a bold "Theorem", "Lemma", "Corollary",
  "Proposition", "Fact", "Conjecture", "Question") from two versions and
  reports those that were added, removed or reworded. Its report against
  the frozen version is kept in `history.md`; every difference is either
  reverted or explained there.

### Steps

Each step ends with a build, a look at the result on the preview next to
the frozen version, and the author's go-ahead for the next one.

1. **Freeze and tooling.** (Done 2026-11-17.) Version mechanism,
   comparison page, `compare_statements.py`, `docs/papers/jane-s-rosary/`
   with the history so far (2022 original, 2026 revision),
   `research/jane-s-rosary/`.

2. **Opening.** Rewritten first screen:
   - two or three sentences that state the puzzle (the rosary, up and
     down moves);
   - the headline results in words: every bead can be told and shortest
     ways are computed in logarithmic time; reluctant Jane tells every
     bead exactly once; she moves up with frequency $\log_3 2$;
   - one sentence of why: an up move is multiplication by $3/2$, so on a
     logarithmic scale the walk turns around a circle by an irrational
     angle;
   - the picture of the reluctant recitation (today's Figure 8) moved up
     as the opening figure;
   - a dictionary with Jane Street's "sidewalk" and the OEIS entries;
   - one enticing open question (Conjecture A or the "$p_1 = 1/2$"
     question) as a teaser.

3. **Roadmap.** The paper becomes three parts with a short map and a
   dependency sketch (a small diagram: which part needs which lemma):
   - Part I, shortest recitations: height, Lemmas 1-2, Theorem 1, the
     logarithmic algorithm;
   - Part II, the reluctant recitation: Theorems 2, 3, then 5 and 6;
   - Part III, the onyx rosary: Theorem 4 and its corollaries.
   Sections are renumbered accordingly; theorem numbers do not change
   (the OEIS entries and the 2023 version refer to them).

4. **Names where they are needed.** The three "names" sections are
   dissolved: each operator ($U$, $D$, $\lambda$, $\mu$, $\nu$), then
   seed, lambex, cone, phase, onyx, is introduced at first use, with the
   same running example (bead 7: $7U = 11$, $7D = 3$, $7\lambda = 4$,
   its seed, its lambex). One reference table of names, with a link from
   each later use. The postfix notation is kept and justified once (it
   reads in the order of the moves). The epigraphs stay, one per part.

5. **Sketches before proofs.**
   - Theorem 1: the existing "in words" paragraph, plus the ladder
     diagrams placed before the proof instead of inside it.
   - Theorem 3: a half-page sketch (down-chains are binary prefixes; a
     bead never told would forbid a whole cone; phases turn by an
     irrational angle, so the cone is entered) with a picture of a cone
     and of the phases on the circle.
   - Theorem 5: why $\log_3 2$ (each up move multiplies by $3/2$, each
     down move divides by $2$, and the walk stays near the frontier).
   - Long technical proofs may be deferred, in the way usual for such
     papers: the theorem is stated in its place with its meaning and a
     sketch, and the full proof comes in a later section of its own
     ("Proof of Theorem 6"), not in a detached appendix. A deferred proof
     restates the theorem, says what it uses, and is linked both ways with
     the statement. Candidate: Theorem 6, if rereading confirms that it is
     the heaviest and that nothing later depends on its details.
   - Each proof is followed by a one-line "what was used".

6. **Context.** A short section: the puzzle's origin (Jane Street,
   Numberphile); the OEIS sequences; the $3/2$ maps (Odlyzko-Wilf, the
   Josephus-type sequence A061419, Collatz-type problems) and what is
   and is not analogous; what is new here, stated carefully and only
   after a literature check.

7. **Figures.**
   - Every caption says what to look at.
   - New pictures: the dependency sketch; a cone and its phases (Theorem
     3); the numerical data as a plot.
   - Figure 11 (onyx ordering) redrawn so that it can be read as a
     picture (fewer beads), with the large one live.
   - The plot of heights and the onyx tree become live in the page on a
     click (the option reserved in spec 0001).

8. **Evidence and open questions.**
   - The numerical table becomes a plot; the table goes to the appendix.
   - One box, "checked by computer", says what was verified, up to where,
     and with which program of `research/jane-s-rosary/`.
   - The open questions keep their section, reordered by appeal, each
     with its evidence in one or two lines.

9. **Housekeeping.**
   - Equations that are referred to get automatic numbers and labels
     (spec 0001, rules for mathematics).
   - References as a proper list with complete entries.
   - A summary of two or three sentences in the front matter, used as
     the page description and, later, as the abstract.
   - The "changes" appendix leaves for `history.md`.

10. **Closing.** `compare_statements.py` against the frozen version, with
    every difference explained; full reading by the author; status
    `implemented`; a new frozen version only when the next campaign
    starts.

### What does not change

- The statements (see the tool above) and the proofs' arguments. A proof
  may be reordered, split, or given a sketch; a change of argument is
  listed in `history.md`.
- Theorem, lemma and conjecture numbers and names.
- The address of the paper.
- The source format and the rules of spec 0001.

## Invariants

- A frozen version is never modified
  (`docs/invariants/0003-frozen-versions.md`; the build compares the
  digest of each directory under `content/versions/` with the digest
  recorded when it was frozen; tests in `tools/test_checks.py`).

## Decisions (2026-11-17)

- Three versions are kept: the original post (2022-2023), the revision of
  November 2026, and the overhauled paper.
- The blog version keeps its playful voice: the "treat" tone, the
  epigraphs, the rosary vocabulary.
- Sketches, context and examples take precedence over length.
- Technical proofs may be deferred to later sections, never cut off from
  the text (see step 5).
- The research code lives in this repository, under `research/`.
- The same layout will serve the hats papers.
- The site shows the paper's history to its readers: a short "History of
  this paper" under the title (date and one line per version, with links
  to the earlier versions). The detailed account stays in
  `docs/papers/jane-s-rosary/history.md`.

## References

- Spec 0001 (`docs/specs/0001-static-site.md`): the site, the source
  rules, the figures.
- The paper: `content/posts/2022-12-02-jane-s-infinite-rosary/index.md`.
- The original post:
  <https://github.com/douzebis/blog.atlant.is-import/tree/master/2022-12-02-jane-s-infinite-rosary>.
