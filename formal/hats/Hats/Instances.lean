-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Substitute
import Hats.TwistedShift

/-!
# The operations of the article are substitutions

Each operation, applied to `s`, is `s` put in the place of the bottom hat
of what the operation makes of the strategy on one hat: the two shifts,
the double shift, the twisted double shift, and the three resets by a
strategy `b`.  With `hits_sub` this gives second proofs of the hits of the
shifts, where the strategy substituted into is a fixed one on two or three
hats.
-/

namespace Hats

theorem tds_eq_sub {n : ℕ} (hn : 1 ≤ n) (s : ℕ → ℤ) (t : ℕ) :
    tds n s t = sub n (tds 1 one) s t := by
  have hP : 2 ≤ 2 ^ n := by
    have : 2 ^ 1 ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hn
    simpa using this
  have a1 : ∀ x : ℕ, (2 * x + 1) / 2 = x := by intro x; omega
  have a2 : ∀ x : ℕ, (2 * x + 1) % 2 = 1 := by intro x; omega
  unfold tds sub subPoint one
  simp only [pow_one, Nat.mul_mod_right, Nat.mul_div_cancel_left _ (show 0 < 2 by norm_num),
    a1, a2]
  generalize t / 2 ^ n = x
  generalize t % 2 ^ n = l
  split_ifs <;> simp_all <;> omega

/-- The hits of the twisted double shift, from the hits of a substitution. -/
theorem hits_tds_of_sub {n : ℕ} {s : ℕ → ℤ} (hs : Proper n s) :
    hits (n + 2) (tds n s) = 16 * hits n s + 6 := by
  have h := hits_sub (k := 2) hs (tds_proper one_proper)
  have e : hits (n + 2) (tds n s) = hits (n + 2) (sub n (tds 1 one) s) :=
    hits_congr fun t _ => tds_eq_sub hs.pos s t
  have h3 : hits 3 (tds 1 one) = 22 := by decide
  rw [h3] at h
  omega

/-- A stack, by its `n` lowest hats and the hats above. -/
theorem stack_eq_iff (n t q r : ℕ) (hr : r < 2 ^ n) :
    t = 2 ^ n * q + r ↔ t / 2 ^ n = q ∧ t % 2 ^ n = r := by
  rw [Nat.div_mod_unique (Nat.two_pow_pos n)]
  constructor
  · intro h; exact ⟨by omega, hr⟩
  · intro h; omega

section

variable {n : ℕ} (hn : 1 ≤ n) (s : ℕ → ℤ) (t : ℕ)
include hn

private theorem two_le : 2 ≤ 2 ^ n := by
  have : 2 ^ 1 ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hn
  simpa using this

/-- The left shift is a substitution. -/
theorem ls_eq_sub : ls n s t = sub n (ls 1 one) s t := by
  have hP := two_le hn
  have h1 := stack_eq_iff n t 1 0 (by omega)
  simp only [mul_one, add_zero] at h1
  unfold ls sub subPoint one
  simp only [h1, pow_one]
  generalize t / 2 ^ n = x
  generalize t % 2 ^ n = l
  split_ifs <;> simp_all

/-- The right shift is a substitution. -/
theorem rs_eq_sub : rs n s t = sub n (rs 1 one) s t := by
  have hP := two_le hn
  have h1 := stack_eq_iff n t 0 (2 ^ n - 1) (by omega)
  simp only [mul_zero, zero_add] at h1
  unfold rs sub subPoint one
  simp only [h1, pow_one]
  generalize t / 2 ^ n = x
  generalize t % 2 ^ n = l
  split_ifs <;> simp_all
  omega

end

/-- The left reset is a substitution. -/
theorem lr_eq_sub {m n : ℕ} (hm : 1 ≤ m) (a : ℕ → ℤ) {b : ℕ → ℤ} (hb : Proper n b)
    {t : ℕ} (ht : t < 2 ^ (m + n)) : lr m a b t = sub m (lr 1 one b) a t := by
  have hP := two_le hm
  have hq : t / 2 ^ m < 2 ^ n := by
    rwa [Nat.div_lt_iff_lt_mul (Nat.two_pow_pos m), mul_comm, ← pow_add]
  have hbq := hb _ hq
  have a1 : ∀ x : ℕ, (2 * x + 1) / 2 = x := by intro x; omega
  have a2 : ∀ x : ℕ, (2 * x + 1) % 2 = 1 := by intro x; omega
  unfold lr sub subPoint one
  simp only [pow_one, Nat.mul_mod_right, Nat.mul_div_cancel_left _ (show 0 < 2 by norm_num),
    a1, a2]
  generalize t / 2 ^ m = x at *
  generalize t % 2 ^ m = l
  split_ifs <;> simp_all
  omega

/-- The right reset is a substitution. -/
theorem rr_eq_sub {m n : ℕ} (hm : 1 ≤ m) (a : ℕ → ℤ) {b : ℕ → ℤ} (hb : Proper n b)
    {t : ℕ} (ht : t < 2 ^ (m + n)) : rr m a b t = sub m (rr 1 one b) a t := by
  have hP := two_le hm
  have hq : t / 2 ^ m < 2 ^ n := by
    rwa [Nat.div_lt_iff_lt_mul (Nat.two_pow_pos m), mul_comm, ← pow_add]
  have hbq := hb _ hq
  have a1 : ∀ x : ℕ, (2 * x + 1) / 2 = x := by intro x; omega
  have a2 : ∀ x : ℕ, (2 * x + 1) % 2 = 1 := by intro x; omega
  unfold rr sub subPoint one
  simp only [pow_one, Nat.mul_mod_right, Nat.mul_div_cancel_left _ (show 0 < 2 by norm_num),
    a1, a2]
  generalize t / 2 ^ m = x at *
  generalize t % 2 ^ m = l
  split_ifs <;> simp_all <;> omega

/-- The double reset is a substitution. -/
theorem dr_eq_sub {m n : ℕ} (hm : 1 ≤ m) (a : ℕ → ℤ) {b : ℕ → ℤ} (hb : Proper n b)
    {t : ℕ} (ht : t < 2 ^ (m + n)) : dr m a b t = sub m (dr 1 one b) a t := by
  have hP := two_le hm
  have hq : t / 2 ^ m < 2 ^ n := by
    rwa [Nat.div_lt_iff_lt_mul (Nat.two_pow_pos m), mul_comm, ← pow_add]
  have hbq := hb _ hq
  have a1 : ∀ x : ℕ, (2 * x + 1) / 2 = x := by intro x; omega
  have a2 : ∀ x : ℕ, (2 * x + 1) % 2 = 1 := by intro x; omega
  unfold dr sub subPoint one
  simp only [pow_one, Nat.mul_mod_right, Nat.mul_div_cancel_left _ (show 0 < 2 by norm_num),
    a1, a2]
  generalize t / 2 ^ m = x at *
  generalize t % 2 ^ m = l
  split_ifs <;> simp_all <;> omega

/-- The double shift is a substitution. -/
theorem ds_eq_sub {n : ℕ} (hn : 1 ≤ n) (s : ℕ → ℤ) (t : ℕ) :
    ds n s t = sub n (ds 1 one) s t := by
  have hP := two_le hn
  have h3 := stack_eq_iff n t 3 0 (by omega)
  have h2 := stack_eq_iff n t 2 0 (by omega)
  have e3 : 2 ^ (n + 1) + 2 ^ n = 2 ^ n * 3 + 0 := by rw [pow_succ]; ring
  have e2 : 2 ^ (n + 1) = 2 ^ n * 2 + 0 := by rw [pow_succ]; ring
  have hmm : t % 2 ^ (n + 1) % 2 ^ n = t % 2 ^ n :=
    Nat.mod_mod_of_dvd t ⟨2, by rw [pow_succ]⟩
  have hB : t % 2 ^ (n + 1) = 2 ^ n - 1 ↔ t / 2 ^ n % 2 = 0 ∧ t % 2 ^ n = 2 ^ n - 1 := by
    have hd := Nat.div_add_mod t (2 ^ n)
    have hr := Nat.mod_lt t (Nat.two_pow_pos n)
    have hd2 := Nat.div_add_mod (t / 2 ^ n) 2
    have e : t % 2 ^ (n + 1) = 2 ^ n * (t / 2 ^ n % 2) + t % 2 ^ n := by
      rw [pow_succ, Nat.mod_mul]; ring
    rw [e]
    rcases Nat.mod_two_eq_zero_or_one (t / 2 ^ n) with h | h <;> rw [h] <;> omega
  have e3' : t = 2 ^ (n + 1) + 2 ^ n ↔ t / 2 ^ n = 3 ∧ t % 2 ^ n = 0 := by rw [e3]; exact h3
  have e2' : t = 2 ^ (n + 1) ↔ t / 2 ^ n = 2 ∧ t % 2 ^ n = 0 := by rw [e2]; exact h2
  have lhs : ds n s t = if t / 2 ^ n = 3 ∧ t % 2 ^ n = 0 then (n : ℤ) + 1
      else if t / 2 ^ n = 2 ∧ t % 2 ^ n = 0 then (n : ℤ) + 1
      else if t / 2 ^ n % 2 = 0 ∧ t % 2 ^ n = 2 ^ n - 1 then (n : ℤ)
      else s (t % 2 ^ n) := by
    unfold ds ls rs
    simp only [e3', e2', hmm, hB]
    push_cast
    rfl
  have rhs : ∀ a, ds 1 one a = if a = 6 then 2 else if a = 4 then 2
      else if a % 4 = 1 then 1 else 0 := by
    intro a
    unfold ds ls rs one
    norm_num
  rw [lhs]
  unfold sub subPoint
  simp only [rhs]
  generalize t / 2 ^ n = x
  generalize t % 2 ^ n = l
  have f1 : 2 * x = 6 ↔ x = 3 := by omega
  have f2 : 2 * x = 4 ↔ x = 2 := by omega
  have f3 : ¬ 2 * x % 4 = 1 := by omega
  have f4 : ¬ 2 * x + 1 = 6 := by omega
  have f5 : ¬ 2 * x + 1 = 4 := by omega
  have f6 : (2 * x + 1) % 4 = 1 ↔ x % 2 = 0 := by omega
  simp only [f1, f2, f3, f4, f5, f6, ↓reduceIte]
  by_cases h0 : l = 0
  · by_cases h3 : x = 3
    · simp [h0, h3]
    · by_cases h2 : x = 2
      · simp [h0, h2]
      · have : (0 : ℕ) ≠ 2 ^ n - 1 := by omega
        simp [h0, h3, h2, this]
  · by_cases hB : l = 2 ^ n - 1
    · have hne : 2 ^ n - 1 ≠ 0 := by omega
      by_cases he : x % 2 = 0
      · simp [hB, he, hne]
      · simp [hB, he, hne]
    · simp [h0, hB]

/-- The hits of the two shifts and of the double shift, from the hits of a
substitution: second proofs of `hits_ls`, `hits_rs` and `hits_ds`. -/
theorem hits_ls_of_sub {n : ℕ} {s : ℕ → ℤ} (hs : Proper n s) :
    hits (n + 1) (ls n s) = 4 * hits n s + 1 := by
  have pm : Proper (1 + 1) (ls 1 one) := by
    intro t _; unfold ls one; split_ifs <;> constructor <;> norm_num
  have h := hits_sub (k := 1) hs pm
  have e : hits (n + 1) (ls n s) = hits (n + 1) (sub n (ls 1 one) s) :=
    hits_congr fun t _ => ls_eq_sub hs.pos s t
  have h2 : hits 2 (ls 1 one) = 5 := by decide
  rw [h2] at h
  omega

theorem hits_rs_of_sub {n : ℕ} {s : ℕ → ℤ} (hs : Proper n s) :
    hits (n + 1) (rs n s) = 4 * hits n s + 1 := by
  have h := hits_sub (k := 1) hs (rs_proper one_proper)
  have e : hits (n + 1) (rs n s) = hits (n + 1) (sub n (rs 1 one) s) :=
    hits_congr fun t _ => rs_eq_sub hs.pos s t
  have h2 : hits 2 (rs 1 one) = 5 := by decide
  rw [h2] at h
  omega

theorem hits_ds_of_sub {n : ℕ} {s : ℕ → ℤ} (hs : Proper n s) :
    hits (n + 2) (ds n s) = 16 * hits n s + 6 := by
  have h := hits_sub (k := 2) hs (ds_proper one_proper)
  have e : hits (n + 2) (ds n s) = hits (n + 2) (sub n (ds 1 one) s) :=
    hits_congr fun t _ => ds_eq_sub hs.pos s t
  have h3 : hits 3 (ds 1 one) = 22 := by decide
  rw [h3] at h
  omega

end Hats
