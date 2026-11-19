-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Rosary.Basic

/-! # Lemma 1 (commutation) -/

namespace Rosary

/-- **Lemma 1.**  Let `w` be a white bead.

1. Exactly one of `wμ`, `wν` is white.  Call it `ŵ`.  Then `ŵλD = wλ`.
2. The other one, call it `b`, is black.  Both `bμ` and `bν` are white, and
   `bμλDD = bνλDD = wλ`. -/
theorem lemma1 (w : Nat) (hw : 1 ≤ w) (hwhite : White w) :
    ∃ ŵ b : Nat,
      ((ŵ = mu w ∧ b = nu w) ∨ (ŵ = nu w ∧ b = mu w)) ∧
      White ŵ ∧ Black b ∧
      down (lam ŵ) = lam w ∧
      White (mu b) ∧ White (nu b) ∧
      down (down (lam (mu b))) = lam w ∧
      down (down (lam (nu b))) = lam w := by
  -- A white bead is `3k` or `3k + 2`: two cases, as in the paper.
  by_cases h : w % 3 = 0
  · -- `w = 3k`: the white one is `wμ`, the black one is `wν`.
    refine ⟨mu w, nu w, Or.inl ⟨rfl, rfl⟩, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> rosary
  · -- `w = 3k + 2`: the white one is `wν`, the black one is `wμ`.
    refine ⟨nu w, mu w, Or.inr ⟨rfl, rfl⟩, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩ <;> rosary

end Rosary
