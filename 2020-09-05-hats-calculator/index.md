---
title: "Hats Calculator (2/3)"
date: "2020-09-05"
---

![The hats medic](http://blog.atlant.is/wp-content/uploads/2020/09/hats-medic.png)

The hats medic

This is the second in a series of three _exercices de style_ to show some interesting aspects of the _game of hats_: a puzzle which was initially proposed by Lionel Levine.

- [First exercice](https://blog.atlant.is/?p=1183)

Here we introduce the _hats calculator_: a toy application which implements the operations introduced [in the first exercice](https://blog.atlant.is/?p=1183#Operations_on_strategies).

## Try it yourself

\[auto-iframe link="https://fredatatlantis.github.io/hats/hats.html" width="100%" height=330 autosize=no scroll=yes\]

## Installing the hats calculator

The hats calculator is a single file JavaScript application.

Clone it from the [repository on GitHub](https://github.com/fredatatlantis/hats):

Use the [D8 JavaScript shell](https://v8.dev/docs/d8) to run in from the terminal.

## Evaluating strategies

The syntax for evaluating strategy expressions is as follows:

`<expr>` can be a strategy or a call to an operation on strategies. Strategies are keyed in as arrays, strings (shortened notation), or using predefined constant names.

Predefined constants include:

- `T0`: Top strategy $\\mathbf{T}\_0$
- `W0`, $\\cdots$, `W9`: Lowest-white strategies $\\mathbf{W}\_n$
- `B0`, $\\cdots$, `B9`: Lowest-black strategies $\\mathbf{B}\_n$
- `C1`, $\\cdots$, `C9`: Carter strategies $\\mathbf{C}\_n$
- `R0`, $\\cdots$, `R3`: Reyes strategies $\\mathbf{R}\_n$

Available operations include:

- `lr(a, b)`: `a` left-reset by `b` ($b \\rightarrow a$)
- `rr(a, b)`: `a` right-reset by `b` ($a \\leftarrow b$)
- `dr(a, b)`: `a` double-reset by `b` ($DR(a, b)$)
- `ls(a)`: `a` left-shifted ($\\uparrow\\!a$)
- `rs(a)`: `a` right-shifted ($a\\!\\uparrow$)
- `ds(a)`: `a` double-shifted ($a\\!\\Uparrow$)
- `emb(a, n)`: `a` embedded in $\\mathbb{S}\_\\text{n}$ ($e\_n(a)$)
- `crush(a)`: a transform of `a` with the same hit score but such that $\\forall t, \\; a(t) \\le t$.

## Searching for optimal strategies

The syntax for searching for optimal strategies is as follows:

- `-n`: specifies the height of the strategies (defaults to $1$)
- `-s`: limits the search to strategies close to a seed strategy (defaults to the constant zero strategy)
- `-d`: limits the search to strategies within a specified hamming distance of the seed strategy (defaults $0$ which means no limit)
- `-a`: displays all occurrences of optimal strategies, not just the first one
- `-q`: works quietly, displays only a summary line
- `-c`: don't actually perform the search; instead: prints the optimized JavaScript code which performs the search

### Performance

Measured on chrome on a MacBook Pro 2015.

For $n = 4$, the search for the optimal strategy takes about $0.8$ second and compares $100\\,663\\,296$ strategies.

\# of strategies compared

$100\\,663\\,296$

Processing time

$0.82$ s

Duration per strategy rating

$8.15$ ns

\# of processor cycles per rating

$25$

Search performance for $n = 4$ (chrome on MacBook Pro 2015, 3.1 GHz)

For $n = 5$ the search for the optimal strategy would theoretically take $\\approx 113\\,000$ years and would compare $178\\,813\\,934\\,326\\,171\\,875\\,000$ strategies!

\# of strategies compared

$178\\,813\\,934\\,326\\,171\\,875\\,000$

Processing time

$\\approx 113\\,000$ years

Duration per strategy rating

$\\approx20$ ns

\# of processor cycles per rating

$\\approx62$

Search performance for $n = 5$ (chrome on MacBook Pro 2015, 3.1 GHz)

## Implementation tips

`hats.js` implements several optimizations to increase the performance of the search.

1. Uses the fact that the hit score is independent on the choice a strategy makes for a tower all black or all white. For $n = 5$ this decreases the cardinality of the problem by a factor of $25$.
2. Uses an argument on "positions permutation" which allows to consider only _crushed_ strategies (for which $\\forall s, \\; s(t) \\le t$). For $n = 5$ this decreases the cardinality of the problem by an additional factor of $6$.
3. Computes the hit score incrementally, changing one strategy choice at a time. For $n = 5$ this decreases the execution time by an additional factor of $32$.
4. Uses a smart representation of strategy choices as bit patterns, which enables a faster computation of the incremental hit score.
5. Eliminates most loops, indices, and array accesses by automatically generating "unfolded specialized" search code, optimized for each specific search query\[efn\_note\]This technique leverages the ability of JavaScript to process _self-modifying_ code, for example using the _worker_ construct.\[/efn\_note\]. To have a look at the generated code, try e.g.: `search -n 4 -c` in the _Try it yourself_ window.
6. Tries to keep code and data of the search algorithm as much as possible within the processor cache. (Significant performance decrease is observed with less concise code.)

Automatically generated code pattern for the search algorithm

Unfortunately, these optimization do not make the $114\\,000$ years computation time for $n = 5$ any more accessible. Different methods than brute force are definitely needed.

## What's next

In the next article I plan to go back to the theory of the game of hats and tackle the problem of playing with infinite towers.
