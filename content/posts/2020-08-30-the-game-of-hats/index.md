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

The posts of 2020 brought the operations with their formulas, the Carter strategy for every number of hats, and the description of the limit strategies by machines. This article adds the closed form $7 \cdot 4^n / 20$ rounded down and its link with the conjecture, a second double shift, the proofs for stacks that never end, and the results of Section 8. As far as we know these are not in the papers cited above.

The statements of Sections 2 to 6 were checked by a proof assistant, Lean, and the numbers of this article by programs; a table at the end says which statement is checked by what.

#### For the readers of the posts of 2020

Three things changed, to agree with the papers that appeared since. The players now point at black hats, and black is the digit $1$. A pile of hats is a *stack*, no longer a tower. The operations are named after a color instead of a side: the left reset of 2020 is the white reset.

### 2. Stacks, strategies, hits

*To come.*

### 3. Resets

*To come.*

### 4. Shifts

*To come.*

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
