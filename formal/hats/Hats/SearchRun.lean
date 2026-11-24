-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.SearchFast
import Hats.Families

/-!
# The search, run by Lean

The value of `best n` for small `n`, computed inside Lean's logic, and
what follows: the best number of hits on one, two and three hats.
-/

namespace Hats

theorem best_one : best 1 = 1 := by decide

theorem best_two : best 2 = 5 := by decide

theorem best_three : best 3 = 22 := by decide +kernel

/-- **On three hats, no strategy has more than 22 hits**: the Carter
strategy on three hats is optimal. -/
theorem hits_three_le (s : ℕ → ℤ) : hits 3 s ≤ 22 :=
  best_three ▸ hits_le_best (by norm_num) s

theorem hits_carter_three : hits 3 (carter 3) = 22 := by
  rw [hits_carter (by norm_num)]; norm_num

/-- The search that counts as it goes finds the same numbers. -/
theorem bestFast_three : bestFast 3 = 22 := by decide +kernel

end Hats
