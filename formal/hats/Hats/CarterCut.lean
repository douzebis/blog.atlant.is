-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.CarterRule

/-!
# The Carter strategies are one rule, cut to `n` hats

`carter_words`: on `n ≥ 1` hats the Carter strategy is the rule in words.

The *cut* to `k` hats of a strategy `s` on `n` hats points, for a stack
`t` of `k` hats, where `s` points for every stack of `n` hats whose `k`
lowest hats are `t`, when that is one position below `k`; and at the
bottom hat otherwise.  `carter_cut`: the cut to `k` hats of the Carter
strategy on `n` hats is the Carter strategy on `k` hats.
-/

namespace Hats

theorem ones_le : ∀ (m r : ℕ), ones m r ≤ m
  | 0, _ => by simp [ones]
  | m + 1, r => by
    have := ones_le m (r / 2)
    simp only [ones]
    split_ifs <;> omega

theorem zeros_le : ∀ (m r : ℕ), zeros m r ≤ m
  | 0, _ => by simp [zeros]
  | m + 1, r => by
    have := zeros_le m (r / 2)
    simp only [zeros]
    split_ifs <;> omega

/-- The rule points inside the stack. -/
theorem carterWords_bounds {k : ℕ} (hk : 1 ≤ k) (t : ℕ) :
    0 ≤ carterWords k t ∧ carterWords k t < k := by
  have h1 := zeros_le k t
  unfold carterWords
  split_ifs <;> constructor <;> push_cast <;> omega

/-- The Carter strategy on `n ≥ 1` hats is the rule in words. -/
theorem carter_words {n : ℕ} (hn : 1 ≤ n) {t : ℕ} (ht : t < 2 ^ n) :
    carter n t = carterWords n t := by
  unfold carter
  by_cases h : n % 2 = 1
  · simp only [h, ↓reduceIte]
    have e : n = 2 * (n / 2) + 1 := by omega
    have := carterOdd_words (n / 2) t (by rw [← e]; exact ht)
    rw [this, ← e]
  · simp only [h, ↓reduceIte]
    have e : n = 2 * (n / 2 - 1) + 2 := by omega
    have := carterEven_words (n / 2 - 1) t (by rw [← e]; exact ht)
    rw [this, ← e]

section

variable {k j t : ℕ}

/-- With white hats above, the rule on more hats is the rule on `k` hats,
for a stack that is not of a single color. -/
theorem carterWords_white_above (ht : t < 2 ^ k) (h0 : t ≠ 0) (hB : t ≠ 2 ^ k - 1) :
    carterWords (k + j) t = carterWords k t := by
  have ho := ones_split k j 0 t ht
  have hz := zeros_split k j 0 t ht
  simp only [mul_zero, zero_add, hB, h0, ↓reduceIte] at ho hz
  have ol := ones_lt k t ht hB
  have zl := zeros_lt k t ht h0
  unfold carterWords
  rw [ho, hz]
  by_cases hodd : t % 2 = 1
  · have c1 : ones k t < k + j := by omega
    simp [hodd, ol, c1]
  · have c1 : zeros k t ≠ k + j := by omega
    have c2 : zeros k t ≠ k := by omega
    simp only [hodd, ↓reduceIte, c1, c2]
    by_cases hq : zeros k t % 2 = 0
    · simp [hq]
    · by_cases hlt : zeros k t + 1 < k
      · have c3 : zeros k t + 1 < k + j := by omega
        simp [hq, hlt, c3]
      · have bit : t.testBit (zeros k t + 1) = false := by
          apply Nat.testBit_lt_two_pow
          calc t < 2 ^ k := ht
            _ ≤ 2 ^ (zeros k t + 1) := Nat.pow_le_pow_right (by norm_num) (by omega)
        simp [hq, hlt, bit]

/-- Where the rule on `k` hats does not point at the bottom hat, the hats
above do not matter. -/
theorem carterWords_determined (ht : t < 2 ^ k) (h0 : t ≠ 0) (hB : t ≠ 2 ^ k - 1)
    (hne : carterWords k t ≠ 0) (x : ℕ) :
    carterWords (k + j) (2 ^ k * x + t) = carterWords k t := by
  have hk : 1 ≤ k := by
    rcases Nat.eq_zero_or_pos k with rfl | h
    · simp at ht; omega
    · exact h
  have e1 : (2 ^ k * x + t) % 2 = t % 2 := by
    obtain ⟨i, rfl⟩ : ∃ i, k = i + 1 := ⟨k - 1, by omega⟩
    rw [show 2 ^ (i + 1) * x = 2 * (2 ^ i * x) by rw [pow_succ]; ring]
    omega
  have ho := ones_split k j x t ht
  have hz := zeros_split k j x t ht
  simp only [hB, h0, ↓reduceIte] at ho hz
  have ol := ones_lt k t ht hB
  have zl := zeros_lt k t ht h0
  unfold carterWords at hne ⊢
  rw [e1, ho, hz]
  by_cases hodd : t % 2 = 1
  · have c1 : ones k t < k + j := by omega
    simp [hodd, ol, c1]
  · have c1 : zeros k t ≠ k + j := by omega
    have c2 : zeros k t ≠ k := by omega
    simp only [hodd, ↓reduceIte, c1, c2] at hne ⊢
    by_cases hq : zeros k t % 2 = 0
    · simp [hq]
    · simp only [hq, ↓reduceIte] at hne ⊢
      by_cases hc : zeros k t + 1 < k ∧ t.testBit (zeros k t + 1) = true
      · have c3 : zeros k t + 1 < k + j := by omega
        have bit : (2 ^ k * x + t).testBit (zeros k t + 1) = t.testBit (zeros k t + 1) := by
          rw [Nat.testBit_two_pow_mul_add x ht]
          simp [hc.1]
        simp [hc, c3, bit]
      · simp [hc] at hne

end

/-- A stack of `k` black hats under white ones: the rule points at the
bottom hat or at the hat just above the black ones. -/
theorem carterWords_black_under_white {k : ℕ} (hk : 1 ≤ k) (j : ℕ) :
    carterWords (k + j) (2 ^ k - 1) = 0 ∨ (k : ℤ) ≤ carterWords (k + j) (2 ^ k - 1) := by
  have h := carterWords_black hk j 0
  simp only [mul_zero, zero_add] at h
  rw [h]
  split_ifs
  · right; push_cast; omega
  · left; rfl

/-- **The cut of a Carter strategy is a Carter strategy.**  For a stack
`t` of `k` hats: if the Carter strategy on `k + j` hats points at one
position `p < k` for every stack whose `k` lowest hats are `t`, the Carter
strategy on `k` hats points at `p`; otherwise it points at the bottom
hat. -/
theorem carter_cut {k : ℕ} (hk : 1 ≤ k) (j : ℕ) {t : ℕ} (ht : t < 2 ^ k) :
    (∃ p : ℤ, 0 ≤ p ∧ p < k ∧ (∀ x < 2 ^ j, carter (k + j) (2 ^ k * x + t) = p)
        ∧ carter k t = p)
      ∨ ((¬ ∃ p : ℤ, 0 ≤ p ∧ p < k ∧ ∀ x < 2 ^ j, carter (k + j) (2 ^ k * x + t) = p)
        ∧ carter k t = 0) := by
  have hkj : 1 ≤ k + j := by omega
  have ext : ∀ x, x < 2 ^ j → carter (k + j) (2 ^ k * x + t) = carterWords (k + j) (2 ^ k * x + t) := by
    intro x hx
    apply carter_words hkj
    rw [pow_add]
    have : 2 ^ k * x + t < 2 ^ k * (x + 1) := by rw [mul_add]; omega
    exact lt_of_lt_of_le this (Nat.mul_le_mul_left _ hx)
  have x0 : carter (k + j) (2 ^ k * 0 + t) = carterWords (k + j) t := by
    have := ext 0 (Nat.two_pow_pos j)
    simpa using this
  rw [carter_words hk ht]
  have hP : 0 < 2 ^ k := Nat.two_pow_pos k
  by_cases h : ∃ p : ℤ, 0 ≤ p ∧ p < k ∧ ∀ x < 2 ^ j, carter (k + j) (2 ^ k * x + t) = p
  · left
    obtain ⟨p, hp0, hpk, hall⟩ := h
    refine ⟨p, hp0, hpk, hall, ?_⟩
    have hx0 := hall 0 (Nat.two_pow_pos j)
    rw [x0] at hx0
    by_cases h0 : t = 0
    · subst h0
      rw [carterWords_all_white hkj] at hx0
      rw [carterWords_all_white hk, hx0]
    · by_cases hB : t = 2 ^ k - 1
      · subst hB
        rw [carterWords_all_black hk]
        rcases carterWords_black_under_white hk j with hz | hge
        · rw [hz] at hx0; exact hx0
        · rw [hx0] at hge; omega
      · rw [← hx0, carterWords_white_above ht h0 hB]
  · right
    refine ⟨h, ?_⟩
    by_contra hne
    apply h
    by_cases h0 : t = 0
    · subst h0; exact absurd (carterWords_all_white hk) hne
    · by_cases hB : t = 2 ^ k - 1
      · subst hB; exact absurd (carterWords_all_black hk) hne
      · have b := carterWords_bounds hk t
        refine ⟨carterWords k t, b.1, b.2, fun x hx => ?_⟩
        rw [ext x hx, carterWords_determined ht h0 hB hne x]

end Hats
