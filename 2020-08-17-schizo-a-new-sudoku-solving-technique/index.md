---
title: "Schizo: a different sudoku solving technique"
date: "2020-08-17"
---

Over the years, several tips and techniques have been developed to help solve sudoku puzzles with logic rather than brute force. To name a few, [sudoku9x9](https://sudoku9x9.com/) mentions (among others) _hidden single_, _naked single_, _x-wing_.

## At least one solution

These techniques are all based on a common principle: they work "ad absurdum", by eliminating moves that would lead to an invalid grid: a puzzle with zero solution. For example, the grid below illustrates the _hidden single_ technique:

table { border-collapse: collapse; font-family: Calibri, sans-serif; } colgroup, tbody { border: solid medium; } td { border: solid thin; height: 2em; width: 2em; text-align: center; padding: 0; }

Hidden single example   

2

1

3

2

Number **2** cannot be placed in any of the red cells because this would lead to a grid with no solution. Therefore it must be placed in the green cell, leading to the next step:

table { border-collapse: collapse; font-family: Calibri, sans-serif; } colgroup, tbody { border: solid medium; } td { border: solid thin; height: 2em; width: 2em; text-align: center; padding: 0; }

The hidden single is revealed   

2

1

2

3

2

## At most one solution

Here is a (novel?) technique based on the opposite principle: it works by eliminating a move that would lead to a grid with more than one solution. (By current rules, well formed sudoku puzzles must have a single solution.)

The grid below illustrates this technique, which we call _schizo_ (as in schizophrenia):

table { border-collapse: collapse; font-family: Calibri, sans-serif; } colgroup, tbody { border: solid medium; } td { border: solid thin; height: 2em; width: 2em; text-align: center; padding: 0; }

Schizo example   

3

6

1

2

2

5

1

48

478

9

3

6

6

3

2

478

5

1

9

2

48

48

7

1

7

1

9

5

3

6

2

8

4

1

9

2

4

2

7

1

3

5

1

9

5

8

2

5

6

2

4

1

Number **7** cannot be placed in the red cell because this would eventually lead to two equally valid solutions:

table { border-collapse: collapse; font-family: Calibri, sans-serif; } colgroup, tbody { border: solid medium; } td { border: solid thin; height: 2em; width: 2em; text-align: center; padding: 0; }

Eventual solution 1   

3

6

1

2

2

5

1

4

8

9

3

6

6

3

2

7

5

1

9

2

8

4

7

1

7

1

9

5

3

6

2

8

4

1

9

2

4

2

7

1

3

5

1

9

5

8

2

5

6

2

4

1

table { border-collapse: collapse; font-family: Calibri, sans-serif; } colgroup, tbody { border: solid medium; } td { border: solid thin; height: 2em; width: 2em; text-align: center; padding: 0; }

Eventual solution 2   

3

6

1

2

2

5

1

8

4

9

3

6

6

3

2

7

5

1

9

2

4

8

7

1

7

1

9

5

3

6

2

8

4

1

9

2

4

2

7

1

3

5

1

9

5

8

2

5

6

2

4

1

Therefore **7** must be placed in the green cell, leading to the next step:

table { border-collapse: collapse; font-family: Calibri, sans-serif; } colgroup, tbody { border: solid medium; } td { border: solid thin; height: 2em; width: 2em; text-align: center; padding: 0; }

Schizophrenia is avoided   

3

6

1

2

2

5

1

48

7

9

3

6

6

3

2

48

5

1

9

2

48

48

7

1

7

1

9

5

3

6

2

8

4

1

9

2

4

2

7

1

3

5

1

9

5

8

2

5

6

2

4

1

$\\Box$
