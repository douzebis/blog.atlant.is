-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Rosary.Basic

/-! # Fact 1 -/

namespace Rosary

/-! ## Part 1: up is injective and its image is the set of white beads -/

/-- `(2j-1)U = 3j-1`. -/
theorem up_odd (j : Nat) (hj : 1 ≤ j) : up (2 * j - 1) = 3 * j - 1 := by rosary

/-- `(2j)U = 3j`. -/
theorem up_even (j : Nat) : up (2 * j) = 3 * j := by rosary

/-- `U` is injective. -/
theorem up_injective (m n : Nat) (h : up m = up n) : m = n := by rosary

/-- An up move from a bead leads to a white bead. -/
theorem up_white (n : Nat) (hn : 1 ≤ n) : 1 ≤ up n ∧ White (up n) := by rosary

/-- Every white bead `n` is reached by an up move, from the bead `nλ`:
`nλU = n`. -/
theorem lam_up (n : Nat) (hn : 1 ≤ n) (hw : White n) :
    1 ≤ lam n ∧ up (lam n) = n := by rosary

/-- `nUλ = n` for every `n`. -/
theorem up_lam (n : Nat) : lam (up n) = n := by rosary

/-- A black bead can never be reached by an up move. -/
theorem black_not_up (b n : Nat) (hb : Black b) : up n ≠ b := by rosary

/-! ## Part 2: the beads that go down to `n` are `nμ` (even) and `nν` (odd) -/

theorem down_eq_iff (m n : Nat) : down m = n ↔ m = mu n ∨ m = nu n := by rosary

theorem mu_even (n : Nat) : mu n % 2 = 0 := by rosary

theorem nu_odd (n : Nat) : nu n % 2 = 1 := by rosary

theorem mu_down (n : Nat) : down (mu n) = n := by rosary

theorem nu_down (n : Nat) : down (nu n) = n := by rosary

end Rosary
