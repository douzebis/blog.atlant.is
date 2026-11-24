-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.SearchProgram
import Hats.SearchRun

/-!
# The search on four hats, run as a compiled program

On four hats the search tries 100 663 296 strategies.  Lean's kernel, which
checks every other proof of this project, is too slow for that.  Here the
fast search program is run by Lean's compiled code instead
(`native_decide`).

The theorems of this file therefore rest on one more assumption than the
rest of the project: that the Lean compiler is right (the axiom
`Lean.ofReduceBool`).  What is proved without it, in
`Hats/SearchProgram.lean`, is that the program is correct: *if* it returns
89, no strategy on four hats has more than 89 hits.

This file is not part of the audit of `Hats/Audit.lean`, which only admits
Lean's three standard axioms.
-/

namespace Hats

/-- The fast search program returns 89 on four hats. -/
theorem search_four : HatsSearch.search 4 0 = 89 := by native_decide

/-- **On four hats, no strategy has more than 89 hits** (the compiler
trusted): the Carter strategy on four hats is optimal. -/
theorem hits_four_le (s : ℕ → ℤ) : hits 4 s ≤ 89 := by
  have h := (search_spec (n := 4) (by norm_num) (by norm_num) 0).1 s
  rwa [search_four] at h

theorem hits_carter_four : hits 4 (carter 4) = 89 := by
  rw [hits_carter (by norm_num)]; norm_num

end Hats
