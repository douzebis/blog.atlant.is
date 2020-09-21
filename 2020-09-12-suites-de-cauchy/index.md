---
title: "Suites de Cauchy"
date: "2020-09-12"
---

Cet exercice s'inspire d'une des méthodes classiques de construction des réels à partir des rationels.

Considérons l'ensemble des suites de Cauchy dans $\\mathbb{R}$, noté $\\mathbf{C}(\\mathbb{R})$.

Soit $\\equiv\_\\mathbb{R}$ la relation entre suites de Cauchy définie comme suit:

$$\\forall u, v \\in \\mathbf{C}(\\mathbb{R}) \\quad  
u \\equiv\_\\mathbb{R} v  
\\;\\stackrel{\\text{def}}{\\iff}\\;  
\\text{lim }u = \\text{lim }v$$

(1) Montrer que $\\equiv\_\\mathbb{R}$ est bien définie.

(2) Montrer que $\\equiv\_\\mathbb{R}$ est une relation d'équivalence.

(3) Trouver une formulation de $\\equiv\_\\mathbb{R}$ qui ne fasse pas intervenir explicitement de nombre réel (c'est à dire par exemple qui ne fasse pas référence à la limite des suites $u$ et $v$).

(4) Utiliser la formulation trouvée au (3) pour définir une relation d'équivalence $\\equiv\_\\mathbb{Q}$ similaire à $\\equiv\_\\mathbb{R}$, mais pour l'ensemble $\\mathbf{C}(\\mathbb{Q})$ des suites de Cauchy dans $\\mathbb{Q}$.

(5) Construire une bijection entre l'ensemble des réels $\\mathbb{R}$ et le quotien des suites de Cauchy $\\mathbf{C}(\\mathbb{Q})$ par la relation $\\equiv\_\\mathbb{Q}$.

$\\Box$

* * *

### Indices

La question (3) est difficile. Deux mots indice:

1. Entrelacement
2. Différence

* * *

### Indices++

1. Si $u$ et $v$ sont deux suites de Cauchy, considérer la suite w définie comme suit: $$\\forall n\\in\\mathbb{N}, w\_{2n}= u\_n\\text{ et }w\_{2n+1}=v\_n$$
2. Si $u$ et $v$ sont deux suites de Cauchy à valeurs dans $\\mathbb{Q}$, $\\mathbb{R}$ ou $\\mathbb{C}$, considérer la suite w définie comme suit: $$\\forall n\\in\\mathbb{N}, w\_n=v\_n-u\_n$$
