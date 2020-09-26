---
title: "Classic 15 Puzzle"
date: "2020-09-14"
---

\[auto-iframe link=https://fredatatlantis.github.io/FifteenPuzzle.js/fifteenpuzzle.html width=100% height=400 autosize=no\]

15-puzzle by Mark Rohlich

## Genesis

> The Fifteen Puzzle consists of fifteen numbered square tiles in a 4×4 square grid, with one position empty or blank. Any tile horizontally or vertically adjacent to the blank can be moved into the blank position. The task is to rearrange the tiles from some random initial configuration into a desired goal configuration, ideally or optimally using the fewest moves possible.
> 
> The Fifteen Puzzle was invented by Sam Loyd\[efn\_note\]Although this is [disputed](https://en.wikipedia.org/wiki/15_puzzle).\[/efn\_note\] in the 1870s \[zotpressInText item="{6833562:DA682IHW}"\], and appeared in the scientific literature shortly thereafter \[zotpressInText item="{6833562:929MI6GN}"\]. The editor of the journal added the following comment to the paper: “The ‘15’ puzzle for the last few weeks has been prominently before the American public, and may safely be said to have engaged the attention of nine out of ten persons of both sexes and of all ages and conditions of the community.”
> 
> One reason for the world-wide Fifteen Puzzle craze was that Loyd offered a $1000 cash prize to transform a particular initial state to a particular goal state. Johnson and Story proved that it wasn’t possible, that the entire state space was divided into even and odd permutations, and that there is no way to transform one into the other by legal moves.
> 
> \[zotpressInText item="{6833562:Q2GV7Z5H}"\]

![](https://blog.atlant.is/wp-content/uploads/2020/09/fifteen-loyd.png)

Loyd's impossible goal state with a \\$1000 cash prize

## Proof of insolvability

The classical proof\[efn\_note\]As given on [wikipedia](https://en.wikipedia.org/wiki/15_puzzle) or [numberphile](https://www.youtube.com/watch?v=YI1WqYKHi78&vl=fr).\[/efn\_note\] for the insolvability of the puzzle involves an argument on:

- the parity\[efn\_note\]Refer to section [cheatsheet](#cheatsheet) for permutations notations and the definition of parity.\[/efn\_note\] of the permutation of the squares on the grid,
- versus the parity of the taxicab distance (number of rows plus number of columns) traveled by the blank square

A summertime conversation with G.R., who was not aware of the question or the proof, lead to his suggesting a subtle and interesting variant which fully dispenses with the blank square. Here it goes...

## Variant

The classical insolvability proof works by identifying the set of possible puzzle states with the group $\\mathcal{S}\_{16}$ of permutations of the squares on the puzzle grid. Instead for the variant we work with the group $\\mathcal{S}\_{18}$ of permutations of the _fifteen_ tiles plus _three_ fictitious elements $a$, $b$, $c$, which represent the horizontal separations between the rows of the puzzle.

### Puzzle states

As shown in the picture below, the initial state of the puzzle is represented by the identity permutation in $\\mathcal{S}\_{18}$:

$$\\text{Id} =  
\\left(  
\\begin{array}{l}  
1\\;2\\;3\\;4\\;a\\;5\\;6\\;7\\;8\\;b\\;9\\;10\\;11\\;12\\;c\\;13\\;14\\;15\\\\  
1\\;2\\;3\\;4\\;a\\;5\\;6\\;7\\;8\\;b\\;9\\;10\\;11\\;12\\;c\\;13\\;14\\;15  
\\end{array}  
\\right)$$

![](https://blog.atlant.is/wp-content/uploads/2020/09/fifteen-phy-1.png)

![](https://blog.atlant.is/wp-content/uploads/2020/09/fifteen-s18-1.png)

Initial puzzle state

Element of $\\mathcal{S}\_{18} $

Note that moving a tile horizontally does not change the representation in $\\mathcal{S}\_{18}$, but moving a tile vertically does:

![](https://blog.atlant.is/wp-content/uploads/2020/09/fifteen-phy-2.png)

![](https://blog.atlant.is/wp-content/uploads/2020/09/fifteen-s18-2.png)

After moving tile $11$ down

Element of $\\mathcal{S}\_{18} $

After tile $11$ has been moved down, the representation of the puzzle becomes:

\\begin{align\*}  
&\\left(  
\\begin{array}{l}  
1\\;2\\;3\\;4\\;a\\;5\\;6\\;7\\;8\\;b\\;9\\;10\\;11\\;12\\;c\\;\\;13\\;14\\;15\\\\  
1\\;2\\;3\\;4\\;a\\;5\\;6\\;7\\;8\\;b\\;9\\;10\\;12\\;\\;c\\;13\\;14\\;11\\;15  
\\end{array}  
\\right)\\\\  
\\\\  
\=&(11\\;12\\;c\\;13\\;14)\\quad \\text{(cycle of length 5)}  
\\end{align\*}

Let $\\mathcal{P} \\subset \\mathcal{S}\_{18}$ be the set of (representations of) all possible puzzle states, legal and non-legal. Then $\\mathcal{P}$ is precisely:

$$\\mathcal{P} = \\left\\{s\\in\\mathcal{S}\_{18}\\quad  
\\left|\\quad  
\\begin{array}{ll}  
&\\big(s(4)=a\\;\\text{and}\\;s(8)=b\\;\\text{and}\\;s(12)=c\\big)\\\\  
\\text{or}&\\big(s(4)=a\\;\\text{and}\\;s(8)=b\\;\\text{and}\\;s(c)=c\\big)\\\\  
\\text{or}&\\big(s(4)=a\\;\\text{and}\\;s(b)=b\\;\\text{and}\\;s(c)=c\\big)\\\\  
\\text{or}&\\big(s(a)=a\\;\\text{and}\\;s(b)=b\\;\\text{and}\\;s(c)=c\\big)  
\\end{array}  
\\right.  
\\;  
\\right\\}  
$$

### Tile moves

We sort tile moves according to their _type_, where there are exactly 24 types as shown in the following picture:

![](https://blog.atlant.is/wp-content/uploads/2020/09/fifteen-types.png)

$2\\cdot3\\cdot4=24$ types of moves

For instance, type $\\downarrow\_{c3}$ gather all moves like so:

- downwards,
- crossing separator $c$,
- in column $3$.

![](https://blog.atlant.is/wp-content/uploads/2020/09/fifteen-dc3.png)

This is move type $\\downarrow\_{c3}$

Let $\\mathcal{M}\\subset\\mathcal{P}\\times\\mathcal{P}$ be the set of (representations of) all possible tile moves, where $(s, e)\\in\\mathcal{M}$ is the move starting at $s$ and ending at $e$. Finally let us split $\\mathcal{M}$ along move types:

$$\\mathcal{M}\\quad=\\;\\;\\bigcup\_{\\text{all types }t}\\mathcal{M}\_t$$

### Tile moves are cycles

Lemma: all moves in $\\mathcal{M}$ are cycles of length $5$.

We verify this by considering every move type in turn.

For example, $\\forall (s, e)\\in\\mathcal{M}\_{\\downarrow\_{c3}}$:

$$\\begin{array}{l}  
e&=\\left(  
\\begin{array}{l}  
\\;\\;1\\;\\;\\;\\;2\\;\\;\\;\\;3\\;\\;\\;\\;4\\;\\;\\;\\;\\,a\\;\\;\\;\\;5\\;\\;\\;\\;6\\;\\;\\;\\;7\\;\\;\\;\\;8\\;\\;\\;b \\\\  
s(1) s(2) s(3) s(4) \\;a\\;s(5) s(6) s(7) s(8) b  
\\end{array}  
\\right. \\\\  
&\\\\  
&\\quad\\quad\\left.  
\\begin{array}{l}  
\\;\\;\\;9\\;\\;\\;\\;10\\;\\;\\;\\;11\\;\\;\\;12\\;\\;\\;\\;c\\;\\;\\;\\;\\;13\\;\\;\\;\\;14\\;\\;\\;\\;15 \\\\  
s(9) s(10) s(12)\\;\\;c\\;s(13) s(14) s(11) s(15)  
\\end{array}  
\\right) \\\\  
&\\\\  
&=\\;\\; (11\\;\\;12\\;\\;c\\;\\;13\\;\\;14)\\circ s,  
\\end{array}$$

which gives $e \\circ s^{-1} = (11\\;\\;12\\;\\;c\\;\\;13\\;\\;14)$.

And so on\[efn\_note\]  
\\begin{array}{|c|c|}  
\\hline  
(s,e)\\in&e\\circ s^{-1} =\\\\  
\\hline  
\\mathcal{M}\_{\\downarrow\_{a1}}&(1\\;2\\;3\\;4\\;a)\\\\  
\\mathcal{M}\_{\\downarrow\_{a2}}&(2\\;3\\;4\\;a\\;5)\\\\  
\\mathcal{M}\_{\\downarrow\_{a3}}&(3\\;4\\;a\\;5\\;6)\\\\  
\\mathcal{M}\_{\\downarrow\_{a4}}&(4\\;a\\;5\\;6\\;7)\\\\  
\\hline  
\\mathcal{M}\_{\\downarrow\_{b1}}&(5\\;6\\;7\\;8\\;b)\\\\  
\\mathcal{M}\_{\\downarrow\_{b2}}&(6\\;7\\;8\\;b\\;9)\\\\  
\\mathcal{M}\_{\\downarrow\_{b3}}&(7\\;8\\;b\\;9\\;10)\\\\  
\\mathcal{M}\_{\\downarrow\_{b4}}&(8\\;b\\;9\\;10\\;11)\\\\  
\\hline  
\\mathcal{M}\_{\\downarrow\_{c1}}&(9\\;10\\;11\\;12\\;c)\\\\  
\\mathcal{M}\_{\\downarrow\_{c2}}&(10\\;11\\;12\\;c\\;13)\\\\  
\\mathcal{M}\_{\\downarrow\_{c3}}&(11\\;12\\;c\\;13\\;14)\\\\  
\\mathcal{M}\_{\\downarrow\_{c4}}&(12\\;c\\;13\\;14\\;15)\\\\  
\\hline  
\\end{array}  
\[/efn\_note\]... Hence all moves are cycles of length $5$ and even parity:

$$  
\\forall (s, e) \\in \\mathcal{M}, \\quad \\pi(e \\circ s^{-1}) = 1  
$$

### Conclusion

Consider a _legal_ puzzle state $s\\in\\mathcal{P}$. There exists a sequence of moves $(s\_0,e\_0), \\cdots, (s\_n,e\_n)$ in $\\mathcal{M}$, such that:

$$  
\\left\\{  
\\begin{array}{l}  
s\_0=\\text{Id}\\\\  
\\forall i < n,\\quad s\_{i+1}=e\_i\\\\  
e\_n=s  
\\end{array}  
\\right.  
$$

It follows that:

\\begin{align\*}  
s&=e\_n\\circ(s\_n^{-1}\\circ e\_{n-1})\\circ\\cdots\\circ(s\_1^{-1}\\circ e\_0)\\circ\\text{Id}\\\\  
&=(e\_n\\circ s\_n^{-1})\\circ(e\_{n-1}\\circ s\_{n-1}^{-1})\\circ\\cdots\\circ (e\_1\\circ s\_1^{-1})\\circ(e\_0\\circ s\_0^{-1})  
\\end{align\*}

is a permutation with even parity.

Hence Loyd's \\$1000-cash puzzle goal state is not legal.$\\quad\\Box$

## References

\[zotpressInTextBib style="apa" sort="ASC"\]

* * *

## Permutations cheatsheet

A _permutation_ of the set $\\{1, 2, \\cdots, n\\}$ is a bijection of $\\{1, 2, \\cdots, n\\}$ with itself. The set of permutations of $\\{1, 2, \\cdots, n\\}$\[efn\_note\]or for that matter, of any set of finite cardinal $n\\in\\mathbb{N}$.\[/efn\_note\] is denoted by $\\mathcal{S}\_n$.

One usual way of writing a permutation $p$ is by providing the exhaustive list of $x \\mapsto p(x)$ mappings, in a rectangular matrix like so:

$$p=\\left(\\begin{array}{cccccc}  
1&2&3&4&5&6&7\\\\  
7&3&5&2&4&6&1  
\\end{array}\\right)$$

A more concise way is by specifying $p$ as a combination of _cycles_. For example:

$$p = (1\\;\\;7) (2\\;\\;3\\;\\;5\\;\\;4)$$

A permutation that consists of a single length-2 cycle is called a _transposition_. Every permutation in $\\mathcal{S}\_n$ can be expressed as a _composition_ of tranpositions. For example:

$$(1\\;\\;7) (2\\;\\;3\\;\\;5\\;\\;4) = (1\\;\\;7)\\circ(2\\;\\;3)\\circ(3\\;\\;5)\\circ(5\\;\\;4)$$

The operation of composition gives the set $\\mathcal{S}\_n$ a structure of _group_. There is a unique group morphism from $\\big(\\mathcal{S}\_n, \\circ\\big)$ to $\\big(\\{-1,1\\},\\cdot\\big)$ which maps transpositions to the value -1. This morphism is called _parity_ (denoted by $\\pi$ in this article).

$$\\pi: \\mathcal{S}\_n \\rightarrow \\{-1,1\\}$$

$$\\forall x, y \\in \\mathcal{S}\_n, \\;\\;\\pi(y\\circ x) = \\pi(y)\\cdot\\pi(x)$$

A cycle of length even (respectively odd) has parity odd (respectively even).
