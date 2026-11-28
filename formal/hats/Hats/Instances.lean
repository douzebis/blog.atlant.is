-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Substitute
import Hats.TwistedShift

/-!
# The operations of the article are substitutions

The twisted double shift of `s` is `s` put in the place of the bottom hat
of the twisted double shift of the strategy on one hat.  With `hits_sub`
this gives a second proof of `hits_tds`.
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

end Hats
