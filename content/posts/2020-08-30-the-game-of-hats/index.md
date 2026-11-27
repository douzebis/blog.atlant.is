---
# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: CC-BY-4.0

title: "The game of hats"
date: "2020-08-30"
language: "en"
math: true
toc: true
description: "Two players, a stack of black and white hats on each head; each points at one of their own hats, and they win when both hats are black. Strategies built with resets and shifts, their win rates, and the question whether 7/20 can be beaten."
# Until the article is complete it is on the site, but in no list and no
# feed, and search engines are asked to leave it out
# (docs/specs/0007-hats-article.md).
noindex: true
build:
  list: never
compare: "compare/the-game-of-hats"
history:
  - date: "2020-08-30"
    text: "Towers of hats, the first of three posts on the author's WordPress blog, blog.douzeb.is: resets, shifts and the families of strategies."
    version: "versions/the-game-of-hats/2020/2020-08-30-tower-of-hats"
  - date: "2020-09-05"
    text: "Hats Calculator, the second post: the calculator and the search for the best strategies on few hats."
    version: "versions/the-game-of-hats/2020/2020-09-05-hats-calculator"
  - date: "2020-09-26"
    text: "Infinitely Many Hats, the third post: strategies on infinite stacks."
    version: "versions/the-game-of-hats/2020/2020-09-26-infinitely-many-hats-3-3"
categories:
  - "friandises"
  - "math"
---

![A towering pillar of hats](images/hats-towering-pillar.png)

> A towering pillar of hats: stack $3$ (picture: *Team Fortress 2*, © Valve Corporation)

> This article is being written, one section at a time. It will replace the three posts of 2020, which are listed in its history above.

### 1. The game

Alice and Bob each wear a stack of hats. Each hat is black or white, as decided by the toss of a fair coin, one toss per hat. Alice sees Bob's stack and Bob sees Alice's, but nobody sees their own. Without a word or a wink, each of them points at one of their own hats. They win when both point at a black hat.

They may agree on a plan beforehand, and that is the whole question: what plan gives them the best chance?

Whatever Alice does, the hat she points at is black half of the time: the hats she sees tell her nothing about her own. The same goes for Bob. If the two of them point without thinking, they win one time in four. To do better they cannot improve their own luck; they can only arrange to be lucky together.

Here is a way. Each player looks for the lowest black hat of the other, and points at the same position on their own stack. We count positions from the bottom, starting at $0$. Take stacks of three hats:

$$
\begin{array}{ccc}
\text{position} & \text{Alice} & \text{Bob} \\
2 & \whitemark & \blackmark \\
1 & \blackmark & \blackmark \\
0 & \blackmark & \whitemark
\end{array}
$$

Bob's lowest black hat is at position $1$, so Alice points at her position $1$: black. Alice's lowest black hat is at position $0$, so Bob points at his position $0$: white. They lose. Had Bob's bottom hat been black, they would both have pointed at position $0$ and won.

How often does this plan win? Look at the two bottom hats. Both are black one time in four, and then the players win. They differ half of the time, and then the players lose: the one who sees the black bottom hat points at the bottom of their own stack, and that hat is white. Both are white one time in four, and then both players move up one hat and the game starts again, one position higher. With stacks that never end, the win rate $x$ satisfies $x = \frac14 + \frac14 x$, hence $x = \frac13$. With stacks of $n$ hats the players run out of hats once in $4^n$ games, and the win rate is $\frac13 \left(1 - \frac{1}{4^n}\right)$.

So $\frac14$ can be beaten. It can be beaten by more than that: there are plans that win $7$ times in $20$. Whether one can do better is not known.

#### Where the game comes from

The puzzle is due to Lionel Levine, and seems to have come out of his work with Tobias Friedrich on the fast simulation of growth models [FL13]. Tanya Khovanova made it public on her blog in 2011 [Kh11]. Levine's version has any number of players, each with an infinite stack, and they win when all of them point at a black hat; he conjectured that the best win rate tends to $0$ as the number of players grows. This article has two players only.

For two players, the plan above, with its win rate of $\frac13$, has no doubt been found by many. A plan that wins $7$ times in $20$ took three more years: it was found in 2014 by two groups, Larry Carter, Jay-C Reyes, Joel Rosenberg and Mark Tiefenbruck on one side, Jonathan Kariv and Dmytro Yeroshkin on the other [BFGKRTVY]. Stan Wagon made it a *Problem of the Week* that year [Wa14], and listed the best strategies then known on stacks of up to $8$ hats, which he credits to Carter and Reyes. That is where the strategies $\mathbf{C}_n$ and $\mathbf{R}_n$ of this article get their names.

The reference is now the paper of Buhler, Freiling, Graham, Kariv, Roche, Tiefenbruck, Van Alten and Yeroshkin [BFGKRTVY]. Write $V$ for the best win rate of two players. They prove

$$
\frac{7}{20} = 0.35 \;\leq\; V \;\leq\; \frac{81}{224} = 0.3616\ldots
$$

and conjecture that $V = \frac{7}{20}$. They also prove that the best win rate decreases with each player added, which Alon, Friedgut, Kalai and Kindler prove by other means [AFKK]. More recently, Bouquet, Chikhi, Charles, Zhou and Wang [BCCZW] found new plans that win $7$ times in $20$, built on blocks of five hats, then of any odd number of hats, where the plans of 2014 use blocks of three. They quote one more upper bound, $V \leq 0.37193$, obtained by Heilman and Tamuz without a computer [HT25]. A better upper bound, $V \leq \frac{57}{160} = 0.35625$, was claimed in November 2026 in a note that has not been reviewed [Ya26]; Section 8 confirms it by an independent computation.

The author met the game in 2020 through a video of *Numberphile* in which Joe Buhler presents it [Bu20], and wrote three blog posts about it that summer. This article replaces them.

#### What this article does

A plan for stacks of $n$ hats is a table: for each stack that a player may see, the position to point at. There are $n^{2^n}$ such tables when both players use the same one, which is the case in most of this article: $6{,}561$ for three hats, more than four billion for four. We call them *strategies*.

This article is about building good strategies from small ones, with a handful of operations.

- A *reset* stacks one strategy on top of another: play the first on the lowest hats, unless they are all of one color, in which case forget them and play the second on the hats above. The plan of the lowest black hat is a strategy on one hat, reset by itself again and again.
- A *shift* adds one hat, or two, on top of the stack that a strategy plays on, and changes what the strategy does for one or two stacks.

For each operation there is an exact formula: the number of winning pairs of stacks of the result, from those of its parts (Sections 3 and 4). With these formulas the win rates of whole families of strategies are computed in a line. The main family is that of the *Carter strategies* $\mathbf{C}_n$, one for each number of hats (Section 5):

| Hats | Winning pairs of $\mathbf{C}_n$ | Out of | Short of $\frac{7}{20}$ by |
|---|---|---|---|
| $1$ | $1$ | $4$ | $\frac{1}{10}$ |
| $2$ | $5$ | $16$ | $\frac{3}{80}$ |
| $3$ | $22$ | $64$ | $\frac{1}{160}$ |
| $4$ | $89$ | $256$ | $\frac{3}{1280}$ |
| $5$ | $358$ | $1{,}024$ | $\frac{1}{2560}$ |
| $6$ | $1{,}433$ | $4{,}096$ | $\frac{3}{20480}$ |
| $7$ | $5{,}734$ | $16{,}384$ | $\frac{1}{40960}$ |
| $8$ | $22{,}937$ | $65{,}536$ | $\frac{3}{327680}$ |

On $n$ hats, $\mathbf{C}_n$ wins $7 \cdot 4^n / 20$ pairs of stacks, rounded down. A win rate on $n$ hats is a whole number of pairs out of $4^n$, so nothing can come closer to $\frac{7}{20}$ from below; and the conjecture $V = \frac{7}{20}$ says exactly that no plan on any number of hats wins one pair more than the Carter strategy, even a plan in which Alice and Bob use different tables (Section 8).

The rest of the article:

- stacks that never end, where the limits of our families win exactly one time in three, or $7$ times in $20$, and are computed by a machine that reads the hats one at a time (Section 6);
- a calculator for strategies, which the reader can use on this page, and what a search by computer says of the best strategies on few hats (Section 7);
- attempts at beating $\frac{7}{20}$: resets of a more general kind, and a search around the Carter strategies. None succeeds (Section 8);
- open questions (Section 9).

#### What is new, and what is not

The game, the plans that win $7$ times in $20$ and the strategies of Carter and Reyes on up to $8$ hats are not ours. The word "reset" is in [BFGKRTVY], and the formula for one of our resets, the double reset, is the "combining formula" of [BCCZW].

The posts of 2020 brought the operations with their formulas, the Carter strategy for every number of hats, and the description of the limit strategies by machines. This article adds the closed form $7 \cdot 4^n / 20$ rounded down and its link with the conjecture, the proofs for stacks that never end, and the results of Section 8, among them a link between the upper bounds on $V$ and the Carter strategies. As far as we know these are not in the papers cited above.

The statements of Sections 2 to 6 were checked by a proof assistant, Lean, and the numbers of this article by programs; a table at the end says which statement is checked by what.

#### For the readers of the posts of 2020

Three things changed, to agree with the papers that appeared since. The players now point at black hats, and black is the digit $1$. A pile of hats is a *stack*, no longer a tower. The operations are named after a color instead of a side: the left reset of 2020 is the white reset.

### 2. Stacks, strategies, hits

#### Stacks

We write a stack of hats as a number in binary: a black hat is the digit $1$, a white hat the digit $0$, and the bottom hat is the units digit. A stack of $n$ hats is then a whole number $t$ with $0 \leq t < 2^n$. The stack of the picture at the top is $3$, in binary $011$: two black hats under a white one. Here are the four stacks of two hats:

$$
\begin{array}{ccccc}
\text{position} & t = 0 & t = 1 & t = 2 & t = 3 \\
1 & \whitemark & \whitemark & \blackmark & \blackmark \\
0 & \whitemark & \blackmark & \whitemark & \blackmark
\end{array}
$$

The positions of a stack of $n$ hats are $0, 1, \ldots, n - 1$, from the bottom up. We write $t_p$ for the color of the hat of $t$ at position $p$: it is the binary digit of $t$ of weight $2^p$. Where the stack has no hat, below position $0$ or above position $n - 1$, we set $t_p = 0$: no hat is not a black hat.

Two stacks have a single color: the all-white stack, which is $0$, and the all-black stack, which is $2^n - 1$. Exchanging the two colors of a stack $t$ of $n$ hats gives the stack $\dual{t} = 2^n - 1 - t$.

#### Strategies

A *strategy* on $n$ hats tells a player where to point: for each stack $t$ of $n$ hats that the player may see, a position $s(t)$. We write a strategy as the word $s(0)\,s(1) \cdots s(2^n - 1)$, in typewriter type. The plan of Section 1 on two hats is

$$
\str{0010}
$$

Seeing stack $1$ or stack $3$, whose bottom hat is black, the player points at position $0$; seeing stack $2$, at position $1$. Seeing stack $0$, which has no black hat to follow, the word says position $0$. Any other choice would do as well, as we will see.

A strategy is *proper* when it always points at a hat: $0 \leq s(t) < n$ for every stack $t$ of $n$ hats. Nothing forbids pointing elsewhere, but it never wins. Such strategies turn up by themselves when strategies are combined, and a few statements below fail for them; this is why each statement says whether it needs proper strategies.

Unless we say otherwise, Alice and Bob use the same strategy $s$. Say that Alice wears $t$ and Bob wears $u$. Alice sees $u$ and points at her position $s(u)$, where her hat has the color $t_{s(u)}$. Bob sees $t$ and points at his position $s(t)$, where his hat has the color $u_{s(t)}$. They win when

$$
t_{s(u)} \, u_{s(t)} = 1 .
$$

#### Hits

A *hit* of the strategy $s$ is a pair $(t, u)$ of stacks of $n$ hats on which the players win. We write $H(s)$ for the set of the hits of $s$, and $|H(s)|$ for their number:

$$
|H(s)| = \sum_{t, u} t_{s(u)} \, u_{s(t)} ,
$$

where $t$ and $u$ run over the stacks of $n$ hats. The $4^n$ pairs of stacks are equally likely, so the *win rate* of $s$ is

$$
w(s) = \frac{|H(s)|}{4^n} .
$$

Hits are whole numbers, and most of this article counts hits; the win rates follow.

Take $\str{0010}$ again. In the table below, a mark says that the pair is a hit. The row is the stack that Alice wears, the column the stack that Bob wears.

| | $u = 0$ | $u = 1$ | $u = 2$ | $u = 3$ |
|---|---|---|---|---|
| $t = 0$ | | | | |
| $t = 1$ | | ✓ | | ✓ |
| $t = 2$ | | | ✓ | |
| $t = 3$ | | ✓ | | ✓ |

There are $5$ hits, and the win rate is $\frac{5}{16}$, which is $\frac13 \left(1 - \frac{1}{4^2}\right)$ as Section 1 said. The table is symmetric, as it is for every strategy: if $(t, u)$ is a hit, so is $(u, t)$.

A simpler example: the strategy that points at the same position $p$ whatever it sees, such as $\str{0000}$. The players win when both wear a black hat at position $p$, which happens for $4^{n-1}$ pairs of stacks out of $4^n$: the win rate is $\frac14$, that of players who do not look at each other (Lean: `hits_const`).

#### Four facts

The rest of the article leans on four facts about hits. The first says that two letters of the word of a strategy do not matter.

**Proposition 1 (two choices that do not matter).** Let $s$ and $s'$ be two strategies on $n$ hats.

1. If $s$ and $s'$ differ only in what they do for the all-white stack, they have the same hits.
2. If $s$ and $s'$ are proper and differ only in what they do for the all-black stack, they have the same number of hits.

*Proof.* What a strategy does for the stack $0$ only matters to a pair of stacks in which one of the stacks is $0$. Such a pair is never a hit: the player who wears the all-white stack has no black hat to point at. This proves the first point.

For the second point, write $b = 2^n - 1$ for the all-black stack. What a strategy does for $b$ only matters to the pairs $(t, b)$ and $(b, t)$. The player who wears $b$ points at a black hat, since the strategy is proper. So $(t, b)$ is a hit exactly when $t$ has a black hat at position $s(b)$, and this is the case for half of the stacks $t$, whatever the position $s(b)$ is. The pairs that are hits change with $s(b)$; their number does not.

(Lean: `hits_congr_white`, `hits_congr_black`.) On one hat, the strategy $\str{00}$ has one hit, the pair $(1, 1)$. A strategy that points above the hat when it sees a black hat has none: the second point needs proper strategies.

**Proposition 2 (the positions renamed).** Let $\sigma$ be a permutation of the positions $0, \ldots, n - 1$. For a stack $t$ of $n$ hats, write $\sigma \cdot t$ for the stack whose hat at position $\sigma(p)$ is the hat of $t$ at position $p$. For a proper strategy $s$ on $n$ hats, write $\sigma \cdot s$ for the strategy that points at $\sigma(s(t))$ when it sees $\sigma \cdot t$. Then $\sigma \cdot s$ and $s$ have the same number of hits.

*Proof.* The pair $(\sigma \cdot t, \sigma \cdot u)$ is a hit of $\sigma \cdot s$ exactly when $(t, u)$ is a hit of $s$: the hat of $\sigma \cdot t$ at position $\sigma(s(u))$ is the hat of $t$ at position $s(u)$, and the same holds with $t$ and $u$ exchanged.

(Lean: `hits_swapStrat`, for the permutation that exchanges two positions; every permutation is a product of such.)

The third fact is less obvious: the game is not the same for the two colors, since the players must point at black hats, and yet exchanging the colors that a strategy sees costs nothing.

**Proposition 3 (the colors exchanged).** The *dual* of a strategy $s$ on $n$ hats is the strategy $\dual{s}$ with the two colors exchanged: $\dual{s}(t) = s(\dual{t})$. A proper strategy and its dual have the same number of hits.

*Proof.* The pair $(\dual{t}, \dual{u})$ is a hit of $\dual{s}$ when, with the stacks $t$ and $u$ and the strategy $s$, both players point at a *white* hat. So we must show that $s$ has as many pairs on which both point at a white hat as pairs on which both point at a black hat.

Sort the $4^n$ pairs $(t, u)$ by what the players point at with $s$: both at black ($a$ pairs), Alice at black and Bob at white ($b$ pairs), Alice at white and Bob at black ($c$ pairs), both at white ($d$ pairs). Alice points at a black hat for half of the pairs: whatever stack $u$ she sees, the position $s(u)$ is in her stack, and half of the stacks that she may wear are black there. So $a + b = \frac12 4^n$. In the same way $a + c = \frac12 4^n$. Hence

$$
d = 4^n - (a + b) - (a + c) + a = a .
$$

(Lean: `hits_dual`.) On one hat, the strategy that points at the hat when it sees a black hat, and above it when it sees a white hat, has one hit; its dual has none. Here again the strategies must be proper.

[Propositions 2](#proposition-2) and [3](#proposition-3) are about the symmetries of the game, and they are not of the same kind.

Renaming the positions is a symmetry of the game itself. The hits of $\sigma \cdot s$ are the hits of $s$ with the hats renamed, pair by pair; the two strategies play the same game, and only the names of the hats differ. We say that two strategies on $n$ hats are **equivalent** when one is the other with the positions renamed. There are $n!$ ways to rename $n$ positions, so a strategy has up to $n!$ equivalent ones, and they all have the same number of hits.

Exchanging the colors is a symmetry of the score only. The rule of the game prefers a color, and the hits of $\dual{s}$ are not those of $s$ under another name: they come from the pairs on which, with $s$, both players point at a white hat. That there are as many of these as hits is a matter of counting, and it needs a proper strategy. A strategy and its dual are in general not equivalent.

The last fact lets us compare strategies on different numbers of hats.

**Proposition 4 (taller stacks).** A strategy $s$ on $n$ hats can be played with stacks of $n + k$ hats, by looking at the $n$ lowest hats only. If $s$ is proper, it then has $4^k \, |H(s)|$ hits, and so the same win rate.

*Proof.* A pair of stacks of $n + k$ hats is a hit exactly when the pair of their $n$ lowest hats is a hit of $s$. Each pair of stacks of $n$ hats is continued upward in $4^k$ ways.

(Lean: `hits_emb`.) In particular the best win rate on $n + 1$ hats is at least the best win rate on $n$ hats.

### 3. Resets

The plan of Section 1 has a shape worth a name. Look at the bottom hat; if it is of no use, forget it and start again one hat higher. A *reset* does this with any two strategies, and with blocks of several hats.

#### Three resets

Let $a$ be a strategy on $m$ hats and $b$ a strategy on $n$ hats. The resets of $a$ by $b$ are strategies on $m + n$ hats. For a stack $t$ of $m + n$ hats, write $t_{<m}$ for the stack of its $m$ lowest hats and $t_{\geq m}$ for the stack of the $n$ hats above them.

- The **white reset** $a \wreset b$ plays $a$ on the $m$ lowest hats; but when these are all white, it plays $b$ on the hats above.
- The **black reset** $a \breset b$ plays $a$ on the $m$ lowest hats; but when these are all black, it plays $b$ on the hats above.
- The **double reset** $a \dreset b$ plays $a$ on the $m$ lowest hats; but when these are all white or all black, it plays $b$ on the hats above.

The mark after the triangle is the color that triggers the reset; no mark, either color. In a formula, for the white reset:

$$
(a \wreset b)(t) =
\begin{cases}
m + b(t_{\geq m}) & \text{if } t_{<m} = 0, \\
a(t_{<m}) & \text{otherwise,}
\end{cases}
$$

and the same for the other two, with the condition $t_{<m} = 2^m - 1$ for the black reset, and "$t_{<m} = 0$ or $t_{<m} = 2^m - 1$" for the double reset. "Playing $b$ on the hats above" means pointing at $m + b(t_{\geq m})$: the position that $b$ chooses, counted from the bottom of the whole stack.

An example. Take $a = \str{0010}$ on two hats, and $b = \str{00}$, the strategy on one hat, which points at it. Here is what the white reset $a \wreset b$ does for two of the stacks of three hats:

$$
\begin{array}{ccc}
\text{position} & t = 4 & t = 6 \\
2 & \blackmark & \blackmark \\
1 & \whitemark & \blackmark \\
0 & \whitemark & \whitemark
\end{array}
$$

Seeing stack $4$, whose two lowest hats are white, it plays $b$ above them and points at position $2$. Seeing stack $6$, it plays $a$ on the two lowest hats, which are the stack $2$, and points at position $1$. The three resets of $a$ by $b$ are

$$
a \wreset b = \str{20102010}, \qquad
a \breset b = \str{00120012}, \qquad
a \dreset b = \str{20122012} .
$$

The word of a reset is easy to write: the word of $a$, once for each stack of $n$ hats, and in each copy the first letter (for the white reset), the last letter (for the black reset) or both (for the double reset) replaced by what $b$ says.

A reset of proper strategies is proper. And the plan of Section 1 on two hats is a reset: $\str{00} \wreset \str{00} = \str{1010}$, which differs from $\str{0010}$ only in what it does for the all-white stack, where nothing matters ([Proposition 1](#proposition-1)).

#### The hits of a reset

**Theorem 1 (hits of the resets).** Let $a$ be a proper strategy on $m$ hats and $b$ a strategy on $n$ hats. Then

$$
|H(a \wreset b)| = 4^n \, |H(a)| + |H(b)| .
$$

If $b$ is proper too, then

$$
\begin{aligned}
|H(a \breset b)| &= 4^n \, |H(a)| + |H(b)| , \\
|H(a \dreset b)| &= 4^n \, |H(a)| + 4 \, |H(b)| - 4^n .
\end{aligned}
$$

As win rates:

$$
w(a \wreset b) = w(a \breset b) = w(a) + \frac{w(b)}{4^m} , \qquad
w(a \dreset b) = w(a) + \frac{4 \, w(b) - 1}{4^m} .
$$

(Lean: `hits_lr`, `hits_rr`, `hits_dr`; as win rates, `rate_lr`, `rate_rr`, `rate_dr`.)

The first formula can be read aloud. The players win as often as with $a$; and one time in $4^m$, when the lowest hats of both are all white, a game that $a$ would lose is played again with $b$. The double reset is more of a gamble, since it also gives up some games that $a$ would win, when a player sees $m$ black hats; this is the $-1$.

*Proof for the white reset.* Let $s = a \wreset b$, and take two stacks $t$ and $u$ of $m + n$ hats. There are three cases.

- *Neither $t_{<m}$ nor $u_{<m}$ is all white.* Both players play $a$ on the lowest hats: the pair is a hit exactly when $(t_{<m}, u_{<m})$ is a hit of $a$. Every hit of $a$ is of this kind, since a pair with an all-white stack is never a hit, and each is continued upward in $4^n$ ways: $4^n \, |H(a)|$ hits.
- *Both are all white.* Both players play $b$ above: the pair is a hit exactly when $(t_{\geq m}, u_{\geq m})$ is a hit of $b$. This gives $|H(b)|$ hits.
- *One is all white and the other is not*, say $t_{<m}$ is. The player who wears $t$ sees lowest hats that are not all white, plays $a$, and points at one of their own $m$ lowest hats, since $a$ is proper. These are white: no hit.

*Proof for the black reset.* Exchanging the colors turns one reset into the other:

$$
\dual{a \breset b} = \dual{a} \wreset \dual{b} ,
$$

because the lowest hats of $\dual{t}$ are all white when those of $t$ are all black. The double reset is its own mirror: $\dual{a \dreset b} = \dual{a} \dreset \dual{b}$. All these strategies are proper, and a proper strategy has as many hits as its dual ([Proposition 3](#proposition-3)). So $a \breset b$ has as many hits as $\dual{a} \wreset \dual{b}$, that is $4^n \, |H(\dual{a})| + |H(\dual{b})| = 4^n \, |H(a)| + |H(b)|$.

*Proof for the double reset.* Let $s = a \dreset b$. We first count the hits of $a$ in which one of the stacks is the all-black stack $2^m - 1$. The proof of [Proposition 1](#proposition-1) does it: there are $2^{m-1}$ stacks that have a black hat at the position that $a$ points at when it sees the all-black stack. One of them is the all-black stack itself. This gives $2 \, (2^{m-1} - 1) + 1 = 2^m - 1$ hits. Now the cases.

- *Neither $t_{<m}$ nor $u_{<m}$ has a single color.* Both play $a$. The hits of $a$ with no all-black stack number $|H(a)| - (2^m - 1)$, and each is continued in $4^n$ ways.
- *Both have a single color.* Both play $b$ above, and the colors below do not matter: $4 \, |H(b)|$ hits.
- *One has a single color and the other does not*, say $t_{<m}$ has. The player who wears $t$ plays $a$ and points at one of their $m$ lowest hats: it must be black, so $t_{<m}$ is all black. The other player plays $b$ above and points at a hat that is black for half of the stacks $u_{\geq m}$ that they may wear there, since $b$ is proper. With $2^m - 2$ choices for $u_{<m}$, $2^n$ for $t_{\geq m}$ and $2^{n-1}$ for $u_{\geq m}$, and as many again with $t$ and $u$ exchanged, this gives $(2^m - 2) \, 4^n$ hits.

In all: $4^n \left(|H(a)| - 2^m + 1\right) + 4 \, |H(b)| + (2^m - 2) \, 4^n = 4^n \, |H(a)| + 4 \, |H(b)| - 4^n$.

The conditions are needed. For the lower strategy: on one hat, let $a$ point at the hat when it sees white and just above it when it sees black. It has no hit. But once $\str{00}$ is put on top of it by a white reset, "just above" is a hat: the result always points at position $1$ and has $4$ hits, where the formula would give $1$. For the upper strategy: let $b$, on one hat, point at the hat when it sees white and just below it when it sees black. It has no hit either; but $\str{00} \breset b$ has $5$ hits, where the formula would give $4$, because "just below" is now the hat of $\str{00}$.

#### A first look at $\frac{7}{20}$

Reset a strategy $a$ on $m$ hats by itself, again and again, with double resets. If the win rates settle on a value $x$, the last formula of [Theorem 1](#theorem-1) says what it is:

$$
x = w(a) + \frac{4x - 1}{4^m}, \qquad \text{that is} \qquad x = \frac{4^m \, w(a) - 1}{4^m - 4} .
$$

With a strategy on three hats that has $22$ hits out of $64$, this is $\frac{21}{60} = \frac{7}{20}$. There is such a strategy, and $22$ is the best that three hats allow (Sections 5 and 7). With white resets alone, the same computation gives $x = \frac{22}{63}$, a little less. Section 6 makes "again and again" precise.

#### Chains of resets

**Proposition 5 (the white and the black reset are associative).** For strategies $a$, $b$ and $c$,

$$
(a \wreset b) \wreset c = a \wreset (b \wreset c) , \qquad
(a \breset b) \breset c = a \breset (b \breset c) .
$$

*Proof.* Let $a$ be on $m$ hats and $b$ on $n$ hats. On both sides the strategy plays $a$ unless the $m$ lowest hats are all white; then $b$ on the next $n$ hats unless these are all white too; then $c$ above. The same goes for black.

(Lean: `lr_assoc`, `rr_assoc`. These are equalities of strategies, not only of hits, and need no proper strategy.)

The double reset is not associative. Take $a = \str{0010}$, which has $5$ hits on two hats. By [Theorem 1](#theorem-1), $a \dreset a$ has $84$ hits on four hats, and on six hats

$$
|H((a \dreset a) \dreset a)| = 1348 , \qquad |H(a \dreset (a \dreset a))| = 1360 .
$$

The general computation is short. For proper strategies $a$, $b$, $c$, with $c$ on $k$ hats, [Theorem 1](#theorem-1) gives

$$
|H(a \dreset (b \dreset c))| - |H((a \dreset b) \dreset c)| = 12 \left( |H(c)| - 4^{k-1} \right) .
$$

So nesting to the right is the better choice as soon as $c$ wins more than one time in four. We therefore read a chain of resets from the bottom up, as a tower of powers is read:

$$
a \dreset b \dreset c = a \dreset (b \dreset c) .
$$

### 4. Shifts

A reset adds a whole strategy on top of another. A *shift* adds one hat, and changes what the strategy does for a single stack.

#### The white shift and the black shift

Let $s$ be a strategy on $n$ hats. Its shifts are strategies on $n + 1$ hats; the new hat, on top, is at position $n$.

- The **white shift** $s\,\wshift$ plays $s$ on the $n$ lowest hats, with one exception: seeing $n$ white hats under a black one, it points at the top hat.
- The **black shift** $s\,\bshift$ plays $s$ on the $n$ lowest hats, with one exception: seeing $n$ black hats under a white one, it points at the top hat.

The stack of the exception is $2^n$ for the white shift and $2^n - 1$ for the black shift. The mark after the arrow is the color of the $n$ lowest hats of that stack. On one hat, with $s = \str{00}$:

$$
\begin{array}{ccc}
\text{position} & t = 2 & t = 1 \\
1 & \blackmark & \whitemark \\
0 & \whitemark & \blackmark
\end{array}
\qquad\qquad
\str{00}\,\wshift = \str{0010} , \qquad \str{00}\,\bshift = \str{0100} .
$$

The white shift of $\str{00}$ points at position $1$ when it sees stack $2$; the black shift, when it sees stack $1$. The first is once more the plan of Section 1 on two hats.

Shifts are written after the strategy and are read from left to right: $s\,\bshift\,\wshift$ is the white shift of the black shift of $s$. They bind tighter than resets: $a \dreset b\,\wshift$ is $a \dreset (b\,\wshift)$.

#### Two shifts in a row, and one better

Shifting twice adds two hats, and it can be done in two orders: $s\,\bshift\,\wshift$ and $s\,\wshift\,\bshift$. These are different strategies, and stay different when the positions are renamed. Either can be improved by changing what it does for one more stack. This gives the operation that matters most in this article.

The **double shift** $s\,\dshift$ plays $s$ on the $n$ lowest hats, with two exceptions.

- Seeing $n$ black hats with a white hat just above them, it points at that hat, at position $n$.
- Seeing $n$ white hats and a black hat at the top, it points at the top hat, at position $n + 1$.

The double shift is $s\,\bshift\,\wshift$ with one choice changed. Both point at position $n$ for the two stacks that have $n$ black hats and a white hat above them, and at position $n + 1$ for the stack $2^{n+1}$, which is $n + 1$ white hats under a black one. The double shift also points at position $n + 1$ for the stack $2^{n+1} + 2^n$: $n$ white hats under two black ones. For that stack $s\,\bshift\,\wshift$ plays $s$.

On one hat, with $s = \str{00}$:

$$
\str{00}\,\bshift\,\wshift = \str{01002100} , \qquad \str{00}\,\dshift = \str{01002120} .
$$

The first word has $21$ hits out of $64$, the second $22$. One letter makes the difference, the seventh, for stack $6$:

$$
\begin{array}{cc}
\text{position} & t = 6 \\
2 & \blackmark \\
1 & \blackmark \\
0 & \whitemark
\end{array}
$$

#### The hits of a shift

**Theorem 2 (hits of the shifts).** Let $s$ be a proper strategy on $n$ hats. Then

$$
|H(s\,\wshift)| = |H(s\,\bshift)| = 4 \, |H(s)| + 1 , \qquad
|H(s\,\dshift)| = 16 \, |H(s)| + 6 .
$$

As win rates:

$$
w(s\,\wshift) = w(s\,\bshift) = w(s) + \frac{1}{4^{n+1}} , \qquad
w(s\,\dshift) = w(s) + \frac{6}{4^{n+2}} .
$$

(Lean: `hits_ls`, `hits_rs`, `hits_ds`; as win rates, `rate_ls`, `rate_rs`, `rate_ds`.)

Two shifts in a row give $4 \, (4 \, |H(s)| + 1) + 1 = 16 \, |H(s)| + 5$ hits, in either order. The double shift has one more.

*Proof for the white shift.* Played on stacks of $n + 1$ hats, $s$ has $4 \, |H(s)|$ hits ([Proposition 4](#proposition-4)). The white shift changes what it does for one stack, $k = 2^n$, so only the pairs that contain $k$ can change. The player who wears $k$ has a single black hat, the top one. Before the change nobody points at their top hat, so no pair with $k$ is a hit. After the change a player points at the top hat only when seeing $k$: the pair $(k, k)$ is a hit, and it is the only one. One hit is gained.

*Proof for the black shift.* Exchanging the colors turns one shift into the other, $\dual{s\,\bshift} = \dual{s}\,\wshift$: seeing $n$ black hats under a white one is, for the dual, seeing $n$ white hats under a black one. These strategies are proper, so [Proposition 3](#proposition-3) gives $|H(s\,\bshift)| = |H(\dual{s}\,\wshift)| = 4 \, |H(\dual{s})| + 1 = 4 \, |H(s)| + 1$.

*Proof for the double shift.* Let $s' = s\,\bshift\,\wshift$, which has $16 \, |H(s)| + 5$ hits. The double shift changes what $s'$ does for one stack, $k = 2^{n+1} + 2^n$: seeing $k$, it points at position $n + 1$, where $s'$ points at one of the $n$ lowest positions. We count the hits that contain $k$, before and after.

The player who wears $k$ has black hats at positions $n$ and $n + 1$ only. So the other player must wear a stack $t$ for which the strategy points there, and there are three such stacks besides $k$:

$$
t_1 = 2^n - 1 , \qquad t_2 = 2^{n+1} + 2^n - 1 , \qquad t_3 = 2^{n+1} .
$$

The first two have $n$ black hats with a white hat above them, and send to position $n$; the third sends to position $n + 1$. Their hats:

| Stack | The $n$ lowest hats | Position $n$ | Position $n + 1$ |
|---|---|---|---|
| $t_1$ | black | white | white |
| $t_2$ | black | white | black |
| $t_3$ | white | white | black |
| $k$ | white | black | black |

*Before.* Seeing $k$, a player points at one of their $n$ lowest hats. This hat is black for $t_1$ and $t_2$, white for $t_3$ and for $k$. The hits that contain $k$ are $(t_1, k)$, $(t_2, k)$ and the same two in the other order: $4$ hits.

*After.* Seeing $k$, a player points at position $n + 1$. This hat is black for $t_2$, $t_3$ and $k$, white for $t_1$. The hits that contain $k$ are $(t_2, k)$, $(t_3, k)$, the same two in the other order, and $(k, k)$: $5$ hits.

One hit is gained: $16 \, |H(s)| + 6$.

#### The other double shift

The double shift starts from the black shift followed by the white shift. Starting from the other order gives a second double shift, and it is equivalent to the first.

**Proposition 6 (the two double shifts are equivalent).** Let $s$ be a strategy on $n$ hats, with $n \geq 1$, and let $\sigma$ be the exchange of the positions $n$ and $n + 1$.

1. Take $s\,\wshift\,\bshift$ and make it point at position $n + 1$ for the stack $2^n - 1$, which is $n$ black hats under two white ones. The result is $\sigma \cdot (s\,\dshift)$: the double shift with its two new positions exchanged.
2. Exchanging the colors does the same: $\dual{s\,\dshift} = \sigma \cdot (\dual{s}\,\dshift)$.

*Proof.* Exchange the positions $n$ and $n + 1$ in the two exceptions of the double shift. The strategy $\sigma \cdot (s\,\dshift)$ plays $s$ on the $n$ lowest hats, except that seeing $n$ black hats and a white hat at the top it points at position $n + 1$, and that seeing $n$ white hats with a black hat just above them it points at position $n$.

For the first point: the white shift sends the stack $2^n$ to position $n$; the black shift after it plays the white shift on the $n + 1$ lowest hats, so it sends both stacks that have $n$ white hats with a black hat just above them to position $n$, and it sends $2^{n+1} - 1$, which is $n + 1$ black hats under a white one, to position $n + 1$. With $2^n - 1$ sent to position $n + 1$ as well, these are the exceptions above.

For the second point: the dual of $s\,\dshift$ plays $\dual{s}$ on the $n$ lowest hats, and its exceptions are those of the double shift with the colors exchanged, which are again the exceptions above.

(Lean: `ds` is defined as $s\,\bshift\,\wshift$ with one choice changed; `sibling_eq` says that the strategy of the first point is the dual of the double shift of the dual, and `sibling_eq_swap` that it is $\sigma \cdot (s\,\dshift)$, for a proper $s$.)

So there are two double shifts, and they are equivalent: each is the other with the two new positions renamed. We keep the first and write it $s\,\dshift$. Nothing later depends on this choice, by the next statement.

**Proposition 7 (the operations respect equivalence).** Let $a$ and $a'$ be equivalent strategies on $m$ hats, and $b$ and $b'$ equivalent strategies on $n$ hats. Then $a' \wreset b'$ is equivalent to $a \wreset b$, and the same holds for the black reset and the double reset. The shifts $a'\,\wshift$, $a'\,\bshift$ and $a'\,\dshift$ are equivalent to $a\,\wshift$, $a\,\bshift$ and $a\,\dshift$.

*Proof.* Let $a' = \sigma \cdot a$ and $b' = \tau \cdot b$. Let $\rho$ be the renaming of the $m + n$ positions that acts as $\sigma$ on the $m$ lowest and as $\tau$ on the $n$ above. We show that $a' \wreset b' = \rho \cdot (a \wreset b)$. Take a stack $t$ of $m + n$ hats. The $m$ lowest hats of $\rho \cdot t$ are those of $t$, renamed by $\sigma$: they are all white exactly when those of $t$ are. If they are not, both strategies play on the lowest hats: $a \wreset b$ points at $a(t_{<m})$ when it sees $t$, and $a' \wreset b'$ points at $\sigma(a(t_{<m}))$ when it sees $\rho \cdot t$. If they are, both play above, and the same holds with $b$ and $\tau$. This is what $a' \wreset b' = \rho \cdot (a \wreset b)$ means. The proof is the same for the other resets, with "all black" or "of a single color". For the shifts, $\rho$ acts as $\sigma$ on the $m$ lowest positions and leaves the new ones in place; the stacks of the exceptions are told by their $m$ lowest hats being all white or all black, and by the new hats.

(Lean, for the exchange of two positions, of which every renaming is a product, and for proper strategies: `lr_swap_low`, `lr_swap_high`, `rr_swap_low`, `rr_swap_high`, `dr_swap_low`, `dr_swap_high`, `ls_swap`, `rs_swap`, `ds_swap`.) So in a strategy written with resets and shifts, replacing a part by an equivalent one gives an equivalent strategy. In particular it does not matter which double shift is used, and where.

Compare with the single shifts. Exchanging the colors turns the white shift into the black shift, and these two are not equivalent: $\str{0010}$ and $\str{0100}$ are not the same strategy with the positions renamed. The double shift is sent by the exchange of the colors to an equivalent strategy. It does not prefer a color.

#### Another way to add two hats

The double shift is not the only operation that adds two hats and gains $6$ hits. Here is another, which we call the *twisted double shift*. It plays $s$ on the $n$ lowest hats, with two exceptions.

- Seeing $n$ black hats with a white hat just above them, it points at the top hat, at position $n + 1$ (the double shift points at position $n$).
- Seeing $n$ hats of a single color, white or black, with a black hat just above them and a white hat at the top, it points at position $n$.

For every proper strategy $s$ that we tried, the result has $16 \, |H(s)| + 6$ hits, as for the double shift: all the strategies on one and two hats, and random ones on three and four. We have no proof yet. It is a different operation, and not the double shift under other names: on two hats, for none of the $16$ strategies $s$ is the result equivalent to $s\,\dshift$. Its dual is a fourth operation of the same kind. On one hat it gives $\str{02110200}$, which has $22$ hits and is equivalent to $\mathbf{C}_3$, as every best strategy on three hats is. On three hats it gives something new (Section 7).

That one changed letter is worth a remark. Resets and single shifts build a strategy on many hats out of strategies on fewer hats, and their hits add up as the formulas say. The double shift is not built that way: it is a block on two hats that does better than the two single shifts it is made of. A natural question is whether a block on three or more hats does better still. We come back to it in Section 8.

### 5. Five families

We now have what it takes to name strategies on any number of hats and to compute their win rates. There are five families. In bold, $\mathbf{T}_n$, $\mathbf{B}_n$, $\mathbf{W}_n$ and $\mathbf{C}_n$ are strategies on $n$ hats; $\mathbf{R}_j$ is a strategy on $3j$ hats.

#### Always the same hat

$\mathbf{T}_n$ points at the bottom hat whatever it sees: its word is $2^n$ zeros. We met it in Section 2: it has $4^{n-1}$ hits, and its win rate is $\frac14$ for every $n$. It is the yardstick: a strategy is worth something when it beats $\frac14$.

#### The lowest black hat, the lowest white hat

$\mathbf{B}_n$ points where the stack it sees has its lowest black hat; this is the plan of Section 1. $\mathbf{W}_n$ points where the stack it sees has its lowest white hat. They are chains of resets of the strategy on one hat:

$$
\mathbf{B}_n = \underbrace{\str{00} \wreset \str{00} \wreset \cdots \wreset \str{00}}_{n} , \qquad
\mathbf{W}_n = \underbrace{\str{00} \breset \str{00} \breset \cdots \breset \str{00}}_{n} ,
$$

up to the one choice that does not matter: what $\mathbf{B}_n$ does for the all-white stack, and $\mathbf{W}_n$ for the all-black stack. On three hats, $\mathbf{B}_3 = \str{00102010}$ and $\mathbf{W}_3 = \str{01020100}$. Each is the dual of the other.

**Proposition 8 (the lowest black hat, the lowest white hat).** For every $n \geq 1$,

$$
|H(\mathbf{B}_n)| = |H(\mathbf{W}_n)| = \frac{4^n - 1}{3} , \qquad
w(\mathbf{B}_n) = w(\mathbf{W}_n) = \frac13 \left( 1 - \frac{1}{4^n} \right) .
$$

*Proof.* By [Theorem 1](#theorem-1), with $|H(\str{00})| = 1$: the hits $h_n$ of the chain of $n$ resets satisfy $h_1 = 1$ and $h_{n+1} = 4^n + h_n$. So $h_n = 1 + 4 + \cdots + 4^{n-1}$.

(Lean: `hits_lowBlack`, `hits_lowWhite`, `rate_lowBlack`, `rate_lowWhite`.) The win rates climb toward $\frac13$ and never reach it.

#### The Carter strategies

Start from the strategy on one hat and add two hats at a time with double shifts; for an even number of hats, finish with one single shift.

$$
\mathbf{C}_1 = \str{00} , \qquad
\mathbf{C}_{n+2} = \mathbf{C}_n\,\dshift \ \text{ for odd } n , \qquad
\mathbf{C}_{n+1} = \mathbf{C}_n\,\bshift \ \text{ for odd } n .
$$

The first five:

| Hats | $\mathbf{C}_n$ |
|---|---|
| $1$ | $\str{00}$ |
| $2$ | $\str{0100}$ |
| $3$ | $\str{01002120}$ |
| $4$ | $\str{01002123\,01002120}$ |
| $5$ | $\str{01002123\,01002120\,41002123\,41002120}$ |

Unfolding the shifts gives a rule that is the same for every number of hats. Look at the bottom hat of the stack you see.

- If it is black, find the lowest white hat. If it is at an odd position, point there.
- If it is white, find the lowest black hat. If it is at an even position, point there. If it is at an odd position and the hat just above it is black too, point at the hat just above.
- In every other case, point at the bottom hat.

So $\mathbf{C}_n$ is one rule, cut to $n$ hats. Seeing stack $6$ of three hats (white, black, black from the bottom), the lowest black hat is at position $1$ and the hat above it is black: point at position $2$, the seventh letter of $\str{01002120}$.

**Theorem 3 (the Carter strategies).** For every $n \geq 1$, the Carter strategy on $n$ hats has

$$
|H(\mathbf{C}_n)| = \left\lfloor \frac{7 \cdot 4^n}{20} \right\rfloor
$$

hits: $7 \cdot 4^n / 20$, rounded down. More precisely,

$$
w(\mathbf{C}_n) = \frac{7}{20} - \frac{2}{5 \cdot 4^n} \ \text{ for odd } n , \qquad
w(\mathbf{C}_n) = \frac{7}{20} - \frac{3}{5 \cdot 4^n} \ \text{ for even } n .
$$

*Proof.* Write $h_n = |H(\mathbf{C}_n)|$. For odd $n$ we claim that $20 \, h_n = 7 \cdot 4^n - 8$. This holds for $n = 1$, where $h_1 = 1$. If it holds for $n$, [Theorem 2](#theorem-2) gives $h_{n+2} = 16 \, h_n + 6$, hence $20 \, h_{n+2} = 16 \, (7 \cdot 4^n - 8) + 120 = 7 \cdot 4^{n+2} - 8$. For even $n + 1$, [Theorem 2](#theorem-2) gives $h_{n+1} = 4 \, h_n + 1$, hence $20 \, h_{n+1} = 4 \, (7 \cdot 4^n - 8) + 20 = 7 \cdot 4^{n+1} - 12$. In both cases $20 \, h_n$ is the largest multiple of $20$ below $7 \cdot 4^n$, because $7 \cdot 4^n$ leaves the remainder $8$ or $12$ when divided by $20$. Dividing by $20 \cdot 4^n$ gives the win rates.

(Lean: `hits_carterOdd`, `hits_carterEven`, `hits_carter`, `rate_carterOdd`, `rate_carterEven`.) The table of Section 1 lists the first eight.

Two remarks. A win rate on $n$ hats is a whole number of hits out of $4^n$, and $7 \cdot 4^n / 20$ is never whole. So no strategy on $n$ hats has a win rate between that of $\mathbf{C}_n$ and $\frac{7}{20}$: on each number of hats, the Carter strategy is as close to $\frac{7}{20}$ from below as a strategy can be. And the single shift that finishes the even case could as well be the white shift, which has the same hits by [Theorem 2](#theorem-2).

#### The Reyes strategies

Take the Carter strategy on three hats and reset it by itself with double resets:

$$
\mathbf{R}_1 = \mathbf{C}_3 , \qquad \mathbf{R}_{j+1} = \mathbf{C}_3 \dreset \mathbf{R}_j ,
$$

that is, with the convention on chains, $\mathbf{R}_j = \mathbf{C}_3 \dreset \mathbf{C}_3 \dreset \cdots \dreset \mathbf{C}_3$ with $j$ copies. In words: look at the hats three by three from the bottom; skip every block of three that is all white or all black; on the first block that is not, play $\mathbf{C}_3$. This is the shape of the plans of 2014 that win $7$ times in $20$ on stacks that never end [BFGKRTVY].

**Proposition 9 (the Reyes strategies).** For every $j \geq 1$, the Reyes strategy on $3j$ hats has

$$
|H(\mathbf{R}_j)| = \frac{7 \cdot 64^j - 2 \cdot 4^j}{20} , \qquad
w(\mathbf{R}_j) = \frac{7}{20} - \frac{1}{10 \cdot 16^j} .
$$

*Proof.* The win rate of $\mathbf{C}_3$ is $\frac{22}{64}$. By [Theorem 1](#theorem-1),

$$
w(\mathbf{R}_{j+1}) = \frac{22}{64} + \frac{4 \, w(\mathbf{R}_j) - 1}{64} .
$$

Write $w(\mathbf{R}_j) = \frac{7}{20} - e_j$. Then $w(\mathbf{R}_{j+1}) = \frac{22}{64} + \frac{2}{5 \cdot 64} - \frac{e_j}{16} = \frac{7}{20} - \frac{e_j}{16}$, since $22 + \frac25 = 64 \cdot \frac{7}{20}$. And $e_1 = \frac{7}{20} - \frac{22}{64} = \frac{1}{160}$.

(Lean: `hits_reyes`, `rate_reyes`.) This is the computation of "A first look at $\frac{7}{20}$" in Section 3, done one step at a time.

#### The five families side by side

Hits, out of $4^n$:

| Hats | $\mathbf{T}_n$ | $\mathbf{B}_n$, $\mathbf{W}_n$ | $\mathbf{C}_n$ | $\mathbf{R}_{n/3}$ | Out of |
|---|---|---|---|---|---|
| $1$ | $1$ | $1$ | $1$ | | $4$ |
| $2$ | $4$ | $5$ | $5$ | | $16$ |
| $3$ | $16$ | $21$ | $22$ | $22$ | $64$ |
| $4$ | $64$ | $85$ | $89$ | | $256$ |
| $5$ | $256$ | $341$ | $358$ | | $1{,}024$ |
| $6$ | $1{,}024$ | $1{,}365$ | $1{,}433$ | $1{,}432$ | $4{,}096$ |
| $7$ | $4{,}096$ | $5{,}461$ | $5{,}734$ | | $16{,}384$ |
| $8$ | $16{,}384$ | $21{,}845$ | $22{,}937$ | | $65{,}536$ |
| $9$ | $65{,}536$ | $87{,}381$ | $91{,}750$ | $91{,}744$ | $262{,}144$ |

The Carter and the Reyes strategies both climb toward $\frac{7}{20}$, at different paces. The Reyes strategy on $3j$ hats has exactly the win rate of the Carter strategy on $2j + 1$ hats, $\frac{7}{20} - \frac{1}{10 \cdot 16^j}$: the Carter strategies get there with fewer hats, and on the same number of hats they win more, as the table shows on $6$ and $9$ hats. We know no direct reason for this coincidence of win rates, no way to turn one strategy into the other (Section 9).

What the Reyes strategies have for them is their shape: the same block, played again and again. That shape goes over to stacks that never end without any change, which is the subject of the next section.

### 6. Infinite stacks

So far the stacks had $n$ hats. Levine's game has stacks that never end: a hat at every position $0, 1, 2, \ldots$ On such stacks $\frac{7}{20}$ is not only approached, it is reached.

#### The game on infinite stacks

An *infinite stack* $t$ gives a color $t_p$ to every position $p \geq 0$. Each hat is black with probability $\frac12$, independently of the others, for both players. This defines a probability on the pairs of infinite stacks, which we write $\mathbf{P}$. For an infinite stack $t$ we still write $t_{<n}$ for its $n$ lowest hats, a stack of $n$ hats.

A strategy $S$ on infinite stacks gives, for each infinite stack, a position to point at, or nothing at all: we allow a strategy to have no answer for some stacks, and then the players lose. Its hits are the pairs $(t, u)$ of infinite stacks on which both players point at a black hat, and its win rate is their probability:

$$
w(S) = \mathbf{P}(H(S)) .
$$

A word of caution. A strategy on infinite stacks is a function of infinitely many hats, and there are more such functions than real numbers (Lean: `continuum_lt_mk_strategies`). Most of them are of no use to anyone, and for some the set $H(S)$ has no probability at all: the paper [BFGKRTVY] has an appendix on what the axiom of choice does to a game of this kind. The strategies of this section are tame. Each is computed by reading finitely many hats, with probability $1$, and its hits form a set that has a probability.

The simplest strategies on infinite stacks are those we already have.

**Proposition 10 (a strategy on $n$ hats, on infinite stacks).** A proper strategy $s$ on $n$ hats, played on infinite stacks by looking at the $n$ lowest hats only, has the win rate $w(s)$.

*Proof.* A pair $(t, u)$ of infinite stacks is a hit exactly when $(t_{<n}, u_{<n})$ is a hit of $s$, and each pair of stacks of $n$ hats has probability $\frac{1}{4^n}$ of being the lowest hats of the two players.

(Lean: `rateInf_lift`.) This is [Proposition 4](#proposition-4) with infinitely many hats added on top. So every win rate of Section 5 is a win rate on infinite stacks, and the best win rate on infinite stacks is at least $w(\mathbf{C}_n)$ for every $n$, hence at least $\frac{7}{20}$. To reach $\frac{7}{20}$ itself takes a strategy that may look at any number of hats.

#### Limits of strategies

The families of Section 5 have a property in common: adding hats changes what the strategy does for few stacks. Seeing a stack whose bottom hat is black, $\mathbf{B}_n$ points at the bottom hat for every $n$. This is what makes a limit.

Let $s_0, s_1, s_2, \ldots$ be strategies on more and more hats, $s_k$ on $n_k$ hats. We say that the sequence *settles* on an infinite stack $t$ when the positions $s_k(t_{<n_k})$ are the same from some $k$ on. The *limit* of the sequence is the strategy $S$ on infinite stacks that points at that position, and has no answer for the stacks on which the sequence does not settle.

**Theorem 4 (the win rate of a limit).** Let $s_k$ be a proper strategy on $n_k$ hats, for $k = 0, 1, 2, \ldots$, and let $A_k$ be a set of stacks of $n_k$ hats, such that:

1. the sequence has settled on every infinite stack $t$ whose lowest hats are outside $A_k$: if $t_{<n_k}$ is not in $A_k$, then $s_j(t_{<n_j}) = s_k(t_{<n_k})$ for all $j \geq k$;
2. the proportion of $A_k$ among the stacks of $n_k$ hats, $|A_k| / 2^{n_k}$, tends to $0$;
3. the win rates $w(s_k)$ tend to a number $L$.

Then the limit $S$ of the sequence has the win rate $L$. More precisely, for every $k$,

$$
\left| w(S) - w(s_k) \right| \leq \frac{2 \, |A_k|}{2^{n_k}} .
$$

*Proof.* Fix $k$, and play $s_k$ on infinite stacks; by [Proposition 10](#proposition-10) its win rate is still $w(s_k)$. By the first condition, $S$ and $s_k$ point at the same position for every infinite stack whose $n_k$ lowest hats are outside $A_k$. So a pair $(t, u)$ in which neither $t_{<n_k}$ nor $u_{<n_k}$ is in $A_k$ is a hit of both or of neither. The other pairs have probability at most $2 \, |A_k| / 2^{n_k}$: this is the inequality. Let $k$ grow, and the second and third conditions give $w(S) = L$.

(Lean: `abs_rateInf_sub_rate_le`, `rateInf_limitOf`. That the hits of such a limit form a set that has a probability: `measurable_limitOf`, `measurableSet_hitSet`.)

The set $A_k$ holds the stacks of $n_k$ hats that are still undecided. The theorem says that the win rate goes to the limit as soon as the undecided become rare.

#### Three limits

**Theorem 5 (the limits of the families).**

1. The strategies $\mathbf{B}_n$ have a limit $\mathbf{B}_\infty$: point where the stack you see has its lowest black hat. It has an answer for every stack but the all-white one, and $w(\mathbf{B}_\infty) = \frac13$.
2. The Carter strategies have a limit $\mathbf{C}_\infty$: the rule of Section 5, with no limit on the number of hats. It has an answer for every stack but the all-white and the all-black ones, and $w(\mathbf{C}_\infty) = \frac{7}{20}$.
3. The Reyes strategies have a limit $\mathbf{R}_\infty$: look at the hats three by three from the bottom, skip the blocks that are all white or all black, and play $\mathbf{C}_3$ on the first block that is not. It has an answer for every stack in which some block is neither all white nor all black, and $w(\mathbf{R}_\infty) = \frac{7}{20}$.

*Proof.* In each case we give the sets $A_k$ of [Theorem 4](#theorem-4).

For $\mathbf{B}_n$: take $A_n$ to be the all-white stack of $n$ hats alone. Once the $n$ lowest hats are not all white, the lowest black hat is among them, and more hats do not change it. The proportion is $\frac{1}{2^n}$, and the win rates tend to $\frac13$ ([Proposition 8](#proposition-8)).

For the Carter strategies on $1, 3, 5, \ldots$ hats: take the all-white and the all-black stacks. A double shift plays the strategy it starts from, except when the hats that this strategy looks at are all black or all white. So once the lowest hats are of both colors, the double shifts above them change nothing. The proportion is $\frac{2}{2^n}$, and the win rates tend to $\frac{7}{20}$ ([Theorem 3](#theorem-3)).

For the Reyes strategies on $3, 6, 9, \ldots$ hats: take the stacks of $3j$ hats whose $j$ blocks of three are each all white or all black. There are $2^j$ of them among $8^j$, a proportion of $\frac{1}{4^j}$. Once a block is neither, the strategy plays $\mathbf{C}_3$ on the first such block, whatever comes above. The win rates tend to $\frac{7}{20}$ ([Proposition 9](#proposition-9)).

(Lean: `rateInf_lowBlackInf`, `rateInf_carterInf`, `rateInf_reyesInf`, with `lowBlackInf_spec` and `reyesInf_spec` for what the limits do.)

The same goes for the lowest white hat, with the colors exchanged. So on infinite stacks there are strategies that win exactly $7$ times in $20$, where no strategy on $n$ hats does. This is the form in which the result of 2014 is usually told: the limit $\mathbf{R}_\infty$ has the shape of the plans of [BFGKRTVY]. The limit $\mathbf{C}_\infty$ is another one, not built on blocks of a fixed size.

The stacks for which these limits have no answer are few: one or two stacks for $\mathbf{B}_\infty$ and $\mathbf{C}_\infty$, and for $\mathbf{R}_\infty$ a set of stacks of probability $0$.

One point of vocabulary. In the papers, the best win rate $V$ is defined through finite stacks, as the limit of the best win rates on $n$ hats, to keep away from the strategies that have no win rate. With strategies on infinite stacks whose hits have a probability, the best win rate is the same number $V$ [BCCZW]. [Theorem 5](#theorem-5) says that it is at least $\frac{7}{20}$, and that if $V = \frac{7}{20}$ then the best win rate is attained on infinite stacks.

#### Machines that read the hats

Each of the three limits can be computed by a player who reads the other stack from the bottom up, one hat at a time, and stops as soon as the position to point at is known. The player needs a counter, and a few words of memory.

*For $\mathbf{B}_\infty$.* Count the white hats. At the first black hat, stop: the position is the count.

*For $\mathbf{R}_\infty$.* Read three hats. If they are all white or all black, add $3$ to the counter and read three more. If not, stop: the position is the counter plus what $\mathbf{C}_3$ says of these three hats.

*For $\mathbf{C}_\infty$.* The counter $c$ starts at $0$ and moves by $2$. Start at row $1$ of the table; at each row, read the next hat and do what the table says.

| Row | Hats read so far | If the next hat is black | If the next hat is white |
|---|---|---|---|
| $1$ | none | go to row $5$ | go to row $2$ |
| $2$ | $c + 1$ white hats | go to row $3$ | go to row $4$ |
| $3$ | a black hat on $c + 1$ white hats | stop: position $c + 2$ | stop: position $0$ |
| $4$ | $c + 2$ white hats | stop: position $c + 2$ | add $2$ to $c$; go to row $2$ |
| $5$ | $c + 1$ black hats | go to row $6$ | stop: position $c + 1$ |
| $6$ | $c + 2$ black hats | add $2$ to $c$; go to row $5$ | stop: position $0$ |

This is the rule of Section 5: on a white bottom hat, find the lowest black hat, and so on.

**Proposition 11 (the limits are computed by machines).** For each of $\mathbf{B}_\infty$, $\mathbf{C}_\infty$ and $\mathbf{R}_\infty$, the machine above stops on every stack for which the limit has an answer, after finitely many hats, and stops with that answer. Each step of the machine is a computation on whole numbers of the simplest kind.

(Lean: `lowBlackReader_outputs`, `carterReader_outputs`, `reyesReader_outputs`; the steps are primitive recursive: `lowBlackReader_computable`, `carterReader_computable`, `reyesReader_computable`.)

These machines are not finite automata, as the posts of 2020 called them: the counter can be as large as the stack requires. But with probability $1$ a player reads finitely many hats, and few: for $\mathbf{B}_\infty$, two on average.

### 7. The calculator, and the best strategies on few hats

#### A calculator for strategies

The operations of Sections 3 and 4 are easy to carry out and easy to get wrong. Here is a calculator that does them. Type a query and press "Submit".

{{< frame src="https://blog.atlant.is/figures/hats/hats.html" height="330" >}}

The command `eval` takes a strategy and prints its word, its hits and its win rate:

```
eval C3
"01002120" w = 22/64 ~ 34.38%
```

Long words are printed in groups of eight letters. A strategy can be a word between quotes, a name, or an operation applied to strategies:

| Query | What it is |
|---|---|
| `"0010"` | the strategy with that word |
| `B3`, `W3`, `C3`, `R2` | $\mathbf{B}_3$, $\mathbf{W}_3$, $\mathbf{C}_3$, $\mathbf{R}_2$ (`B`, `W`, `C` up to $9$ hats, `R` up to `R3`) |
| `wr(a, b)`, `br(a, b)`, `dr(a, b)` | $a \wreset b$, $a \breset b$, $a \dreset b$ |
| `ws(a)`, `bs(a)`, `ds(a)` | $a\,\wshift$, $a\,\bshift$, $a\,\dshift$ |
| `sd(a)` | the other double shift ([Proposition 6](#proposition-6)) |
| `dual(a)` | $\dual{a}$ |
| `emb(a, n)` | $a$ played on stacks of $n$ hats |

For instance:

```
eval ds(ds(C1))
"01002123-01002120--41002123-41002120" w = 358/1024 ~ 34.96%

eval dr(C3,C3)
"31002123-41002124--31002123-31002123
 51002125-41002124--51002125-31002123" w = 1432/4096 ~ 34.96%
```

The first is $\mathbf{C}_5$, the second $\mathbf{R}_2$. The query `help eval` lists everything. The calculator is one file of JavaScript.

#### Searching for the best strategy

The command `search` looks for the best strategies on $n$ hats, by trying them. Trying all of them is not possible for long, since there are $n^{2^n}$, so the search uses the symmetries of Section 2.

- The choices for the all-white and the all-black stack do not matter ([Proposition 1](#proposition-1)): both are set to position $0$.
- Renaming the positions does not change the hits ([Proposition 2](#proposition-2)). So it is enough to try one strategy in each class of equivalent strategies, or at least not to try all of them. The search tries the *crushed* strategies: those that, seeing stack number $t$, point at a position at most $t$. Seeing stack $1$ a crushed strategy points at position $0$ or $1$, seeing stack $2$ at position $0$, $1$ or $2$, and so on. Every proper strategy is equivalent to a crushed one (Lean: `exists_crushed`).

On four hats this leaves $2 \cdot 3 \cdot 4 \cdot 4^{11} = 100{,}663{,}296$ strategies out of $4^{16}$, about $43$ times fewer, and the search takes a second:

```
search -n 4 -q
Done comparing 100,663,296 strategie(s) in 0.906s.
Best win rate is 89/256 ~ 34.77% (102 occurrences).
E.g.: "01221122-33331100"
```

Crushing does not use all the symmetry: several crushed strategies can be equivalent. And on five hats there are still $120 \cdot 5^{26}$ crushed strategies, more than $10^{20}$: the search of the calculator stops at four hats, unless it is told to stay near a given strategy (`help search`).

#### The best scores

Write $V_n$ for the best win rate on $n$ hats when the two players may use different strategies, as in the papers. What is known:

| Hats | Best score with one shared strategy | Established by | With two strategies |
|---|---|---|---|
| $1$ | $1$ out of $4$ | Lean (`hits_one_le`) | the same, by enumeration |
| $2$ | $5$ out of $16$ | Lean (`hits_two_le`) | the same, by enumeration |
| $3$ | $22$ out of $64$ | Lean (`hits_three_le`) | the same, by enumeration |
| $4$ | $89$ out of $256$ | Lean, the compiler trusted (`hits_four_le`); the search above | the same, by a solver |
| $5$ | $358$ out of $1{,}024$ | two solvers and a search program, see below | the same, by one solver and by Section 8 |
| $6$ | at least $1{,}433$, at most $1{,}448$, out of $4{,}096$ | see below | at most $1{,}448$ |

In each row the best score is that of the Carter strategy, $7 \cdot 4^n / 20$ rounded down.

*One to four hats.* For one, two and three hats, Lean proves that no strategy has more hits, with nothing to trust but Lean itself. The search with crushed strategies is itself proved correct in Lean (`hits_le_best`), and for three hats Lean runs it. For four hats it is too slow inside Lean; there the theorem rests on the same search compiled into a program, which Lean trusts its compiler to run faithfully.

*Five hats.* That $358$ is the best score of a shared strategy was announced in 2014 [Wa14]. We find it again with an integer program given to the solver SCIP (the model of Section 8 with nothing skipped; $99$ seconds), and in 2026 the author obtained it with two more programs: the solver HiGHS and a search written for the purpose. These are answers of programs working with rounded numbers, not proofs that a machine has checked.

*Two strategies.* When Alice and Bob may use different strategies, they do not win more on one to four hats: the best score is the same. For up to three hats this is an enumeration (for each strategy of Alice, the best answer of Bob is found one stack at a time); for four hats, and for five, it is the answer of SCIP to an integer program ($384$ seconds for five hats). For five hats the question was listed as open in [Wa14]; besides this solver, on two models written separately, Section 8 gives a second computation of another kind.

*Six hats.* Nobody knows whether $1{,}433$ is the best score. The general bound $V \leq \frac{81}{224}$ of [BFGKRTVY] allows up to $1{,}481$ hits, and the bound $\frac{57}{160}$ of Section 8 up to $1{,}459$. The method of [BFGKRTVY] can be applied to six hats directly: sort the stacks that Alice may wear by their number of black hats, and bound the hits of each sort separately, by a solver. The author did this in 2026 and found $63 + 267 + 468 + 427 + 191 + 32 = 1{,}448$. This too is the answer of a solver. It leaves $15$ hits between the best strategy known and the bound.

#### What the best strategies look like

The search can list all the best crushed strategies (`search -n 3 -a`). Sorting them into classes of equivalent strategies gives:

| Hats | Best crushed strategies | Classes | Classes, a strategy and its dual together | Classes built with resets and shifts |
|---|---|---|---|---|
| $2$ | $2$ | $2$ | $1$ | $2$ |
| $3$ | $4$ | $1$ | $1$ | $1$ |
| $4$ | $102$ | $10$ | $5$ | $6$ |
| $5$ | $1{,}014$ | $27$ | $15$ | $9$ |

On two hats the best strategies are $\mathbf{B}_2$ and $\mathbf{W}_2$, which is $\mathbf{C}_2$. On three hats there is only one: every strategy with $22$ hits is equivalent to $\mathbf{C}_3$, up to the two choices that do not matter. On four hats there are ten, on five hats twenty-seven. (For five hats the list comes from a search of its own, which also finds, in a minute, that no strategy has $359$ hits.)

The last column counts the classes that hold a strategy built from $\str{00}$ with the three resets, the two shifts and the double shift. On four hats, four of the ten classes hold no such strategy. One of them is that of

$$
\str{00103030\,22112230}
$$

which has $89$ hits like $\mathbf{C}_4$. So resets and shifts do not give all the best strategies. If the conjecture $V = \frac{7}{20}$ holds, they give at least one on every number of hats, the Carter strategy.

#### Cuts: strategies that are best at every height

What tells the six classes that are built from the four that are not? Here is one answer.

Say that a strategy on $n$ hats is *bottom-up* when it never points above the hats that it had to read: if the $k$ lowest hats of the stack seen are enough to know where it points, it points below position $k$. For such a strategy, the *cut* to $k$ hats is the strategy on $k$ hats that points where it points when $k$ hats are enough to know, and at the bottom hat otherwise. The Carter strategies are bottom-up, and their cuts are Carter strategies: the cut of $\mathbf{C}_n$ to $k$ hats is $\mathbf{C}_k$. This is one more way to say that $\mathbf{C}_n$ is a single rule, cut to $n$ hats.

Call a best strategy on $n$ hats *hereditary* when its cuts to $1, 2, \ldots, n - 1$ hats are best strategies too, and *primitive* when no strategy equivalent to it is hereditary.

- The Carter strategies are hereditary, as far as the best scores are known. Being bottom-up is not rare: of the $120$ strategies equivalent to $\mathbf{C}_5$, $80$ are. But only $4$ of them are hereditary: $\mathbf{C}_5$ and those obtained by taking the other double shift at one step or at both.
- On four hats, the six classes built with resets and shifts each hold a hereditary strategy. The four others are primitive: the cuts of their strategies to three hats have at most $20$ hits, where the best is $22$.

- On five hats it is the same: the nine classes that are built are the nine that hold a hereditary strategy. The eighteen others are primitive; the cuts of their strategies are best on three hats, with $22$ hits, and one short on four, with $88$.

On five hats the picture can be made simpler still. The twenty-seven classes are three strategies, each with two *loose* choices: two stacks for which the strategy may point at any of three positions without changing its hits (for $\mathbf{C}_5$, the stacks $2$ and $27$, and the positions $0$, $3$ and $4$). Three times three choices make nine classes for each. The three strategies are

- the Carter strategy $\mathbf{C}_5 = \mathbf{C}_3\,\dshift$, whose nine variants are the nine built classes;
- the twisted double shift of $\mathbf{C}_3$ (Section 4);
- the dual of the twisted double shift of the dual of $\mathbf{C}_3$.

The last two are exchanged by the exchange of the colors. So up to the renamings of the positions, the exchange of the colors and the loose choices, there are two best strategies on five hats: the two ways to add two hats to $\mathbf{C}_3$ with a gain of $6$. With the twisted double shift among the operations, every best strategy on five hats is built.

So on four and on five hats, "built with resets and shifts" and "best at every smaller number of hats" say the same thing. The first primitive best strategies appear on four hats, and they owe nothing to a best strategy on three hats. (This is the answer of programs, `cuts.py` and `best_classes5.py` in the repository.)

### 8. Can $\frac{7}{20}$ be beaten?

Nobody knows. This section says what beating $\frac{7}{20}$ would take, and reports three attempts with the tools of this article. None succeeds.

Recall that $V_n$ is the best win rate on $n$ hats when Alice and Bob may use different strategies, and that $V$, the best win rate of the game, is the limit of the $V_n$, which never decrease ([Proposition 4](#proposition-4)).

#### One more hit

**Proposition 12 (the conjecture, one number of hats at a time).** The following are equivalent.

1. $V = \frac{7}{20}$.
2. For every $n \geq 1$, nothing on $n$ hats wins more pairs of stacks than the Carter strategy: $V_n = w(\mathbf{C}_n)$.

*Proof.* A win rate on $n$ hats is a whole number of pairs out of $4^n$, with one strategy or with two. By [Theorem 3](#theorem-3) the Carter strategy wins $7 \cdot 4^n / 20$ pairs rounded down, and $7 \cdot 4^n / 20$ is never whole. So a plan on $n$ hats that wins one more pair than $\mathbf{C}_n$ has a win rate above $\frac{7}{20}$, and then $V > \frac{7}{20}$. Conversely, if nothing beats $\mathbf{C}_n$ for any $n$, every $V_n$ is below $\frac{7}{20}$, and so is their limit; and it is not less, by the Carter strategies themselves.

So the conjecture is an infinite list of statements about whole numbers, one for each number of hats, and Section 7 says where we stand: the first five are checked. The sixth is whether some plan on six hats wins $1{,}434$ pairs out of $4{,}096$. One such plan, resetting itself forever with double resets as in Section 3, would win with probability $\frac{1{,}433}{4{,}092} = 0.35019\ldots$

The misses are not all of the same size. On an odd number of hats, $7 \cdot 4^n / 20$ exceeds the Carter score by $0.4$; on an even number, by $0.6$. An extra hit is a shorter step on an even number of hats.

#### Better shifts

The double shift does better than two single shifts. Could an operation that adds three hats, or more, do better than the shifts that we have? Say that an operation that adds $k$ hats is *of gain $c$* when it turns every proper strategy $s$ into a strategy with $4^k \, |H(s)| + c$ hits. The white and the black shift are of gain $1$, the double shift of gain $6$. Shifts in a row give, with $h = |H(s)|$:

| Hats added | Operation | Hits |
|---|---|---|
| $3$ | $s\,\wshift\,\dshift$ | $64 \, h + 22$ |
| $3$ | $s\,\dshift\,\wshift$ | $64 \, h + 25$ |
| $4$ | $s\,\dshift\,\dshift$ | $256 \, h + 102$ |

**Proposition 13 (the shifts cannot be improved).** An operation that adds $k$ hats has a gain of at most $1$, $6$, $25$, $102$ for $k = 1, 2, 3, 4$. The shifts above reach these gains.

*Proof.* Apply the operation to the strategy $\str{00}$ on one hat, which has one hit. The result is a strategy on $k + 1$ hats with $4^k + c$ hits, at most the best score on $k + 1$ hats: $5$, $22$, $89$, $358$ (Section 7). So $c$ is at most $5 - 4$, $22 - 16$, $89 - 64$, $358 - 256$.

The statement is as sure as the best scores it uses: proved for $k = 1$ and $2$, proved with a compiler trusted for $k = 3$, the answer of solvers for $k = 4$. So there is no "triple shift" of gain $26$: it would make a strategy with $90$ hits on four hats. In general, an operation that adds $k$ hats with a better gain than shifts in a row would beat the Carter strategy on $k + 1$ hats, and with it $\frac{7}{20}$.

#### More general resets

A double reset skips a block of hats when it is all white or all black. Why these two stacks? One may skip any set of stacks.

A *scheme* on blocks of $m$ hats is a set $Z$ of stacks of $m$ hats, the *skipped* stacks, not all of them, and a strategy $a$ on $m$ hats. It defines a strategy on infinite stacks: look at the hats $m$ by $m$ from the bottom; skip every block that is in $Z$; on the first block that is not, play $a$. The paper [BCCZW] calls these *recursive strategies*. The limit $\mathbf{R}_\infty$ is the scheme on blocks of three hats with $Z$ made of the all-white and the all-black stack and $a = \mathbf{C}_3$; the limit $\mathbf{B}_\infty$ is a scheme on blocks of one hat.

**Proposition 14 (the win rate of a scheme).** The scheme $(Z, a)$ on blocks of $m$ hats, with $a$ proper, has the win rate

$$
\frac{A + c}{4^m - |Z|^2} ,
$$

where $A$ is the number of hits $(t, u)$ of $a$ with neither $t$ nor $u$ in $Z$, and $c$ is the number of pairs $(t, u)$ with $t$ in $Z$, $u$ not in $Z$, and a black hat of $t$ at the position $a(u)$.

*Proof.* Let $x$ be the win rate, and look at the lowest blocks $t$ and $u$ of the two players. If neither is skipped, both play $a$ and win when $(t, u)$ is a hit of $a$: $A$ pairs out of $4^m$. If both are skipped, the game starts again above: $|Z|^2$ pairs, each won with probability $x$. If $t$ is skipped and $u$ is not, the player who wears $t$ sees $u$ and points at the position $a(u)$ of the block $t$; the other player skips $t$ and points at a hat above their lowest block, chosen without a look at their own hats: it is black half of the time. The same goes with the two players exchanged, which makes $2 \cdot \frac12 \cdot c$. Hence $4^m \, x = A + c + |Z|^2 \, x$.

For the double reset, $Z$ has two stacks, and the formula becomes that of "A first look at $\frac{7}{20}$" in Section 3:

$$
x = \frac{|H(a)| - 1}{4^m - 4} .
$$

**Proposition 15 (double resets of the Carter strategies).** Reset the Carter strategy on $n$ hats by itself forever, with double resets. For odd $n \geq 3$ the win rate is $\frac{7}{20}$. For even $n$ it is $\dfrac{7 \cdot 4^n - 32}{20 \, (4^n - 4)}$, which is less.

*Proof.* Put the hits of [Theorem 3](#theorem-3) in the formula: $20 \, |H(\mathbf{C}_n)|$ is $7 \cdot 4^n - 8$ for odd $n$ and $7 \cdot 4^n - 12$ for even $n$.

So $\frac{7}{20}$ is reached with blocks of every odd size, three, five, seven and so on, and the Carter strategy is a block that does it. The paper [BCCZW] has this result: a scheme on blocks of five hats that wins $7$ times in $20$, then one for every odd size, and none for an even size when the skipped stacks are the all-white and the all-black one.

Now the question: does some scheme beat $\frac{7}{20}$? There is a bound that needs no computer.

**Proposition 16 (a scheme that skips much does not win much).** With the notation of [Proposition 14](#proposition-14),

$$
A + c \leq 2^{m-1} \left( 2^m - |Z| \right) , \qquad \text{so that the win rate is at most} \quad \frac{2^{m-1}}{2^m + |Z|} .
$$

A scheme with $|Z| \geq \frac67 \, 2^{m-1}$ does not beat $\frac{7}{20}$.

*Proof.* Fix a stack $u$ outside $Z$. Among the $2^m$ stacks $t$, exactly $2^{m-1}$ have a black hat at the position $a(u)$. The pairs $(t, u)$ that $A$ and $c$ count are among them: for $A$ the stack $t$ is outside $Z$ and must be black at $a(u)$ for the pair to be a hit, for $c$ it is in $Z$ and black at $a(u)$. There are $2^m - |Z|$ stacks $u$. This gives the first inequality; divide by $4^m - |Z|^2 = (2^m - |Z|)(2^m + |Z|)$ for the second. The last statement is $\frac{2^{m-1}}{2^m + |Z|} \leq \frac{7}{20}$, solved for $|Z|$.

(Lean: `schemeScore_le`, `schemeScore_le_seven_twentieths`, for the inequality on $A + c$. The win rate formula of [Proposition 14](#proposition-14) is not in Lean.)

For blocks of five hats, this settles the schemes that skip $14$ stacks or more. For the others we asked programs.

**Result (programs).** No scheme on blocks of at most five hats beats $\frac{7}{20}$.

| Block | Schemes | Best win rate | How |
|---|---|---|---|
| $1$ hat | $3$ | $\frac13$ | all tried |
| $2$ hats | $80$ | $\frac13$ | all tried |
| $3$ hats | $65{,}535$ | $\frac{7}{20}$, by the double reset of $\mathbf{C}_3$ and its equivalents only | all tried |
| $4$ hats | $5^{16}$, about $1.5 \cdot 10^{11}$ | $\frac{7}{20}$, by the scheme on three hats with a fourth hat that is not looked at | all tried |
| $5$ hats | $6^{32}$, about $8 \cdot 10^{24}$ | $\frac{7}{20}$ | see below |

Blocks of five hats have too many schemes to try. The work was split by the number of skipped stacks:

| Skipped stacks | No scheme beats $\frac{7}{20}$, by |
|---|---|
| $0$ to $5$ | the solver SCIP on one integer program for each number; from $99$ seconds to $2$ hours $45$ |
| $6$ and $7$ | SCIP on one program for each set $Z$, one $Z$ in each class under the renamings of the positions: $10{,}195$ and $34{,}230$ runs |
| $4$ to $13$ | a search written for the purpose, which counts the pairs of stacks on which one player points at a black hat and the other does not; from $57$ thousand cases for $13$ skipped stacks to $3.3 \cdot 10^{11}$ for $4$ |
| $14$ to $31$ | [Proposition 16](#proposition-16) |

The numbers $4$ to $7$ are settled twice, by programs that have nothing in common. All this is the answer of programs, apart from [Proposition 16](#proposition-16).

Blocks of six hats are open. [Proposition 16](#proposition-16) settles the schemes that skip $28$ stacks or more, out of $64$.

#### Around the Carter strategies

The last attempt is the simplest: start from a Carter strategy and change some of its choices. A program looked, on six, seven and eight hats, for a strategy with one more hit.

| Hats | Carter score | No better strategy within | Random walks |
|---|---|---|---|
| $6$ | $1{,}433$ | $8$ changed choices | $300{,}000$ steps, nothing |
| $7$ | $5{,}734$ | $7$ changed choices | $300{,}000$ steps, nothing |
| $8$ | $22{,}937$ | $6$ changed choices | $100{,}000$ steps, nothing |

"Within $r$ changed choices" is complete: every strategy that differs from the Carter strategy for at most $r$ stacks was ruled out. The walks move from a strategy to another with the same score, one or two changes at a time, and look around each. There is room to walk: on eight hats, $14.9$ million strategies differ from $\mathbf{C}_8$ for exactly six stacks and have its score, and a walk went as far as $21$ changes away. A Carter strategy is not an isolated peak. It sits on a wide plateau, and we found no way up from it.

#### From above: hints

Everything so far is about strategies, that is, about lower bounds on $V$. The upper bounds come from an idea of [BFGKRTVY]: give the players a *hint*. If they cannot win more than a certain rate with the hint, they cannot without it, since they are free to ignore it.

The hint of dimension $d$ is this. Take the $2^d$ points $x$ with $d$ coordinates $0$ or $1$, and the functions $f(x) = a \cdot x + b$ modulo $2$, with $a$ not zero: the affine functions that are not constant. There are $m = 2 \, (2^d - 1)$ of them, and each takes the value $1$ at half of the points. The referee picks one of them, $f$, at random, and makes Alice's stack out of its values: each of her hats is the value of $f$ at a point, black for $1$, and every point comes back again and again up the stack. Each hat of Alice is still black or white with equal chances, so the game is the same for players who ignore how the stack was made. But the players are told how it was made. Bob, who sees Alice's stack, then knows $f$; all that he can do is to sort the $m$ functions into blocks, one block for each of his own hats that he may point at. Alice, who sees which of Bob's hats are black, picks a point. Write $H_d$ for the best win rate of this game. Then

$$
V \leq H_d \quad \text{for every } d .
$$

The first bound of [BFGKRTVY], $\frac38$, is $H_1$, and their best, $\frac{81}{224}$, is $H_3$: they computed it by trying all the ways of sorting $14$ functions into blocks, about $190$ million.

The hint game contains the game of hats on $d + 1$ hats, almost.

**Proposition 17 (the hint and the game on $d + 1$ hats).** Let $n = d + 1$. For any two strategies on $n$ hats, one for Alice and one for Bob, the number of pairs of stacks on which they win is at most

$$
2^d + 2^n \left( 2^n - 2 \right) H_d .
$$

*Proof.* In the hint game, let Alice look only at the hats that are the values of $f$ at $n$ points: the point $0$ and the $d$ points with a single coordinate $1$. The values of $f$ there are $b$ and $b + a_1, \ldots, b + a_d$. As $f$ runs over the affine functions that are not constant, these $n$ hats make each stack of $n$ hats once, except the all-white and the all-black ones. So Alice and Bob, with their strategies on $n$ hats, play the game on $n$ hats with a stack of Alice that is not of a single color, each such stack being as likely as the others; and this is a way to play the hint game, where Bob uses $n$ of his hats. Their win rate is then at most $H_d$. There are $2^n - 2$ stacks for Alice and $2^n$ for Bob: at most $2^n (2^n - 2) H_d$ winning pairs in which Alice's stack is not of a single color. When it is all white they lose. When it is all black they win at most when Bob's hat is black where he points, which is the case for $2^d$ of his stacks.

(Lean: `hitsTwo_le_hintWins`, `hitsTwo_le_of_hint_le`.)

So an upper bound on $V$ obtained from a hint is also an upper bound on the best score on a given number of hats, for two strategies as well as for one. And it works the other way: with the Carter strategy on $d + 1$ hats, [Proposition 17](#proposition-17) says that $H_d$ is at least

$$
\frac{|H(\mathbf{C}_{d+1})| - 2^d}{2^{d+1} \left( 2^{d+1} - 2 \right)} ,
$$

the win rate of $\mathbf{C}_{d+1}$ when Alice's stack is known not to be of a single color. Here is that number next to what is known of $H_d$.

| $d$ | Hits of $\mathbf{C}_{d+1}$ | Its win rate, Alice's stack not of one color | $H_d$ |
|---|---|---|---|
| $1$ | $5$ | $\frac38$ | $\frac38$ [BFGKRTVY] |
| $2$ | $22$ | $\frac38$ | $\frac38$ [BFGKRTVY] |
| $3$ | $89$ | $\frac{81}{224}$ | $\frac{81}{224}$ [BFGKRTVY] |
| $4$ | $358$ | $\frac{57}{160}$ | $\frac{57}{160}$ ([Ya26], and below) |
| $5$ | $1{,}433$ | $\frac{1401}{3968}$ | at least this; at most $\frac{17}{48}$ according to [Ya26] |
| $6$ | $5{,}734$ | $\frac{45}{128}$ | at least this |

In every case where $H_d$ is known, it is the Carter number: neither the points that Alice may use beyond the $d + 1$ of the proof, nor the hats that Bob may use beyond $d + 1$, bring anything. We do not know why. In closed form the Carter number is $\frac{7}{20} + \left( \frac15 - \frac{c}{2^d} \right) \frac{1}{m}$, with $c = \frac15$ for even $d$ and $\frac{3}{10}$ for odd $d$: about $\frac{7}{20} + \frac{1}{10 \cdot 2^d}$.

**Result (programs).** $H_4 = \frac{57}{160}$, and so

$$
V \leq \frac{57}{160} = 0.35625 .
$$

This value was announced in November 2026 in a note that comes with programs and that nobody has reviewed [Ya26]. We wrote a program of our own for it, from the definition of the game, without reading theirs. It goes through the ways of sorting the $30$ functions into blocks. It drops a partial sorting as soon as a bound shows that it cannot do better than the target: the $30$ functions hold $15$ copies of the hint of dimension $3$, whose values are all in a table, and the win rate is at most the average of these $15$. It also uses the $645{,}120$ symmetries of the hint. With the target $\frac{57}{160}$ it scored $38{,}779{,}772$ complete sortings exactly, in $17$ hours of one processor, and found none above the target. Those at the target make $11$ classes under the symmetries, $250{,}880$ sortings in all, with $5$ or $6$ blocks: the numbers of [Ya26]. On the way, the program finds $\frac{81}{224}$ again for dimension $3$, reached by $3{,}920$ sortings, as [BFGKRTVY] say. This is the answer of programs, not a proof that a machine has checked.

Three consequences.

- By [Proposition 17](#proposition-17) with $d = 3$ and $d = 4$: no two strategies win more than $8 + 224 \cdot \frac{81}{224} = 89$ pairs on four hats, nor more than $16 + 960 \cdot \frac{57}{160} = 358$ on five. This is another way to the best scores of Section 7, by programs of a different kind, and it covers two different strategies. (Lean checks the step from the hint values to the scores: `hitsTwo_four_le`, `hitsTwo_five_le`. The hint values themselves are computations.)
- This family of hints will not settle the conjecture cheaply. The hint of dimension $d$ cannot prove a bound below the Carter number, about $\frac{7}{20} + \frac{1}{10 \cdot 2^d}$, and each dimension costs far more than the one before.
- If $H_5 \leq \frac{17}{48}$, as [Ya26] reports, then $V \leq \frac{17}{48} = 0.35416\ldots$, and by [Proposition 17](#proposition-17) no two strategies win more than $1{,}437$ pairs on six hats. We have not checked that computation.

#### How fast the best win rates climb

Whatever $V$ is, [Theorem 3](#theorem-3) says how fast the best win rates on $n$ hats get near $\frac{7}{20}$ at least:

$$
V_n \;\geq\; \frac{7}{20} - \frac{3}{5 \cdot 4^n} \quad \text{for every } n \geq 1 ,
$$

with $2$ in place of $3$ for odd $n$. If $V = \frac{7}{20}$, this is an equality ([Proposition 12](#proposition-12)), and no smaller gap is possible in any case: the gap between $\frac{7}{20}$ and a win rate on $n$ hats is at least $\frac{1}{5 \cdot 4^n}$, as [BCCZW] note. The same paper proves that $\frac{7}{20} - V_n$ is at most a constant times $(4^{1 - \varepsilon})^{-n}$, for every $\varepsilon > 0$. The Carter strategies give the exponent $4^{-n}$ itself.

### 9. Open questions

The first three are in the papers. The others came up in this work; we do not know whether they were asked before.

**Conjecture A (the value of the game).** $V = \frac{7}{20}$ [BFGKRTVY].

By [Proposition 12](#proposition-12) this says that on every number of hats, no plan wins one more pair of stacks than the Carter strategy. The first case that is not settled is six hats: the best score is between $1{,}433$ and $1{,}448$ out of $4{,}096$ (Section 7).

**Question B (two strategies).** On some number of hats, do Alice and Bob win more with two different strategies than with the best strategy that they can share?

Not on one to four hats; not on five either, according to one solver (Section 7). If the answer is no for every number of hats, the game is that of this article: one strategy, counted by its hits.

**Conjecture C (many players).** With more players, each wearing a stack and all of them having to point at a black hat, the best win rate tends to $0$ as the number of players grows (Levine; see [BFGKRTVY], where it is proved that the best win rate decreases with each player).

Our resets and shifts are for two players. Do they have a counterpart for three, with formulas for the hits? A first look by program suggests that the Carter rule has a part to play there. With three players and five hats each, let each player compute where the Carter rule points for each of the two stacks seen, and point at the sum of these two positions modulo $3$: this wins $8{,}704$ times out of $32{,}768$. A table of $15$ entries that says where to point for each pair of Carter positions does better, $8{,}903$. The best table known, found by a search in 2014 [BFGKRTVY], wins $9{,}120$ times; it has $528$ entries and no description.

**Question D (general resets).** Does a scheme on blocks of six hats or more win more than $7$ times in $20$?

Not on blocks of at most five hats (Section 8). On blocks of six hats, [Proposition 16](#proposition-16) leaves the schemes that skip fewer than $28$ stacks out of $64$. One may also let the game go on in different ways after different skipped blocks: a scheme with several continuations. We have not looked at these.

**Question E (the best strategies that are not built).** On four hats, four of the ten classes of best strategies hold no strategy built with resets and shifts (Section 7). What are they? Is there one more operation that gives them? And on every number of hats, is some best strategy built with resets and shifts?

The last question has the answer yes if [Conjecture A](#conjecture-A) holds, since the Carter strategies are built. The numbers of classes, $2$, $1$, $10$ on two, three and four hats, are too few to guess a rule.

**Question F (Carter and Reyes).** The Reyes strategy on $3j$ hats and the Carter strategy on $2j + 1$ hats have the same win rate, $\frac{7}{20} - \frac{1}{10 \cdot 16^j}$ (Section 5). Is there a reason, such as a way to turn one into the other?

**Question G (an upper bound from matrices).** For a strategy $s$ on $n$ hats, let $N$ be the table with $n$ rows and $n$ columns in which $N_{p,q}$ is the number of stacks $t$ with $s(t) = p$ and a black hat at position $q$. Then

$$
|H(s)| = \sum_{p,q} N_{p,q} \, N_{q,p} ,
$$

the trace of the square of $N$. Which tables come from a strategy? Does a description of them by inequalities give an upper bound on $V$ below those of Section 8?

**Question H (the best strategies on infinite stacks).** If $V = \frac{7}{20}$, the limits $\mathbf{C}_\infty$ and $\mathbf{R}_\infty$ are best strategies on infinite stacks, and they are computed by machines that read finitely many hats and stop (Section 6). Is every best strategy of that kind, up to a set of stacks of probability $0$? And whatever $V$ is, is it the best win rate of such machines?

**Question I (certificates).** That $358$ is the best score on five hats, and the bound $1{,}448$ on six, are the answers of solvers that compute with rounded numbers. Can they be turned into proofs that a proof assistant checks? A solver can in principle give its answer with a certificate, a combination of inequalities with exact weights, whose check is arithmetic. For six hats this would make "$1{,}433$ is the best score", if true, a theorem. How large such a certificate would be, we do not know.

**Question J (hints and the Carter strategies).** Is the best win rate $H_d$ of the hint game of dimension $d$ (Section 8) always the win rate of the Carter strategy on $d + 1$ hats when Alice's stack is not of a single color?

It is for $d$ from $1$ to $4$. If it is for every $d$, then $V = \frac{7}{20}$, since these numbers tend to $\frac{7}{20}$. And $H_5 = \frac{1401}{3968}$ alone would prove that $1{,}433$ is the best score on six hats.

**Question K (hereditary and primitive).** Is every hereditary best strategy built with resets and shifts? Are there primitive best strategies on every number of hats from four on, and how many classes?

On four and on five hats the answer to the first question is yes, and the primitive classes are four out of ten, then eighteen out of twenty-seven (Section 7). On five hats the primitive ones come from one more operation, the twisted double shift of Section 4. Is there a finite list of operations that builds every best strategy, on every number of hats? And does the twisted double shift have $16 \, |H(s)| + 6$ hits for every proper $s$, as it does for all those we tried?

## References

- [AFKK] N. Alon, E. Friedgut, G. Kalai and G. Kindler, *The success probability in Levine's hat problem, and independent sets in graphs*, preprint, 2022, [arXiv:2208.06858](https://arxiv.org/abs/2208.06858).
- [BCCZW] C. Bouquet, S. Chikhi, T. Charles, Y. Zhou and E. Wang, *An analytical framework for the Levine hats problem: new strategies, bounds and generalizations*, preprint, 2025, [arXiv:2508.01737](https://arxiv.org/abs/2508.01737).
- [BFGKRTVY] J. Buhler, C. Freiling, R. Graham, J. Kariv, J. R. Roche, M. Tiefenbruck, C. Van Alten and D. Yeroshkin, *On Levine's notorious hat puzzle*, Integers 21 (2021), A45, [arXiv:1407.4711](https://arxiv.org/abs/1407.4711).
- [Bu20] J. Buhler, *Hat Problems*, Numberphile, video, 2020, <https://www.youtube.com/watch?v=laAtv310pyk>.
- [FL13] T. Friedrich and L. Levine, *Fast simulation of large-scale growth models*, Random Structures & Algorithms 42 (2013), 185–213, [arXiv:1006.1003](https://arxiv.org/abs/1006.1003).
- [HT25] S. Heilman and O. Tamuz, *A Fourier approach to Levine's hat puzzle*, preprint, 2025 (as quoted in [BCCZW]).
- [Kh11] T. Khovanova, *How many hats can fit on your head?*, blog post, 2011, <https://blog.tanyakhovanova.com/2011/04/how-many-hats-can-fit-on-your-head/>.
- [Wa14] S. Wagon, *Problem 1179: An infinitely puzzling hat problem*, Macalester Problem of the Week, 2014, <http://stanwagon.com/potw/fall13/p1179.html>.
- [Ya26] "Yang" (GitHub account yangsong97), *levine-hat-bounds*, a note with programs, November 2026, not reviewed, <https://github.com/yangsong97/levine-hat-bounds>.
