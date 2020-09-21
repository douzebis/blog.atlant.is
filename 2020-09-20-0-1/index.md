---
title: "0! = 1"
date: "2020-09-20"
---

La fonction factorielle est souvent définie comme le produit : $$n!=\\prod\_{k=1}^n k\\text{,}$$ ou bien par récurrence : $$n!=n\\cdot(n-1)!\\text{,}$$ en prenant par convention : $0!=1$. Mais pourquoi cette convention ?

Bien sûr c'est assez pratique pour la formule des [combinaisons](https://fr.wikipedia.org/wiki/Combinaison_(math%C3%A9matiques)), car ainsi on peut écrire : $$C\_n^k=\\left(\\begin{array}{c}n\\\\k\\end{array}\\right)={n!\\over k!(n-k)!}$$ même quand $k=n$, et vérifier qu'il y a bien une seule façon de choisir $n$ éléments parmi $n$ :)

On peut trouver une explication plus satisfaisante en revenant au sens ensembliste de la factorielle : $n!$ c'est le nombre de permutations d'un ensemble à $n$ éléments, c'est à dire le nombre de bijections possibles entre cet ensemble et lui-même.

Du coup la question devient : quelles sont les bijections entre l'ensemble vide $\\emptyset$ et lui-même ? Quel est leur nombre ?

Pour revenir aux bases, une application $f$ d'un ensemble $A$ vers un ensemble $B$ est une relation entre $A$ et $B$ -- autrement dit une partie $f\\subset A\\times B$ -- qui vérifie : $$\\forall x\\in A, \\exists! y\\in B, (x,y)\\in f\\text{.}$$ Et dans le cas où $(x,y)\\in f$ on écrit : $y=f(x)$.

On observe que $\\emptyset\\times\\emptyset=\\emptyset$, que donc $\\emptyset$ est la seule partie de $\\emptyset\\times\\emptyset$, et on vérifie que $\\forall x\\in \\emptyset, \\exists! y\\in \\emptyset, (x,y)\\in \\emptyset$, ce qui démontre que $\\emptyset$ est la seule application de $\\emptyset$ vers $\\emptyset$. On remarque que le domaine de (l'application) $\\emptyset$ est vide, et que donc on n'a jamais l'occasion d'écrire $\\emptyset(x)=y$.

Pour finir, on constate que (l'application) $\\emptyset:\\emptyset\\to\\emptyset$ est à la fois injective (son domaine est vide) et surjective (son ensemble d'arrivée est vide), ce qui démontre que $\\emptyset$ est une bijection.

Il est temps de conclure : $\\emptyset$ est l'unique bijection entre $\\emptyset$ et $\\emptyset$...

$0!=1$.$\\quad \\Box$
