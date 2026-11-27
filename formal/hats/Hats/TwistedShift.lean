-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Dual

/-!
# The twisted double shift

A second operation that adds two hats and gains `6` hits, found on
2026-11-27 through the best strategies on five hats.  It plays `s` on the
`n` lowest hats, with two exceptions:

* seeing `n` black hats with a white hat just above them, it points at the
  top hat, at position `n + 1`;
* seeing `n` hats of a single color with a black hat just above them and a
  white hat at the top, it points at position `n`.

The proof of `hits_tds` goes through a black reset.  Let `b` be the
strategy on two hats that points at the top hat when the bottom hat is
white, and at the bottom hat otherwise: it has `5` hits.  The black reset
of `s` by `b` has `16 * hits s + 5` hits.  Make it point at position `n`
for the stack of `n` white hats under a black one and a white one: this
gains one hit (`hits_update`).  The result is the twisted double shift,
except for what it does when it sees the all-black stack, which does not
matter.
-/

namespace Hats

open Finset

/-- `s` (a strategy on `n` hats) twisted-double-shifted. -/
def tds (n : ℕ) (s : ℕ → ℤ) : ℕ → ℤ := fun t =>
  if t % 2 ^ n = 2 ^ n - 1 ∧ t / 2 ^ n % 2 = 0 then n + 1
  else if (t % 2 ^ n = 0 ∨ t % 2 ^ n = 2 ^ n - 1) ∧ t / 2 ^ n % 4 = 1 then n
  else s (t % 2 ^ n)

/-- On two hats: point at the top hat when the bottom hat is white, at the
bottom hat when it is black.  Its word is `1010`. -/
def topIfWhite : ℕ → ℤ := fun x => if x = 0 ∨ x = 2 then 1 else 0

theorem topIfWhite_proper : Proper 2 topIfWhite := by
  intro t _
  unfold topIfWhite
  split_ifs <;> constructor <;> norm_num

theorem hits_topIfWhite : hits 2 topIfWhite = 5 := by decide

/-- The colors of the stack of `n` white hats under a black one. -/
theorem hat_two_pow (n : ℕ) (p : ℤ) : hat (2 ^ n) p = if p = n then 1 else 0 := by
  by_cases hp : 0 ≤ p
  · obtain ⟨q, rfl⟩ := Int.eq_ofNat_of_zero_le hp
    by_cases h : q = n
    · subst h; simp [hat]
    · have h' : ¬ n = q := fun e => h e.symm
      have h'' : ¬ (q : ℤ) = (n : ℤ) := by exact_mod_cast h
      simp [hat, h', h'']
  · have : ¬ p = (n : ℤ) := by omega
    simp [hat, hp, this]

/-- The black reset by `topIfWhite`, with one more choice changed. -/
private def step (n : ℕ) (s : ℕ → ℤ) : ℕ → ℤ := fun t =>
  if t = 2 ^ n then n else rr n s topIfWhite t

/-- **Win rate after a twisted double shift**, as a count of hits:
`16 * hits s + 6`, as for the double shift. -/
theorem hits_tds {n : ℕ} {s : ℕ → ℤ} (hs : Proper n s) :
    hits (n + 2) (tds n s) = 16 * hits n s + 6 := by
  have hn := hs.pos
  have hP : 2 ≤ 2 ^ n := by
    have : 2 ^ 1 ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hn
    simpa using this
  have hR : 2 ^ (n + 2) = 2 ^ n * 4 := by rw [pow_add]; norm_num
  have hs0 := hs 0 (Nat.two_pow_pos n)
  have hk : 2 ^ n < 2 ^ (n + 2) := by omega
  -- the black reset, on the stack `2 ^ n * q + r`
  have v0 : ∀ q r, r < 2 ^ n → rr n s topIfWhite (2 ^ n * q + r)
      = if r = 2 ^ n - 1 then (n : ℤ) + topIfWhite q else s r := fun q r hr =>
    rr_apply n s topIfWhite q hr
  have vk0 : rr n s topIfWhite (2 ^ n) = s 0 := by
    have h := v0 1 0 (by omega)
    have h2 : (0 : ℕ) ≠ 2 ^ n - 1 := by omega
    simpa [h2] using h
  have hagree : ∀ t, t ≠ 2 ^ n → rr n s topIfWhite t = step n s t := by
    intro t ht; simp [step, ht]
  have vk1 : step n s (2 ^ n) = (n : ℤ) := by simp [step]
  -- the row of the stack `2 ^ n`, before the change
  have row0 : ∑ t ∈ range (2 ^ (n + 2)), pair (rr n s topIfWhite) t (2 ^ n) = 2 := by
    rw [hR, sum_range_mul]
    have term : ∀ q ∈ range 4, ∀ r ∈ range (2 ^ n),
        pair (rr n s topIfWhite) (2 ^ n * q + r) (2 ^ n)
          = if r = 2 ^ n - 1 ∧ (q = 1 ∨ q = 3) then 1 else 0 := by
      intro q hq r hr
      have hr' := mem_range.mp hr
      have hq' : q < 4 := mem_range.mp hq
      unfold pair
      rw [vk0, v0 q r hr', hat_low q hr' hs0.1 hs0.2, hat_two_pow]
      by_cases h : r = 2 ^ n - 1
      · subst h
        rw [hat_ones hs0.1 hs0.2]
        interval_cases q <;> simp [topIfWhite]
      · have := hs r hr'
        have hne : ¬ s r = (n : ℤ) := by omega
        simp [h, hne]
    rw [sum_congr rfl fun q hq => sum_congr rfl fun r hr => term q hq r hr]
    have hW : 2 ^ n - 1 ∈ range (2 ^ n) := mem_range.mpr (by omega)
    simp [sum_range_succ]
  -- the row of the stack `2 ^ n`, after the change
  have row1 : ∑ t ∈ range (2 ^ (n + 2)), pair (step n s) t (2 ^ n) = 3 := by
    rw [hR, sum_range_mul]
    have term : ∀ q ∈ range 4, ∀ r ∈ range (2 ^ n),
        pair (step n s) (2 ^ n * q + r) (2 ^ n)
          = (if q = 1 ∧ r = 0 then 1 else 0)
            + (if r = 2 ^ n - 1 ∧ (q = 1 ∨ q = 3) then 1 else 0) := by
      intro q hq r hr
      have hr' := mem_range.mp hr
      have hq' : q < 4 := mem_range.mp hq
      unfold pair
      have hA : hat (2 ^ n * q + r) (n : ℤ) = hat q 0 := by
        have := hat_above q hr' (p := 0) le_rfl
        simpa using this
      rw [vk1, hA, hat_two_pow]
      by_cases hkk : 2 ^ n * q + r = 2 ^ n
      · have hq1 : q = 1 ∧ r = 0 := by
          interval_cases q <;> omega
        obtain ⟨rfl, rfl⟩ := hq1
        have h2 : (0 : ℕ) ≠ 2 ^ n - 1 := by omega
        have e : 2 ^ n * 1 + 0 = 2 ^ n := by ring
        rw [e, vk1]
        simp [hat, h2]
      · rw [← hagree _ hkk, v0 q r hr']
        have hnot : ¬ (q = 1 ∧ r = 0) := by
          rintro ⟨rfl, rfl⟩; exact hkk (by ring)
        by_cases h : r = 2 ^ n - 1
        · subst h
          have hne0 : 2 ^ n - 1 ≠ 0 := by omega
          interval_cases q <;> simp [topIfWhite, hat, hne0]
        · have := hs r hr'
          have hne : ¬ s r = (n : ℤ) := by omega
          simp [h, hne, hnot]
    rw [sum_congr rfl fun q hq => sum_congr rfl fun r hr => term q hq r hr]
    have hW : 2 ^ n - 1 ∈ range (2 ^ n) := mem_range.mpr (by omega)
    have h0 : 0 ∈ range (2 ^ n) := mem_range.mpr (by omega)
    simp [sum_range_succ, sum_add_distrib]
  -- the pair of that stack with itself
  have d0 : pair (rr n s topIfWhite) (2 ^ n) (2 ^ n) = 0 := by
    unfold pair
    rw [vk0, hat_two_pow]
    have : ¬ s 0 = (n : ℤ) := by omega
    simp [this]
  have d1 : pair (step n s) (2 ^ n) (2 ^ n) = 1 := by
    unfold pair
    rw [vk1, hat_two_pow]
    simp
  have upd := hits_update hk hagree
  rw [row0, row1, d0, d1] at upd
  have e0 := hits_rr hs topIfWhite_proper
  rw [hits_topIfWhite] at e0
  -- the twisted double shift and `step` only differ for the all-black stack
  have pstep : Proper (n + 2) (step n s) := by
    intro t _
    have := hs _ (Nat.mod_lt t (Nat.two_pow_pos n))
    unfold step rr topIfWhite
    split_ifs <;> constructor <;> push_cast <;> omega
  have ptds : Proper (n + 2) (tds n s) := by
    intro t _
    have := hs _ (Nat.mod_lt t (Nat.two_pow_pos n))
    unfold tds
    split_ifs <;> constructor <;> push_cast <;> omega
  have same : hits (n + 2) (tds n s) = hits (n + 2) (step n s) := by
    refine hits_congr_black ptds pstep fun t ht => ?_
    have hdm := Nat.div_add_mod t (2 ^ n)
    have hr := Nat.mod_lt t (Nat.two_pow_pos n)
    have hq : t / 2 ^ n < 4 := by
      rw [Nat.div_lt_iff_lt_mul (Nat.two_pow_pos n)]; omega
    have hne0 : (0 : ℕ) ≠ 2 ^ n - 1 := by omega
    -- the two strategies, by the hats above (`q`) and the hats below (`r`)
    have hk' : t = 2 ^ n ↔ t / 2 ^ n = 1 ∧ t % 2 ^ n = 0 := by
      constructor
      · intro h
        have h1 : t / 2 ^ n = 1 := by rw [h]; exact Nat.div_self (Nat.two_pow_pos n)
        have h2 : t % 2 ^ n = 0 := by rw [h]; exact Nat.mod_self _
        exact ⟨h1, h2⟩
      · rintro ⟨h1, h2⟩
        rw [h1, h2] at hdm
        omega
    have hall : ¬ (t / 2 ^ n = 3 ∧ t % 2 ^ n = 2 ^ n - 1) := by
      rintro ⟨h1, h2⟩
      rw [h1, h2] at hdm
      omega
    unfold tds step rr
    simp only [hk']
    generalize t / 2 ^ n = q at *
    generalize t % 2 ^ n = r at *
    by_cases h1 : r = 2 ^ n - 1
    · subst h1
      interval_cases q <;> simp_all [topIfWhite]
    · by_cases h2 : r = 0
      · interval_cases q <;> simp [h2, hne0]
      · simp [h1, h2]
  omega

theorem tds_proper {n : ℕ} {s : ℕ → ℤ} (hs : Proper n s) : Proper (n + 2) (tds n s) := by
  intro t _
  have := hs _ (Nat.mod_lt t (Nat.two_pow_pos n))
  unfold tds
  split_ifs <;> constructor <;> push_cast <;> omega

end Hats
