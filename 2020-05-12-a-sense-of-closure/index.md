---
title: "Mathematical Cover-Up"
date: "2020-05-12"
---

![](https://blog.atlant.is/wp-content/uploads/2020/05/john-conway.jpg)

[Great mathematician John H. Conway](https://www.theguardian.com/science/2020/apr/23/john-horton-conway-obituary) passed away Saturday April 11th, as a result of complications from COVID-19. 
  
He had a slyly bent sense of humour. Together, he and Princeton University colleague Alexander Soifer managed to get the world record for the shortest paper ever published in a serious Math Journal.

The paper was published in the January 2005 issue of the _[American Mathematical Monthly](http://www.maa.org/publications/periodicals/american-mathematical-monthly)_. Numberphile [recalls the event](https://www.youtube.com/watch?v=QvvkJT8myeI).

[The paper](https://fermatslibrary.com/s/shortest-paper-ever-published-in-a-serious-math-journal-john-conway-alexander-soifer) asks the question: _Can $n^2+ 1$ unit equilateral triangles cover an equilateral triangle of side $> n$, say $n + \\epsilon$?_ then proceeds to give the answer: _$n^2+ 2$ can_, together with figures showing two different ways of achieving the result\[efn\_note\]Figure 1 is easy enough to understand: take the bottom horizontal "strip" of the size-$n$ triangle (comprised of $2n - 1$ triangles); by squeezing it horizontally and adding $2$ triangles, we increase its height until it covers up the $n + \\epsilon$ triangle.\[/efn\_note\]\[efn\_note\]Figure 2 is slightly more difficult: take the bottom horizontal strip of the size-$n$ triangle; squeeze it vertically so as to make it a little wider (to fit an $n + \\epsilon$ side); meanwhile its height will decrease a little; do the same with all remaining horizontal strips (but the triangle on top), you end up covering up the $n + \\epsilon$ triangle except for a triangular area on top that is slightly larger than a unit triangle; this remaining area can be covered-up using three unit triangles, as figure 2 shows. I believe there is a typo in the figure though: the length on the bottom left should read $1 - {\\epsilon \\over n}$ instead of $1 - \\epsilon$.\[/efn\_note\].

![](https://blog.atlant.is/wp-content/uploads/2020/05/conway-fig1.png)

Figure 1:

![](https://blog.atlant.is/wp-content/uploads/2020/05/conway-fig2.png)

Figure 2:

The folks at numberphile worry that Conway and Soifer have written nothing about the possibility of an $n^2 + 1$ unit triangles cover-up: Tony Padilla (at 4 min 40): "Yes, so that's what I think about it. I don't think they even answered the question."

Actually, in his book [How Does One Cut a Triangle?](https://link.springer.com/chapter/10.1007%2F978-0-387-74652-4_15), Soifer recollects the $n^2 + 1$ case was the easy part ("Area considerations alone show the need for at least $n^2 + 1$ of them"). So they needed not bother to encumber their proof with it.

It could have gone like this:

_Consider the "canonic" cover-up of the triangle of side $n + \\epsilon$ with $n^2$ small triangles of side $1 + {\\epsilon \\over n}$.  
Consider the combined $n^2 + 2$ vertices of these small triangles.  
The distance between any two vertices is greater than or equal to $1 + {\\epsilon \\over n}$, so no two vertices belong to the same unit triangle.  
Consequently a cover-up of the _$n + \\epsilon$_ triangle must be comprised of at least $n^2 + 2$ unit triangles._ $\\Box$
