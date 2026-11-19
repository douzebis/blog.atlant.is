-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Rosary.Basic

/-!
# The examples of Section 1, as tests of the definitions

Lean checks proofs, not intentions: if a definition in `Basic.lean` did not
say what the paper says, every theorem would be about something else.  These
lines compute the examples that the paper gives with bead 8.
-/

namespace Rosary

example : label 8 = 4 := by decide
example : up 8 = 12 := by decide
example : down 8 = 4 := by decide
example : lam 8 = 5 := by decide
example : mu 8 = 16 := by decide
example : nu 8 = 17 := by decide
example : Black 4 := by unfold Black; decide
example : White 8 := by unfold White; decide

/-- The labels of the first beads: 1, 1, 2, 2, 3, 3. -/
example : [1, 2, 3, 4, 5, 6].map label = [1, 1, 2, 2, 3, 3] := by decide

/-- `1 UUUUD` is bead 4: four moves up, to bead 8, and one move down. -/
example : upPow 1 4 = 8 ∧ down 8 = 4 := by decide

/-- The up-chain of bead 1 starts 1, 2, 3, 5, 8, 12, 18, 27, 41. -/
example : (List.range 9).map (upPow 1) = [1, 2, 3, 5, 8, 12, 18, 27, 41] := by
  decide

end Rosary
