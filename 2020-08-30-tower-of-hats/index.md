---
title: "Towers of hats (1/3)"
date: "2020-08-30"
---

![](https://blog.atlant.is/wp-content/uploads/2020/09/hats-towering-pillar.png)

A towering pillar of hats (number $4$)

This is the first in a series of three _exercices de style_ to show some interesting aspects of the _game of hats_: a puzzle which was initially proposed by Lionel Levine, and arose from his work with Tobias Friedrich on \[zotpressInText item="{6833562:A7GHFPNK}"\]

- [Second exercice](https://blog.atlant.is/?p=1893)

I borrow the introduction from \[zotpressInText item="{6833562:APHK998J}"\]:

> Two players each have countably many hats put on their heads.  
> Each hat is either black or white with equal probability. Furthermore, the players are only able to see the hats on the other person’s head. Simultaneously each player points to a hat on their own head. They win if both players pick out a white hat.
> 
> The question is what is the optimal strategy for this game? It should be noted that each individual player will pick a white hat with probability one half regardless of the strategy employed. The challenge then is to correlate their choices.
> 
> At a first glance, it may seem that there is no strategy with better than random ($1 \\over 4$) chance of winning. This can be quickly discounted by the following simple strategy: each player looks for the first white hat on the partner’s head and chooses the corresponding hat on his or her own head.
> 
> Observe that if both players have a white hat first ($1 \\over 4$ chance) then they win, if the two first hats are different ( $1 \\over 2$ chance) then they lose, and if the two first hats are both black ($1 \\over 4$ chance) then effectively they replay the game with the first hat removed. So, we see that the chance of winning is $x = {1 \\over 4} + {1 \\over 4} \\cdot x$, so $x = {1 \\over 3}$.

## Finite case

### Definitions and notations

#### Towers

Consider a _tower_ of $n$ stacked hats ($n$ finite), each hat either black or white. We refer to $n$ as the tower's _height_. By identifying each hat with a _bit_ (value $0$ for black, $1$ for white), we can view the tower as the binary representation of a natural number, the first hat being the least significant bit.

Let $\\mathbb{T}\_n$ denote the set of all possible towers:

\\begin{align}  
\\mathbb{T}\_n \\quad &\\stackrel{\\text{def}}{=} \\quad \\{0, 1\\}^{\[n\]} \\\\  
&= \\quad \[2^n\], \\nonumber  
\\end{align}

where $\[n\] = \\{0, ..., n-1\\}$ is the set of natural numbers strictly smaller than $n$.

Let $t$ be a tower in $\\mathbb{T}\_n$.

As an element of $\[2^n\]$, $t$ is a plain natural number, which provide a convenient way to name it. For instance, $4 \\in \\mathbb{T}\_3$ is the tower consisting of one white hat on top of two black hats.

$$  
4 \\quad = \\quad  
\\begin{array}{c}  
○\\\\  
●\\\\  
●  
\\end{array}  
$$

Alternately, as an element of $\\{0, 1\\}^{\[n\]}$, $t$ is a map: $\[n\] \\rightarrow \\{0, 1\\}$. Given a _position_ $p$ in $\[n\]$, $t(p)$ tells us the color of the hat at position $p$ in the tower ($0$ for black or $1$ for white). $t(p)$ is also the value of the $p$th bit in the binary representation of $t$.

To avoid confusing $t(p)$ (map application) with $t \\cdot (p)$ (multiplication of numbers), we write $\\overline{(t)}(p)$ (overlined) for the map application. Also, we extend the domain of $\\overline{(t)}$ to the set of integers:

\\begin{equation}  
\\forall t \\in \\mathbb{T}\_n, \\forall p \\in \\mathbb{Z}, \\quad  
\\overline{(t)}(p) \\;\\stackrel{\\text{def}}{=}\\; (t \\gg p) \\mathbin{\\%} 2,  
\\end{equation}

(where $\\gg$ is the bitwise right shift operator and $\\mathbin{\\%}$ the remainder operator).

##### Example

\\begin{align\*}  
\\overline{(4)}(-1) &= 0 \\\\  
\\overline{(4)}(0) &= 0 \\\\  
\\overline{(4)}(1) &= 0 \\\\  
\\overline{(4)}(2) &= 1 \\\\  
\\overline{(4)}(3) &= 0  
\\end{align\*}

#### Strategies

A (deterministic) _strategy_ $s$ for the game of $n$ hats is a way for each player, when presented with the tower of hats on top of their partner's head, of choosing the position of a (hopefully white) hat on their own head. In other words: $s$ is a map from $\\mathbb{T}\_n$ to $\\mathbb{Z}$.

Note that we allow a strategy to choose a position outside of the tower ($\\ge n$ or $< 0$).

Let $\\mathbb{S}\_n = \\mathbb{Z}^{\\mathbb{T}\_n}$ denote the set of all possible strategies for towers of $n$ hats:

\\begin{equation}  
\\mathbb{S}\_n \\; \\stackrel{\\text{def}}{=} \\; \\mathbb{Z}^{\\mathbb{T}\_n}.  
\\end{equation}

A natural way to name a strategy is to use a $2^n$-uple for enumerating the choices it makes.

For instance if $s \\in \\mathbb{S}\_2$ is such that:

$$  
\\left\\{  
\\begin{array}{ll}  
s\\left(\\begin{array}{c}  
●\\\\  
●  
\\end{array}\\right) = s(0) = 0,\\\\  
s\\left(\\begin{array}{c}  
●\\\\  
○  
\\end{array}\\right) = s(1) = 0,\\\\  
s\\left(\\begin{array}{c}  
○\\\\  
●  
\\end{array}\\right) = s(2) = 1,\\\\  
s\\left(\\begin{array}{c}  
○\\\\  
○  
\\end{array}\\right) = s(3) = 0,  
\\end{array}  
\\right.  
$$

then we write:

$$s = (0,0,1,0).$$

When there is no ambiguity (e.g.: all positions are single digit), we shorten the notation:

$$s = \[0010\].$$

And for clarity, when $n$ gets too big, we use hyphens to separate groups of digits, e.g.: write $\[0100 \\text{-} 2123 \\text{-} 0100 \\text{-} 2120\]$ for $\[0100212301002120\] \\in \\mathbb{S}\_4$.

##### Hit score

A configuration for the game of $n$ hats is a pair of towers $t$ and $u$ in $\\mathbb{T}\_n$: one for each player's head. Given a strategy $s$ in $\\mathbb{S}\_n$, we denote by $\\eta\_{t,u}(s)$ the outcome of applying strategy $s$ in the configuration $(t, u)$: $1$ for _hit_ (win), $0$ for _miss_ (loss).

\\begin{equation}  
\\eta\_{t,u}(s) \\; \\stackrel{\\text{def}}{=} \\; \\overline{(t)}\\big(s(u)\\big) \\cdot \\overline{(u)}\\big(s(t)\\big)  
\\end{equation}

We call _hit score_ of $s$, denoted by $\\eta(s)$, the sum of all such outcomes, i.e. the count of all game configurations where the team wins.:

\\begin{equation}  
\\eta(s) \\; \\stackrel{\\text{def}}{=} \\; \\sum\_{t,u \\in \\mathbb{T}\_n}\\eta\_{t,u}(s)  
\\end{equation}

##### Win rate

Given a strategy $s$ in $\\mathbb{S}\_n$, we denote by $\\mu(s)$ the _win rate_ (or _measure_) of $s$, i.e. the probability that a team applying the strategy wins.

\\begin{equation}  
\\mu(s) \\; \\stackrel{\\text{def}}{=} \\; {1 \\over{4^n}} \\cdot \\eta(s)  
\\end{equation}

##### Equivalence

We call two strategies $a$ and $b$ in $\\mathbb{S}\_n$ _equivalent_, when they agree on the winning configurations:

\\begin{equation}  
a \\equiv b \\; \\stackrel{\\text{def}}{\\iff} \\; \\forall t,u \\in \\mathbb{T}\_n, \\eta\_{t,u}(a) = \\eta\_{t,u}(b).  
\\end{equation}

Note that two strategies $a$ and $b$ in $\\mathbb{S}\_n$ which differ only in the choice of $a(0) \\neq b(0)$ are equivalent. This is because they make different choices only when one of the players is presented with tower $0$ (all black hats), which is always a losing situation for the team.

\\begin{equation}  
\\big(\\forall t \\in \\mathbb{T}\_n \\setminus \\{0\\}, \\;\\; a(t) = b(t)\\big) \\quad \\implies \\quad a \\equiv b.  
\\end{equation}

Of course, equivalent strategies have the same hit score and win rate:

\\begin{equation}  
\\forall a, b \\in \\mathbb{S}\_n, \\quad a \\equiv b \\implies \\eta(a) = \\eta(b).  
\\label{EquivRate}  
\\end{equation}

### Examples of strategies

****Name****

Tuple

Height

Hit score

Win rate

top

$\\mathbf{T}\_0 = \[-1\]$

$0$

$0$

${0 \\over 1} = 0\\%$

top

$\\mathbf{T}\_1 = \[00\]$

$1$

$1$

${1 \\over 4} = 25\\%$

lowest-white

$\\mathbf{W}\_2 = \[1010\]$

$2$

$5$

${5 \\over 16} = 31.25\\%$

lowest-black

$\\mathbf{B}\_3 = \[01020102\]$

$3$

$21$

${21 \\over 64} \\approx 31.81\\%$

Examples of strategies

#### Constant strategies

We call _constant_ a strategy $s \\in \\mathbb{S}\_n$ which always chooses the same position:

$$s \\text{ constant } \\;\\stackrel{\\text{def}}{\\iff}\\; \\forall t, u \\in \\mathbb{T}\_n, \\; s(t) = s(u)$$

Observe:

- all constant strategies of height $0$ are equivalent,
- a constant strategy which chooses position $p \\not\\in \[n\]$ has hit score and win rate $0$,
- a constant strategy of height $>0$ which chooses position $p \\in \[n\]$ has hit score $4^{n-1}$ and win rate of $1 \\over 4$.

In particular, we denote by $\\mathbf{T}\_n$ (_top_ $n$) the strategy in $\\mathbb{S}\_n$ which chooses position $n-1$ (i.e. the top position in the tower, when the tower is not empty).

\\begin{equation}  
\\forall t \\in \\mathbb{T}\_n, \\quad \\mathbf{T}\_n(t) \\stackrel{\\text{def}}{=} n-1  
\\end{equation}

#### Lowest-white strategies

We denote by $\\mathbf{W}\_n$ (_white_ n) the strategy in $\\mathbb{S}\_n$ which chooses the position of the lowest white hat, or $n-1$ if there is no white hat.

##### Example

$\\mathbf{W}\_2 = \[1010\]$ chooses position $1$ when the first hat is black, position $0$ otherwise.

$\\eta\_{t\_1,t\_2}(\\mathbf{W}\_2)$

$\\mathbf{W}\_2(t\_2)$

$1$

$0$

$1$

$0$

$\\mathbf{W}\_2(t\_1)$

$\\downarrow\\!t1 \\quad t2\\!\\rightarrow$

$0 = \\begin{array}{c}●\\\\●\\end{array}$

$1 = \\begin{array}{c}●\\\\○\\end{array}$

$2 = \\begin{array}{c}○\\\\●\\end{array}$

$3 = \\begin{array}{c}○\\\\○\\end{array}$

$1$

$0 = \\begin{array}{c}●\\\\●\\end{array}$              

0×0

0×0

0×1

0×1

$0$

$1 = \\begin{array}{c}●\\\\○\\end{array}$              

0×0

**1×1**

0×0

**1×1**

$1$

$2 = \\begin{array}{c}○\\\\●\\end{array}$              

1×0

0×0

**1×1**

0×1

$0$

$3 = \\begin{array}{c}○\\\\○\\end{array}$              

1×0

**1×1**

1×0

**1×1**

Hits for strategy $\\mathbf{W}\_2 = \[0010\]$

$\\mathbf{W}\_2$ has hit score $5$ and win rate $5 \\over 16$.

#### Lowest-black strategies

We denote by $\\mathbf{B}\_n$ (_black_ n) the strategy in $\\mathbb{S}\_n$ which chooses the position of the lowest black hat, or $n-1$ if there is no black hat.

##### Example

$\\mathbf{B}\_3 = \[01020102\]$ chooses position $2$ when the lowest two hats are white, otherwise position $1$ when the lowest hat is white, otherwise position $0$.

$\\mathbf{B}\_3$ has hit score $21$ and win rate $21 \\over 64$.

### Operations on strategies

Name

Example

embedding

$e\_3(\[0100\]) \\;=\\; \[0100 \\text{-} 0100\]$

left reset

$\[0101\] \\rightarrow \[-1\] \\;=\\; \[0101\]$

$\[0101\] \\rightarrow \[00\] \\;=\\; \[01 \\text{-} 02 \\text{-} 01 \\text{-} 02\]$

$\[00\] \\rightarrow \[0000\] \\;=\\; \[2000 \\text{-} 2000\]$

$\[1010\] \\rightarrow \[1010\] \\;=\\; \[3010 \\text{-} 2010 \\text{-} 3010 \\text{-} 2010\]$

right reset

$\[0101\] \\leftarrow \[-1\] \\;=\\; \[0101\]$

$\[0101\] \\leftarrow \[00\] \\;=\\; \[0102 \\text{-} 0102\]$

$\[0000\] \\leftarrow \[00\] \\;=\\; \[0002 \\text{-} 0002\]$

double reset

$DR(\[0010\], \[0010\]) \\;=\\; \[2012 \\text{-} 2012 \\text{-} 3012 \\text{-} 2012\]$

left shift

$\\uparrow\\!\[0\] \\;=\\; \[0 \\text{-} 0\]$

$\\uparrow\\!\[00\] \\;=\\; \[00 \\text{-} 10\]$

right shift

$\[00\]\\!\\uparrow \\;=\\; \[01 \\text{-} 00\]$

double shift

$\[00\]\\!\\Uparrow \\;=\\; \[01 \\text{-} 00 \\text{--} 21 \\text{-} 20\]$

Operations on strategies

#### Embedding

$e\_1(\[-1\]) = (-1, -1)$

$e\_3(\[1010\]) = \[1010 \\text{-} 1010\]$

Embedding examples

Given a strategy $s$ in $\\mathbb{S}\_n$ and an integer $m > n$, we can use $s$ to play the game of $m$ hats. Simply: do not"looking" at the hats above position $n$ ($n$ included). This defines an embedding $e\_m: \\mathbb{S}\_n \\rightarrow \\mathbb{S}\_m$:

\\begin{align\*}  
e\_m: \\mathbb{S}\_n \\rightarrow \\mathbb{S}\_m\\\\  
s \\mapsto e\_m(s)  
\\end{align\*}

\\begin{equation}  
\\forall t \\in \\mathbb{T}\_n, \\;\\; \\big(e\_m(s)\\big)(t) \\stackrel{\\text{def}}{=} s(t \\mathbin{\\%} 2^n)  
\\end{equation}

(where $\\mathbin{\\%}$ is the remainder operator).

Win rate is invariant under embedding into $\\mathbb{S}\_m$:

\\begin{equation}  
\\forall s \\in \\mathbb{S}\_n, \\forall m > n, \\;\\; \\mu(s) = \\mu(e\_m(s))  
\\end{equation}

#### Left reset

$\[00\] \\rightarrow \[-1\] = \[00\]$

$\[00\] \\rightarrow \[00\] \\rightarrow \[-1\] = \[10 \\text{-} 10\]$

$\[00\] \\rightarrow \[00\] \\rightarrow \[00\] \\rightarrow \[-1\] = \[2010 \\text{-} 2010\]$

Left-reset examples

Given two strategies $a \\in \\mathbb{S}\_m$ and $b \\in \\mathbb{S}\_n$, we call "$a$ _left-reset_ by $b$", denoted by $LR(a,b)$, the following strategy in $\\mathbb{S}\_{m+n}$: whenever the lowest $m$ hats in the tower are not all black, use strategy $a$; otherwise, use strategy $b$ on the remaining $n$ hats. Formally:

\\begin{align}  
LR(a,b): \\; & \\mathbb{T}\_{m+n} \\rightarrow \[m+n\] \\nonumber \\\\  
\\nonumber \\\\  
& t \\stackrel{\\text{def}}{\\mapsto}  
\\left\\{  
\\begin{array}{l}  
a(t) \\quad\\text{if } t \\not \\equiv 0 \\bmod 2^m\\\\  
m + b(t \\gg m) \\quad\\text{otherwise}  
\\end{array}  
\\right.  
\\end{align}

(where $\\gg$ is the bitwise right shift operator).

Left reset is associative:

$$\\forall a, b, c, \\quad LR(a, LR(b, c)) \\,=\\, LR(LR(a, b), c)$$

so we make it into a binary operator:

\\begin{equation}  
b \\rightarrow a \\;\\stackrel{\\text{def}}{=}\\; LR(a, b),  
\\end{equation}

and the following holds:

\\begin{equation}  
\\forall a, b, c, \\;\\; (c \\rightarrow b) \\rightarrow a \\,=\\, c \\rightarrow (b \\rightarrow a) \\,=\\, c \\rightarrow b \\rightarrow a  
\\end{equation}

#### Right reset

$\[-1\] \\leftarrow \[00\] = \[00\]$

$\[-1\] \\leftarrow \[00\] \\leftarrow \[00\] = \[01 \\text{-} 01\]$

$\[-1\] \\leftarrow \[00\] \\leftarrow \[00\] \\leftarrow \[00\] = \[0102 \\text{-} 0102\]$

Right-reset examples

Given two strategies $a \\in \\mathbb{S}\_m$ and $b \\in \\mathbb{S}\_n$, we call "$a$ _right-reset_ by $b$", denoted by $RR(a,b)$, the following strategy in $\\mathbb{S}\_{m+n}$: whenever the lowest $m$ hats in the tower are not all white, use strategy $a$; otherwise, use strategy $b$ on the remaining $n$ hats. Formally:

\\begin{align}  
RR(a,b): \\; & \\mathbb{T}\_{m+n} \\rightarrow \[m+n\] \\nonumber \\\\  
\\nonumber \\\\  
& t \\stackrel{\\text{def}}{\\mapsto}  
\\left\\{  
\\begin{array}{l}  
a(t) \\quad \\text{if } t \\not\\equiv -1 \\bmod 2^m\\\\  
m + b(t \\gg m) \\quad \\text{otherwise,}  
\\end{array}  
\\right.  
\\end{align}

where $\\gg$ is the bitwise right shift operator.

Right reset is associative:

$$\\forall a, b, c, \\;\\; RR(a, RR(b, c)) \\,=\\, RR(RR(a, b), c)$$

so we make it into a binary operator:

\\begin{equation}  
a \\leftarrow b \\;\\stackrel{\\text{def}}{=}\\; RR(a, b),  
\\end{equation}

and the following holds:

\\begin{equation}  
\\forall a, b, c, \\;\\; (a \\leftarrow b) \\leftarrow c \\,=\\, a \\leftarrow (b \\leftarrow c) \\,=\\, a \\leftarrow b \\leftarrow c  
\\end{equation}

#### Double reset

$DR(\[00\], \[00\]) = \[1111\]$

$DR(DR(\[1010\], \[00\]), \[00\]) = \[30122013 \\text{-} 30122013\]$

$DR(\[1010\], DR(\[00\], \[00\])) = \[30133013 \\text{-} 30133013\]$

Double-reset examples

Given two strategies $a \\in \\mathbb{S}\_m$ and $b \\in \\mathbb{S}\_n$, we call "$a$ _double-reset_ by $b$", denoted by $DR(a, b)$, the following strategy in $\\mathbb{S}\_{m+n}$: whenever the lowest $m$ hats in the tower are not all black and not all white, use strategy $a$; otherwise, use strategy $b$ on the remaining $n$ hats. Formally:

\\begin{align}  
DR(a,b): \\; & \\mathbb{T}\_{m+n} \\rightarrow \[m+n\] \\nonumber \\\\  
\\nonumber \\\\  
& t \\stackrel{\\text{def}}{\\mapsto}  
\\left\\{  
\\begin{array}{l}  
a(t) \\quad \\text{if } t \\not\\equiv 0 \\text{ and } t \\not\\equiv -1 \\bmod 2^m \\\\  
m + b(t \\gg m) \\quad \\text{otherwise,}  
\\end{array}  
\\right.  
\\end{align}

where $\\gg$ is the bitwise right shift operator.

Double-reset is _not_ associative.

#### Left shift

$\\uparrow\\!\[0\] = \[0 \\text{-} 0\]$

$\\uparrow\\!\[00\] = \[00 \\text{-} 10\]$

$\\uparrow\\!\[0000\] = \[0000 \\text{-} 2000\]$

Left-shift examples

Given a strategie $s \\in \\mathbb{S}\_n$, we call "$s$ _left-shifted_", denoted by $\\uparrow\\!s$, the following strategy in $\\mathbb{S}\_{n+1}$:

\\begin{equation}  
\\forall t \\in \\mathbb{T}\_{n+1}, \\quad (\\uparrow\\!s)(t) \\stackrel{\\text{def}}{=}  
\\left\\{  
\\begin{array}{ll}  
n & \\text{if } t = 2^n\\\\  
s(t \\mathbin{\\%} 2^n) & \\text{otherwise,}  
\\end{array}  
\\right.  
\\end{equation}

where $\\mathbin{\\%}$ is the remainder operator.

#### Right shift

$\[0\]\\!\\uparrow = \[0 \\text{-} 0\]$

$\[00\]\\!\\uparrow = \[01 \\text{-} 00\]$

$\[0000\]\\!\\uparrow = \[0002 \\text{-} 0000\]$

Right-shift examples

Given a strategie $s \\in \\mathbb{S}\_n$, we call "$s$ _right-shifted_", denoted by $s\\!\\uparrow$, the following strategy in $\\mathbb{S}\_{n+1}$:

\\begin{equation}  
\\forall t \\in \\mathbb{T}\_{n+1}, \\quad (s\\!\\uparrow)(t) \\stackrel{\\text{def}}{=}  
\\left\\{  
\\begin{array}{ll}  
n & \\text{if } t = 2^n - 1\\\\  
s(t \\mathbin{\\%} 2^n) & \\text{otherwise,}  
\\end{array}  
\\right.  
\\end{equation}

where $\\mathbin{\\%}$ is the remainder operator.

#### Double shift

$\[00\]\\!\\Uparrow = \[01 \\text{-} 00 \\text{--} 21 \\text{-} 20\]$

$\[0000\]\\!\\Uparrow = \[0002 \\text{-} 0000 \\text{--} 3001 \\text{-} 3000\]$

Double-shift examples

Given a strategie $s \\in \\mathbb{S}\_n$, we call "$s$ _double-shifted_", denoted by $s\\!\\Uparrow$, the following strategy in $\\mathbb{S}\_{n+2}$:

\\begin{equation}  
\\forall t \\in \\mathbb{T}\_{n+2}, \\quad (s\\!\\Uparrow)(t) \\stackrel{\\text{def}}{=}  
\\left\\{  
\\begin{array}{ll}  
n+1 & \\text{if } t = 2^{n+1} + 2^n\\\\  
\\big(\\uparrow\\!(s\\!\\uparrow)\\big)(t) & \\text{otherwise.}  
\\end{array}  
\\right.  
\\end{equation}

### Win rate computation

Brute-force computing the win rate would be expensive for large values of $n$. In the remainder of this section, we give simple formulae for calculating the win rate of certain strategies.

#### Formulae

Operation

Condition

Win rate

left-reset

$a \\in \\mathbb{S}\_n$,  
$b \\in \\mathbb{S}\_m$

$\\mu(b \\rightarrow a) = \\mu(a) + {\\mu(b) \\over 4^n}$

right-reset

$a \\in \[n\]^{\\mathbb{T}\_n}$,  
$b \\in \[m\]^{\\mathbb{T}\_m}$

$\\mu(a \\leftarrow b) = \\mu(a) + {\\mu(b) \\over 4^n}$

double-reset

$a \\in \[n\]^{\\mathbb{T}\_n}$,  
$b \\in \[m\]^{\\mathbb{T}\_m}$

$\\mu(DR(a, b)) = \\mu(a) + {{4 \\mu(b) - 1} \\over 4^n}$

left-shift

$s \\in {\\mathbb{S}\_n}$

$\\mu(\\uparrow\\!s) = \\mu(s) + {1 \\over 4^{n+1}}$

right-shift

$s \\in \[n\]^{\\mathbb{T}\_n}$

$\\mu(s\\!\\uparrow) = \\mu(s) + {1 \\over 4^{n+1}}$

double-shift

$s \\in \[n\]^{\\mathbb{T}\_n}$

$\\mu(s\\!\\Uparrow) = \\mu(s) + {1 \\over 4^{n+1}}+ {2 \\over 4^{n+2}}$

Formulae for win rate calculation

#### Observations

Let $a$ be a strategy in $\\mathbb{S}\_n$. Recall that the hit score of $a$ is $\\eta(a) = \\sum\_{t,u \\in \\mathbb{T}\_n}\\eta\_{t,u}(a)$, where $\\eta\_{t,u}(a)$ denotes $\\overline{(t)}(a(u)) \\cdot \\overline{(u)}(a(t))$.

Let $\\sum\\mathcal{M}$ denote the sum of all coefficients of matrix $\\mathcal{M}$.

Then $\\eta(a)$ can be written as:

\\begin{align\*}  
\\sum  
\\begin{pmatrix}  
\\big(\\eta\_{0,0}(a) & \\eta\_{0,1}(a) & \\cdots & \\eta\_{0,2^n-2}(a) & \\eta\_{0,2^n-1}(a) \\\\  
\\big(\\eta\_{1,0}(a) & \\eta\_{1,1}(a) & \\cdots & \\eta\_{1,2^n-2}(a) & \\eta\_{1,2^n-1}(a) \\\\  
\\vdots & \\vdots & \\ddots& \\vdots& \\vdots \\\\  
\\big(\\eta\_{2^n-2,0}(a) & \\eta\_{2^n-2,1}(a) & \\cdots & \\eta\_{2^n-2,2^n-2}(a) & \\eta\_{2^n-2,2^n-1}(a) \\\\  
\\big(\\eta\_{2^n-1,0}(a) & \\eta\_{2^n-1,1}(a) & \\cdots & \\eta\_{2^n-1,2^n-2}(a) & \\eta\_{2^n-1,2^n-1}(a)  
\\end{pmatrix}  
\\end{align\*}

Which simplifies to:

\\begin{equation}  
\\sum  
\\begin{pmatrix}  
0 & 0 & \\cdots & 0 & 0 \\\\  
\\cdot & \\eta\_{1,1}(a) & \\cdots & \\eta\_{1,2^n-2}(a) & \\eta\_{1,2^n-1}(a) \\\\  
\\vdots & \\vdots & \\ddots& \\vdots& \\vdots \\\\  
\\cdot & \\cdot & \\cdots & \\eta\_{2^n-2,2^n-2}(a) & \\eta\_{2^n-2,2^n-1}(a) \\\\  
\\cdot & \\cdot & \\cdots & \\cdot & \\eta\_{2^n-1,2^n-1}(a)  
\\end{pmatrix}  
\\end{equation}

Which when $a \\in \[n\]^{\\mathbb{T}\_n}$ further simplifies to:

\\begin{equation}  
\\!\\!\\!\\!\\!\\!\\!\\!\\!\\!\\!\\!\\sum  
\\begin{pmatrix}  
0 & 0 & \\cdots & 0 & 0 \\\\  
\\cdot & \\eta\_{1,1}(a) & \\cdots & \\eta\_{1,2^n-2}(a) & \\overline{(1)}\\big(a(2^n-1)\\big) \\\\  
\\vdots & \\vdots & \\ddots& \\vdots& \\vdots \\\\  
\\cdot & \\cdot & \\cdots & \\eta\_{2^n-2,2^n-2}(a) & \\overline{(2^n-2)}\\big(a(2^n-1)\\big) \\\\  
\\cdot & \\cdot & \\cdots & \\cdot & 1  
\\end{pmatrix}  
\\end{equation}

Note that:

- these matrices are symmetric
- the coefficients of the first line add up to $0$
- the coefficients of the last column add up to:

$\\quad\\quad  
\\left\\{  
\\begin{array}{ll}  
2^{n-1} & \\text{when } a(2^m-1) \\in \[n\]\\\\  
0 & \\text{otherwise}  
\\end{array}  
\\right.  
$

Consequence: two strategies $a$ and $b$ in $\[n\]^{\\mathbb{T}\_n}$ which differ only in the choice of $a(2^n-1) \\neq b(2^n-1)$ have the same hit score and win rate:

\\begin{equation}  
\\big(\\forall t \\in \\mathbb{T}\_n \\setminus \\{2^n-1\\}, \\;\\; a(t) = b(t)\\big) \\;\\; \\implies \\;\\; \\eta(a) = \\eta(b).  
\\label{SameRate}  
\\end{equation}

#### Win rate after left reset

Let $a \\in \\mathbb{S}\_n, b \\in \\mathbb{S}\_m$:

\\begin{equation}  
\\mu(b \\rightarrow a) = \\mu(a) + {\\mu(b) \\over 4^n}  
\\label{LeftResetRule}  
\\end{equation}

Proof:

\\begin{align\*}  
& {\\eta(b \\rightarrow a) \\over 4^m} \\\\  
  
& \\;\\;=\\;\\; \\sum  
\\begin{pmatrix}  
\\mu(b) & 0 & \\cdots & 0 & 0 \\\\  
\\cdot & \\eta\_{1,1}(a) & \\cdots & \\eta\_{1,2^n-2}(a) & \\eta\_{1,2^n-1}(a) \\\\  
\\vdots & \\vdots & \\ddots& \\vdots& \\vdots \\\\  
\\cdot & \\cdot & \\cdots & \\eta\_{2^n-2,2^n-2}(a) & \\eta\_{2^n-2,2^n-1}(a) \\\\  
\\cdot & \\cdot & \\cdots & \\cdot & \\eta\_{2^n-1,2^n-1}(a)  
\\end{pmatrix} \\\\  
  
& \\;\\;=\\;\\; \\eta(a) + \\mu(b) \\\\  
  
& \\;\\;=\\;\\; 4^n \\cdot \\left(\\mu(a) + {\\mu(b) \\over 4^n}\\right) \\quad \\Box  
\\end{align\*}

#### Win rate after right reset

This formula works for strategies which choose positions within the tower.

Let $a \\in \\mathbb{S}\_n, b \\in \\mathbb{S}\_m$:

\\begin{equation}  
\\left\\{  
\\begin{array}{l}  
a \\in \[n\]^{\\mathbb{T}\_n} \\\\  
b \\in \[m\]^{\\mathbb{T}\_m}  
\\end{array}  
\\right. \\;\\; \\implies \\;\\; \\mu(a \\leftarrow b) = \\mu(a) + {\\mu(b) \\over 4^n}  
\\label{RightResetRule}  
\\end{equation}

Proof:

\\begin{align\*}  
& {\\eta(a \\leftarrow b) \\over 4^m}  
\\\\  
& \\;\\;=\\;\\; \\sum \\\\  
& \\begin{pmatrix}  
0 & 0 & \\cdots & 0 & {1 \\over 4^m} \\sum\_{t,u\\in\\mathbb{T}\_m} \\big(\\overline{(t)}(b(u)) \\cdot \\overline{(2^n-1)}(a(0))\\big) \\\\  
\\cdot & \\eta\_{1,1}(a) & \\cdots & \\eta\_{1,2^n-2}(a) & {1 \\over 4^m} \\sum\_{t,u\\in\\mathbb{T}\_m} \\big(\\overline{(t)}(b(u)) \\cdot \\overline{(2^n-1)}(a(1))\\big) \\\\  
\\vdots & \\vdots & \\ddots& \\vdots& \\vdots \\\\  
\\cdot & \\cdot & \\cdots & \\eta\_{2^n-2,2^n-2}(a) & {1 \\over 4^m} \\sum\_{t,u\\in\\mathbb{T}\_m} \\big(\\overline{(t)}(b(u)) \\cdot \\overline{(2^n-1)}(a(2^n-2))\\big) \\\\  
\\cdot & \\cdot & \\cdots & \\cdot & \\mu(b)  
\\end{pmatrix} \\\\  
\\\\  
& \\;\\;=\\;\\; \\sum \\\\  
& \\begin{pmatrix}  
0 & 0 & \\cdots & 0 & {1 \\over 4^m} \\sum\_{u\\in\\mathbb{T}\_m}\\sum\_{t\\in\\mathbb{T}\_m} \\overline{(t)}(b(u)) \\\\  
\\cdot & \\eta\_{1,1}(a) & \\cdots & \\eta\_{1,2^n-2}(a) & {1 \\over 4^m} \\sum\_{u\\in\\mathbb{T}\_m}\\sum\_{t\\in\\mathbb{T}\_m} \\overline{(t)}(b(u)) \\\\  
\\vdots & \\vdots & \\ddots& \\vdots& \\vdots \\\\  
\\cdot & \\cdot & \\cdots & \\eta\_{2^n-2,2^n-2}(a) & {1 \\over 4^m} \\sum\_{u\\in\\mathbb{T}\_m}\\sum\_{t\\in\\mathbb{T}\_m} \\overline{(t)}(b(u)) \\\\  
\\cdot & \\cdot & \\cdots & \\cdot & \\mu(b)  
\\end{pmatrix}  
\\end{align\*}

Now since $0 \\le b(u) < m, \\quad \\sum\_{t\\in\\mathbb{T}\_m} (\\overline{(t)}(b(u)) = 2^{m-1}$.  

Hence:

\\begin{align\*}  
{\\eta(a \\leftarrow b) \\over 4^m} \\;\\;  
&= \\;\\; \\sum  
\\begin{pmatrix}  
0 & 0 & \\cdots & 0 & {1 \\over 2} \\\\  
\\cdot & \\eta\_{1,1}(a) & \\cdots & \\eta\_{1,2^n-2}(a) & {1 \\over 2} \\\\  
\\vdots & \\vdots & \\ddots& \\vdots& \\vdots \\\\  
\\cdot & \\cdot & \\cdots & \\eta\_{2^n-2,2^n-2}(a) & {1 \\over 2} \\\\  
\\cdot & \\cdot & \\cdots & \\cdot & \\mu(b)  
\\end{pmatrix} \\\\  
  
&= \\;\\; \\eta(a) + \\mu(b) \\\\  
  
&= \\;\\; 4^n \\cdot \\left(\\mu(a) + {\\mu(b) \\over 4^n}\\right) \\quad \\Box  
\\end{align\*}

#### Win rate after double reset

This formula works for strategies which choose positions within the tower.

Let $a \\in \\mathbb{S}\_n, b \\in \\mathbb{S}\_m$:

\\begin{equation}  
\\left\\{  
\\begin{array}{l}  
a \\in \[n\]^{\\mathbb{T}\_n} \\\\  
b \\in \[m\]^{\\mathbb{T}\_m}  
\\end{array}  
\\right. \\;\\; \\implies \\;\\;  
\\mu(DR(a, b)) = \\mu(a) + {{4 \\mu(b) - 1} \\over 4^n}  
\\label{DoubleResetRule}  
\\end{equation}

Proof:

\\begin{align\*}  
& {\\eta(DR(a, b)) \\over 4^m} \\\\  
\\\\  
& \\;\\;=\\;\\; \\sum \\\\  
& \\begin{pmatrix}  
\\mu(b) & 0 & \\cdots & 0 & \\mu(b) \\\\  
\\cdot & \\eta\_{1,1}(a) & \\cdots & \\eta\_{1,2^n-2}(a) & {1 \\over 4^m} \\sum\_{t,u\\in\\mathbb{T}\_m} \\big(\\overline{(t)}(b(u)) \\cdot \\overline{(2^n-1)}(a(1))\\big) \\\\  
\\vdots & \\vdots & \\ddots& \\vdots& \\vdots \\\\  
\\cdot & \\cdot & \\cdots & \\eta\_{2^n-2,2^n-2}(a) & {1 \\over 4^m} \\sum\_{t,u\\in\\mathbb{T}\_m} \\big(\\overline{(t)}(b(u)) \\cdot \\overline{(2^n-1)}(a(2^n-2))\\big) \\\\  
\\cdot & \\cdot & \\cdots & \\cdot & \\mu(b)  
\\end{pmatrix} \\\\  
\\\\  
& \\;\\;=\\;\\; \\sum \\\\  
& \\begin{pmatrix}  
\\mu(b) & 0 & \\cdots & 0 & \\mu(b) \\\\  
\\cdot & \\eta\_{1,1}(a) & \\cdots & \\eta\_{1,2^n-2}(a) & {1 \\over 2} \\\\  
\\vdots & \\vdots & \\ddots& \\vdots& \\vdots \\\\  
\\cdot & \\cdot & \\cdots & \\eta\_{2^n-2,2^n-2}(a) & {1 \\over 2} \\\\  
\\cdot & \\cdot & \\cdots & \\cdot & \\mu(b)  
\\end{pmatrix} \\\\  
\\\\  
&= \\;\\; \\eta(a) + 4 \\mu(b) - 1 \\\\  
\\\\  
&= \\;\\; 4^n\\left(\\mu(a) + {{4 \\mu(b) - 1} \\over 4^n}\\right) \\quad \\Box  
\\end{align\*}

#### Win rate after left shift

Let $s \\in \\mathbb{S}\_n$:

\\begin{equation}  
\\mu(\\uparrow\\!s) = \\mu(s) + {1 \\over 4^{n+1}}  
\\label{LeftShiftRule}  
\\end{equation}

Proof:

Note that the strategy $(\\uparrow\\!s)$ is equivalent to $(\[00\] \\rightarrow s)$.

Hence $(\\ref{EquivRate})$ they have the same hit score and win rate. Applying $(\\ref{LeftResetRule})$ we get:

\\begin{align\*}  
\\mu(\\uparrow\\!s) \\;\\;=\\;\\; \\mu(\[00\] \\rightarrow s) \\;\\;=\\;\\; \\mu(s) + {\\mu(\[00\]) \\over 4^n} \\quad \\Box  
\\end{align\*}

#### Win rate after right shift

This formula works for a strategy which chooses positions within the tower.

Let $s \\in \\mathbb{S}\_n$:

\\begin{equation}  
s \\in \[n\]^{\\mathbb{T}\_n} \\;\\;  
\\implies \\;\\; \\mu(s\\!\\uparrow) = \\mu(s) + {1 \\over 4^{n+1}}  
\\label{RightShiftRule}  
\\end{equation}

Proof:

Note that the strategies $(s\\!\\uparrow)$ and $(s \\leftarrow \[00\])$ make the same choices except when presented with a tower with only white hats.

Hence $(\\ref{SameRate})$ they have the same hit score and win rate. Applying $(\\ref{RightResetRule})$ we get:

\\begin{align\*}  
\\mu(\\uparrow\\!s) \\;\\;=\\;\\; \\mu(s \\leftarrow \[00\]) \\;\\;=\\;\\; \\mu(s) + {\\mu(\[00\]) \\over 4^n} \\quad \\Box  
\\end{align\*}

#### Win rate after double shift

This formula works for a strategy which chooses positions within the tower.

Let $s \\in \\mathbb{S}\_n$:

\\begin{equation}  
s \\in \[n\]^{\\mathbb{T}\_n} \\;\\;  
\\implies \\;\\; \\mu(s\\!\\Uparrow) = \\mu(s) + {1 \\over 4^{n+1}}+ {2 \\over 4^{n+2}}  
\\label{DoubleShiftRule}  
\\end{equation}

Proof:

Consider $s\_1 = \\uparrow\\!(s\\!\\uparrow)$ and $s\_2 = s\\!\\Uparrow$:

$s\_1 = \\uparrow\\!(s\\!\\uparrow)$

$s\_2 = s\\!\\Uparrow$

$s(0), s(1), \\!\\cdot\\cdot, s(2^n\\text{-}2), \\pmb{n},$  
$s(0), s(1), \\!\\cdot\\cdot, s(2^n\\text{-}2), s(2^n\\text{-}1),$  
$\\pmb{n}\\!\\pmb{+}\\!\\pmb{1}, s(1), \\!\\cdot\\cdot, s(2^n\\text{-}2), \\pmb{n},$  
$\\pmb{s(0)}, s(1), \\!\\cdot\\cdot, s(2^n\\text{-}2), s(2^n\\text{-}1)$

$s(0), s(1), \\!\\cdot\\cdot, s(2^n\\text{-}2), \\pmb{n},$  
$s(0), s(1), \\!\\cdot\\cdot, s(2^n\\text{-}2), s(2^n\\text{-}1),$  
$\\pmb{n}\\!\\pmb{+}\\!\\pmb{1}, s(1), \\!\\cdot\\cdot, s(2^n\\text{-}2), \\pmb{n},$  
$\\pmb{n}\\!\\pmb{+}\\!\\pmb{1}, s(1), \\!\\cdot\\cdot, s(2^n\\text{-}2), s(2^n\\text{-}1)$

The only difference between $s\_1$ and $s\_2$ is the position they choose for tower $k = 2^{n+1} + 2^n$:

$$s\_2(k) = n + 1 \\neq s(0) = s\_1(k)$$

Let's compare the hit scores. Since the $\\eta\_{t,u}$ are equal unless $t$ or $u$ equals $k$, we have:

\\begin{align}  
\\eta(s\_2) - \\eta(s\_1) \\;\\; & =\\;\\; \\sum\_{t,u \\in \\mathbb{T}\_{n+2}} \\big(\\eta\_{t,u}(s\_2) - \\eta\_{t,u}(s\_1)\\big) \\nonumber \\\\  
  
& =\\;\\; 2 \\!\\!\\sum\_{t \\in \\mathbb{T}\_{n+2}, t \\neq k}\\!\\!  
\\big(\\eta\_{t,k}(s\_2) - \\eta\_{t,k}(s\_1)\\big) \\label{PartialDoubleShift}\\\\  
& \\;\\;\\;\\;\\;\\; + \\big(\\eta\_{k,k}(s\_2)\\big)^2. \\nonumber  
\\end{align}

Now:

\\begin{align}  
& \\sum\_{t \\in \\mathbb{T}\_{n+2}, t \\neq k}  
\\big(\\eta\_{t,k}(s\_2) - \\eta\_{t,k}(s\_1)\\big) \\nonumber \\\\  
  
& \\quad = \\!\\!\\sum\_{t \\in \\mathbb{T}\_{n+2}, t \\neq k}\\!\\!  
\\big(\\overline{(t)}(s\_2(k))\\cdot\\overline{(k)}(s\_2(t))  
\- \\overline{(t)}(s\_1(k))\\cdot\\overline{(k)}(s\_1(t))\\big) \\nonumber  
\\end{align}

Because $k = 2^{n+1} + 2^n$ (all bits null but the two most significant), for the terms in this sum it holds that:

$$  
\\left\\{  
\\begin{array}{l}  
\\overline{(k)}(s\_2(t)) \\neq 0 \\implies s\_2(t) \\ge n  
\\implies t \\in \\{2^n-1, 2^{n+1}, 2^{n+1}-1\\} \\\\  
\\overline{(k)}(s\_1(t)) \\neq 0 \\implies s\_1(t) \\ge n  
\\implies t \\in \\{2^n-1, 2^{n+1}, 2^{n+1}-1\\}  
\\end{array}  
\\right.  
$$

Hence:

\\begin{align\*}  
& \\sum\_{t \\in \\mathbb{T}\_{n+2}, t \\neq k}  
\\big(\\eta\_{t,k}(s\_2) - \\eta\_{t,k}(s\_1)\\big) \\\\  
\\\\  
& \\quad = \\;\\;\\; \\overline{(2^n-1)}(s\_2(k)) \\,- \\overline{(2^n-1)}(s\_1(k)) \\\\  
&\\quad \\;\\;\\; + \\overline{(2^{n+1})}(s\_2(k)) \\,- \\overline{(2^{n+1})}(s\_1(k)) \\\\  
&\\quad \\;\\;\\; + \\overline{(2^{n+1}-1)}(s\_2(k)) \\,- \\overline{(2^{n+1}-1)}(s\_1(k)) \\\\  
\\\\  
& \\quad = \\;\\;\\; \\overline{(2^n-1)}(n+1) \\,- \\overline{(2^n-1)}(s(0)) \\\\  
&\\quad \\;\\;\\; + \\overline{(2^{n+1})}(n+1) \\,-\\overline{(2^{n+1})}(s(0)) \\\\  
&\\quad \\;\\;\\; + \\overline{(2^{n+1}-1)}(n+1) \\,- \\overline{(2^{n+1}-1)}(s(0))  
\\end{align\*}

Finally since $0 \\le s(0) < n$:

\\begin{align\*}  
\\sum\_{t \\in \\mathbb{T}\_{n+2}, t \\neq k}  
& \\big(\\eta\_{t,k}(s\_2) - \\eta\_{t,k}(s\_1)\\big) \\\\  
\\\\  
\= \\quad & \\quad\\; 0 \\quad-\\quad 1 \\\\  
& + 1 \\quad-\\quad 0 \\\\  
& + 1 \\quad-\\quad 1 \\\\  
\\\\  
\= \\quad & \\quad\\; 0  
\\end{align\*}

Going back to $(\\ref{PartialDoubleShift})$, we conclude:

\\begin{align\*}  
\\eta(s\_2) - \\eta(s\_1) \\;\\; & =\\;\\; \\big(\\eta\_{k,k}(s\_2)\\big)^2 \\;\\;=\\;\\; 1 \\\\  
\\eta(s\\!\\Uparrow) \\;\\; & =\\;\\; \\eta(\\uparrow\\!(s\\!\\uparrow)) + 1 \\\\  
& =\\;\\; \\big( 16 \\cdot \\eta(s) + 4 + 1\\big) + 1 \\\\  
& =\\;\\; 4^{n+2} \\cdot \\big(\\mu(s) + {1 \\over 4^{n+1}} + {2 \\over 4^{n+2}}\\big)  
\\quad \\Box  
\\end{align\*}

### Efficient strategies

****Strategy****

Height

Win rate

Optimal?

$\\mathbf{T}\_0 = \[-1\]$

$0$

$0$

yes

$\\mathbf{T}\_1 = \[00\]$

$1$

${1 \\over 4}$

yes

$\\mathbf{W}\_2 = \[1010\]$

$2$

${5 \\over 16}$

yes

$\\mathbf{B}\_2 = \[0101\]$

$2$

${5 \\over 16}$

yes

$\\mathbf{R}\_2 = \[0010\]$

$2$

${5 \\over 16}$

yes

$\\mathbf{C}\_3 = \\mathbf{R}\_1 =$  
$\[01002120\]$

$3$

${21 \\over 64}$

yes

$\\mathbf{C}\_4 =$  
$\[01002123$  
$01002120\]$

$4$

${89 \\over 256}$

yes

$\\mathbf{C}\_5 =$  
$\[01002123$  
$01002120$  
$41002123$  
$41002120\]$

$5$

${358 \\over 1024}$

yes

$\\mathbf{T}\_n$

$n$

${1 \\over 4}$

no for $n>1$

$\\mathbf{W}\_n$

$n$

${1 \\over 3}\\big(1 - {1 \\over 4^n}\\big)$

no for $n>2$

$\\mathbf{B}\_n$

$n$

${1 \\over 3}\\big(1 - {1 \\over 4^n}\\big)$

no for $n>2$

$\\mathbf{C}\_{2n+1}$

$2n+1$

${7 \\over 20} - {1 \\over 10 (16)^n}$

yes?

$\\mathbf{C}\_{2n+2}$

$2n+2$

${7 \\over 20} - {3 \\over 80 (16)^n}$

yes?

$\\mathbf{R}\_n$

$3n$

${7 \\over 20} - {1 \\over {10 (16)^n}}$

no for $n>1$

Efficiency of various strategies

#### Lowest-white strategies

The lowest-white strategies are obtained by repeatedly left-resetting the strategy $\[00\]$:

\\begin{align}  
\\mathbf{W}\_0 \\;  
&\\stackrel{\\text{def}}{=} \\; \[-1\] \\\\  
\\forall n \\in \\mathbb{N}, \\quad \\mathbf{W}\_{n+1} \\;  
&\\stackrel{\\text{def}}{=} \\; \[00\] \\rightarrow \\mathbf{W}\_n \\nonumber  
\\end{align}

Applying $(\\ref{LeftResetRule})$ we get:

\\begin{equation}  
\\mu(\\mathbf{W}\_n) = {1 \\over 3} \\cdot \\big(1 - {1 \\over 4^n}\\big).  
\\end{equation}

As the height of the towers goes to infinity, the win rate of the lowest-white strategies converges to $1 \\over 3$:

\\begin{equation}  
\\lim\_{n \\to \\infty}\\mu(\\mathbf{W}\_n) = {1 \\over 3} \\approx 33.33\\%.  
\\end{equation}

#### Lowest-black strategies

The lowest-black strategies are obtained by repeatedly right-resetting the strategy $\[00\]$:

\\begin{align}  
\\mathbf{B}\_0 \\;  
&\\stackrel{\\text{def}}{=} \\; \[-1\] \\\\  
\\forall n \\in \\mathbb{N}, \\quad \\mathbf{B}\_{n+1} \\;  
&\\stackrel{\\text{def}}{=} \\; \\mathbf{B}\_n \\leftarrow \[00\] \\nonumber  
\\end{align}

Applying $(\\ref{RightResetRule})$ we get:

\\begin{equation}  
\\mu(\\mathbf{B}\_n) = {1 \\over 3} \\cdot \\big(1 - {1 \\over 4^n}\\big).  
\\end{equation}

As the height of the towers goes to infinity, the win rate of the lowest-black strategies converges to $1 \\over 3$:

\\begin{equation}  
\\lim\_{n \\to \\infty}\\mu(\\mathbf{B}\_n) = {1 \\over 3} \\approx 33.33\\%.  
\\end{equation}

#### Carter strategies

$\\mathbf{C}$

Win  
rate

Tuple

$\\mathbf{C}\_1$

$1 \\over 4$

$\[00\]$

$\\mathbf{C}\_2$

$5 \\over 16$

$\[0100\]$

$\\mathbf{C}\_3$

$2 \\over 64$

$\[01002120\]$

$\\mathbf{C}\_4$

$89 \\over 256$

$\[0100212\\text{-}01002120\]$

$\\mathbf{C}\_5$

$358 \\over 1024$

$\[01002123 \\text{-} 01002120 \\text{-} 41002123 \\text{-} 41002120\]$

$\\mathbf{C}\_6$

$1433 \\over 4096$

$\[01002123 \\text{-} 01002120 \\text{-} 41002123 \\text{-} 41002125$  
$01002123 \\text{-} 01002120 \\text{-} 41002123 \\text{-} 41002120\]$

Carter strategies

_Carter_ strategies are defined by repeatedly shifting and double-shifting the strategy $\[00\]$:

\\begin{align}  
\\mathbf{C}\_1 \\quad &\\stackrel{\\text{def}}{=} \\quad \[00\], \\nonumber \\\\  
\\mathbf{C}\_{2n+2} \\quad &\\stackrel{\\text{def}}{=} \\quad \\mathbf{C}\_{2n+1}\\!\\uparrow, \\\\  
\\mathbf{C}\_{2n+3} \\quad &\\stackrel{\\text{def}}{=} \\quad \\mathbf{C}\_{2n+1}\\!\\Uparrow. \\nonumber  
\\end{align}

Applying $(\\ref{LeftShiftRule})$ & $(\\ref{DoubleShiftRule})$ we get:

\\begin{align}  
\\mu(\\mathbf{C}\_{2n+1}) \\quad &= \\quad {7 \\over 20} - {1 \\over 10 \\cdot (16)^n}, \\\\  
\\mu(\\mathbf{C}\_{2n+2}) \\quad &= \\quad {7 \\over 20} - {3 \\over 80 \\cdot (16)^n}.  
\\end{align}

As the height of the towers goes to infinity, the win rate of the Carter strategies converges to $7 \\over 20$:

\\begin{equation}  
\\lim\_{n \\to \\infty}\\mu(\\mathbf{C}\_n) = {7 \\over 20} = 35\\%.  
\\end{equation}

#### Reyes strategies

$\\mathbf{R}$

Win  
rate

Tuple

$\\mathbf{R}\_0$

$0$

$\[-1\]$

$\\mathbf{R}\_1$

$22 \\over 64$

$\[01002120\]$

$\\mathbf{R}\_2$

$1432 \\over 4096$

$\[31002123 \\text{-} 41002124 \\text{-} 31002123 \\text{-} 31002123$  
$51002125 \\text{-} 41002124 \\text{-} 51002125 \\text{-} 31002123\]$

Reyes strategies

_Reyes_ strategies are defined by repeatedly double-resetting the Carter strategy $\\mathbf{C}\_3$:

\\begin{align}  
\\mathbf{R}\_0 \\;  
&\\stackrel{\\text{def}}{=} \\; \[-1\] \\\\  
\\forall n \\in \\mathbb{N}, \\quad \\mathbf{R}\_{n+1} \\;  
&\\stackrel{\\text{def}}{=} \\; DR(\\mathbf{R}\_n, \\mathbf{C}\_3). \\nonumber  
\\end{align}

Applying $(\\ref{DoubleResetRule})$ we get:

\\begin{equation}  
\\mu(\\mathbf{R}\_n) = {7 \\over 20} - {1 \\over {10 \\cdot (16)^n}}.  
\\end{equation}

As the height of the towers goes to infinity, the win rate of the Reyes strategies converges to $7 \\over 20$:

\\begin{equation}  
\\lim\_{n \\to \\infty}\\mu(\\mathbf{R}\_n) = {7 \\over 20} = 35\\%.  
\\end{equation}

## Recap and Whereto?

I came across the game of hats through [Numberphile's](https://www.youtube.com/watch?v=laAtv310pyk) \[zotpressInText item="{6833562:J37FUJWX}"\]. Then Google pointed to the interesting article by Stan Wagon \[zotpressInText item="{6833562:NCUAUHGU}"\].

Wagon provides a state of the art as of 2014:

- Gives a list of best known symmetric strategies due to Carter and Reyes, up to $n = 8$ (hence the christening of the $\\mathbf{C}\_n$ and $\\mathbf{R}\_n$ strategies in this article). Carter and Reyes strategies are proven optimal by brute force for $n < 5$. For $n = 5$ Wagon mentions an indirect proof by Jim Roche and him, further confirmed by a different proof by Rob Pratt. For $n > 5$ we don't know.
- Mentions a proof by Walter Stromquist that $15\\over40$ is an upper bound for the win rate of any symmetric strategy.
- Tells about asymmetric strategies (it is believed that they do not lead to better the win rates than the symmetric strategies).
- Tells about playing the game with more than two players.
- Shows how to leverage the axiom of choice to define a strategy for the game with countably infinitely many hats.

Wagon's state of the art doesn't give the explicit value of the Carter strategies beyond $\\mathbf{C}\_8$, nor does it give a procedural way to construct them. It even asks the question: "What about n = 9 or larger?". By contrast this article provides an explicit construction of $\\mathbf{C}\_n$ for all $n > 0$.

In the next article I plan to describe a "hat calculator" which implements the operations defined in this article and lets you play with strategies. It also implements an efficient brute-force algorithm to look for optimal strategies (other than Carter's).

## References

\[zotpressInTextBib style="apa" sort="ASC"\]
