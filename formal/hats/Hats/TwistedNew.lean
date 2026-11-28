-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.TwistedShift

/-!
# The twisted double shift is not a renamed double shift

On two hats, for each of the sixteen strategies `s`, no renaming of the
four positions turns the double shift of `s` into its twisted double
shift, whatever these two strategies do when they see the all-white and
the all-black stacks (`tds_not_renamed_ds`, checked by the kernel).
-/

namespace Hats

open Finset

/-- The stack `t` of four hats with its positions renamed by `p`: the hat
at position `j` goes to position `p[j]`. -/
def renameStack (p : List ℕ) (t : ℕ) : ℕ :=
  ((List.range 4).map fun j => if t.testBit j then 2 ^ p.getD j 0 else 0).sum

/-- The twenty-four renamings of four positions. -/
def perms4 : List (List ℕ) := [
  [0, 1, 2, 3],
  [0, 1, 3, 2],
  [0, 2, 1, 3],
  [0, 2, 3, 1],
  [0, 3, 1, 2],
  [0, 3, 2, 1],
  [1, 0, 2, 3],
  [1, 0, 3, 2],
  [1, 2, 0, 3],
  [1, 2, 3, 0],
  [1, 3, 0, 2],
  [1, 3, 2, 0],
  [2, 0, 1, 3],
  [2, 0, 3, 1],
  [2, 1, 0, 3],
  [2, 1, 3, 0],
  [2, 3, 0, 1],
  [2, 3, 1, 0],
  [3, 0, 1, 2],
  [3, 0, 2, 1],
  [3, 1, 0, 2],
  [3, 1, 2, 0],
  [3, 2, 0, 1],
  [3, 2, 1, 0]]

/-- The strategy on two hats with the choices `a`, `b`, `c`, `d`. -/
def word2 (a b c d : ℕ) : ℕ → ℤ := fun t => (([a, b, c, d].getD t 0 : ℕ) : ℤ)

/-- For every strategy on two hats and every renaming `p`, some stack that
is not of a single color tells the two strategies apart: the twisted
double shift, seeing the renamed stack, does not point at the renamed
choice of the double shift. -/
theorem tds_not_renamed_ds :
    ∀ a ∈ range 2, ∀ b ∈ range 2, ∀ c ∈ range 2, ∀ d ∈ range 2, ∀ p ∈ perms4,
      ∃ t ∈ Ico 1 15,
        tds 2 (word2 a b c d) (renameStack p t)
          ≠ ((p.getD (ds 2 (word2 a b c d) t).toNat 0 : ℕ) : ℤ) := by
  decide +kernel

end Hats
