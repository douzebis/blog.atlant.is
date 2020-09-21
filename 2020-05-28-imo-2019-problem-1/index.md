---
title: "IMO 2019 Problem 1"
date: "2020-05-28"
---

An exercice with [MathJax](https://www.mathjax.org/)

[![](https://blog.atlant.is/wp-content/uploads/2020/05/imo-logo.png)](https://www.imo-official.org/)

[Olympiade Internationale de Mathématiques](https://www.imo-official.org/)

Problem 1: Let $\\mathbb{Z}$ be the set of integers. Determine all functions $f : \\mathbb{Z} \\rightarrow \\mathbb{Z}$ such that

\\begin{equation}  
\\forall (a, b) \\in \\mathbb{Z} \\times \\mathbb{Z}, \\quad f(2a) + 2 f(b) = f(f(a + b))  
\\label{eq1}  
\\end{equation}

* * *

Substituting $0$ for $a$, $x$ for $b$ in $(\\ref{eq1})$ yields:

\\begin{equation}  
\\forall x \\in \\mathbb{Z}, \\quad f(0) + 2 f(x) = f(f(x))  
\\label{eq2}  
\\end{equation}

Substituting $1$ for $a$, $x - 1$ for $b$ in $(\\ref{eq1})$ yields:

\\begin{equation}  
\\forall x \\in \\mathbb{Z}, \\quad f(2) + 2 f(x - 1) = f(f(x))  
\\label{eq3}  
\\end{equation}

Combining $(\\ref{eq2})$ and $(\\ref{eq3})$ yields:

$$\\forall x \\in \\mathbb{Z}, \\quad f(x) = f(x - 1) + {{f(2) - f(0)} \\over 2}$$

Thus $f$ is necessary of the form $f(x) = m x + n$ for some $(m, n) \\in \\mathbb{Z} \\times \\mathbb{Z}$.

Expanding $(\\ref{eq1})$ yields:

$$\\forall (a, b) \\in \\mathbb{Z} \\times \\mathbb{Z}, \\quad m (2 - m)(a + b) + n(2 - m) = 0$$

It follows that necessarily either $m = 2$ or $m = n = 0$.

We can verify that these values actually give solutions to equation $(\\ref{eq1})$.

Thus the set of functions $f$ solutions to problem 1 is exactly:

$$\\{ f: x \\mapsto 0 \\} \\cup \\{f: x \\mapsto 2x + n, n \\in \\mathbb{Z} \\}$$

$\\Box$
