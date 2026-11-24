-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Reset
import Hats.Reset2

/-!
# The left reset and the right reset are associative

Resetting `a` by `b`, then the result by `c`, is resetting `a` by "`b`
reset by `c`".  The double reset is not associative (`Hats/Examples.lean`).
-/

namespace Hats

/-- The `m + n` lowest hats of a stack, and its `m` lowest. -/
theorem mod_mod_pow (t m n : ℕ) : t % 2 ^ (m + n) % 2 ^ m = t % 2 ^ m :=
  Nat.mod_mod_of_dvd t (pow_dvd_pow 2 (Nat.le_add_right m n))

theorem mod_div_pow (t m n : ℕ) : t % 2 ^ (m + n) / 2 ^ m = t / 2 ^ m % 2 ^ n := by
  rw [pow_add, Nat.mod_mul_right_div_self]

theorem div_div_pow (t m n : ℕ) : t / 2 ^ m / 2 ^ n = t / 2 ^ (m + n) := by
  rw [pow_add, Nat.div_div_eq_div_mul]

/-- A stack has its `m + n` lowest hats white when its `m` lowest are, and
the `n` next ones too. -/
theorem mod_pow_eq_zero (t m n : ℕ) :
    t % 2 ^ (m + n) = 0 ↔ t % 2 ^ m = 0 ∧ t / 2 ^ m % 2 ^ n = 0 := by
  have h := Nat.div_add_mod (t % 2 ^ (m + n)) (2 ^ m)
  rw [mod_mod_pow, mod_div_pow] at h
  have hpos : 0 < 2 ^ m := Nat.two_pow_pos m
  constructor
  · intro h0
    rw [h0] at h
    have h1 : t % 2 ^ m = 0 := by omega
    have h2 : 2 ^ m * (t / 2 ^ m % 2 ^ n) = 0 := by omega
    exact ⟨h1, (Nat.mul_eq_zero.mp h2).resolve_left (by omega)⟩
  · rintro ⟨h1, h2⟩
    rw [h1, h2] at h
    omega

/-- The same for black hats. -/
theorem mod_pow_eq_ones (t m n : ℕ) :
    t % 2 ^ (m + n) = 2 ^ (m + n) - 1
      ↔ t % 2 ^ m = 2 ^ m - 1 ∧ t / 2 ^ m % 2 ^ n = 2 ^ n - 1 := by
  have h := Nat.div_add_mod (t % 2 ^ (m + n)) (2 ^ m)
  rw [mod_mod_pow, mod_div_pow] at h
  have hm : 0 < 2 ^ m := Nat.two_pow_pos m
  have hn : 0 < 2 ^ n := Nat.two_pow_pos n
  have h1 : t % 2 ^ m < 2 ^ m := Nat.mod_lt _ hm
  have h2 : t / 2 ^ m % 2 ^ n < 2 ^ n := Nat.mod_lt _ hn
  have hmn : 2 ^ (m + n) = 2 ^ m * 2 ^ n := pow_add 2 m n
  constructor
  · intro h0
    rw [h0, hmn] at h
    have key : 2 ^ m * (t / 2 ^ m % 2 ^ n) + t % 2 ^ m + 1 = 2 ^ m * 2 ^ n := by
      have : 0 < 2 ^ m * 2 ^ n := Nat.mul_pos hm hn
      omega
    have hle : t / 2 ^ m % 2 ^ n + 1 ≤ 2 ^ n := h2
    have hmul : 2 ^ m * (t / 2 ^ m % 2 ^ n + 1) ≤ 2 ^ m * 2 ^ n := Nat.mul_le_mul_left _ hle
    have hq : t / 2 ^ m % 2 ^ n = 2 ^ n - 1 := by
      by_contra hne
      have hlt : t / 2 ^ m % 2 ^ n + 2 ≤ 2 ^ n := by omega
      have : 2 ^ m * (t / 2 ^ m % 2 ^ n + 2) ≤ 2 ^ m * 2 ^ n := Nat.mul_le_mul_left _ hlt
      rw [Nat.mul_add] at this hmul
      omega
    refine ⟨?_, hq⟩
    rw [hq] at key
    have : 2 ^ m * (2 ^ n - 1) + 2 ^ m = 2 ^ m * 2 ^ n := by
      rw [← Nat.mul_succ]; congr 1; omega
    omega
  · rintro ⟨e1, e2⟩
    rw [e1, e2] at h
    have : 2 ^ m * (2 ^ n - 1) + 2 ^ m = 2 ^ m * 2 ^ n := by
      rw [← Nat.mul_succ]; congr 1; omega
    omega

/-- **The left reset is associative.** -/
theorem lr_assoc (m n : ℕ) (a b c : ℕ → ℤ) :
    lr (m + n) (lr m a b) c = lr m a (lr n b c) := by
  funext t
  simp only [lr, mod_mod_pow, mod_div_pow, div_div_pow, mod_pow_eq_zero]
  by_cases h1 : t % 2 ^ m = 0 <;> by_cases h2 : t / 2 ^ m % 2 ^ n = 0 <;>
    (simp [h1, h2]; try ring)

/-- **The right reset is associative.** -/
theorem rr_assoc (m n : ℕ) (a b c : ℕ → ℤ) :
    rr (m + n) (rr m a b) c = rr m a (rr n b c) := by
  funext t
  simp only [rr, mod_mod_pow, mod_div_pow, div_div_pow, mod_pow_eq_ones]
  by_cases h1 : t % 2 ^ m = 2 ^ m - 1 <;> by_cases h2 : t / 2 ^ m % 2 ^ n = 2 ^ n - 1 <;>
    (simp [h1, h2]; try ring)

end Hats
