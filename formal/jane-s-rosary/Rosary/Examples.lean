-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Rosary.Fast
import Rosary.Reluctant
import Rosary.Onyx
import Rosary.Address

/-!
# The examples of the paper, as tests of the definitions

Lean checks proofs, not intentions: if a definition did not say what the
paper says, every theorem would be about something else.  These lines
compute the examples that the paper gives.
-/

namespace Rosary

/-! ## Section 1: bead 8 -/

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

/-! ## Section 2: heights -/

/-- The recitation 1, 2, 3, 5, 8, 4 has five moves. -/
example : Reach 5 4 := reach_4

/-- `h(n) = 0, 1, 2, 5, 3, 6, 9, 4, 7, 10, 10` for `n = 1, …, 11`, as the
fast algorithm computes them. -/
example : [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11].map heightFast
    = [0, 1, 2, 5, 3, 6, 9, 4, 7, 10, 10] := by decide

/-- The height of bead 4 is 5 (Figure 3). -/
example : height 4 = 5 := by rw [height_eq_heightFast 4 (by decide)]; decide

/-- The height of bead 8 is 4. -/
example : height 8 = 4 := by rw [height_eq_heightFast 8 (by decide)]; decide

/-! ## Section 4: seeds and lambexes -/

example : seed 8 = 1 ∧ lambex 8 = 4 := by decide
example : seed 9 = 4 ∧ lambex 9 = 2 := by decide
example : lamPow 8 4 = 1 := by decide

/-! ## Section 5: above the black bead 4, μ wins -/

example : lambex (mu 4) = 4 ∧ lambex (nu 4) = 2 := by decide

/-- Above the black bead 10 the candidates are 20, with seed 13, and 21,
with seed 4 (Section 9). -/
example : seed (mu 10) = 13 ∧ seed (nu 10) = 4 := by decide

/-! ## Section 6: the reluctant recitation -/

/-- `ρ(0), ρ(1), … = 1, 2, 3, 5, 8, 4, 6, 9, 14, 7, 11, 17, 26, 13, …` -/
example : (List.range 14).map rho
    = [1, 2, 3, 5, 8, 4, 6, 9, 14, 7, 11, 17, 26, 13] := by decide

example : rho 5 = 4 ∧ rho 12 = 26 := by decide

/-! ## Sections 9 and 10: the onyx rosary -/

/-- The onyxes 1, 2, 3, 4 are the beads 1, 4, 7, 10. -/
example : [1, 2, 3, 4].map bullet = [1, 4, 7, 10] := by decide

/-- `𝛑(𝟒) = 𝟐` and `𝛑(𝟐) = 𝟏`. -/
example : pi 4 = 2 ∧ pi 2 = 1 := by decide

/-- The bound of Proposition 2 is attained: `𝛑(𝟏𝟎) = 𝟗`. -/
example : pi 10 = 9 := by decide

/-- The first covers of onyx 1 are 2, 5, 11, 16, and those of onyx 2 are
3, 4, 6. -/
example : [2, 5, 11, 16].map pi = [1, 1, 1, 1] ∧ [3, 4, 6].map pi = [2, 2, 2] := by
  decide

/-- The table of addresses: `𝛕(𝟏) = ()`, `𝛕(𝟐) = (1)`, …, `𝛕(𝟏𝟏) = (3)`. -/
example : [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11].map address
    = [[], [1], [1, 1], [1, 2], [2], [1, 3], [1, 1, 1], [2, 1], [2, 1, 1], [2, 1, 1, 1], [3]] := by
  decide

/-- `𝛊(𝟑𝟗) = 4`: onyx 39 is the fourth cover of onyx 5. -/
example : pi 39 = 5 ∧ rank 39 = 4 := by decide

/-- Lemma 8, the example: `↑(256) ∩ (↑(22) + 1)`.  The chain of 22 reaches
255, and `255 + 1 = 2^8`. -/
example : upPow 22 6 = 255 := by decide

end Rosary
