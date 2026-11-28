-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Dual
import Hats.Reset2

/-!
# Two remarks of Section 3 of the article

* `rr_eq_dual_lr`: the black reset is the dual of the white reset of the
  duals.
* `hits_dr_nestings`: the two ways to nest double resets differ by
  `12 * (hits c - 4 ^ (k - 1))` hits, written without subtraction.
-/

namespace Hats

/-- The hats above the lowest ones, with the colors exchanged. -/
theorem flip_div (a b : ℕ) {t : ℕ} (ht : t < 2 ^ (a + b)) :
    flip (a + b) t / 2 ^ a = flip b (t / 2 ^ a) := by
  have hP := Nat.two_pow_pos a
  have hq : t / 2 ^ a < 2 ^ b := by
    rw [Nat.div_lt_iff_lt_mul hP, mul_comm, ← pow_add]
    exact ht
  have hr := Nat.mod_lt t hP
  have ht' := Nat.div_add_mod t (2 ^ a)
  have e : 2 ^ (a + b) - 1 - t
      = 2 ^ a * (2 ^ b - 1 - t / 2 ^ a) + (2 ^ a - 1 - t % 2 ^ a) := by
    have h1 : 2 ^ (a + b) = 2 ^ a * (2 ^ b - 1 - t / 2 ^ a) + 2 ^ a * (t / 2 ^ a) + 2 ^ a := by
      rw [pow_add, ← Nat.mul_add, ← Nat.mul_succ]
      congr 1
      omega
    omega
  have z : (2 ^ a - 1 - t % 2 ^ a) / 2 ^ a = 0 := Nat.div_eq_of_lt (by omega)
  unfold flip
  rw [e, Nat.mul_add_div hP, z, add_zero]

/-- **The black reset is the dual of the white reset of the duals.** -/
theorem rr_eq_dual_lr (m n : ℕ) (a b : ℕ → ℤ) {t : ℕ} (ht : t < 2 ^ (m + n)) :
    rr m a b t = dual (m + n) (lr m (dual m a) (dual n b)) t := by
  have hP := Nat.two_pow_pos m
  have hr := Nat.mod_lt t hP
  have hq : t / 2 ^ m < 2 ^ n := by
    rw [Nat.div_lt_iff_lt_mul hP, mul_comm, ← pow_add]
    exact ht
  have e : flip m (t % 2 ^ m) = 0 ↔ t % 2 ^ m = 2 ^ m - 1 := by
    unfold flip; omega
  simp only [rr, dual, lr, flip_mod m n ht, flip_div m n ht, flip_flip hr, flip_flip hq, e]

/-- **The two nestings of double resets.** -/
theorem hits_dr_nestings {m n k : ℕ} {a b c : ℕ → ℤ} (ha : Proper m a) (hb : Proper n b)
    (hc : Proper k c) :
    hits (m + (n + k)) (dr m a (dr n b c)) + 3 * 4 ^ k
      = hits (m + n + k) (dr (m + n) (dr m a b) c) + 12 * hits k c := by
  have h1 := hits_dr ha hb
  have h2 := hits_dr (dr_proper ha hb) hc
  have h3 := hits_dr hb hc
  have h4 := hits_dr ha (dr_proper hb hc)
  zify at h1 h2 h3 h4 ⊢
  rw [pow_add] at h4
  linear_combination h4 - h2 + 4 * h3 - (4 : ℤ) ^ k * h1

end Hats
