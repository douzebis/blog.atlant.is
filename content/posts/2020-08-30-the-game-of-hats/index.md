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

and conjecture that $V = \frac{7}{20}$. They also prove that the best win rate decreases with each player added, which Alon, Friedgut, Kalai and Kindler prove by other means [AFKK]. More recently, Bouquet, Chikhi, Charles, Zhou and Wang [BCCZW] found new plans that win $7$ times in $20$, built on blocks of five hats, then of any odd number of hats, where the plans of 2014 use blocks of three. They quote one more upper bound, $V \leq 0.37193$, obtained by Heilman and Tamuz without a computer [HT25].

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

The posts of 2020 brought the operations with their formulas, the Carter strategy for every number of hats, and the description of the limit strategies by machines. This article adds the closed form $7 \cdot 4^n / 20$ rounded down and its link with the conjecture, the proofs for stacks that never end, and the results of Section 8. As far as we know these are not in the papers cited above.

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

(Lean: `ds` is defined as $s\,\bshift\,\wshift$ with one choice changed; `sibling_eq` says that the strategy of the first point is the dual of the double shift of the dual. That it is $\sigma \cdot (s\,\dshift)$ is checked by program.)

So there are two double shifts, and they are equivalent: each is the other with the two new positions renamed. We keep the first and write it $s\,\dshift$. Nothing later depends on this choice, because the operations of this article only look at a block of hats to ask whether it is all white or all black, which a renaming inside the block does not change: replacing a double shift by the other one anywhere in a strategy gives an equivalent strategy.

Compare with the single shifts. Exchanging the colors turns the white shift into the black shift, and these two are not equivalent: $\str{0010}$ and $\str{0100}$ are not the same strategy with the positions renamed. The double shift is sent by the exchange of the colors to an equivalent strategy. It does not prefer a color.

That one changed letter is worth a remark. Resets and single shifts build a strategy on many hats out of strategies on fewer hats, and their hits add up as the formulas say. The double shift is not built that way: it is a block on two hats that does better than the two single shifts it is made of. A natural question is whether a block on three or more hats does better still. We come back to it in Section 8.

### 5. Five families

*To come.*

### 6. Infinite stacks

*To come.*

### 7. The calculator, and the best strategies on few hats

*To come.*

### 8. Can $\frac{7}{20}$ be beaten?

*To come.*

### 9. Open questions

*To come.*

## References

- [AFKK] N. Alon, E. Friedgut, G. Kalai and G. Kindler, *The success probability in Levine's hat problem, and independent sets in graphs*, preprint, 2022, [arXiv:2208.06858](https://arxiv.org/abs/2208.06858).
- [BCCZW] C. Bouquet, S. Chikhi, T. Charles, Y. Zhou and E. Wang, *An analytical framework for the Levine hats problem: new strategies, bounds and generalizations*, preprint, 2025, [arXiv:2508.01737](https://arxiv.org/abs/2508.01737).
- [BFGKRTVY] J. Buhler, C. Freiling, R. Graham, J. Kariv, J. R. Roche, M. Tiefenbruck, C. Van Alten and D. Yeroshkin, *On Levine's notorious hat puzzle*, Integers 21 (2021), A45, [arXiv:1407.4711](https://arxiv.org/abs/1407.4711).
- [Bu20] J. Buhler, *Hat Problems*, Numberphile, video, 2020, <https://www.youtube.com/watch?v=laAtv310pyk>.
- [FL13] T. Friedrich and L. Levine, *Fast simulation of large-scale growth models*, Random Structures & Algorithms 42 (2013), 185–213, [arXiv:1006.1003](https://arxiv.org/abs/1006.1003).
- [HT25] S. Heilman and O. Tamuz, *A Fourier approach to Levine's hat puzzle*, preprint, 2025 (as quoted in [BCCZW]).
- [Kh11] T. Khovanova, *How many hats can fit on your head?*, blog post, 2011, <https://blog.tanyakhovanova.com/2011/04/how-many-hats-can-fit-on-your-head/>.
- [Wa14] S. Wagon, *Problem 1179: An infinitely puzzling hat problem*, Macalester Problem of the Week, 2014, <http://stanwagon.com/potw/fall13/p1179.html>.
