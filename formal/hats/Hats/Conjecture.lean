-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Instances
import Hats.SearchRun
import Hats.Rates

/-!
# Around the conjecture `V = 7 / 20`

* `conjecture_iff` (Proposition 12 of the article): no strategy on any
  number of hats has a win rate above `7 / 20` if and only if, on every
  number of hats, the best score is that of the Carter strategy.
* `hits_sub_le`, `hits_sub_two_le`, `hits_sub_three_le` (Proposition 13):
  putting `s` in the place of the bottom hat of a strategy on `k + 1` hats
  gains at most `best (k + 1) - 4 ^ k`: at most `1` for one hat added, `6`
  for two.
* `tendsto_rate_drChain`, `tendsto_rate_drChain_carterOdd` (Proposition
  15): a proper strategy `a` on `n ≥ 2` hats, double-reset by itself again
  and again, has win rates that tend to `(hits a - 1) / (4 ^ n - 4)`;
  for the Carter strategy on an odd number of hats, at least three, this is
  `7 / 20`.
-/

namespace Hats

open Filter Topology

/-- **The conjecture, one number of hats at a time.** -/
theorem conjecture_iff :
    (∀ n, 1 ≤ n → ∀ s : ℕ → ℤ, rate n s ≤ 7 / 20) ↔ ∀ n, 1 ≤ n → best n = 7 * 4 ^ n / 20 := by
  constructor
  · intro h n hn
    obtain ⟨s, hs⟩ := exists_hits_eq_best n
    have h1 := h n hn s
    unfold rate at h1
    rw [hs, div_le_iff₀ (by positivity)] at h1
    have h2 : (20 : ℝ) * best n ≤ 7 * 4 ^ n := by linarith
    have h3 : 20 * best n ≤ 7 * 4 ^ n := by exact_mod_cast h2
    have lo : 7 * 4 ^ n / 20 ≤ best n := by
      rw [← hits_carter hn]; exact hits_le_best hn _
    have hi : best n ≤ 7 * 4 ^ n / 20 := by omega
    omega
  · intro h n hn s
    have h1 := hits_le_best hn s
    rw [h n hn] at h1
    have h2 : 20 * hits n s ≤ 7 * 4 ^ n := by omega
    have h3 : (20 : ℝ) * hits n s ≤ 7 * 4 ^ n := by exact_mod_cast h2
    unfold rate
    rw [div_le_iff₀ (by positivity)]
    linarith

/-- The gain of a substitution is at most the best score on `k + 1` hats
less `4 ^ k`. -/
theorem hits_sub_le {n k : ℕ} {m s : ℕ → ℤ} (hs : Proper n s) (hm : Proper (k + 1) m) :
    hits (n + k) (sub n m s) + 4 ^ k ≤ 4 ^ k * hits n s + best (k + 1) := by
  have h := hits_sub hs hm
  have b := hits_le_best (by omega : 1 ≤ k + 1) m
  omega

/-- One hat added: a gain of at most `1`. -/
theorem hits_sub_two_le {n : ℕ} {m s : ℕ → ℤ} (hs : Proper n s) (hm : Proper 2 m) :
    hits (n + 1) (sub n m s) ≤ 4 * hits n s + 1 := by
  have h := hits_sub_le (k := 1) hs hm
  rw [best_two] at h
  omega

/-- Two hats added: a gain of at most `6`. -/
theorem hits_sub_three_le {n : ℕ} {m s : ℕ → ℤ} (hs : Proper n s) (hm : Proper 3 m) :
    hits (n + 2) (sub n m s) ≤ 16 * hits n s + 6 := by
  have h := hits_sub_le (k := 2) hs hm
  rw [best_three] at h
  omega

/-! ### Double resets again and again -/

/-- `a` double-reset by itself `j` times: a strategy on `n * (j + 1)` hats. -/
def drChain (n : ℕ) (a : ℕ → ℤ) : ℕ → ℕ → ℤ
  | 0 => a
  | j + 1 => dr n a (drChain n a j)

section

variable {n : ℕ} {a : ℕ → ℤ} (ha : Proper n a)
include ha

theorem drChain_proper : ∀ j, Proper (n * (j + 1)) (drChain n a j)
  | 0 => by simpa [drChain] using ha
  | j + 1 => by
    have h := dr_proper ha (drChain_proper j)
    rw [show n * (j + 1 + 1) = n + n * (j + 1) by ring]
    exact h

theorem hits_drChain (j : ℕ) :
    hits (n * (j + 2)) (drChain n a (j + 1)) + 4 ^ (n * (j + 1))
      = 4 ^ (n * (j + 1)) * hits n a + 4 * hits (n * (j + 1)) (drChain n a j) := by
  have h := hits_dr ha (drChain_proper ha j)
  rw [show n * (j + 2) = n + n * (j + 1) by ring]
  exact h

theorem rate_drChain_succ (j : ℕ) :
    rate (n * (j + 2)) (drChain n a (j + 1))
      = ((hits n a : ℝ) - 1) / 4 ^ n + 4 / 4 ^ n * rate (n * (j + 1)) (drChain n a j) := by
  have h := hits_drChain ha j
  have h' : (hits (n * (j + 2)) (drChain n a (j + 1)) : ℝ) + 4 ^ (n * (j + 1))
      = 4 ^ (n * (j + 1)) * (hits n a : ℝ) + 4 * (hits (n * (j + 1)) (drChain n a j) : ℝ) := by
    exact_mod_cast h
  have e : (4 : ℝ) ^ (n * (j + 2)) = 4 ^ n * 4 ^ (n * (j + 1)) := by
    rw [← pow_add]; congr 1; ring
  have p1 : (0 : ℝ) < 4 ^ n := by positivity
  have p2 : (0 : ℝ) < 4 ^ (n * (j + 1)) := by positivity
  unfold rate
  rw [e]
  field_simp
  linarith

/-- **The win rates of repeated double resets tend to
`(hits a - 1) / (4 ^ n - 4)`**, on at least two hats. -/
theorem tendsto_rate_drChain (hn : 2 ≤ n) :
    Tendsto (fun j => rate (n * (j + 1)) (drChain n a j)) atTop
      (𝓝 (((hits n a : ℝ) - 1) / (4 ^ n - 4))) := by
  have hc : (4 : ℝ) < 4 ^ n := by
    have h : 4 < 4 ^ n := by
      calc 4 = 4 ^ 1 := (pow_one 4).symm
        _ < 4 ^ n := Nat.pow_lt_pow_right (by norm_num) (by omega)
    exact_mod_cast h
  have p1 : (0 : ℝ) < 4 ^ n := by positivity
  have q0 : (0 : ℝ) ≤ 4 / 4 ^ n := by positivity
  have q1 : (4 : ℝ) / 4 ^ n < 1 := by rw [div_lt_one p1]; exact hc
  set L : ℝ := ((hits n a : ℝ) - 1) / (4 ^ n - 4) with hL
  have closed : ∀ j, rate (n * (j + 1)) (drChain n a j)
      = L + (4 / 4 ^ n) ^ j * (rate (n * 1) (drChain n a 0) - L) := by
    intro j
    induction j with
    | zero => simp
    | succ j ih =>
      rw [show j + 1 + 1 = j + 2 from rfl, rate_drChain_succ ha, ih, pow_succ]
      have hd : (4 : ℝ) ^ n - 4 ≠ 0 := by linarith
      rw [hL]
      field_simp
      ring
  have t := (tendsto_pow_atTop_nhds_zero_of_lt_one q0 q1).mul_const
    (rate (n * 1) (drChain n a 0) - L)
  have t' := t.const_add L
  simp only [zero_mul, add_zero] at t'
  exact t'.congr fun j => (closed j).symm

end

/-- **The Carter strategy on an odd number of hats, at least three,
double-reset by itself again and again, tends to `7 / 20`.** -/
theorem tendsto_rate_drChain_carterOdd (k : ℕ) (hk : 1 ≤ k) :
    Tendsto (fun j => rate ((2 * k + 1) * (j + 1)) (drChain (2 * k + 1) (carterOdd k) j)) atTop
      (𝓝 (7 / 20)) := by
  have h := tendsto_rate_drChain (carterOdd_proper k) (by omega : 2 ≤ 2 * k + 1)
  have e := hits_carterOdd k
  have e' : (5 : ℝ) * hits (2 * k + 1) (carterOdd k) + 2 = 7 * 16 ^ k := by exact_mod_cast e
  have p : (4 : ℝ) ^ (2 * k + 1) = 4 * 16 ^ k := by
    rw [pow_succ, pow_mul]; norm_num; ring
  have big : (16 : ℝ) ≤ 16 ^ k := by
    calc (16 : ℝ) = 16 ^ 1 := (pow_one _).symm
      _ ≤ 16 ^ k := pow_le_pow_right₀ (by norm_num) hk
  have v : ((hits (2 * k + 1) (carterOdd k) : ℝ) - 1) / (4 ^ (2 * k + 1) - 4) = 7 / 20 := by
    rw [p]
    have hd : (4 : ℝ) * 16 ^ k - 4 ≠ 0 := by linarith
    rw [div_eq_div_iff hd (by norm_num)]
    linarith
  rw [v] at h
  exact h

theorem carterEven_proper (k : ℕ) : Proper (2 * k + 2) (carterEven k) :=
  rs_proper (carterOdd_proper k)

/-- **The Carter strategy on an even number `n` of hats, double-reset by
itself again and again, tends to `(7 * 4 ^ n - 32) / (20 * (4 ^ n - 4))`**,
which is less than `7 / 20`. -/
theorem tendsto_rate_drChain_carterEven (k : ℕ) :
    Tendsto (fun j => rate ((2 * k + 2) * (j + 1)) (drChain (2 * k + 2) (carterEven k) j)) atTop
      (𝓝 ((7 * 4 ^ (2 * k + 2) - 32) / (20 * (4 ^ (2 * k + 2) - 4)))) := by
  have h := tendsto_rate_drChain (carterEven_proper k) (by omega : 2 ≤ 2 * k + 2)
  have e := hits_carterEven k
  have e' : (5 : ℝ) * hits (2 * k + 2) (carterEven k) + 3 = 28 * 16 ^ k := by exact_mod_cast e
  have p : (4 : ℝ) ^ (2 * k + 2) = 16 * 16 ^ k := by
    rw [pow_add, pow_mul]; norm_num; ring
  have big : (1 : ℝ) ≤ 16 ^ k := one_le_pow₀ (by norm_num)
  have v : ((hits (2 * k + 2) (carterEven k) : ℝ) - 1) / (4 ^ (2 * k + 2) - 4)
      = (7 * 4 ^ (2 * k + 2) - 32) / (20 * (4 ^ (2 * k + 2) - 4)) := by
    rw [p]
    have hd : (16 : ℝ) * 16 ^ k - 4 ≠ 0 := by linarith
    have hh : (hits (2 * k + 2) (carterEven k) : ℝ) = (28 * 16 ^ k - 3) / 5 := by linarith
    have hd2 : (20 : ℝ) * (16 * 16 ^ k - 4) ≠ 0 := by positivity
    rw [div_eq_div_iff hd hd2, hh]
    ring
  rw [v] at h
  exact h

theorem carterEven_limit_lt (n : ℕ) (hn : 2 ≤ n) :
    ((7 : ℝ) * 4 ^ n - 32) / (20 * (4 ^ n - 4)) < 7 / 20 := by
  have h : (4 : ℝ) ^ 2 ≤ 4 ^ n := pow_le_pow_right₀ (by norm_num) hn
  have hd : (0 : ℝ) < 20 * (4 ^ n - 4) := by nlinarith
  rw [div_lt_div_iff₀ hd (by norm_num)]
  nlinarith

end Hats
