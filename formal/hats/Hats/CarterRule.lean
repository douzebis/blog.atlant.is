-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Equivalent
import Hats.Families

/-!
# The Carter strategies, in words

The article tells the Carter strategy on `n` hats by a rule:

* the bottom hat seen is black: point at the lowest white hat if it is at
  an odd position, and at the bottom hat otherwise (also when there is no
  white hat);
* the bottom hat seen is white: look at the lowest black hat.  At an even
  position, point at it.  At an odd position, point at the hat just above
  it if there is one and it is black.  In every other case (also when
  there is no black hat) point at the bottom hat.

`carterOdd_rule` and `carterEven_rule`: this rule is the strategy built
with double shifts (and one more black shift for an even number of hats).
-/

namespace Hats

/-- The number of black hats at the bottom of the stack `t`, among its
`f` lowest hats: the position of the lowest white hat. -/
def ones : ℕ → ℕ → ℕ
  | 0, _ => 0
  | f + 1, t => if t % 2 = 1 then ones f (t / 2) + 1 else 0

/-- The number of white hats at the bottom: the position of the lowest
black hat. -/
def zeros : ℕ → ℕ → ℕ
  | 0, _ => 0
  | f + 1, t => if t % 2 = 0 then zeros f (t / 2) + 1 else 0

/-- The Carter strategy on `n` hats, in words. -/
def carterWords (n : ℕ) (t : ℕ) : ℤ :=
  if t % 2 = 1 then
    if ones n t < n ∧ ones n t % 2 = 1 then (ones n t : ℤ) else 0
  else if zeros n t = n then 0
  else if zeros n t % 2 = 0 then (zeros n t : ℤ)
  else if zeros n t + 1 < n ∧ t.testBit (zeros n t + 1) = true then (zeros n t : ℤ) + 1
  else 0

theorem ones_split : ∀ (m j x r : ℕ), r < 2 ^ m →
    ones (m + j) (2 ^ m * x + r) = if r = 2 ^ m - 1 then m + ones j x else ones m r
  | 0, j, x, r, hr => by
    have : r = 0 := by simpa using hr
    subst this
    simp
  | m + 1, j, x, r, hr => by
    have hP : 2 ^ (m + 1) = 2 * 2 ^ m := by rw [pow_succ]; ring
    have hpos := Nat.two_pow_pos m
    have ih := ones_split m j x (r / 2) (by omega)
    have e1 : (2 ^ (m + 1) * x + r) % 2 = r % 2 := by rw [hP, mul_assoc]; omega
    have e2 : (2 ^ (m + 1) * x + r) / 2 = 2 ^ m * x + r / 2 := by rw [hP, mul_assoc]; omega
    rw [show m + 1 + j = m + j + 1 by ring]
    simp only [ones, e1, e2, ih]
    split_ifs <;> omega

theorem zeros_split : ∀ (m j x r : ℕ), r < 2 ^ m →
    zeros (m + j) (2 ^ m * x + r) = if r = 0 then m + zeros j x else zeros m r
  | 0, j, x, r, hr => by
    have : r = 0 := by simpa using hr
    subst this
    simp
  | m + 1, j, x, r, hr => by
    have hP : 2 ^ (m + 1) = 2 * 2 ^ m := by rw [pow_succ]; ring
    have hpos := Nat.two_pow_pos m
    have ih := zeros_split m j x (r / 2) (by omega)
    have e1 : (2 ^ (m + 1) * x + r) % 2 = r % 2 := by rw [hP, mul_assoc]; omega
    have e2 : (2 ^ (m + 1) * x + r) / 2 = 2 ^ m * x + r / 2 := by rw [hP, mul_assoc]; omega
    rw [show m + 1 + j = m + j + 1 by ring]
    simp only [zeros, e1, e2, ih]
    split_ifs <;> omega

theorem ones_lt : ∀ (m r : ℕ), r < 2 ^ m → r ≠ 2 ^ m - 1 → ones m r < m
  | 0, r, hr, hne => by
    have : r = 0 := by simpa using hr
    subst this
    simp at hne
  | m + 1, r, hr, hne => by
    rw [pow_succ] at hr hne
    have hpos := Nat.two_pow_pos m
    simp only [ones]
    by_cases hodd : r % 2 = 1
    · have := ones_lt m (r / 2) (by omega) (by omega)
      simp [hodd]
      omega
    · simp [hodd]

theorem zeros_lt : ∀ (m r : ℕ), r < 2 ^ m → r ≠ 0 → zeros m r < m
  | 0, r, hr, hne => by
    have : r = 0 := by simpa using hr
    exact absurd this hne
  | m + 1, r, hr, hne => by
    rw [pow_succ] at hr
    simp only [zeros]
    by_cases heven : r % 2 = 0
    · have := zeros_lt m (r / 2) (by omega) (by omega)
      simp [heven]
      omega
    · simp [heven]

/-- The rule on `m + j` hats and on `m` hats, for a stack whose `m` lowest
hats are not of a single color, `m` being odd. -/
theorem carterWords_mixed {m j x r : ℕ} (hm : m % 2 = 1) (hj : 1 ≤ j) (hr : r < 2 ^ m)
    (h0 : r ≠ 0) (hB : r ≠ 2 ^ m - 1) :
    carterWords (m + j) (2 ^ m * x + r) = carterWords m r := by
  have hm1 : 1 ≤ m := by omega
  have e1 : (2 ^ m * x + r) % 2 = r % 2 := by
    obtain ⟨i, rfl⟩ : ∃ i, m = i + 1 := ⟨m - 1, by omega⟩
    rw [show 2 ^ (i + 1) * x = 2 * (2 ^ i * x) by rw [pow_succ]; ring]
    omega
  have ho := ones_split m j x r hr
  have hz := zeros_split m j x r hr
  simp only [hB, ↓reduceIte] at ho
  simp only [h0, ↓reduceIte] at hz
  have ol := ones_lt m r hr hB
  have zl := zeros_lt m r hr h0
  unfold carterWords
  rw [e1, ho, hz]
  by_cases hodd : r % 2 = 1
  · have c1 : ones m r < m + j := by omega
    simp [hodd, ol, c1]
  · have c1 : zeros m r ≠ m + j := by omega
    have c2 : zeros m r ≠ m := by omega
    simp only [hodd, ↓reduceIte, c1, c2]
    by_cases hq : zeros m r % 2 = 0
    · simp [hq]
    · have q1 : zeros m r + 1 < m := by omega
      have q2 : zeros m r + 1 < m + j := by omega
      have bit : (2 ^ m * x + r).testBit (zeros m r + 1) = r.testBit (zeros m r + 1) := by
        rw [Nat.testBit_two_pow_mul_add x hr]
        simp [q1]
      simp [hq, q1, q2, bit]

/-- The rule on a stack whose `m` lowest hats are all black. -/
theorem carterWords_black {m : ℕ} (hm : 1 ≤ m) (j x : ℕ) :
    carterWords (m + j) (2 ^ m * x + (2 ^ m - 1))
      = if m + ones j x < m + j ∧ (m + ones j x) % 2 = 1 then ((m + ones j x : ℕ) : ℤ)
        else 0 := by
  have hpos := Nat.two_pow_pos m
  have e1 : (2 ^ m * x + (2 ^ m - 1)) % 2 = 1 := by
    obtain ⟨i, rfl⟩ : ∃ i, m = i + 1 := ⟨m - 1, by omega⟩
    have hi := Nat.two_pow_pos i
    rw [show 2 ^ (i + 1) * x = 2 * (2 ^ i * x) by rw [pow_succ]; ring,
      show 2 ^ (i + 1) = 2 * 2 ^ i by rw [pow_succ]; ring]
    omega
  have ho := ones_split m j x (2 ^ m - 1) (by omega)
  simp only [↓reduceIte] at ho
  unfold carterWords
  rw [e1, ho]
  simp

/-- The rule on a stack whose `m` lowest hats are all white. -/
theorem carterWords_white {m : ℕ} (hm : 1 ≤ m) (j x : ℕ) :
    carterWords (m + j) (2 ^ m * x)
      = if m + zeros j x = m + j then 0
        else if (m + zeros j x) % 2 = 0 then ((m + zeros j x : ℕ) : ℤ)
        else if m + zeros j x + 1 < m + j ∧ x.testBit (zeros j x + 1) = true
          then ((m + zeros j x : ℕ) : ℤ) + 1
        else 0 := by
  have e1 : (2 ^ m * x) % 2 = 0 := by
    obtain ⟨i, rfl⟩ : ∃ i, m = i + 1 := ⟨m - 1, by omega⟩
    rw [show 2 ^ (i + 1) * x = 2 * (2 ^ i * x) by rw [pow_succ]; ring]
    omega
  have hz := zeros_split m j x 0 (Nat.two_pow_pos m)
  simp only [↓reduceIte, add_zero] at hz
  have bit : (2 ^ m * x).testBit (m + zeros j x + 1) = x.testBit (zeros j x + 1) := by
    rw [Nat.testBit_two_pow_mul]
    have : m ≤ m + zeros j x + 1 := by omega
    simp [this, show m + zeros j x + 1 - m = zeros j x + 1 by omega]
  unfold carterWords
  rw [e1, hz, bit]
  simp

theorem carterWords_all_black {m : ℕ} (hm : 1 ≤ m) : carterWords m (2 ^ m - 1) = 0 := by
  have h := carterWords_black hm 0 0
  simpa [ones] using h

theorem carterWords_all_white {m : ℕ} (hm : 1 ≤ m) : carterWords m 0 = 0 := by
  have h := carterWords_white hm 0 0
  simpa [zeros] using h

/-! Small cases, for the hats added on top. -/

theorem ones_two : ones 2 0 = 0 ∧ ones 2 1 = 1 ∧ ones 2 2 = 0 ∧ ones 2 3 = 2 := by decide
theorem zeros_two : zeros 2 0 = 2 ∧ zeros 2 1 = 0 ∧ zeros 2 2 = 1 ∧ zeros 2 3 = 0 := by decide
theorem ones_one : ones 1 0 = 0 ∧ ones 1 1 = 1 := by decide
theorem zeros_one : zeros 1 0 = 1 ∧ zeros 1 1 = 0 := by decide

/-- **The Carter strategy on an odd number of hats is the rule in words.** -/
theorem carterOdd_words : ∀ (k t : ℕ), t < 2 ^ (2 * k + 1) → carterOdd k t = carterWords (2 * k + 1) t
  | 0, t, ht => by
    have : t = 0 ∨ t = 1 := by simp at ht; omega
    rcases this with rfl | rfl <;> simp [carterOdd, one, carterWords, ones, zeros]
  | k + 1, t, ht => by
    have hm1 : 1 ≤ 2 * k + 1 := by omega
    have hmodd : (2 * k + 1) % 2 = 1 := by omega
    have hpos := Nat.two_pow_pos (2 * k + 1)
    have hr : t % 2 ^ (2 * k + 1) < 2 ^ (2 * k + 1) := Nat.mod_lt _ hpos
    have hx : t / 2 ^ (2 * k + 1) < 4 := by
      rw [Nat.div_lt_iff_lt_mul hpos]
      rw [show 2 * (k + 1) + 1 = 2 * k + 1 + 2 by ring, pow_add] at ht
      omega
    have ht' : t = 2 ^ (2 * k + 1) * (2 * (t / 2 ^ (2 * k + 1) / 2) + t / 2 ^ (2 * k + 1) % 2)
        + t % 2 ^ (2 * k + 1) := by
      have := Nat.div_add_mod t (2 ^ (2 * k + 1))
      have h2 := Nat.div_add_mod (t / 2 ^ (2 * k + 1)) 2
      rw [h2]; omega
    have ih : ∀ r, r < 2 ^ (2 * k + 1) → carterOdd k r = carterWords (2 * k + 1) r :=
      fun r hr => carterOdd_words k r hr
    generalize t % 2 ^ (2 * k + 1) = r at *
    generalize t / 2 ^ (2 * k + 1) = x at *
    have ha : x / 2 < 2 := by omega
    have hb : x % 2 < 2 := by omega
    rw [show 2 * (k + 1) + 1 = 2 * k + 1 + 2 by ring, ht',
      show carterOdd (k + 1) = ds (2 * k + 1) (carterOdd k) from rfl,
      ds_apply hm1 (carterOdd k) ha hb hr]
    have hx' : 2 * (x / 2) + x % 2 = x := by omega
    rw [hx']
    by_cases hB : r = 2 ^ (2 * k + 1) - 1
    · subst hB
      rw [carterWords_black hm1, ih _ hr, carterWords_all_black hm1]
      have hne : ((2 : ℕ) ^ (2 * k + 1) - 1 = 0) ↔ False := by
        have : 2 ^ 1 ≤ 2 ^ (2 * k + 1) := Nat.pow_le_pow_right (by norm_num) hm1
        constructor
        · intro h; omega
        · exact False.elim
      simp only [hne, and_false, and_true, ↓reduceIte]
      obtain ⟨o0, o1, o2, o3⟩ := ones_two
      interval_cases x <;> simp [o0, o1, o2, o3]
      omega
    · by_cases h0 : r = 0
      · subst h0
        rw [add_zero, carterWords_white hm1, ih _ hr, carterWords_all_white hm1]
        have hne : ((0 : ℕ) = 2 ^ (2 * k + 1) - 1) ↔ False := by
          have : 2 ^ 1 ≤ 2 ^ (2 * k + 1) := Nat.pow_le_pow_right (by norm_num) hm1
          constructor
          · intro h; omega
          · exact False.elim
        simp only [hne, and_false, and_true, ↓reduceIte]
        obtain ⟨z0, z1, z2, z3⟩ := zeros_two
        have tb1 : Nat.testBit 1 1 = false := by decide
        have tb3 : Nat.testBit 3 1 = true := by decide
        interval_cases x <;> simp [z0, z1, z2, z3, tb1, tb3]
        omega
      · rw [carterWords_mixed hmodd (by norm_num) hr h0 hB, ih _ hr]
        simp [hB, h0]

/-- **The Carter strategy on an even number of hats is the rule in words.** -/
theorem carterEven_words (k t : ℕ) (ht : t < 2 ^ (2 * k + 2)) :
    carterEven k t = carterWords (2 * k + 2) t := by
  have hm1 : 1 ≤ 2 * k + 1 := by omega
  have hmodd : (2 * k + 1) % 2 = 1 := by omega
  have hpos := Nat.two_pow_pos (2 * k + 1)
  have hP : 2 ≤ 2 ^ (2 * k + 1) := by
    have : 2 ^ 1 ≤ 2 ^ (2 * k + 1) := Nat.pow_le_pow_right (by norm_num) hm1
    simpa using this
  have hr : t % 2 ^ (2 * k + 1) < 2 ^ (2 * k + 1) := Nat.mod_lt _ hpos
  have hx : t / 2 ^ (2 * k + 1) < 2 := by
    rw [Nat.div_lt_iff_lt_mul hpos]
    rw [show 2 * k + 2 = 2 * k + 1 + 1 by ring, pow_succ] at ht
    omega
  have hdm := Nat.div_add_mod t (2 ^ (2 * k + 1))
  have ih := carterOdd_words k (t % 2 ^ (2 * k + 1)) hr
  unfold carterEven rs
  rw [ih, show 2 * k + 2 = 2 * k + 1 + 1 by ring]
  conv_rhs => rw [← hdm]
  generalize t % 2 ^ (2 * k + 1) = r at *
  generalize t / 2 ^ (2 * k + 1) = x at *
  by_cases hB : r = 2 ^ (2 * k + 1) - 1
  · subst hB
    rw [carterWords_black hm1, carterWords_all_black hm1]
    obtain ⟨o0, o1⟩ := ones_one
    interval_cases x <;> simp [o0, o1] <;> omega
  · by_cases h0 : r = 0
    · subst h0
      rw [add_zero, carterWords_white hm1, carterWords_all_white hm1]
      obtain ⟨z0, z1⟩ := zeros_one
      interval_cases x <;> simp [z0, z1] <;> omega
    · rw [carterWords_mixed hmodd (by norm_num) hr h0 hB]
      have : t ≠ 2 ^ (2 * k + 1) - 1 := by
        intro h
        rw [h] at hdm
        interval_cases x <;> omega
      simp [this]

end Hats
