<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# 0008 — Hats: searching for strategies by machine, three players first

**Status:** in-progress
**App:** blog.atlant.is (research on the game of hats)
**Implemented in:** <!-- YYYY-MM-DD, fill after implementation -->

## Problem

For two players the Carter strategies are very likely optimal
(`docs/papers/hats/open-questions.md`, items 1 and 8a), and a search by
machine would most likely find them again. For three players and more
the situation is different. The best strategies known (Buhler et al.,
arXiv 1407.4711, Section 5 and Appendix E.4) are tables found by hill
climbing in 2014:

| Players | Hats in a tier | Wins | With resets | Win rate |
|---|---|---|---|---|
| 3 | 5 | 9,120 of 32,768 | 9,119 / 32,670 | 0.279124 |
| 4 | 4 | 14,845 of 65,536 | 14,844 / 64,120 | 0.231503 |

Both are symmetric (all players use the same table, which does not
depend on the order of the stacks seen). There is no formula, no rule in
words, no family in the number of hats, and no claim that they are
optimal. The only upper bound is that of two players, 81/224 = 0.3616.
Our resets and shifts have no counterpart for three players (open
question 3).

## Goals

1. **Ground truth.** A scorer for `n` players and `t` hats, exact, and
   checked: on two players against `research/hats/check_article.py`; on
   three players against an enumeration for 1 and 2 hats and an integer
   program for 3 hats.
2. **Baselines.** Hill climbing, simulated annealing and gradient ascent
   on "soft" strategies (a probability for each position, rounded at the
   end), for three players on 3 to 6 hats. Success: 9,120 of 32,768 on
   five hats is found again, or beaten.
3. **A calculus for three players.** The resets of the paper (reset when
   another player's tier is all white; reset when all the others' tiers
   are all black) as operations with formulas for the wins, checked by
   the scorer. Success: 9,119 / 32,670 is recomputed from 9,120.
4. **Strategies as programs.** A search over short programs (a function
   from the stacks seen to a position, valid for every number of hats,
   written in a small language that has no input or output),
   proposed by a language model and scored on 2 to 6 hats at once.
   Success, in increasing order: a program that equals the best table on
   five hats; a rule in words for it; a family with a formula in the
   number of hats; a win rate above 0.279124.
5. **A record of everything**, in `docs/papers/hats/three-players.md`:
   what was tried, what it gave, the seeds, the times.

## Non-goals

- Beating 7/20 for two players.
- Upper bounds for three players.
- Training a neural network from scratch on a GPU (a later step, only if
  step 4 shows that the tables have a structure that programs miss).
- A section of the article: decided when there is a result.

## Specification

### Layout

```
research/hats/players/
  Cargo.toml, src/   one Rust project:
    score            wins of a strategy table, n players, t hats
    climb            hill climbing and simulated annealing
    lang             the small language: parser and evaluator
  score.py           the scorer again, in Python, slow: the reference
  soft.py            gradient ascent on soft strategies (numpy)
  resets.py          the two resets, their formulas, checks
  candidates/        the search over programs: sources, scores, log
  results/           the best tables found, as text, with their scores
docs/papers/hats/three-players.md
```

### The game and the scorer

Three players, each with a stack of `t` hats; each sees the two other
stacks and points at one of their own hats; they win when all three
hats are black. A symmetric strategy is a table `s(u, v)` with
`s(u, v) = s(v, u)`, the same for the three players. The wins are the
triples `(a, b, c)` of stacks with `a` black at `s(b, c)`, `b` black at
`s(a, c)` and `c` black at `s(a, b)`: `8^t` triples to test, 32,768 for
five hats, 2 million for seven. The scorer also takes three different
tables, not symmetric.

### Baselines (goal 2)

- Moves: change one entry of the table (two entries at once when the
  table is kept symmetric). The change in wins of one move is computed
  in `4^t` steps, not `8^t`.
- Hill climbing with restarts, then annealing, then the walk on plateaus
  of `research/hats/local-search/`.
- Soft strategies: the expected wins are a polynomial of degree 3 in the
  probabilities; ascent, then rounding, then hill climbing.
- Budget: one hour of 8 cores per number of hats to begin with.

### Programs (goal 4)

Requirement (decided by the author on 2026-11-27): **a candidate does no
input or output of any kind**, and nothing that a model writes is ever
run as code by Python, a shell or a compiler.

- A candidate is therefore data: an expression in a small language of
  this project, read by a parser and computed by an evaluator of this
  project. The language has the inputs (the number of hats `t`, the
  stacks seen), a fixed list of pure building blocks (the lowest black
  hat of a stack, the lowest white hat, the number of black hats, the
  color of a hat at a position, "these `k` hats are of one color"),
  whole-number arithmetic, comparisons, `if`, and named sub-expressions.
  It has no loop without a bound, no call outside the list, no string,
  no file, no import: these cannot be written.
- What the parser does not accept is rejected. The evaluator counts its
  steps and stops a candidate over its budget. The text of a candidate
  is never passed to a shell nor used as a file name.
- The list of building blocks is extended by a change of this project,
  never by a candidate. Each extension is recorded in the notes.
- A candidate is at most about 30 lines. The language cannot express a
  table of constants indexed by the stacks, nor a search.
- Score: the wins on 2, 3, 4, 5 and 6 hats, each divided by the best
  known for that number of hats, and the size of the expression as a
  tie-breaker.
- Loop: keep a population of the best candidates in a few separate
  groups; ask the model for a variation of one or a combination of two,
  given their sources and scores; parse, evaluate, score; keep it if it
  scores. The model is used as it is: its weights are not changed.
- Seeds for the population: the lowest black hat (Winkler's sum modulo
  `t`), the tier-and-reset strategies of the paper, and expressions
  fitted to the best table of goal 2.
- Every candidate, its score and its parent are logged; a result is
  reproduced by evaluating the logged source.
- The parser, the evaluator, the scorer and the baseline searches are
  one Rust project (decided by the author on 2026-11-27). Its binary
  reads the text of a candidate on its standard input and prints the
  scores. `score.py` stays as a slow reference to check the scorer. The
  loop that calls the model, if there is one, is a separate small
  script that passes the model's text to that binary unread.

### Stopping rules

- After goal 2: if 9,120 is not found again within 20 core-hours, stop
  and report (the baseline is then the result: the 2014 search is hard
  to reproduce).
- After goal 4: stop at 2,000 candidates or one week, whichever comes
  first, and report whatever the outcome.

## Invariants

None is created. Results quoted in the notes are recomputed by the
reference scorer `score.py` before they are written down.

## What is needed to start

1. **Where the candidates of goal 4 come from** (decided by the author
   on 2026-11-27): the assistant writes them, in working sessions, first
   by itself, then with helper agents for the bulk of the variations.
   The model that wrote each candidate is logged with it, so that what
   each model brings can be compared on the first hundred candidates.
2. **Computing time.** Goals 1 to 3 fit on this machine (8 cores for a
   few hours, at low priority). Long annealing runs on 6 and 7 hats
   would go to the other machine.
3. **Nothing else**: no GPU, no data, no new dependency beyond numpy,
   which the shell of `levine-hats` already has.

## Open questions

- Symmetric tables only, or three different tables too? The paper's
  best are symmetric; the scorer handles both; the search space is 6
  times larger without symmetry.
- Four players at the same time, or only after three? Proposal: after.
- Whether the tables of 2014 can be obtained from the authors (the
  paper gives the scores, not the tables). Having them would make goal 2
  a check instead of a search.
- Where this goes if it works: a section of the article, or a note of
  its own.
