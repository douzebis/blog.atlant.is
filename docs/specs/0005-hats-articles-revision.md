<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# 0005 — Hats articles: defects, notation, prose

**Status:** draft
**App:** blog.atlant.is
**Implemented in:** <!-- YYYY-MM-DD, fill after implementation -->

## Problem

The three hats articles were imported on 2026-11-24 as they stood on the
WordPress blog (commit `560a59c`; spec 0001, "Import policy"):

| Short name | Directory under `content/posts/` | Subject |
|---|---|---|
| Post 1 | `2020-08-30-tower-of-hats` | finite towers, operations on strategies, win-rate formulas |
| Post 2 | `2020-09-05-hats-calculator` | the calculator (`figures/hats/`) |
| Post 3 | `2020-09-26-infinitely-many-hats-3-3` | infinite towers (tagged "Draft" on WordPress) |

Nothing of substance was changed at import. The texts contain errors,
notation that a reader has to decode, and prose that was never revised.
This spec lists what was found, so that each item can be accepted, changed
or dropped before any text is touched.

How each item was established is stated with it:

- **computed**: recomputed during the import with a short independent
  program (strategies as arrays, score by enumeration of all pairs of
  towers), not kept in the repository yet;
- **read**: seen by reading the text, the code or a source;
- **from the notes**: taken from `levine-hats/NOTES.md` (2026-11-16) and
  not checked again here.

## Goals

- Every formula, tuple, score and example printed in the three posts is
  right, and a program in the repository recomputes them (item K1).
- The conditions under which each win-rate formula holds are stated.
- One notation, explained once, used the same way in the three posts and
  in the calculator.
- The sources of the three posts satisfy the rules for mathematics of
  spec 0001 (plain LaTeX with `amsmath`, no Unicode symbol in a formula
  where a command exists).
- The prose is corrected and reads as one text in three parts.
- The results of `levine-hats` enter the articles (Section 7; decided by
  the author on 2026-11-24).
- The three posts become one article and one blog entry (decided on
  2026-11-24): posts 1 and 3 as its text, post 2 as the description of its
  figure, the calculator. The three posts as imported are kept as earlier
  versions (K2).
- The statements of the article are proved in Lean, as for the rosary
  paper (decided on 2026-11-24; the work has its own spec, 0006). The
  proofs by cases of Section 6, point 1, are written for the article and
  for Lean together.
- The sources stay fit for an arXiv version built from the page, as for
  the rosary paper (`arxiv/jane-s-rosary/`). Building it is a later spec.
- The texts as imported stay readable and comparable (item K2).

## Non-goals

- Building the arXiv version (a later spec; this one only keeps it
  possible).
- New computations: the six-hat optimality run of `levine-hats` is not
  part of this spec.
- Rewriting the calculator. Only the defects listed in Section 2 are
  concerned.
- Replacing the three head pictures.

## Specification

Items carry an identifier so that they can be discussed one by one.
Sections 1 and 2 are defects (something is wrong). Sections 3 to 5 are
proposals (something could be better). Section 6 is an assessment of what
else deserves work. Section 7 lists the new material.

### 1. Defects of the texts

#### Post 1, statements and proofs

- **D1** (computed). Three results are stated for all strategies but only
  hold for strategies that choose a position inside their own tower:
  - invariance of the win rate under embedding: `s = (1, 1)` on one hat
    has win rate 0, and 1/4 once embedded in two hats;
  - the left-reset rule: with `a = (1, 1)` and `b = [00]` the rule gives
    1/16, the strategy scores 1/4;
  - the left-shift rule: with `s = (1, 1)` the rule gives 1/16, the
    strategy scores 1/4.

  The table "Formulae for win rate calculation" gives the condition for the
  right reset, the double reset, the right shift and the double shift, and
  none for these three. For the left reset the condition is needed on `a`
  only.
- **D2** (read). `m` and `n` are swapped between the definitions of the
  resets (`a` on `m` hats, `b` on `n` hats) and the win-rate formulas and
  their proofs (`a` on `n` hats, `b` on `m` hats).
- **D3** (read). In the definitions of the three resets, the case "use
  `a`" reads `a(t)` where `a(t mod 2^m)` is meant, and the codomain is
  written `[m+n]` although strategies may choose any integer.
- **D4** (read). In the definition of the embedding, the quantifier reads
  "for all `t` in T_n"; it should be T_m.
- **D5** (read). In "Observations", the last column is said to add up to
  `2^(n-1)` "when `a(2^m - 1)` is in `[n]`"; it should be `a(2^n - 1)`.
  The first matrix has a stray "(" at the start of each row.
- **D6** (read). The proof of the right-shift rule writes the left shift
  (`\mu(\uparrow s)`) in its last line.
- **D7** (computed). Proof of the double-shift rule: the towers for which
  `s_1` chooses a position at or above `n` are said to be
  `2^n - 1`, `2^(n+1)` and `2^(n+1) - 1`. The third is
  `2^(n+1) + 2^n - 1`. The three lines that follow use the right tower, so
  the conclusion stands.
- **D8** (read). Same proof: the term of the diagonal is written
  `(\eta_{k,k}(s_2))^2`. What is meant is
  `\eta_{k,k}(s_2) - \eta_{k,k}(s_1)`, which is 1 - 0.
- **D9** (read). The Carter win rates are said to follow from the
  left-shift rule and the double-shift rule; the definition uses the right
  shift.
- **D10** (read). Unbalanced parenthesis in "Now since
  `0 <= b(u) < m`, ...".

#### Post 1, values and examples

- **D11** (computed). Table "Examples of strategies": 21/64 is given as
  31.81%; it is 32.81%.
- **D12** (computed). Table "Operations on strategies":
  `[0101] -> [00]` is `[1020-1020]`, not `[01-02-01-02]`;
  `DR([0010], [0010])` is `[2012-2012-3013-2012]`, not `...-3012-...`.
- **D13** (computed). "Double-shift examples": the double shift of
  `[0000]` is `[0002-0000--3002-3000]`, not `...--3001-...`.
- **D14** (read). Caption "Hits for strategy W_2 = [0010]": W_2 is
  `[1010]`, as the text and the table above it say.
- **D15** (computed). Table "Efficiency of various strategies":
  C_2 is given as `[0010]`; it is `[0100]` (the Carter table has it right).
  C_3 is given the win rate 21/64; it is 22/64 (again right in the Carter
  table).
- **D16** (computed). Carter table: the tuple of C_4 has 15 digits; a `3`
  is missing (`[01002123-01002120]`).
- **D17** (computed). Reyes strategies are defined twice, differently.
  The text says R_1 = C_3 = `[01002120]`; the Reyes table prints R_1 as
  `[21002122]`, which is "C_3 double-reset by `[-1]`". The printed R_2
  follows the table's R_1. The printed R_3 follows neither: it differs
  from "C_3 double-reset by the printed R_2" on the 8 towers whose three
  blocks are each all black or all white. All variants have the same
  score (they only differ where the team loses anyway), but the text
  should define one sequence and print that one.
- **D18** (read). The Reyes table gives the win rates of R_2 and R_3 as
  358/1024 and 5734/16384. The values are right, but the denominators are
  those of 5 and 7 hats, while R_2 and R_3 play on 6 and 9 hats
  (1432/4096 and 91744/262144).

#### Post 1, references and context

- **D19** (read). The first sentence ends on a citation with no object and
  no full stop ("...arose from his work with Tobias Friedrich on
  (Friedrich & Levine, 2012)").
- **D20** (read, arXiv record of 2026-11-24). The reference "Kariv, van
  Alten & Yeroshkin (2017), *Computing optimal strategies for a
  cooperative hat game*, arXiv:1407.4711" names an earlier version. The
  current record (version 8) is *On Levine's notorious hat puzzle*, by
  Buhler, Freiling, Graham, Kariv, Roche, Tiefenbruck, Van Alten and
  Yeroshkin. The introduction quoted at the top of the post comes from the
  earlier version; the quotation must be checked against the version that
  is cited.
- **D21** (from the notes). The recap presents the explicit construction
  of the Carter strategies for all `n` as new. Wagon's solution page
  credits Tiefenbruck, Reyes, Carter and Rosenberg with a recursive
  extension ("They also showed how to recursively extend strategies"),
  without showing it. The claim should be worded accordingly.
- **D22** (read). The recap stops in 2014. Later work exists (Buhler et
  al., final version; Friedgut, Kalai and Kindler 2021; Alon, Friedgut,
  Kalai and Kindler 2022; Bouquet et al. 2025). The statements "for
  `n > 5` we don't know", "15/40 is an upper bound" and "it is believed
  that asymmetric strategies do not lead to better win rates" must be
  checked against it before they are kept.

#### Post 2

- **D23** (read). The list of the posts links the post to itself ("Second
  exercice").
- **D24** (read). The third and fourth command examples of "Evaluating
  strategies" are the same command (`dr(W2,dr(W1,W1))`).
- **D25** (read). "113 000 years" in the table and its sentence, "114 000
  years" in the conclusion. The figures of the table give about 113,300.
- **D26** (read). "`crush(a)`: ... such that for all `t`, `a(t) <= t`" and,
  in the tips, "for which for all `s`, `s(t) <= t`": the second quantifies
  the wrong letter, and neither says that a position is being compared
  with the number of a tower.
- **D27** (read). The footnote calls the generated search code
  "self-modifying". The program writes the code of a search and runs it in
  a worker; nothing modifies itself.
- **D28** (read). `git clone git@github.com:...` only works for a reader
  with an SSH key registered at GitHub; the HTTPS address works for all.
- **D29** (read). `T0` is listed among the predefined constants; the help
  of the calculator does not list it.
- **D30** (not done). The outputs of the command blocks were not run
  again. The two `search` examples need `d8` or a browser.
- **D31** (from the notes). "Different methods than brute force are
  definitely needed" and "What's next" are out of date: five hats were
  settled in 2014, and again in `levine-hats`.

#### Post 3

- **D32** (read). "W_omega has win rate 7/20" stands under the Carter and
  the Reyes headings; C_omega and R_omega are meant. The second footnote
  says W_omega where C_omega is meant. The squeeze of the Reyes section
  bounds "eta(C_omega)" where R_omega is meant.
- **D33** (read, and the lists in `research/hats/diagrams/Makefile`). The
  sequences X_n are defined from "C_k restricted to" a number of hats,
  for Carter and for Reyes alike. The pictures were drawn with
  X_n = C_n for Carter (X_0 = C_1) and X_(3k-2) = X_(3k-1) = X_(3k) = R_k
  for Reyes. The definitions should say that.
- **D34** (read). "`$eta_{t,u}(s)$`" lacks its backslash and shows as
  "eta".
- **D35** (read). "Baire/Borel measure": the measure meant is the
  fair-coin (product) probability measure on pairs of infinite towers.
  "Baire" and "Borel" name families of sets, not this measure.
- **D36** (read). The automata are called finite, but each carries a
  counter `n` that grows without bound.
- **D37** (from the notes, and read). The three proofs are sketches: that
  the hit set is measurable, that `mu(U_k)` tends to 0 and that the limits
  of `mu(I_k)` and `mu(S_k)` are the announced values are asserted. The
  same paragraph is repeated three times with one letter changed.
- **D38** (read). The proof that an infinite tower is a limit of finite
  ones calls the tower `s`, the letter of strategies. "We can view
  `t in T_N` as the Cauchy completion of `t in T_<N`" means the sets, not
  their elements. "Finite strategies are continuous" has no argument.
- **D39** (read). The post is tagged "Draft" and ends without a conclusion;
  the introduction of post 1 announces three finished pieces.

### 2. Defects of the calculator

- **C1** (computed; corrected in commit `c6625fa`). `R3` was "R2
  double-reset by C3". The article defines R_(n+1) as "C3 double-reset by
  R_n", which is another strategy: 91744/262144 against 91672/262144.
- **C2** (read). `R1` is C_3, as the text of post 1 says; the Reyes table
  of post 1 prints another tuple (D17). The calculator and the article
  must agree once D17 is settled.
- **C3** (read). `eval help` prints the usage and then "Error: Expression
  evaluation error". `help eval` is the intended command. Any expression
  that is not a strategy gets the same message.
- **C4** (read). The calculator groups digits by 8 (`-`, then `--` every
  16, a new line every 32). Post 1 groups them by 1, 2, 4 or 8 depending
  on the place (N9).
- **C5** (read). `hats.html` has no title, no character set, and its style
  sheet stands in the body. It is drawn for a white page and has no dark
  variant (the page gives it a white box).
- **C6** (read). The `tikz` command of 2020 is lost; the one in the
  repository was written again from the pictures (commit `c6625fa`). The
  six trees it draws have the same nodes, numbers and gray nodes as the
  pictures of 2020. Why the last three strategies of a list are not drawn
  is a reconstruction.
- **C7** (read). The calculator has no test.

### 3. Notation

The notation of post 1 is consistent enough to be followed, but several
choices are unusual, and some clash. Proposals, each with its reason.

- **N1. The color of a hat.** `\overline{(t)}(p)` for "the color of the
  hat at position `p` of tower `t`" is defined with the operators `>>` and
  `%` of programming languages, and the overline with parentheses is
  heavy in the proofs (`\overline{(2^n-1)}\big(a(2^n-1)\big)`). Proposal:
  `t_p`, defined as the binary digit of weight `2^p` of `t`, and 0 when
  `p` is not a position of the tower. The matrices of the proofs become
  readable.
- **N2. Operators of programming.** `t \gg m`, `t \mathbin{\%} 2^n`.
  Proposal: `\lfloor t / 2^m \rfloor` and `t \bmod 2^n`, or one sentence
  that splits a tower into its `m` lowest hats and the rest.
- **N3. Two families of T.** `\mathbb{T}_n` is the set of towers and
  `\mathbf{T}_n` the "top" strategy. Blackboard bold is otherwise kept for
  number sets. Proposal: a calligraphic or plain letter for the sets of
  towers and of strategies; the bold letters stay for the named
  strategies.
- **N4. Three uses of square brackets.** `[n]` is the set `{0, ..., n-1}`,
  `[0010]` is a strategy, and `[n]^{T_n}` is a set of strategies. The set
  `[n]` starting at 0 is the convention of set theory; combinatorics
  usually starts at 1. Proposal: keep `[n]` for the set, say so once, and
  write strategies in another way (a typewriter word such as `0010`,
  which is also what the calculator prints and reads).
- **N5. The names "left" and "right".** A left reset hands over when the
  lowest hats are all black, a right reset when they are all white. The
  words come from the position of the all-black and all-white towers in
  the tuple, which the text never says. Proposal: say it, or rename them
  after the colors (the lowest-white strategies are the iterated left
  resets, the lowest-black ones the iterated right resets).
- **N6. The reset arrows.** `b -> a` means "`a` left-reset by `b`", so the
  operands swap between `LR(a, b)` and the arrow, and the strategy that
  plays first stands on the right. The double reset has no arrow.
  Proposal: one written order for the three resets, the same in the
  calculator (`lr(a, b)`), and a sentence that fixes how to read it ("`a`,
  and `b` above it when `a` gives up").
- **N7. The shift arrows.** `\uparrow s`, `s \uparrow`, `s \Uparrow`
  rely on the side of the arrow and need manual spacing (`\!`).
  Proposal: keep them (they are compact and the calculator's names `ls`,
  `rs`, `ds` map onto them), define them with a macro, and add the
  sentence that says what a shift is: the strategy on one more hat that
  differs at a single tower.
- **N8. eta and mu.** `\eta_{t,u}(s)` is an outcome (0 or 1),
  `\eta(s)` a count in post 1 and a set in post 3; `\mu(s)` is the win
  rate, "or measure", and in post 3 `\mu` is also the measure itself
  (`\mu(s) = \mu(\eta(s))`). Proposal: three names for three things (an
  outcome, a hit count or hit set, a probability), the same in the three
  posts.
- **N9. Grouping of digits.** Tuples are cut by hyphens into groups of 1,
  2, 4 or 8 digits, with a double hyphen in some places, and the hyphens
  are typed as `\text{-}` inside formulas. Proposal: one rule (groups of 8
  from 16 digits on, as the calculator prints), stated once.
- **N10. Fractions.** `{1 \over 4}`: `\over` is a TeX primitive that
  `amsmath` warns against. Proposal: `\frac`, and `\tfrac` in the text and
  in the tables.
- **N11. Hats in formulas.** The characters ● and ○ stand inside formulas;
  spec 0001 asks for commands there. Proposal: two macros, drawn like the
  beads of the rosary paper (`\blackmark`, `\whitemark` of
  `data/mathjax.json`).
- **N12. "By definition".** `\stackrel{\text{def}}{=}` and
  `\stackrel{\text{def}}{\iff}` appear about 30 times. Proposal: `:=` for
  the first, words for the second ("we say that...").
- **N13. Equation numbers.** Post 1 numbers nearly 50 formulas and refers to 9 of
  them. References are typed `$(\ref{...})$`. Proposal: number the formulas that
  are referred to, and refer with `\eqref`.
- **N14. Post 3.** `T_{<N}`, `T_N`, `S_N`, `[2]^N`, the subscript `omega`
  for limits, `0_omega`, `s | k` (typed `s\!\mid\!k`) for an initial
  segment, `card`, and X_n used for two different sequences. Proposal:
  settle these with N1 to N8, and give the Carter and the Reyes sequences
  different names.

#### Proposed notation

A proposal to be discussed, not a decision. It answers N1 to N14 together.
The guiding choices: one written order for all operations, from the bottom
of the tower up; the two colors named by the marks of the hats, never by
"left" and "right"; no symbol where a word does.

| Object | Now | Proposed | Remark |
|---|---|---|---|
| Towers of `n` hats | `\mathbb{T}_n`, also `[2^n]` and `\{0,1\}^{[n]}` | `\mathcal{T}_n`, the integers `0` to `2^n - 1` | one description; the set `[n]` is no longer needed |
| Color of the hat at position `p` | `\overline{(t)}(p)`, with `\gg` and `\%` | `t_p`, the binary digit of weight `2^p`; `0` outside the tower | N1, N2 |
| The `m` lowest hats, the rest | `t \% 2^m`, `t \gg m` | `t_{<m}`, `t_{\geq m}` | also replaces `s \mid k` of post 3 |
| Strategies on `n` hats | `\mathbb{S}_n = \mathbb{Z}^{\mathbb{T}_n}` | `\mathcal{S}_n` | N3 |
| A strategy that stays in its tower | `s \in [n]^{\mathbb{T}_n}` | a word: a *proper* strategy | the condition of D1, used in most statements |
| A strategy written out | `[0010]`, `[0100\text{-}2123]` | `\mathtt{0010}`, groups of 8 from 16 digits on | N4, N9; what the calculator reads and prints |
| The strategy on no hat | `[-1]`, `\mathbf{T}_0` | `\varnothing` | it chooses no hat; the calculator keeps `T0` |
| Outcome on a pair of towers | `\eta_{t,u}(s)` | `t_{s(u)}\, u_{s(t)}`, written out | no name needed |
| Hits | `\eta(s)`, a number, then a set | `H(s)`, always the set of winning pairs; `\lvert H(s) \rvert` its size | N8 |
| Win rate | `\mu(s)` | `P(s)`, a probability: `\lvert H(s) \rvert / 4^n`, and the measure of `H(s)` for infinite towers | N8 |
| Same hits | `a \equiv b` | "`a` and `b` have the same hits" | used three times |
| Embedding | `e_m(s)` | none: a strategy on `n` hats plays a taller tower by its `n` lowest hats | as post 3 already does |
| Left reset | `b \rightarrow a`, `LR(a,b)` | `a \rhd_{\bullet} b`, the *black reset*: `a`, and `b` above it when the hats of `a` are all black | N5, N6 |
| Right reset | `a \leftarrow b`, `RR(a,b)` | `a \rhd_{\circ} b`, the *white reset* | |
| Double reset | `DR(a,b)` | `a \rhd_{\bullet\circ} b` | not associative: parentheses stay |
| Left, right, double shift | `\uparrow\!s`, `s\!\uparrow`, `s\!\Uparrow` | `\sigma_{\bullet}(s)`, `\sigma_{\circ}(s)`, `\sigma_{\bullet\circ}(s)`: the black, white and double shift | N7; no manual spacing |
| Named strategies | `\mathbf{T}_n`, `\mathbf{W}_n`, `\mathbf{B}_n`, `\mathbf{C}_n`, `\mathbf{R}_n` | unchanged | the clash with the sets is gone |
| Infinite towers | `\mathbb{T}_{\mathbb{N}}`, `\mathbb{T}_{<\mathbb{N}}` | `\mathcal{T}_{\infty}`; "finite towers" in words | N14 |
| Limit strategies | `\mathbf{W}_\omega`, `\mathbf{C}_\omega`, `\mathbf{R}_\omega` | `\mathbf{W}_\infty`, `\mathbf{C}_\infty`, `\mathbf{R}_\infty` | no ordinal is involved |
| By definition | `\stackrel{\text{def}}{=}` | `:=` | N12 |
| Fractions | `{1 \over 4}` | `\frac14`, `\tfrac14` in text and tables | N10 |
| Hats in formulas | ●, ○ | `\bullet`, `\circ` as indices; the marks of the rosary paper in drawings of towers | N11 |

With it the lowest-white strategy reads
`\mathbf{W}_n = \mathtt{00} \rhd_{\bullet} \cdots \rhd_{\bullet} \mathtt{00}`
(`n` times, from the bottom up), and the Reyes strategy
`\mathbf{R}_{n+1} = \mathbf{C}_3 \rhd_{\bullet\circ} \mathbf{R}_n`.

Accepted by the author on 2026-11-24: the resets are named after the
color that triggers them, with the hat marks on the operator
(`\rhd_{\bullet}`, `\rhd_{\circ}`, `\rhd_{\bullet\circ}`). The article
keeps one sentence on the tuple: the all-black tower is its left end and
the all-white tower its right end, which is where "left" and "right" came
from. The rest of the table is still to be decided.

Two remarks that the new names make visible, to be said in the article:

- the black shift of `s` has the same hits as `s \rhd_{\bullet} \mathtt{00}`,
  and the white shift differs from `s \rhd_{\circ} \mathtt{00}` at the
  all-white tower only (this is how post 1 proves their win rates);
- the calculator keeps its names (`lr`, `rr`, `dr`, `ls`, `rs`, `ds`) or
  takes new ones; either way the article gives the correspondence.

### 4. Prose

- **P1. Spelling and grammar.** Examples, not a full list: "exercice"
  (exercise), "strategie" (strategy), "uple" (tuple), "do not"looking"",
  "which provide a convenient way", "wins.:", "run in from the terminal",
  "these optimization", "independent on", "allows to consider", "Here we
  look at case", "better the win rates". "Formulae" and "formulas" are
  both used. Spelling is American in this repository.
- **P2. The game is never stated for finite towers.** Post 1 opens with a
  quotation about countably many hats, then "Finite case" starts with
  definitions. A reader is not told what the game with `n` hats is, nor
  that it is the game the article studies.
- **P3. The results are not announced.** The reader meets six operations
  and six formulas before learning what they are for: an explicit family
  of strategies whose win rate tends to 7/20. Proposal: say it at the
  start, with the table of the Carter strategies as the goal.
- **P4. Examples come before definitions.** Each operation starts with a
  table of examples and its caption, then the definition. The examples
  cannot be read at that point.
- **P5. Statements are not marked.** Definitions, properties and proofs
  are plain paragraphs ("Proof:", a final box inside a formula). Proposal:
  the form of the rosary paper ("**Proposition 2.**", "*Proof.*"), which
  the site numbers, checks and links.
- **P6. Five levels of headings**, the last one for "Example", "Hit
  score", "Win rate", "Equivalence".
- **P7. Tables.** The hit table of W_2 puts two rows and two columns of
  headings in the body. Several tables hold a single column of formulas.
  "Efficiency of various strategies" mixes facts ("yes"), conjectures
  ("yes?") and negative statements ("no for n > 2") in one column without
  saying what is proved.
- **P8. Captions** are quotations, like the quoted introduction of post 1.
- **P9. Series.** The three posts call themselves "exercices de style" and
  each repeats an opening paragraph and a list of links. Titles, opening
  and navigation should be decided once (and the directory
  `tower-of-hats` has the singular where the title has the plural).
- **P10. Post 2 reads as a manual.** It gives the commands but not what one
  learns with them; its performance figures are those of a 2015 laptop.
- **P11. Voice.** "I borrow...", "I came across...", "I plan to..." in the
  first person, definitions in the "we" of mathematics. Decided on
  2026-11-24: the playful tone stays (this is recreational mathematics),
  toned down where it gets in the way of a statement or a proof.

### 5. Keeping the work checkable

- **K1. A check program.** `research/hats/check_posts.py` (the place and
  the form of `research/jane-s-rosary/`): it recomputes every tuple, score,
  win rate and example of the three posts from the definitions, and the
  six win-rate formulas on all strategies of small towers, in range and
  out of range. A table "Checked by computer" in post 1 names it, as in
  the rosary paper. The independent program used for this spec is its
  starting point.
- **K2. The imported texts stay available.** The three posts as imported
  are kept as earlier versions under `content/versions/`, with a history
  entry in the front matter of each post, so that the comparison page
  shows what changed (spec 0002, invariant 0003).
- **K3. The trees as vector drawings.** The trees and automata of post 3
  can now be built from sources (`research/hats/diagrams/`). Proposal:
  publish them as SVG with a dark variant, like Figures 9, 10 and 12 of
  the rosary paper, instead of raster pictures on a forced white
  background. The trees of the "full" kind overlap in their last row and
  need a smaller depth or another layout.

### 6. Assessment: what else deserves improvement

In decreasing order of what it would bring.

1. **The proofs of the win-rate formulas.** They sum the entries of a
   symmetric matrix with dotted rows. Each formula has a two-line proof by
   cases: split on whether the lowest hats of each player are all black
   (or all white). For the left reset: if neither lower part is all black,
   both play `a`; if both are, both play `b` on the rest; if exactly one
   is, the other player points at a black hat. That gives
   `mu(a) + mu(b) / 4^m` at once, shows where the in-range condition is
   used (D1), and the other five formulas follow the same pattern. This
   would shorten post 1 by a third and remove most of D2 to D8.
2. **Post 3 needs mathematics, not only editing.** Its three results are
   right, but none is proved (D37). A fixed-point argument does it in one
   line each: the Reyes limit is "C_3 double-reset by itself", so its win
   rate `x` satisfies `x = 22/64 + (4x - 1)/64`, hence `x = 7/20` (from
   the notes; the equation was checked here). The same for the lowest
   white hat: `x = 1/4 + x/4`, which is the computation quoted at the top
   of post 1. The limits and the measure then need one careful paragraph
   instead of three sketches.
3. **A remark the articles do not make.** R_n and C_(2n+1) have the same
   win rate, `7/20 - 1/(10 * 16^n)`, on `3n` and `2n+1` hats. The Reyes
   strategies therefore bring nothing in the finite game; their interest
   is the simple block structure, which is what post 3 uses. Saying so
   would explain why both families are there.
4. **What is new and what is known.** According to the notes, the
   operations with proved formulas, and the closed form for the Carter
   scores, were not found in the literature, while the 7/20 strategy and
   the scores up to 8 hats were known in 2014. The articles claim novelty
   for the wrong thing (D21) and do not claim it for the right one. This
   decides the introduction and the recap, and depends on the open
   question about scope.
5. **The calculator as a figure of the site.** It is embedded as a box
   with a text field that shows nothing until "Submit" is pressed, and
   its help is the first thing a reader would need. A default query that
   shows something, examples one can click, and the trees of post 3 drawn
   live from `tikz`-like data would make post 2 worth its place.
6. **One article or three.** Post 2 is short and post 3 is unfinished.
   Posts 1 and 3 together, with the calculator as a figure, would make one
   paper of the size of the rosary paper, and a natural candidate for
   arXiv.

### 7. New material, from `levine-hats`

The author decided on 2026-11-24 that these results belong in the
articles. The list follows `levine-hats/NOTES.md` (Sections 0, 2 and 3);
each item must be checked again when it is written up, and stated with the
kind of evidence it has.

- **M1. A closed form.** The Carter strategy on `n` hats scores exactly
  `floor(7 * 4^n / 20)` (recomputed here for `n` from 1 to 7: 1, 5, 22,
  89, 358, 1433, 5734).
- **M2. A reformulation of the conjecture.** "The Carter strategies are
  optimal for every `n`" is equivalent to "the value of the game with
  infinitely many hats is 7/20".
- **M3. Relation to recent work.** According to the notes, the double-reset
  rule contains as special cases two inequalities of Bouquet et al.
  (2025), the Carter strategies beat their finite lower bounds from 7 hats
  on, and double-resetting an odd Carter strategy seems to answer one of
  their questions. The notes say that their paper was only partly read:
  this needs a full reading before anything is claimed.
- **M4. Five hats.** 358 out of 1024 is optimal when both players use the
  same strategy (three independent programs, one in exact arithmetic).
  When they may use different strategies, one solver gives 358 as well;
  the notes ask for a second confirmation and a check of the literature
  before this is claimed.
- **M5. Six hats.** An upper bound of 1448 out of 4096, against 1433 for
  the best known strategy. It is the output of a floating-point solver,
  not a certificate.
- **M6. What is known and what is new** (fourth point of the assessment):
  the 7/20 strategy, its fixed-point computation and the scores up to 8
  hats were known in 2014; the operations with proved formulas and M1 to
  M3 were not found in the sources.

The programs behind M4 and M5 live in `levine-hats`, which has no remote
and uncommitted changes. What the articles rely on must be brought into
this repository (`research/hats/`) or published with it, as was done for
the rosary paper.

## Invariants

None is created by this spec. K2 extends invariant 0003 (frozen versions)
to the three posts once it is carried out.

## Open questions

- The proposed notation (Section 3): accepted as a whole, in part, or
  replaced by another proposal?
- D17: which R_1? C_3 (the text, the calculator, the pictures of post 3)
  is the natural choice; the table then changes.
- The address and the date of the single article, and what the three old
  addresses become (earlier versions, with a notice that points to the
  article).
- Where the new material goes: M1 and M2 are short and belong with the
  Carter strategies; M4 and M5 need a section on computations.

Decided on 2026-11-24: the results of `levine-hats` enter; one article and
one blog entry; the playful tone stays; Lean verification is wanted, as
early as possible; order of work: the defects first (Sections 1 and 2,
with K1 and K2), then the notation, the prose and the new material.

## References

- `docs/specs/0001-static-site.md`: rules for mathematics, import policy.
- `docs/specs/0002-rosary-presentation-overhaul.md`: how the rosary paper
  was revised, earlier versions and the comparison page.
- `docs/invariants/0003-frozen-versions.md`.
- `levine-hats/NOTES.md` (repository `levine-hats`, 2026-11-16),
  Sections 1 and 2.
- `figures/hats/README.md`, `research/hats/diagrams/README.md`.
- arXiv records read on 2026-11-24: 1407.4711 (Buhler et al.), 2103.01541
  (Friedgut, Kalai, Kindler), 2208.06858 (Alon, Friedgut, Kalai, Kindler),
  2508.01737 (Bouquet et al.), 1006.1003 (Friedrich, Levine).
