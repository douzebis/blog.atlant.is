---
title: "Trial: the onyx rosary with beads counted from 1"
date: "2026-11-18"
language: "en"
math: true
description: "A trial translation of Part III of Jane's infinite rosary to heap coordinates, where the beads are counted from 1."
---

> **This page is a trial, not part of the paper.** It rewrites Part III of
> [Jane's infinite rosary]({{< relref "posts/2022-12-02-jane-s-infinite-rosary" >}}#part-iii-the-onyx-rosary)
> as it would read if the whole paper counted the beads from $1$ ("heap
> coordinates") instead of from $0$. Part III is the part expected to suffer
> most from the change. A table at the end sets the two versions side by
> side.

## What the earlier parts would have said

Everything here is the current paper with every position increased by one.

- **Beads** are numbered $n = 1, 2, 3, \ldots$ and bead $1$ is the end of the
  rosary. $\mathbb{N}^*$ is the set of beads.
- **Down** halves: $nD = \lfloor n/2 \rfloor$ for $n \geq 2$. **Up**:
  $nU = \lceil 3n/2 \rceil$. Both move by the label
  $L(n) = \lceil n/2 \rceil$.
- **Lambda, mu, nu**: $n\lambda = \lfloor 2n/3 \rfloor$ for a white bead $n$,
  $n\mu = 2n$ and $n\nu = 2n + 1$.
- **Black beads** are the beads $n \equiv 1 \pmod 3$: $1, 4, 7, 10, \ldots$
  The $k$-th black bead is written $k^\bullet = 3k - 2$, so that
  $1^\bullet = 1$, $2^\bullet = 4$, $3^\bullet = 7$.
- **Seed** and **lambex** are unchanged: $n = \sigma(n)U^{\Lambda(n)}$ with
  $\sigma(n)$ black.
- The running example, bead $7$ of the current paper, is now **bead $8$**. Its
  seed is $1$ and its lambex is $4$: going back by $\lambda$ gives
  $5, 3, 2, 1$.

**Theorem 1**, the only result that Part III uses, would read as follows.
Let $n \geq 2$ and write

$$2n - 1 = 3^e q \quad\text{with } 3 \nmid q, \qquad\text{and}\qquad
  b_i = 2^i\, 3^{e+1-i}\, q, \quad a_i = b_i - 1 \qquad (0 \leq i \leq e+1).$$

1. $a_0 = n^\bullet\mu$, $b_0 = n^\bullet\nu$, and
   $a_i = n^\bullet\mu\lambda^i$, $b_i = n^\bullet\nu\lambda^i$ for all
   $i \leq e+1$. For $i \leq e$ both are white; exactly one of $a_{e+1}$,
   $b_{e+1} = 2^{e+1}q$ is black.
2. If $b_{e+1}$ is black then
   $\Lambda(n^\bullet\mu) > \Lambda(n^\bullet\nu) = e+1$: *$\mu$ wins*.
   If $a_{e+1}$ is black then
   $\Lambda(n^\bullet\nu) > \Lambda(n^\bullet\mu) = e+1$: *$\nu$ wins*.
3. The winner is also the one with the smaller seed.
4. If $w$ is the winner, there is a minimal recitation to $n^\bullet$ ending
   in $\sigma(w)\,U^{\Lambda(w)}D$.

## Part III. The onyx rosary

*Sections 9 and 10.* Shortest recitations, followed backwards, hop from black
bead to black bead. Keeping only the black beads gives a tree, the onyx
rosary, in which every bead has infinitely many children (Theorem 4). This
part rests on Theorem 1.

### 9. Interlude: for a few names more

> **Colonnello Mortimer**: Che succede ragazzo?
> **Il Monco**: No, niente vecchio, non mi tornavano i conti. Ne mancava uno.
>
> Sergio Leone, *Per qualche dollaro in più* (1965)

Bold letters are for the onyx rosary, which lives on the black beads only.
The example is the black bead $4$, reached through our bead $8$.

- **Canonical recitation** $\boldsymbol{C}(n)$: the recitation
  $1 = a_0, a_1, \ldots, a_{h(n)} = n$ defined backwards by
  $a_{i-1} = a_i\lambda$ if $a_i$ is white, and $a_{i-1} =$ the winner among
  $a_i\mu$, $a_i\nu$ (the one with the larger lambex) if $a_i$ is black. By
  Lemma 2 and Theorem 1 it is a minimal recitation to $n$. For the black
  bead $4$ the candidates are $4\mu = 8$, with lambex $4$, and $4\nu = 9$,
  with lambex $2$: bead $8$ wins, and
  $\boldsymbol{C}(4) = 1, 2, 3, 5, 8, 4$.
- **Onyx rosary**: the rosary obtained by removing all white beads. **Onyx
  bead** $n$ is the $n$-th black bead, $n^\bullet$.
- **Onyx predecessor**: for an onyx bead $n \geq 2$, $\boldsymbol{\pi}(n)$ is
  the onyx bead such that $\boldsymbol{\pi}(n)^\bullet = \sigma(w)$, where $w$
  is the winner among $n^\bullet\mu$, $n^\bullet\nu$. The black beads met by
  the canonical recitation to $n^\bullet$ are exactly
  $n^\bullet, \boldsymbol{\pi}(n)^\bullet, \boldsymbol{\pi}^2(n)^\bullet, \ldots, 1$.
  For onyx bead $2$ (the black bead $4$) the winner is $8$, whose seed is
  $1 = 1^\bullet$: $\boldsymbol{\pi}(2) = 1$.
- **Onyx ordering**: $m \boldsymbol{\preceq} n$ if and only if $m^\bullet$
  appears in the canonical recitation to $n^\bullet$, i.e.
  $m = \boldsymbol{\pi}^j(n)$ for some $j \geq 0$.
- **Onyx height**: $\boldsymbol{h}(n)$ is the number of black beads in
  $\boldsymbol{C}(n^\bullet)$, minus one; i.e.
  $\boldsymbol{\pi}^{\boldsymbol{h}(n)}(n) = 1$.
- **Onyx mu, nu**: $\boldsymbol{\mu}(n)$ and $\boldsymbol{\nu}(n)$ are the
  onyx beads such that $\boldsymbol{\mu}(n)^\bullet = \sigma(n^\bullet\mu)$ and
  $\boldsymbol{\nu}(n)^\bullet = \sigma(n^\bullet\nu)$, so that
  $\boldsymbol{\pi}(n) = \min(\boldsymbol{\mu}(n), \boldsymbol{\nu}(n))$ by
  Theorem 1.

### 10. Jane's onyx rosary

#### Onyx ordering

**Proposition 2.** For every onyx bead $n \geq 2$,
$\boldsymbol{\pi}(n) \leq (8n+1)/9 < n$. Consequently the onyx ordering is a
well-founded partial order with least element $1$, it is embedded in
$(\mathbb{N}^*, \leq)$, i.e. $m \boldsymbol{\preceq} n \implies m \leq n$, and
its Hasse diagram is a tree rooted at $1$ in which $n$ is at distance
$\boldsymbol{h}(n)$ from the root.

*Proof.* With the notations of Theorem 1, the winner is $b_{e+1}$ or
$b_{e+1} - 1$, and it is white, so its seed is at most its image by
$\lambda$, which is at most $\frac{1}{3}(2b_{e+1} - 1)$ in both cases. Since
$b_{e+1} \leq b_1 = 4n - 2$, this gives
$3\boldsymbol{\pi}(n) - 2 = \sigma(w) \leq \frac{1}{3}(8n - 5)$. $\quad\Box$

(The bound is attained: $\boldsymbol{\pi}(10) = 9$.)

We say that $n$ **covers** $m$ when $\boldsymbol{\pi}(n) = m$. Figure 12 of
the paper shows this tree; its labels are the current ones, one less than
here.

#### Theorem 4: every onyx bead has infinitely many covers

*The idea.* The covers of the onyx bead $m$ are found along the up-chain of
the black bead $m^\bullet$. Whenever a bead $k$ of that chain sits just above
a black bead, $kD = n^\bullet$, it is one of the two candidates for the last
step down to $n^\bullet$; and if it wins, $n$ covers $m$. Two things are
needed. First, that the chain passes just above a black bead infinitely
often: this happens each time the parity changes along the chain (Lemma 6),
and it changes forever (Lemma 7). Second, that $k$ loses only finitely often.
By Theorem 1, $k$ can only lose to a neighbor $k \pm 1$ with a smaller seed:
our chain would then run side by side with one of the finitely many chains
that start lower. And two up-chains run side by side only finitely many times
(Lemma 8).

**Lemma 6 (parity).** For every bead $n$: $\ nUD$ is black if and only if $n$
and $nU$ have *different* parities.

*Proof.* Check the four classes of $n$ modulo $4$:
$(4j)UD = 3j$, $(4j+1)UD = 3j+1$, $(4j+2)UD = 3j+1$, $(4j+3)UD = 3j+2$, while
$(4j)U = 6j$, $(4j+1)U = 6j+2$, $(4j+2)U = 6j+3$, $(4j+3)U = 6j+5$. $\quad\Box$

**Lemma 7 (parity changes).** Along any up-chain $n, nU, nU^2, \ldots$ the
parity changes infinitely often. More precisely, $n, nU, \ldots, nU^{r-1}$ are
all even if and only if $2^r \mid n$, and all odd if and only if
$2^r \mid n+1$.

*Proof.* If $n$ is even then $nU = \frac{3}{2}n$; if $n$ is odd then
$nU + 1 = \frac{3}{2}(n+1)$. Iterate. $\quad\Box$

**Lemma 8 (neighboring up-chains).** Let $\uparrow\!(m)$ and $\uparrow\!(n)$ be
two disjoint up-chains. Then $\uparrow\!(n) \cap (\uparrow\!(m) + 1)$ is finite.
More precisely, if it is non-empty and $a$ is the least element of
$\uparrow\!(m)$ such that $a + 1 \in\ \uparrow\!(n)$, then it has exactly
$1 + v_2(a+1)$ elements, where $v_2$ is the 2-adic valuation.

*Proof.* Put $a_r = aU^r$ and $b_r = (a+1)U^r$. Since the chains are disjoint,
$a \geq 3$ (otherwise $a + 1 = aU$), hence $a < a+1 < aU$ and, $U$ being
strictly increasing, $a_r < b_r < a_{r+1}$ for all $r$. So the only element of
$\uparrow\!(m) + 1$ that $b_r$ can be equal to is $a_r + 1$. Now
$b_{r+1} - a_{r+1} = (b_r - a_r) + L(b_r) - L(a_r)$ is non-decreasing in $r$,
and when $b_r - a_r = 1$ it remains equal to $1$ if and only if $a_r$ is odd.
By Lemma 7 this happens exactly for $r \leq v_2(a+1)$. $\quad\Box$

(Two up-chains can keep each other company for a while:
$\uparrow\!(256) \cap (\uparrow\!(22) + 1)$ has 9 elements,
$2^8,\ 2^7 3,\ 2^6 3^2,\ \ldots,\ 3^8$. Only finiteness matters below.)

**Theorem 4.** Every onyx bead has infinitely many covers.

*Proof.* Fix an onyx bead $m$ and let

$$S_m = \{k \in\ \uparrow\!(m^\bullet) \mid kD \text{ is black and } kD > 1\}.$$

By Lemmas 6 and 7, $S_m$ is infinite. For $k \in S_m$, write
$kD = n^\bullet$; then $\{k, k'\} = \{n^\bullet\mu, n^\bullet\nu\}$ where the
*sibling* $k' = k \pm 1$ is white. By Theorem 1, $k$ is the winner (so that
$\boldsymbol{\pi}(n) = m$) if and only if $\sigma(k') > \sigma(k) = m^\bullet$.
Suppose not: then $k' \in\ \uparrow\!(j^\bullet)$ for some $j < m$, and
therefore

$$k \in\ \uparrow\!(m^\bullet) \cap \big((\uparrow\!(j^\bullet) + 1) \cup (\uparrow\!(j^\bullet) - 1)\big).$$

By Lemma 8 (applied twice, exchanging the roles of the two chains for the
"$-1$" part), this set is finite for each of the finitely many $j < m$. So all
but finitely many $k \in S_m$ are winners, and distinct $k$ give distinct
black beads $kD = n^\bullet$, hence distinct onyx beads $n$ covering $m$.
$\quad\Box$

*Used:* Theorem 1 and Lemmas 6, 7 and 8.

#### Corollary: the canonical onyx mapping

Order the covers of each onyx bead increasingly and number them from $1$: let
$\boldsymbol{s}_n(k)$ be the $k$-th cover of $n$, and for $n \geq 2$ let
$\boldsymbol{\iota}(n)$ be the rank of $n$ among the covers of
$\boldsymbol{\pi}(n)$. For instance $\boldsymbol{s}_1(3) = 11$,
$\boldsymbol{s}_2(3) = 6$ and $\boldsymbol{\iota}(39) = 4$ (the covers of $1$
are $2, 5, 11, 16, 24, 53, \ldots$, those of $2$ are $3, 4, 6, 41, 92, \ldots$,
and those of $5$ are $8, 12, 26, 39, \ldots$).

The **canonical onyx mapping** sends $n$ to its address in the tree, read from
the root:

$$C(n) = \Big(\boldsymbol{\iota}\big(\boldsymbol{\pi}^{\boldsymbol{h}(n)-1}(n)\big),\ \ldots,\ \boldsymbol{\iota}\big(\boldsymbol{\pi}(n)\big),\ \boldsymbol{\iota}(n)\Big) \in (\mathbb{N}^*)^{<\omega}.$$

**Corollary 2.** $C$ is a bijection from $\mathbb{N}^*$ onto the set
$(\mathbb{N}^*)^{<\omega}$ of finite sequences of positive integers, and
$m \boldsymbol{\preceq} n$ if and only if $C(m)$ is a prefix of $C(n)$. In
other words, the onyx ordering is isomorphic to the full infinitely branching
tree.

*Proof.* Injectivity and the prefix property hold in any rooted tree;
surjectivity is Theorem 4. $\quad\Box$

| $n$ | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| $C(n)$ | $()$ | $(1)$ | $(1,1)$ | $(1,2)$ | $(2)$ | $(1,3)$ | $(1,1,1)$ | $(2,1)$ | $(2,1,1)$ | $(2,1,1,1)$ | $(3)$ |

#### Jane's foraging sequence

Jane's foraging sequence $(\boldsymbol{\Phi}(i))_{i \ge 0}$ is the sequence of
onyx beads obtained from the reluctant recitation by replacing each $\rho(i)$
with the onyx bead of its seed (the $n$ such that
$\sigma(\rho(i)) = n^\bullet$) and then removing direct repetitions:

$$1, 2, 3, 5, 4, 14, 5, 8, 6, 1, 11, 41, 31, 5, 12, 9, 7, 17, 13, 10, 2, 6, 21, 16, \ldots$$

**Corollary 3.** The foraging sequence is infinite and takes every value
infinitely often.

*Proof.* By Theorem 3 Jane tells every bead of every up-chain, so she is in
$\uparrow\!(m^\bullet)$ at infinitely many times, and she is outside of it at
infinitely many times. Hence the onyx bead of $\sigma(\rho(i))$ takes the
value $m$ on infinitely many maximal runs. $\quad\Box$

```python
import itertools

def Phi(n: int) -> int:
    if n < 0: raise ValueError("argument must be nonnegative")
    visited = {1}
    bead = 1
    res = 1
    for _ in itertools.count():
        if n == 0: return res
        if bead > 1 and bead//2 not in visited:
            bead //= 2               # moving down
        else:
            bead += (bead + 1)//2    # moving up
        visited.add(bead)
        nxt = bead
        while nxt % 3 != 1: nxt = (2*nxt)//3   # compute the seed
        nxt = (nxt + 2)//3                     # its rank among black beads
        if nxt != res:
            res = nxt
            n -= 1
```

## Before and after

| | Counted from $0$ (the paper today) | Counted from $1$ (this page) |
|---|---|---|
| Black beads | $3n$ | $n^\bullet = 3n - 2$ |
| Theorem 1 | $2n + 1 = 3^e q$, $\ a_i = (\frac{2}{3})^i(6n+3) - 2$ | $2n - 1 = 3^e q$, $\ b_i = 2^i 3^{e+1-i} q$ |
| Who wins | $2^{e+1}q \equiv 1$ or $2 \pmod 3$ | $b_{e+1} = 2^{e+1}q$ is black, or not |
| Onyx predecessor | $\boldsymbol{\pi}(n) = \frac{1}{3}\sigma(w)$ | $\boldsymbol{\pi}(n)^\bullet = \sigma(w)$ |
| Proposition 2 | $\boldsymbol{\pi}(n) \leq 8n/9$ | $\boldsymbol{\pi}(n) \leq (8n+1)/9$ |
| Lemma 6 | $3 \mid nUD$ | $nUD$ is black |
| Lemma 7 | $2^r \mid n+2$, $\ 2^r \mid n+1$ | $2^r \mid n$, $\ 2^r \mid n+1$ |
| Lemma 8 | $1 + v_2(a+2)$ | $1 + v_2(a+1)$ |
| Its example | $255, 383, 575, \ldots, 6560$ | $2^8, 2^7 3, \ldots, 3^8$ |
| Root, first cover | $0$, cover number $0$ | $1$, cover number $1$ |
| Seed in the code | `nxt //= 3` | `nxt = (nxt + 2)//3` |

Every statement and every number on this page was checked by computation
(Theorem 1, Proposition 2 and Lemmas 6 to 8 for the onyx beads and beads
below $20\,000$, the table of $C$, the covers quoted and the 24 values of the
foraging sequence).
