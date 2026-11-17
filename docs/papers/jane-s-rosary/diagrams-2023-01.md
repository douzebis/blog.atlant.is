<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: CC-BY-4.0
-->

# Jane's infinite rosary, January 2023: sources of the diagrams

The 26 commutative diagrams of the January 2023 text were written with
`xymatrix` and drawn in the browser by MathJax 3 with the XyJax extension.
The frozen version shows them as pictures
(`content/versions/jane-s-infinite-rosary/2023-01/images/diagram-NN.svg`).
Their sources are kept here, with the macros they use.

## Macros

```latex
\def\black{{\unicode{x25cf}}}
    \def\white{{\unicode{x25cb}}}
    \def\bblack{{\huge\unicode{x25cf}}}
    \def\bwhite{{\huge\unicode{x25cb}}}
    \def\done{{\bigcirc\!\!\!\!\!\checkmark}}
    \def\todo{{\bigcirc}}
    \def\donealt{\unicode{x2d54}}
    \def\todoalt{\unicode{x2d59}}
    \def\qed{\quad\unicode{x25fb}}
    \def\eqdef{{\stackrel{\tiny\mbox{def}}{=}}}
    \def\iffdef{{\stackrel{\tiny\mbox{def}}{\iff}}}
    \def\N{{\mathbb{N}}}
    \def\Z{{\mathbb{Z}}}
    \def\R{{\mathbb{R}}}
    \newcommand{\card}[1]{{\mbox{card}( {#1} )}}
    \newcommand{\floor}[1]{{\lfloor {#1} \rfloor}}
    \newcommand{\b}[1]{{\boldsymbol{#1}}}
```

## Diagram 01

```latex
\begin{xy}
\xymatrix {
8k+4 \ar@{.>}[d]^D \ar[r]^U & \white\,12k+7\ar@2{>}[d]^D \ar@{.>}@/^/[l]^\lambda \\
4k+1 \ar@{.>}[d]^D &\black\,6k+3 \ar@2{>}[d]^D \ar@{.>}@/^/[u]^\mu \\
2k \ar@{.>}[r]^U & {\white\,3k+1} \ar@{.>}@/^/[u]^\mu
}
\end{xy}
```

## Diagram 02

```latex
\begin{xy}
\xymatrix {
8k+5 \ar@{.>}[d]^D \ar[r]^U & \white\,12k+8\ar@2{>}[d]^D \ar@{.>}@/^/[l]^\lambda \\
4k+2 \ar@{.>}[d]^D &\black\,6k+3 \ar@2{>}[d]^D \ar@{.>}@/^/[u]^\nu \\
2k \ar@{.>}[r]^U & {\white\,3k+1} \ar@{.>}@/^/[u]^\mu
}
\end{xy}
```

## Diagram 03

```latex
\begin{xy}
\xymatrix {
4k+2 \ar@{.>}[d]^D \ar[r]^U & \white\,6k+4\ar@{.>}@/^/[l]^\lambda \ar@2{>}[d]^D \\
2k \ar@{.>}[r]^U & \white\,3k+1\ar@{.>}@/^/[u]^\nu
}
\end{xy}
```

## Diagram 04

```latex
\begin{xy}
\xymatrix {
8k+8 \ar@{.>}[d]^D \ar[r]^U & \white\,12k+13\ar@2{>}[d]^D \ar@{.>}@/^/[l]^\lambda \\
4k+3 \ar@{.>}[d]^D &\black\,6k+6 \ar@2{>}[d]^D \ar@{.>}@/^/[u]^\mu \\
2k+1 \ar@{.>}[r]^U & {\white\,3k+2} \ar@{.>}@/^/[u]^\nu
}
\end{xy}
```

## Diagram 05

```latex
\begin{xy}
\xymatrix {
8k+9 \ar@{.>}[d]^D \ar[r]^U & \white\,12k+14\ar@2{>}[d]^D \ar@{.>}@/^/[l]^\lambda \\
4k+4 \ar@{.>}[d]^D &\black\,6k+6 \ar@2{>}[d]^D \ar@{.>}@/^/[u]^\nu \\
2k+1 \ar@{.>}[r]^U & {\white\,3k+2} \ar@{.>}@/^/[u]^\nu
}
\end{xy}
```

## Diagram 06

```latex
\begin{xy}
\xymatrix {
4k+3 \ar@{.>}[d]^D \ar[r]^U & \white\,6k+5\ar@{.>}@/^/[l]^\lambda \ar@2{>}[d]^D \\
2k+1 \ar@{.>}[r]^U & \white\,3k+2\ar@{.>}@/^/[u]^\mu
}
\end{xy}
```

## Diagram 07

```latex
\begin{xy}
\xymatrix {
4k \ar[r]^U & \white\,6k+1\ar@{.>}@/^/[l]^\lambda \ar@2{>}[d]^D \\
& \black\,3k \ar@{.>}@/^/[u]^\mu
}
\end{xy}
```

## Diagram 08

```latex
\begin{xy}
\xymatrix {
4k+1 \ar[r]^U & \white\,6k+2\ar@{.>}@/^/[l]^\lambda \ar@2{>}[d]^D \\
& \black\,3k \ar@{.>}@/^/[u]^\nu
}
\end{xy}
```

## Diagram 09

```latex
\begin{xy}
\xymatrix {
& b_1=4n+1                                               &&&
    \white\,6n+2\ar[lll]^(0.6){\lambda}                                   \\
a_1=4n\ar[ur]^s                                                   &&
    \white\,6n+1\ar[ll]^(0.4){\lambda}\ar[rru]^s                          \\
                                                             &&&
                        \black\,3n\ar[dr]^s\ar[lu]^\mu\ar[uur]^(0.2)\nu   \\
& d_1=2n\ar[uuu]^(0.4)\mu                                &&&
    \white\,3n+1\ar[lll]^(0.6){\lambda}                                   \\
c_1=2n-1\ar[ur]^s\ar[uuu]^(0.4)\nu                                &&
    \white\,3n-1\ar[uur]^(0.7)s\ar[ll]^(0.4){\lambda}
}
\end{xy}
```

## Diagram 10

```latex
\begin{xy}
\xymatrix {
&\quad\white\;b_i\quad\ar[dd]_D\\
\quad\white\;a_i\quad\ar[ur]^s\ar[dd]_D\\
&\quad\white\;d_i\quad\quad\\
\quad\white\;c_i\quad\ar[ur]^s
}
\end{xy}
```

## Diagram 11

```latex
\begin{xy}
\xymatrix {
&b_i=6k+5\\
a_i=6k+4\ar[ur]^s\\
&d_i=3k+2\ar[uu]^\mu\\
c_i=3k+1\ar[ur]^s\ar[uu]^\nu
}
\end{xy}
```

## Diagram 12

```latex
\begin{xy}
\xymatrix {
& b_{i+1}=4k+3                                                 &&
    \white\,b_i=6k+5\ar[ll]^(0.6){\lambda}                                 \\
a_{i+1}=4k+2\ar[ur]^s                                              &&
    \white\,a_i=6k+4\ar[ll]^(0.4){\lambda}\ar[ur]^s                        \\
& d_{i+1}=2k+1\ar[uu]^(0.3)\mu                                 &&
    \white\,d_i=3k+2\ar[uu]_(0.3)\mu\ar[ll]^(0.6){\lambda}                 \\
c_{i+1}=2k\ar[ur]^s\ar[uu]^(0.3)\nu                                &&
    \white\,c_i=3k+1\ar[ur]^(0.4)s\ar[uu]_(0.3)\nu\ar[ll]^(0.4){\lambda}
}
\end{xy}
```

## Diagram 13

```latex
\begin{xy}
\xymatrix {
& \black\,b_i                                             &&&
    \white\,6n+2\ar[lll]^(0.7){\lambda^i}                                  \\
\white\,a_i\ar[ur]^s\ar@{.>}@/^/[rr]^(0.6){U^i}                 &&
    \white\,6n+1\ar[rru]^s\ar[ll]^(0.4){\lambda^i}
                \ar@{.>}@/^/[dr]^(0.6){D}                               \\
                                                              &&&
                        \black\,3n\ar[dr]^s\ar[lu]^\mu\ar[uur]^(0.2)\nu    \\
& \white\,d_i\ar[uuu]^(0.4)\mu                            &&&
    \white\,3n+1\ar[lll]^(0.7){\lambda^i}                                  \\
\black\,c_i\ar[ur]^s\ar[uuu]^(0.4)\nu                              &&
    \white\,3n-1\ar[uur]^(0.7)s\ar[ll]^(0.4){\lambda^i}
}
\end{xy}
```

## Diagram 14

```latex
\begin{xy}
\xymatrix {
& \white\,b_i\ar@{.>}@/^/[rrr]^(0.6){U^i}              &&&
    \white\,6n+2\ar[lll]^(0.6){\lambda_i}
                \ar@{.>}@/^/[ddl]^(0.6)D                               \\
\black\,a_i\ar[ur]^s                                               &&
    \white\,6n+1\ar[rru]^s\ar[ll]^(0.4){\lambda_i}                         \\
                                                              &&&
                        \black\,3n\ar[dr]^s\ar[lu]^\mu\ar[uur]^(0.2)\nu    \\
& \black\,d_i\ar[uuu]^(0.4)\mu                            &&&
    \white\,3n+1\ar[lll]^(0.6){\lambda_i}                                  \\
\white\,c_i\ar[ur]^s\ar[uuu]^(0.4)\nu                              &&
    \white\,3n-1\ar[uur]^(0.7)s\ar[ll]^(0.4){\lambda_i}
}
\end{xy}
```

## Diagram 15

```latex
\begin{xy}
\xymatrix {
\bbox[5pt]{ }\\
\done_2:4k+2\ar@{.>}[d]^D\ar[r]^U          & \done_1:6k+4\ar[d]^D   \\
\todo:g=2k\ar@{.>}[r]^U            & \done_0:3k+1\ar@/^/[u]^\nu
}
\end{xy}
```

## Diagram 16

```latex
\begin{xy}
\xymatrix {
& \done_2\ar[d]_D              \\
\done_j:4k+2\ar@{.>}[d]^D\ar@{.>}[r]^U          & \done_1:6k+4\ar[d]^D   \\
\todo:g=2k\ar@{.>}[r]^U            & \done_0:3k+1\ar@/^/[u]^\nu
}
\end{xy}
```

## Diagram 17

```latex
\begin{xy}
  \xymatrix {
  \bbox[5pt]{ }\\
  \done_3:8k+4\ar@{.>}[d]^D\ar[r]^U  & \done_2:12k+7\ar[d]^D   \\
  \done_j:4k+2\ar@{.>}[d]^D          & \done_1:6k+3\ar[d]^D\ar@/^/[u]^\mu   \\
  \todo:g=2k\ar@{.>}[r]^U            & \done_0:3k+1\ar@/^/[u]^\mu
  }
  \end{xy}
```

## Diagram 18

```latex
\begin{xy}
\xymatrix {
                                             & \done_3\ar[d]_D              \\
\done_j:8k+4\ar@{.>}[d]^D\ar@{.>}[r]^U & \done_2:12k+7\ar[d]^D   \\
\done_{j-1}:4k+2\ar@{.>}[d]^D             & \done_1:6k+3\ar[d]^D\ar@/^/[u]^\mu   \\
\todo:g=2k\ar@{.>}[r]^U                   & \done_0:3k+1\ar@/^/[u]^\mu
}
\end{xy}
```

## Diagram 19

```latex
\begin{xy}
  \xymatrix {
  \bbox[5pt]{ }\\
  \done_3:8k+5\ar@{.>}[d]^D\ar[r]^U  & \done_2:12k+8\ar[d]^D   \\
  \done_j:4k+2\ar@{.>}[d]^D          & \done_1:6k+3\ar[d]^D\ar@/^/[u]^\nu   \\
  \todo:g=2k\ar@{.>}[r]^U            & \done_0:3k+1\ar@/^/[u]^\mu
  }
  \end{xy}
```

## Diagram 20

```latex
\begin{xy}
\xymatrix {
                                             & \done_3\ar[d]_D              \\
\done_j:8k+5\ar@{.>}[d]^D\ar@{.>}[r]^U & \done_2:12k+8\ar[d]^D   \\
\done_{j-1}:4k+2\ar@{.>}[d]^D             & \done_1:6k+3\ar[d]^D\ar@/^/[u]^\nu   \\
\todo:g=2k\ar@{.>}[r]^U                   & \done_0:3k+1\ar@/^/[u]^\mu
}
\end{xy}
```

## Diagram 21

```latex
\begin{xy}
\xymatrix {
\bbox[5pt]{ }\\
\done_2:4k+3\ar@{.>}[d]^D\ar[r]^U          & \done_1:6k+5\ar[d]^D   \\
\todo:g=2k+1\ar@{.>}[r]^U            & \done_0:3k+2\ar@/^/[u]^\mu
}
\end{xy}
```

## Diagram 22

```latex
\begin{xy}
\xymatrix {
& \done_2\ar[d]_D              \\
\done_j:4k+3\ar@{.>}[d]^D\ar@{.>}[r]^U          & \done_1:6k+5\ar[d]^D   \\
\todo:g=2k+1\ar@{.>}[r]^U            & \done_0:3k+2\ar@/^/[u]^\mu
}
\end{xy}
```

## Diagram 23

```latex
\begin{xy}
  \xymatrix {
  \bbox[5pt]{ }\\
  \done_3:8k+8\ar@{.>}[d]^D\ar[r]^U  & \done_2:12k+13\ar[d]^D   \\
  \done_j:4k+3\ar@{.>}[d]^D          & \done_1:6k+6\ar[d]^D\ar@/^/[u]^\mu   \\
  \todo:g=2k+1\ar@{.>}[r]^U            & \done_0:3k+2\ar@/^/[u]^\nu
  }
  \end{xy}
```

## Diagram 24

```latex
\begin{xy}
\xymatrix {
                                             & \done_3\ar[d]_D              \\
\done_j:8k+8\ar@{.>}[d]^D\ar@{.>}[r]^U & \done_2:12k+13\ar[d]^D   \\
\done_{j-1}:4k+3\ar@{.>}[d]^D             & \done_1:6k+6\ar[d]^D\ar@/^/[u]^\mu   \\
\todo:g=2k+1\ar@{.>}[r]^U                   & \done_0:3k+2\ar@/^/[u]^\nu
}
\end{xy}
```

## Diagram 25

```latex
\begin{xy}
  \xymatrix {
  \bbox[5pt]{ }\\
  \done_3:8k+9\ar@{.>}[d]^D\ar[r]^U  & \done_2:12k+14\ar[d]^D   \\
  \done_j:4k+3\ar@{.>}[d]^D          & \done_1:6k+6\ar[d]^D\ar@/^/[u]^\nu   \\
  \todo:g=2k+1\ar@{.>}[r]^U            & \done_0:3k+2\ar@/^/[u]^\nu
  }
  \end{xy}
```

## Diagram 26

```latex
\begin{xy}
\xymatrix {
                                             & \done_3\ar[d]_D              \\
\done_j:8k+9\ar@{.>}[d]^D\ar@{.>}[r]^U & \done_2:12k+14\ar[d]^D   \\
\done_{j-1}:4k+3\ar@{.>}[d]^D             & \done_1:6k+6\ar[d]^D\ar@/^/[u]^\nu   \\
\todo:g=2k+1\ar@{.>}[r]^U                   & \done_0:3k+2\ar@/^/[u]^\nu
}
\end{xy}
```
