<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# Jane's infinite rosary: history

What was done to the paper, version by version. The reader-level summary
shown on the site is the `history` list in the paper's front matter; this
file is the detailed account. Earlier versions are kept, unmodified, under
`content/versions/jane-s-infinite-rosary/` and listed with their digests in
`docs/papers/frozen-versions.sha256`.

## 2023-01 — the original post

- Published on the WordPress blog on 2022-12-02 and worked on until
  January 2023. The text kept is the one the WordPress site still served
  on 2026-11-17 (`blog.douzeb.is/?p=6271`). Its date, 2023-01-05, is the
  date of the last change to the figures it embeds; the date of the last
  edit of the text itself is not known.
- Kept as `content/versions/jane-s-infinite-rosary/2023-01/`, converted
  on 2026-11-17 from the page served by WordPress (HTML) with Pandoc. The
  conversion repairs what WordPress and its plugins did to the text and
  improves nothing:
  - the page title, the table of contents (a plugin) and what the author
    had commented out are left out;
  - formulas: line-break tags removed; `align` and `equation` displays
    written without delimiters are put between `$$`; dashes and curly
    quotes that WordPress put inside formulas are turned back;
  - the 26 commutative diagrams were written with `xymatrix` and drawn by
    MathJax 3.2 with the XyJax 3.0.1 extension, which the site's MathJax 4
    does not have. They are kept as pictures (SVG, a light and a dark
    variant), drawn once with that same setup in a headless browser; their
    sources are in `diagrams-2023-01.md`;
  - the rows of columns (a label and a diagram each) are kept as rows;
  - the 12 embedded figures use the `frame` shortcode, with their
    proportions and the link that covered each of them, on the site's copy
    of the figure pages (which now have themes);
  - the two footnotes (a plugin) become Markdown footnotes; the one
    citation (a plugin that fills it in the browser) is written
    "(Caruso, 2012)" and its reference is copied from the page;
  - the four code listings get their fences back; blocks that the text
    links to keep their anchors.
- Not repaired: the text's own slips.
- Content: the height and its exploration algorithm; shortest recitations
  ending in a white or a black bead; Theorem 1 (the predecessor with the
  larger lambex) with the fast algorithm; Theorem 2 (the reluctant
  recitation never halts); "Conjecture 3: Jane's reluctant recitation
  tells all beads", with two lemmas; the onyx rosary with Theorem 4 and
  the canonical onyx mapping; a "work in progress" part with the onyx
  sequences and the foraging sequence.
- An earlier state of the post (20 December 2022, from the Markdown
  export `douzebis/blog.atlant.is-import`, with Conjectures 1 to 3 and 20
  `CD` diagrams) was imported first and shown on the preview for about an
  hour on 2026-11-17; it was replaced by this one at the author's request
  (three versions are kept: this one, the 2026 revision, the current
  paper). The export remains in its repository.

## 2026-11-17 — the revision with complete proofs

- Written in November 2026 (front matter: revised 2026-11-14), published
  as the first page of the static site.
- Kept as `content/versions/jane-s-infinite-rosary/2026-11-17/`.
- Mathematics: Conjectures 1, 2 and 3 become Theorem 1, Theorem 3 and a
  remark; new Theorems 4 (onyx covers), 5 (frequency of up moves) and 6
  (polynomial time); postfix notation; numerical data to 2^27 moves; open
  questions A to G. The paper's own appendix lists the changes with
  respect to the January 2023 text.
- The list of changes with respect to the January 2023 text, as it stood
  in the paper's own appendix until 2026-11-17 (step 9 of spec 0002 moved
  it here; "Section" numbers are those of the revision):

  - **Conjecture 3 is now Theorem 3** (Section 8). The former "Theorem 3"
    (a dichotomy) and the former Lemma 2 (bound $b(m)$ along a single up-chain)
    are superseded: the key new remark is that down moves preserve the phase
    $\log_2(n+1) \bmod 1$, so the rotation argument applies to the whole
    recitation and not only to one up-chain.
  - New quantitative results: Theorem 5 (frequency of up moves, growth of
    $\rho$), Theorem 6 (polynomial bound on $\rho^{-1}$), numerical table, and a
    list of conjectures.
  - **Theorem 2** has a new, shorter proof: the twelve commutative diagrams are
    replaced by the commutation Lemma 1 and the down-closure Lemma 3. The same
    Lemma 1 also proves the lemma on white beads. No base case ("moves up to the
    20th") is needed any more.
  - **Theorem 1**: the "easy" claims are now proved, with an explicit rule
    ($2n+1 = 3^e q$) for which of $\mu$, $\nu$ wins; the base case is made
    explicit ($3n = 3$, the only case where $c = 0$); the caption of Figure 7
    said "lower lambex", whereas the minimal recitation goes through the
    predecessor with the *larger* lambex (to be checked against the figure).
  - **Fixed**: the fast `height` algorithm (the printed version returns
    $6$ for $n = 3$ and loops forever on $n = 6$, because of the `+ 1` in its
    `case 2`); the bound $h(n) \leq 6\log n/\log(9/8)$, which fails at $n = 1$
    (replaced by Proposition 1, which also has a better constant and a lower
    bound).
  - **Fixed**: former Lemma 3 (now Lemma 6) had the parity condition reversed;
    former Lemma 5 (now Lemma 8) claimed "at most 2 elements", which is false,
    and had no proof; former Lemma 4 (now Lemma 7) is stated for tails of
    up-chains, which is what Theorem 4 needs.
  - **Theorem 4**: the proof is rewritten (the index sets $S_n$, $P_{3n}$ mixed
    beads and onyx beads); the properties of the onyx ordering that were stated
    without proof ($m \boldsymbol{\preceq} n \Rightarrow m \le n$,
    well-foundedness, tree structure) are now Proposition 2.
  - **Corollary 2**: the canonical onyx mapping is now read from the root, so
    that "prefix" is correct (with the former definition and table it should
    have been "suffix"); it is a bijection, not just an injection.
  - Former "Conjecture 3" of the first version ($\sigma(3n \mp 1) \le 2n$) is a
    one-line remark in Section 4.
  - Lemma numbering: old Lemma 1 → Lemma 4; old Lemma 2 → removed (see Lemma 5);
    old Lemmas 3, 4, 5 → Lemmas 6, 7, 8.
  - Typos: "bean" → "bead"; "$L$ is a strictly increasing function" under *Up*
    → $U$; "contant" → "constant"; "$\lambda_i$" → "$\lambda^i$" in the second
    diagram of Theorem 1; "$d_1{i+1}$" → "$d_{i+1}$".

- On the site (2026-11-17, before freezing):
  - the eleven figures as pictures, in light and dark variants, linking to
    live versions served by the site;
  - commutative diagrams restored: Lemma 1 (two general, six concrete, in
    place of a table), Corollary 1 (two), proof of Theorem 1 (two
    ladders); a pointer to Lemma 1's diagrams in the proof of Theorem 2.
- Checks: `research/jane-s-rosary/` (see `statements.md`).

## Current — presentation overhaul (spec 0002)

In progress. Steps done:

- Step 1 (2026-11-17): the 2023-01 and 2026-11-17 versions frozen; comparison page;
  `tools/compare_statements.py`; this history; `statements.md`;
  `research/jane-s-rosary/` (programs rewritten from the working scripts
  and rerun; same results).
- Step 2 (2026-11-17): new opening. In order: the rosary and its moves
  (unchanged, with Figures 1 and 2); the easy answer; "How fast?" (height,
  the example of bead 3, Theorem 1 and the logarithmic algorithm); "What
  if Jane is reluctant?" (her rule, her first 14 beads, Theorems 2, 3, 5
  and 6 in words); "Why it works, in one breath" (halving against
  multiplying by 3/2, the irrational rotation); the onyx rosary in one
  sentence (Theorem 4); "Where this comes from" (a dictionary with Jane
  Street's sidewalk and the three OEIS entries, in place of the list that
  opened the paper); "And what is still open" (the question whether
  p_1 = 1/2). The header picture gets a caption. The former list of two
  questions with theorem numbers is gone; nothing else is removed.
- Step 3 (2026-11-17): roadmap. A section "How to read this paper" after
  the opening, with a small diagram of what each part needs from the
  others. The twelve sections keep their numbers and titles and are
  grouped in four parts and a coda, each part opening with a few lines on
  what it does and what it rests on: I, shortest recitations (Sections 1
  to 5); II, the reluctant recitation (6 to 8); III, the onyx rosary (9
  and 10); IV, the pace of the recitation (11); coda (12). Headings move
  one level down accordingly. The dependencies were read off the proofs:
  Part II uses Lemma 1 and the names from Part I, not Theorem 1; Part III
  rests on Theorem 1 and uses Theorem 3 only for Corollary 3; Part IV uses
  Lemmas 3 and 5 and Theorem 3.
- Step 4 (2026-11-17): names. On rereading, the three "names" sections
  already stand right before the first use of what they define (Section 1
  before Sections 2 and 3, Section 4 before Theorem 1, Section 9 before
  the onyx rosary), so they are kept, with their numbers and titles, and
  made easier instead of being dissolved:
  - the postfix notation is justified once (a recitation reads in the
    order of its moves);
  - bead 7 is followed through the definitions of Sections 1, 4, 8 and 9
    (its label, its neighbors up and down, where Jane can come from, its
    height, its heap coordinate, its up-chain and down-chain, its seed and
    lambex, its phase; then the black bead 3, reached through 7, for the
    canonical recitation and the onyx predecessor); every value was
    checked by computation;
  - each list of names says in a sentence what the names are for; the
    list of Section 1 is split in two (the moves, then the moves run
    backwards);
  - cone and phase get a plain-words explanation where they are defined;
  - a table "Names at a glance" at the end lists every name with its
    notation, a one-line meaning and a link to the section that defines
    it; "How to read this paper" points to it.
  Not done: links from each later use of a name to the table, and one
  epigraph per part (the three epigraphs stay where they are; Parts II and
  IV have none).
- Step 5 (2026-11-17): a sketch before each main proof, under the label
  "The idea" (for Theorem 5: "Why log_3 2"), and a line "Used:" after it.
  - Theorem 1: the sketch carries the two ladder diagrams, which move out
    of the proof; the proof refers to them.
  - Theorem 2: why a gap in an up-chain is the only danger, and what the
    diagrams of Lemma 1 are for.
  - Theorem 3: four numbered points (the cone to avoid, the cone as an arc
    of phases, what the moves do to the phase, the irrational rotation),
    in place of the two-line announcement of the lemmas.
  - Theorem 4: where the covers are found and why a bead of the chain
    loses only finitely often.
  - Theorem 5: the heuristic 3^u = 2^t, then what parts (1) and (2) add;
    the proof of (2) is marked as the most technical passage, which can be
    skipped.
  - Theorem 6: the statement in words; counting in place of waiting.
  No proof is moved to a later section: on rereading, the proof of
  Theorem 6 is short, and the heavy one, Theorem 5 (2), is better kept
  with its statement and marked as skippable. The arguments are
  unchanged.
- Step 6 (2026-11-17): context, as a section "Relatives of the rosary" at
  the head of the coda (after the names are known), with a pointer from
  the opening. Six paragraphs: the sidewalk (what Jane Street's page asks
  and which of its questions Part I answers; it does not explain the runs
  of repeated values); the OEIS entries and the sidewalks that followed;
  powers of 3/2 (Mahler's map, Odlyzko and Wilf); the 3x+1 problem; music
  (the citation of Caruso, which the 2023 text had and the revision had
  lost); what is new.
  - Sources checked on 2026-11-17: the puzzle page
    (janestreet.com/numberphile2022, read in full); the Numberphile page
    of the video that links to it, and N. Sloane's list of videos for its
    date (November 2022); the OEIS entries A358838, A359005, A359008 (all
    by the author, December 2022; the conjecture is still stated as such),
    A061419 (links to Mahler and to Odlyzko-Wilf), A360593-A360595,
    A360744-A360746; two web searches for other work on the sidewalk or
    on its greedy walk, which found none.
  - Checked by computation: up is x -> ceil(3x/2) in heap coordinates; the
    3x+1 map (x -> (3x+1)/2 for odd x, x/2 for even x) is "up from an even
    bead, down from an odd bead" (all beads below 10^6); 3^12/2^19 = 1.0136.
  - Not verified against the sources themselves: the content of [Ma68]
    and [OW91] beyond what the paper already said and what OEIS A061419
    states; the claim about cycles of the 3x+1 map is the standard
    counting argument, not taken from a reference.
  - New reference [JS22].
- Step 7 (2026-11-17): figures.
  - Every caption now says what to look at (which bead is which, what the
    arrows and the colors mean, what the picture shows of a statement).
  - Two new figures, drawn by `research/jane-s-rosary/draw_figures.py` as
    SVG in light and dark variants: Figure 10, the binary tree with each
    bead above its phase, the cone of bead 3 as a strip, and up moves as
    shifts by alpha (Section 8); Figure 13, two columns of the numerical
    table as plots (Section 11).
  - The figures after them move up: the circle of multiples is Figure 11
    (was 10), the onyx tree is Figure 12 (was 11). Picture files are
    renamed accordingly.
  - Figure 12 is redrawn on 70 onyx beads, so that it can be read; its
    live version keeps 1,000 beads.
  - Figures 4 (heights) and 12 (onyx tree) come alive in the page on a
    click: the picture is replaced by the figure itself, which can be
    zoomed. Without JavaScript the picture stays a link.
  - The dependency sketch planned for this step is the diagram of "How to
    read this paper" (step 3).
- Step 8 (2026-11-17): evidence and open questions.
  - The numerical table moves from Section 11 to an appendix
    ("Appendix: numerical data"); Section 11 keeps Figure 13 and two
    sentences on what the long run shows.
  - New section "Checked by computer", after the coda: what was tested,
    on what range, by which program of `research/jane-s-rosary/`, what
    was not tested, and the caution about heights.
  - The open questions keep their order and their letters; a guide at
    the head of Section 12 says which one to pick and why (C the most
    teasing, A and B the most likely, D with an explicit constant, F
    probably out of reach, G an invitation). They are not reordered, so
    that their letters stay in order.
- Touch-ups to the diagrams (2026-11-17, at the author's request, before
  step 9): a paragraph "How to read the diagrams", stated once, at the
  first diagrams (Lemma 1); the loop of the first diagram traced with
  bead 7, in one sentence and without a new diagram; a closing paragraph
  to the proof of Lemma 1 saying how to check a diagram and what the six
  of them establish.
- Step 9 (2026-11-17): housekeeping.
  - The appendix "changes with respect to the January 2023 version"
    leaves the paper; its text is kept above, under the 2026-11-17
    version. Two parentheticals that spoke of "the previous version" are
    reworded (after Theorem 3 and after Lemma 8); the remark that the
    2023 caption of Figure 7 was to be checked against the figure is
    settled: the caption written in step 7 was checked against it.
  - References: complete entries with links; new [Ba75] for Baker's
    theory, which the text invoked without a reference; the OEIS entry
    gets a key. Rhin's bound 8.616 for log 3 / log 2 was confirmed from
    secondary sources (a web search), not from the paper itself.
  - A summary of three sentences in the front matter (`description`),
    used as the description of the page.
  - Equations: nothing to change. The only equations referred to are the
    two marked (*) and (**), each used within one proof, which the rules
    of spec 0001 allow.
- Two clarifications (2026-11-17, after discussing whether to number the
  beads from 1 and whether to say left and right; both conventions are
  kept): the dictionary of the opening says that Jane Street's page
  counts its squares from 1, so that its square n + 1 is bead n; the
  captions of Figures 1 and 2 say that up is to the right.
- Epigraphs (2026-11-17), so that every part and the coda has one:
  - Part II: "I would prefer not to." (Melville, *Bartleby, the
    Scrivener*, 1853), suggested for the reluctant recitation and
    accepted by the author. Quoted from memory of a very well known line;
    not checked against an edition.
  - Part IV: Killy's answer in *Blame!* ("From below. Over 5,000 floors
    below."), with the question before it and the reply after it; chosen
    by the author.
  - Coda: Killy's question, "Anyone here have terminal genes?"; chosen
    by the author.
  - The two *Blame!* epigraphs are free English renderings, from a text
    the author supplied, of a work written in Japanese; they are not taken
    from a printed translation (editions differ: the 2017 film says
    "6,000 levels below"), and the author decided (2026-11-17) that the
    wording may be adapted as long as the origin is given. They are
    therefore signed "freely translated".
- The name "lambex" is explained where it is defined and in the table of
  names (2026-11-17): it stands for "lambda-exponent", the exponent of
  lambda in sigma(n) = n lambda^Lambda(n); etymology confirmed by the
  author, who coined the word in 2022.

Statements compared with the 2026-11-17 version
(`python tools/compare_statements.py content/versions/jane-s-infinite-rosary/2026-11-17/index.md content/posts/2022-12-02-jane-s-infinite-rosary/index.md`):
28 before, 28 after, 3 differences, explained:

- Lemma 1 and Theorem 1: a bead renamed, no change of content.

- Conjecture B: its last words, "in agreement with the table above",
  become "in agreement with Figure 13", because the table moved to the
  appendix (step 8). The conjecture itself is unchanged.

## 2026-11-18 — the overhaul is closed

Spec 0002 is set to `implemented`. The page gives 2026-11-18 as the date
of revision and describes the overhaul in one line of its history. The
author reads the text as it stands; the reading was not made a condition
for closing.

Next: spec 0003 (`docs/specs/0003-rosary-beads-counted-from-1.md`), the
same paper with the beads counted from 1.

## Current — beads counted from 1 (spec 0003)

Decided on 2026-11-18, after a trial on Part III
(`content/drafts/jane-s-rosary-part-3-counted-from-1.md`): the paper
numbers its beads from 1, so that a down move halves the position and the
"heap coordinates" of the earlier versions are the only coordinates.

- 2026-11-18, step 1: the overhauled paper, counted from 0, is kept as
  `content/versions/jane-s-infinite-rosary/2026-11-18/`. Four versions are
  now kept. The comparison page names its versions by their directory
  (`?left=2026-11-18&right=current`).
- 2026-11-18, step 2: the research code counts from 1.
  `check_renumbering.py` keeps the earlier definitions and checks that
  each function is the earlier one shifted by one (moves, seeds, lambexes,
  heights, reluctant recitation, onyx predecessor, foraging sequence).
  `walk.c` was run again: the frontier column of its result is one more,
  nothing else changed.
- 2026-11-18, step 3: the live figures take `first=1` to show positions
  and onyx numbers from 1. Without it they are unchanged, for the earlier
  versions: captures of all figures with the default are byte for byte
  the pictures of the 2026-11-18 version.
- 2026-11-18, step 4: the text, in four commits (opening and Part I,
  Part II, Part III, then Part IV, the coda, the tables and the
  appendix). What changed for the reader:
  - Every position is one more: Jane starts at bead 1, the running
    example is bead 8 (it was 7), the black beads are 1, 4, 7, ...
  - Down is floor(n/2), up is ceil(3n/2), mu and nu are 2n and 2n + 1, the
    label is ceil(n/2), the phase is log2 n mod 1. The "heap coordinates"
    x = n + 1 are gone; one paragraph says that the rosary is the binary
    tree in heap order.
  - New notation: the black bead number n (bold) is written with a
    bullet, n-bullet = 3n - 2; bold numbers and letters count black beads.
    In Part III the beads of the onyx rosary are called onyxes ("onyx 4
    is bead 10"), the canonical recitation is plain C(n), and the
    canonical onyx mapping becomes the address tau(n). Ranks of covers
    start at 1.
  - Theorem 1 is stated with b_i = 2^i 3^(e+1-i) q and a_i = b_i - 1,
    where 2n - 1 = 3^e q; "mu wins" exactly when b_(e+1) is black.
  - The onyx predecessor is defined with an example first (the canonical
    recitation to bead 10, which leaves the reluctant recitation at bead
    14), and a black bead is said to have two numbers.
  - The frontier F(t) is still the smallest bead not told, hence one more
    than before; the table of the appendix is rebuilt from the new run.
  - The 3x+1 remark of the coda now reads "up from the odd beads and down
    from the even ones", between beads 1 and 2.
  - The table "Where this comes from" says how to pass to the OEIS
    entries, which count from 0 (their slab n - 1 is bead n).
  - Numbers quoted with Conjecture D: the means 4.720 and 4.849 become
    4.716 and 4.850 (the same random integers now name the next bead).
  - Time (the index of a recitation), heights, lambexes and all results
    are unchanged.
- 2026-11-18, step 5: the trial page is removed; spec 0003 is
  `implemented`.

Statements compared with the 2026-11-18 version
(`python tools/compare_statements.py content/versions/jane-s-infinite-rosary/2026-11-18/index.md content/posts/2022-12-02-jane-s-infinite-rosary/index.md`):
28 before, 28 after, 18 differences, explained by group:

- The same statement with every position increased by one, and nothing
  else: Fact 1, Corollary 1 (b > 1 for b > 0), Lemma 3 (n > 1), Theorem 3
  (a permutation of the positive integers), Lemma 4, Lemma 5, Lemma 6
  ("nUD is black" for "3 divides nUD"), Lemma 7 (2^r divides n, or
  n + 1), Lemma 8 (1 + v2(a + 1)), Theorem 5 (log2 rho(t)), Theorem 6
  (kappa m^(2 mu0 - 1); the bound on F loses its "- 1" because F is one
  more), Question G (labels ceil(n/k)).
- The same, written with the new notation (bullet, bold, onyx, tau):
  Theorem 1, Proposition 2 (pi(n) <= (8n + 1)/9, which is the shift of
  pi(n) <= 8n/9), Theorem 4, Corollary 2, Conjecture F.
- Proposition 1: the lower bound and the bound (4n - 1)/3 are the exact
  shifts. The logarithmic bound is stated as 12 + 3 ln n / ln(9/8), where
  the exact shift has ln(n - 1): it is implied by the earlier statement
  and very slightly weaker. This is the only statement whose content
  changed.

Unchanged: Lemma 1, Lemma 2, Theorem 2, Corollary 3, Lemma 9, Conjectures
A, B and D, Questions C and E. (The proofs of Lemma 1 and of Theorems 1
and 6 were rewritten in the new numbering; `check_shortest.py` now checks
the six diagrams of Lemma 1 and the chains of Theorem 1.)

### 2026-11-19 — a reading of the whole text after the renumbering

The text was reread from end to end as prose. Changes:

- A wrong claim is removed: the opening said that Jane Street's page
  counts from 1. The page labels its squares and does not number them
  (where it needs an index it counts from 0). The dictionary now says
  "the n-th square".
- Lemma 9 and the proofs of Theorems 5 and 6 write the exponent
  mu0 - 1 as beta. It was nu, which is also the name of a move. Lemma 9
  is the only statement that differs from the previous day's text, and
  only by this letter.
- Lemma 3 in words is "once Jane has left a bead, the bead below it has
  been told" (the earlier wording, "never leaves a bead before", was
  wrong for a down move), in its four places; Remark 1 after Theorem 3
  says "never moves up from a bead before".
- The cone of m is said to contain m; "every black bead" (not "every
  bead") has infinitely many children in the onyx rosary; "a few names"
  for "seven names", which did not match the count; "paper" for "note".

### 2026-11-19 and 2026-11-20 — the proofs checked by Lean, and what it changed in the text

The plan and its record are in
`docs/specs/0004-rosary-formal-verification.md`. No error was found in
the paper's proofs. Changes to the paper:

- New sections "Checked by a proof assistant" (what is verified, where,
  how the checked proofs differ from the text, and a second proof of
  Theorem 3 with integers only, found on the way) and "Annex: the machine
  checks".
- Lemma 9: same statement; its proof now takes the best approximations
  of alpha by their defining property, where it took "the denominators of
  the convergents", and spells out the two uses of Dirichlet's theorem.
  This is the proof Lean checked.
- Theorem 6: same statement; its proof is reorganized as in the checked
  proof (an excursion above N with J up moves brings m within 2t moves;
  then the count), and its constants change: 4 (N + 1)(J + 1) <= 56 J^2 m
  for 2 ((N + 1) J + N) <= 30 J^2 m.
- After Theorem 6, "Which exponent?": the classical measures (Baker,
  Rhin), and R. K. Jha's formalized bound 3 on the irrationality exponent
  of log 3 / log 2, with which Theorem 6 has the exponent 5 + 2 eps. The
  bound is credited to him; what we did with it is in
  `log23-reproduction.md`. References [Jh26] and [OAI26] added.
- Step 4 of the proof of Theorem 3: one sentence in parentheses on the
  form in which Lean keeps the books.
- Lemma 5 is unchanged: the Lean statements were made strict to match it.

Sources checked on 2026-11-20:

- Rhin's 8.616 is a bound for log 3 / log 2: L. Spiegelhofer, *Collisions
  of the binary and ternary sum-of-digits functions* (arXiv:2105.11173v1,
  2021), writes, for alpha = log 3 / log 2: "a bound for the irrationality
  measure mu(alpha) of alpha [...] was given by Rhin [46, Equation (8)]:
  we have mu(alpha) <= 8.616. We also note that Wu and Wang [58] obtained
  the bound mu(log 3) <= 5.1163051." Rhin's paper itself was not read
  (not available online to us).
- Wu and Wang's 5.1163051 (J. Number Theory 142, 2014) is stated for
  log 3. Jha's manuscript says that their linear-form estimate implies
  the same bound for log 3 / log 2. We could not read their paper
  (publisher's page refused), so the paper keeps Rhin's value for
  log 3 / log 2 and does not quote 5.1163051.
- Read on 2026-11-21, from copies supplied by the author (not kept in
  the repository):
  - Rhin's paper. Its Proposition (page 160) is about the linear form
    Lambda = u0 + u1 log 2 + u2 log 3, with H = max(|u1|, |u2|): equation
    (7) says |Lambda| >= H^(-13.3) for all H >= 2, and equation (8) says
    |Lambda| >= H^(-7.616) for H >= H0, effectively computable. With
    u0 = 0 this bounds |log 3 / log 2 - p/q| from below by a constant
    times q^(-8.616): the 8.616 quoted through Spiegelhofer is confirmed
    at the source, and it is a statement about log 3 / log 2 as much as
    about log 3.
  - Wu and Wang's paper. Its Theorem 1 is of the same shape:
    |p + q1 log 2 + q2 log 3| >= H^(-4.1163051 - eps) for H >= H0(eps),
    effectively computable; its Corollary 1 is mu(log 3) <= 5.1163051.
    The same remark (take p = 0) gives 5.1163051 for log 3 / log 2, as
    Jha's manuscript says. The paper now quotes both values, with this
    one-line deduction, and the exponent of Theorem 6 becomes at most
    9.24 instead of 16.24.
- [OAI26]: at commit adc7f124 of github.com/openai/math (the commit Jha's
  sources are copied from), the directory
  `preprints/The-irrationality-exponent-of-pi-is-2-September-24-2026`
  holds `paper.pdf` and a README giving the author as OpenAI and the date
  as September 24, 2026; `lean/OAI/NumberTheory/PiExponent/Main.lean`
  states `theorem main` and contains no `sorry`. We did not compile that
  file; the part of that library which Jha's proof uses was compiled and
  replayed with the rest of his sources.

2026-11-20: the word "lambex" becomes "lambdex" in the text of the paper
(the author's choice). The Lean files, the programs, the figure code and
the earlier versions keep `lambex`.

2026-11-20, later: Corollaries 2 and 3, the bound on the frontier and
parts 2 and 3 of Theorem 5 are checked by Lean too; every theorem, lemma,
proposition and corollary of the paper now is. No error was found. The
paper's section on the proof assistant says where the checked proof of
Theorem 5, part 2, has cruder constants than the text.
