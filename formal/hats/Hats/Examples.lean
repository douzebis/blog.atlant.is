-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Reset

/-!
# Examples computed by Lean

Strategies of the article, written as the list of their choices: the entry
of rank `t` is the position chosen for tower `t`.
-/

namespace Hats

/-- The strategy whose choices are listed in `l`. -/
def ofList (l : List ℤ) : ℕ → ℤ := fun t => l.getD t 0

/-- The lowest-white strategy on two hats has 5 hits (out of 16). -/
example : hits 2 (ofList [1, 0, 1, 0]) = 5 := by decide

/-- The Carter strategy on three hats has 22 hits (out of 64). -/
example : hits 3 (ofList [0, 1, 0, 0, 2, 1, 2, 0]) = 22 := by decide

/-- A strategy that points outside its tower: `(1, 1)` on one hat has no
hit, and the left reset by `[00]` has 4 hits out of 16, not the 1 that the
formula would give.  The formula needs a proper strategy. -/
example : hits 1 (ofList [1, 1]) = 0 := by decide
example : hits 2 (lr 1 (ofList [1, 1]) (ofList [0, 0])) = 4 := by decide

end Hats
