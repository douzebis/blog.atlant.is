<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# The search for the best strategy, as a fast Lean program

The search of the hats calculator (`figures/hats/hats.js`, command
`search`), written in Lean and compiled to a native program.

```sh
cd research/hats/search-lean
lake build 2>&1 | tee /tmp/hats-search-lean-build.log
.lake/build/bin/hats-search 4        # one task
.lake/build/bin/hats-search 4 4      # the choices of 4 stacks shared out to tasks
```

It tries every crushed strategy on `n` hats (2 to 4), with fixed choices
for the all-white and the all-black stacks, and prints the most hits and
how many strategies reach it:

```
4 hats: best 89 hits out of 256, reached by 102 strategies
```

The calculator prints the same two numbers.

It is not verified. The verified search is `Hats.bestFast`
(`formal/hats/Hats/SearchFast.lean`), proved to return the most hits of
any strategy; it is the same enumeration, written plainly and much
slower.

## How it goes fast

- The counts that the score needs are kept in four machine words, one per
  chosen position, each cut into fields of 8 bits, one per position.
  Choosing for a stack costs a few additions and shifts of words, whatever
  the number of stacks already seen. (The calculator does the same with
  fields of 5 bits in JavaScript numbers.)
- The last stack that has a choice is not a level of the recursion: its
  four scores are read from one word.
- The search is cut into tasks by fixing the choices of the first stacks
  in every way; the tasks run on all the cores.

There is no SIMD instruction in it: Lean has no access to them. Packing
several counters in one word is the same idea within a register.

## Timings

On the shared 12-core host of 2026-11-24, four hats (100,663,296
strategies), best of a few runs; indicative only:

| Program | Time |
|---|---|
| `hats.js`, generated search code, Node 24 | 0.6 to 1.0 s |
| `hats-search 4` (one task) | 0.41 to 0.48 s |
| `hats-search 4 4` (96 tasks) | 0.065 s |
