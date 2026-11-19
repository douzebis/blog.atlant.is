-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Rosary.Basic

/-! # Lemmas 6 and 7 (parity along an up-chain) -/

namespace Rosary

/-- **Lemma 6 (parity).**  `nUD` is black if and only if `n` and `nU` have
different parities. -/
theorem lemma6 (n : Nat) : Black (down (up n)) ↔ n % 2 ≠ up n % 2 := by rosary

/-! ## Lemma 7 -/

/-- If `n` is even then `nU = (3/2) n`. -/
theorem up_of_even (k : Nat) : up (2 * k) = 3 * k := by rosary

/-- If `n` is odd then `nU + 1 = (3/2)(n + 1)`. -/
theorem up_of_odd (k : Nat) : up (2 * k + 1) + 1 = 3 * (k + 1) := by rosary

theorem upPow_succ_left (n i : Nat) : upPow n (i + 1) = upPow (up n) i := by
  induction i with
  | zero => rfl
  | succ i ih => simp only [upPow] at *; rw [ih]

theorem upPow_add (n i j : Nat) : upPow n (i + j) = upPow (upPow n i) j := by
  induction j with
  | zero => rfl
  | succ j ih => rw [← Nat.add_assoc]; simp only [upPow]; rw [ih]

theorem upPow_pos (n i : Nat) (hn : 1 ≤ n) : 1 ≤ upPow n i := by
  induction i with
  | zero => exact hn
  | succ i ih => simp only [upPow]; rosary

theorem two_pow_succ_mul (r c : Nat) : 2 ^ (r + 1) * c = 2 * (2 ^ r * c) := by
  rw [Nat.pow_succ]; ac_rfl

/-- A power of `2` that divides `3k` divides `k`. -/
theorem two_pow_dvd_of_dvd_three_mul (r k : Nat) (h : 2 ^ r ∣ 3 * k) : 2 ^ r ∣ k := by
  induction r generalizing k with
  | zero => simp
  | succ r ih =>
    obtain ⟨c, hc⟩ := h
    rw [two_pow_succ_mul] at hc
    obtain ⟨k', rfl⟩ : ∃ k', k = 2 * k' := ⟨k / 2, by omega⟩
    obtain ⟨d, hd⟩ := ih k' ⟨c, by omega⟩
    exact ⟨d, by rw [two_pow_succ_mul]; omega⟩

/-- **Lemma 7, even case.**  `n, nU, …, nU^(r-1)` are all even if and only
if `2^r` divides `n`. -/
theorem lemma7_even (n r : Nat) :
    (∀ i, i < r → upPow n i % 2 = 0) ↔ 2 ^ r ∣ n := by
  induction r generalizing n with
  | zero => simp
  | succ r ih =>
    constructor
    · intro h
      have h0 : n % 2 = 0 := h 0 (Nat.zero_lt_succ r)
      obtain ⟨k, rfl⟩ : ∃ k, n = 2 * k := ⟨n / 2, by omega⟩
      have h' : 2 ^ r ∣ up (2 * k) := (ih _).mp fun i hi => by
        rw [← upPow_succ_left]; exact h (i + 1) (Nat.succ_lt_succ hi)
      rw [up_of_even] at h'
      obtain ⟨d, hd⟩ := two_pow_dvd_of_dvd_three_mul r k h'
      exact ⟨d, by rw [two_pow_succ_mul]; omega⟩
    · intro ⟨c, hc⟩ i hi
      rw [two_pow_succ_mul] at hc
      cases i with
      | zero => show n % 2 = _; omega
      | succ i =>
        rw [upPow_succ_left]
        refine (ih (up n)).mpr ⟨3 * c, ?_⟩ i (Nat.lt_of_succ_lt_succ hi)
        have : up n = 3 * (2 ^ r * c) := by
          rw [hc]; exact up_of_even _
        rw [this]; ac_rfl

/-- **Lemma 7, odd case.**  `n, nU, …, nU^(r-1)` are all odd if and only if
`2^r` divides `n + 1`. -/
theorem lemma7_odd (n r : Nat) :
    (∀ i, i < r → upPow n i % 2 = 1) ↔ 2 ^ r ∣ n + 1 := by
  induction r generalizing n with
  | zero => simp
  | succ r ih =>
    constructor
    · intro h
      have h0 : n % 2 = 1 := h 0 (Nat.zero_lt_succ r)
      obtain ⟨k, rfl⟩ : ∃ k, n = 2 * k + 1 := ⟨n / 2, by omega⟩
      have h' : 2 ^ r ∣ up (2 * k + 1) + 1 := (ih _).mp fun i hi => by
        rw [← upPow_succ_left]; exact h (i + 1) (Nat.succ_lt_succ hi)
      rw [up_of_odd] at h'
      obtain ⟨d, hd⟩ := two_pow_dvd_of_dvd_three_mul r (k + 1) h'
      exact ⟨d, by rw [two_pow_succ_mul]; omega⟩
    · intro ⟨c, hc⟩ i hi
      rw [two_pow_succ_mul] at hc
      cases i with
      | zero => show n % 2 = _; omega
      | succ i =>
        rw [upPow_succ_left]
        refine (ih (up n)).mpr ⟨3 * c, ?_⟩ i (Nat.lt_of_succ_lt_succ hi)
        obtain ⟨k, rfl⟩ : ∃ k, n = 2 * k + 1 := ⟨n / 2, by omega⟩
        have : up (2 * k + 1) + 1 = 3 * (2 ^ r * c) := by
          rw [up_of_odd]; omega
        rw [this]; ac_rfl

/-- **Lemma 7.**  Along the up-chain of a bead `n`, the parity changes
infinitely often: after any step `i` there is a later step `j` at which
`nU^j` and `nU^(j+1)` have different parities. -/
theorem lemma7 (n : Nat) (hn : 1 ≤ n) (i : Nat) :
    ∃ j, i ≤ j ∧ upPow n j % 2 ≠ upPow n (j + 1) % 2 := by
  -- Suppose not: from step `i` on, the parity never changes.
  apply Classical.byContradiction
  intro hno
  have hsame : ∀ k, upPow (upPow n i) k % 2 = upPow n i % 2 := by
    intro k
    induction k with
    | zero => rfl
    | succ k ih =>
      rw [← ih, ← upPow_add, ← upPow_add]
      apply Classical.byContradiction
      intro hne
      exact hno ⟨i + k, by omega, fun h => hne h.symm⟩
  -- Call `m` the bead at step `i`.
  have hm : 1 ≤ upPow n i := upPow_pos n i hn
  generalize upPow n i = m at hsame hm
  have hlt : m + 1 < 2 ^ (m + 1) := Nat.lt_two_pow_self
  by_cases hpar : m % 2 = 0
  · -- All even: every power of 2 divides `m`.
    have hd : 2 ^ (m + 1) ∣ m := (lemma7_even m (m + 1)).mp fun k _ => by
      rw [hsame]; exact hpar
    have := Nat.le_of_dvd (by omega) hd
    omega
  · -- All odd: every power of 2 divides `m + 1`.
    have hd : 2 ^ (m + 1) ∣ m + 1 := (lemma7_odd m (m + 1)).mp fun k _ => by
      rw [hsame]; omega
    have := Nat.le_of_dvd (by omega) hd
    omega

end Rosary
