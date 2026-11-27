---
# SPDX-FileCopyrightText: 2020 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: CC-BY-4.0

title: "Hats Calculator (2/3)"
date: "2020-09-05"
language: "en"
math: true
toc: true
version: "2020"
version_date: "2020-09-05"
version_of: "posts/2020-08-30-the-game-of-hats"
version_note: "The second of the three posts of 2020, as it stood on the author's WordPress blog, blog.douzeb.is. The players point at white hats, white is the digit 1, and a stack of hats is called a tower."
wordpress_id: 1893
categories:
  - "coding"
  - "friandises"
  - "geek"
---

![The hats medic](images/hats-medic.png)

> The hats medic (picture: *Team Fortress 2*, © Valve Corporation)

This is the second in a series of three _exercices de style_ to show some interesting aspects of the _game of hats_: a puzzle which was initially proposed by Lionel Levine.

- [First exercice](../2020-08-30-tower-of-hats/)
- [Second exercice](../2020-09-05-hats-calculator/)
- [Third exercice](../2020-09-26-infinitely-many-hats-3-3/)

Here we introduce the _hats calculator_: a toy application which implements the operations introduced [in the first exercice](../2020-08-30-tower-of-hats/#operations-on-strategies).

## Try it yourself

{{< frame src="https://blog.atlant.is/figures/hats/hats.html" width="100%" height="330" >}}

## Installing the hats calculator

The hats calculator is a single file JavaScript application.

Clone it from the [repository on GitHub](https://github.com/douzebis/hats):

```console
$ git clone git@github.com:douzebis/hats.git
$ cd hats
```

Use the [D8 JavaScript shell](https://v8.dev/docs/d8) to run in from the terminal.

## Evaluating strategies

The syntax for evaluating strategy expressions is as follows:

```console
$ d8 hats.js -- eval '<expr>'
```

`<expr>` can be a strategy or a call to an operation on strategies. Strategies are keyed in as arrays, strings (shortened notation), or using predefined constant names.

```console
$ d8 hats.js -- eval '[0,1,0,0]'
"0100" mu = 5/16 = 31.25%
$ d8 hats.js -- eval '"0100"'
"0100" mu = 5/16 = 31.25%
$ d8 hats.js -- eval '[1,1,-1,-1]'
[1,1,-1,-1] mu = 0/16 = 0%
$ d8 hats.js -- eval 'C3'
"01002120" mu = 22/64 ~ 34.38%
```

Predefined constants include:

- `T0`: Top strategy $\mathbf{T}_0$
- `W0`, $\cdots$, `W9`: Lowest-white strategies $\mathbf{W}_n$
- `B0`, $\cdots$, `B9`: Lowest-black strategies $\mathbf{B}_n$
- `C1`, $\cdots$, `C9`: Carter strategies $\mathbf{C}_n$
- `R0`, $\cdots$, `R3`: Reyes strategies $\mathbf{R}_n$

Available operations include:

- `lr(a, b)`: `a` left-reset by `b` ($b \rightarrow a$)
- `rr(a, b)`: `a` right-reset by `b` ($a \leftarrow b$)
- `dr(a, b)`: `a` double-reset by `b` ($DR(a, b)$)
- `ls(a)`: `a` left-shifted ($\uparrow\!a$)
- `rs(a)`: `a` right-shifted ($a\!\uparrow$)
- `ds(a)`: `a` double-shifted ($a\!\Uparrow$)
- `emb(a, n)`: `a` embedded in $\mathbb{S}_\text{n}$ ($e_n(a)$)
- `crush(a)`: a transform of `a` with the same hit score but such that $\forall t, \; a(t) \le t$.

```console
$ d8 hats.js -- eval 'dr(dr(W2,W1),W1)'
"30122013-30122013" mu = 80/256 = 31.25%
$ d8 hats.js -- eval 'dr(W2,dr(W1,W1))'
"30133013-30133013" mu = 80/256 = 31.25%
$ d8 hats.js -- eval 'dr(W2,dr(W1,W1))'
"30133013-30133013" mu = 80/256 = 31.25%
$ d8 hats.js -- eval 'dr(ds(W1),ds(W1))'
"31002123-41002124--31002123-31002123
 51002125-41002124--51002125-31002123" mu = 1432/4096 ~ 34.96%
```

## Searching for optimal strategies

The syntax for searching for optimal strategies is as follows:

```console
$ d8 hats.js -- search [-n <num>] [-s <seed>] [-d <distance>] [-a] [-q] [-c]
```

- `-n`: specifies the height of the strategies (defaults to $1$)
- `-s`: limits the search to strategies close to a seed strategy (defaults to the constant zero strategy)
- `-d`: limits the search to strategies within a specified hamming distance of the seed strategy (defaults $0$ which means no limit)
- `-a`: displays all occurrences of optimal strategies, not just the first one
- `-q`: works quietly, displays only a summary line
- `-c`: don't actually perform the search; instead: prints the optimized JavaScript code which performs the search

```console
$ d8 hats.js -- search -n 4 -q
Done comparing 100 663 296 strategie(s) in 0.818s.
Best win rate is 89/256 ~ 34.77% (102 occurrences).
E.g.: "00003030-22223130"
$ d8 hats.js -- search -n 5 -d 6 -q
Done comparing 1 876 630 200 strategie(s) in 54s.
Best win rate is 292/1024 ~ 28.52% (155 occurrences).
E.g.: "00000000-00000000--00004040-40404040"
```

### Performance

Measured on chrome on a MacBook Pro 2015.

For $n = 4$, the search for the optimal strategy takes about $0.8$ second and compares $100\,663\,296$ strategies.

|   |   |
|---|---|
| # of strategies compared | $100\,663\,296$ |
| Processing time | $0.82$ s |
| Duration per strategy rating | $8.15$ ns |
| # of processor cycles per rating | $25$ |

> Search performance for $n = 4$ (chrome on MacBook Pro 2015, 3.1 GHz)

For $n = 5$ the search for the optimal strategy would theoretically take $\approx 113\,000$ years and would compare $178\,813\,934\,326\,171\,875\,000$ strategies!

|   |   |
|---|---|
| # of strategies compared | $178\,813\,934\,326\,171\,875\,000$ |
| Processing time | $\approx 113\,000$ years |
| Duration per strategy rating | $\approx20$ ns |
| # of processor cycles per rating | $\approx62$ |

> Search performance for $n = 5$ (chrome on MacBook Pro 2015, 3.1 GHz)

## Implementation tips

`hats.js` implements several optimizations to increase the performance of the search.

1. Uses the fact that the hit score is independent on the choice a strategy makes for a tower all black or all white. For $n = 5$ this decreases the cardinality of the problem by a factor of $25$.
2. Uses an argument on "positions permutation" which allows to consider only _crushed_ strategies (for which $\forall s, \; s(t) \le t$). For $n = 5$ this decreases the cardinality of the problem by an additional factor of $6$.
3. Computes the hit score incrementally, changing one strategy choice at a time. For $n = 5$ this decreases the execution time by an additional factor of $32$.
4. Uses a smart representation of strategy choices as bit patterns, which enables a faster computation of the incremental hit score.
5. Eliminates most loops, indices, and array accesses by automatically generating "unfolded specialized" search code, optimized for each specific search query[^1]. To have a look at the generated code, try e.g.: `search -n 4 -c` in the _Try it yourself_ window.
6. Tries to keep code and data of the search algorithm as much as possible within the processor cache. (Significant performance decrease is observed with less concise code.)

```js
// Compute incremental hit score of choices for tower 3
function x3(H) { // H is the current hit score
x4(H);
let e = ((s1 + s5 + s7 + s9 + s11 + s13 + s15) << 1) + s3;
H -= ((e + (e >> 5)) & 31)
s3 = 32;
e = ((s2 + s6 + s7 + s10 + s11 + s14 + s15) << 1) + s3;
x4(H +((e + (e >> 5)) & 31));
s3 = 1024;
e = ((s4 + s5 + s6 + s7 + s12 + s13 + s14 + s15) << 1);
x4(H + ((e + (e >> 5)) & 31));
s3 = 32768;
e = ((s8 + s9 + s10 + s11 + s12 + s13 + s14 + s15) << 1);
x4(H + ((e + (e >> 5)) & 31));
s3 = 1;
}
```

> Automatically generated code pattern for the search algorithm

Unfortunately, these optimization do not make the $114\,000$ years computation time for $n = 5$ any more accessible. Different methods than brute force are definitely needed.

## What's next

In the next article I plan to go back to the theory of the game of hats and tackle the problem of playing with infinite towers.

[^1]: This technique leverages the ability of JavaScript to process _self-modifying_ code, for example using the _worker_ construct.
