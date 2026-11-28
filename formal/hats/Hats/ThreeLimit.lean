-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Three
import Mathlib.Analysis.SpecificLimits.Basic

/-!
# Three players: the win rate of repeated resets

A table `S` on `T` hats, reset by itself again and again: `iter3 T S j` is
a table on `T * (j + 1)` hats.  Its win rate tends to

  `(wins3 S - 1) / (8 ^ T - (3 * 2 ^ T + 2))`

(`tendsto_rate3`).  So every proper table on `T` hats with `W` wins gives
tables on more and more hats whose win rates come as close as wanted to
`(W - 1) / (8 ^ T - 3 * 2 ^ T - 2)`.
-/

namespace Hats

open Filter Topology

theorem reset3_proper {n k : ℕ} {S M : ℕ → ℕ → ℤ} (hS : Proper3 n S) (hM : Proper3 k M) :
    Proper3 (n + k) (reset3 n S M) := by
  intro u v hu hv
  have hpos := Nat.two_pow_pos n
  have hq : ∀ t, t < 2 ^ (n + k) → t / 2 ^ n < 2 ^ k := by
    intro t ht
    rwa [Nat.div_lt_iff_lt_mul hpos, mul_comm, ← pow_add]
  have a := hS _ _ (Nat.mod_lt u hpos) (Nat.mod_lt v hpos)
  have b := hM _ _ (hq u hu) (hq v hv)
  unfold reset3
  split_ifs <;> constructor <;> push_cast <;> omega

/-- `S` reset by itself `j` times: a table on `T * (j + 1)` hats. -/
def iter3 (T : ℕ) (S : ℕ → ℕ → ℤ) : ℕ → ℕ → ℕ → ℤ
  | 0 => S
  | j + 1 => reset3 T S (iter3 T S j)

section

variable {T : ℕ} {S : ℕ → ℕ → ℤ} (hS : Proper3 T S)
include hS

theorem iter3_proper : ∀ j, Proper3 (T * (j + 1)) (iter3 T S j)
  | 0 => by simpa [iter3] using hS
  | j + 1 => by
    have h := reset3_proper hS (iter3_proper j)
    rw [show T * (j + 1 + 1) = T + T * (j + 1) by ring]
    exact h

/-- The wins after one more reset. -/
theorem wins3_iter (j : ℕ) :
    wins3 (T * (j + 2)) (iter3 T S (j + 1)) + 8 ^ (T * (j + 1))
      = 8 ^ (T * (j + 1)) * wins3 T S
        + (3 * 2 ^ T + 2) * wins3 (T * (j + 1)) (iter3 T S j) := by
  have h := wins3_reset hS (iter3_proper hS j)
  rw [show T * (j + 2) = T + T * (j + 1) by ring]
  exact h

/-- The win rate of `S` reset by itself `j` times. -/
noncomputable def rate3 (T : ℕ) (S : ℕ → ℕ → ℤ) (j : ℕ) : ℝ :=
  (wins3 (T * (j + 1)) (iter3 T S j) : ℝ) / 8 ^ (T * (j + 1))

/-- The limit of these win rates. -/
noncomputable def limit3 (T : ℕ) (S : ℕ → ℕ → ℤ) : ℝ :=
  ((wins3 T S : ℝ) - 1) / (8 ^ T - (3 * 2 ^ T + 2))

theorem rate3_succ (j : ℕ) :
    rate3 T S (j + 1)
      = ((wins3 T S : ℝ) - 1) / 8 ^ T + (3 * 2 ^ T + 2) / 8 ^ T * rate3 T S j := by
  have h := wins3_iter hS j
  have h' : (wins3 (T * (j + 2)) (iter3 T S (j + 1)) : ℝ) + 8 ^ (T * (j + 1))
      = 8 ^ (T * (j + 1)) * (wins3 T S : ℝ)
        + (3 * 2 ^ T + 2) * (wins3 (T * (j + 1)) (iter3 T S j) : ℝ) := by
    exact_mod_cast h
  have e : (8 : ℝ) ^ (T * (j + 1 + 1)) = 8 ^ T * 8 ^ (T * (j + 1)) := by
    rw [← pow_add]; congr 1; ring
  have p1 : (0 : ℝ) < 8 ^ T := by positivity
  have p2 : (0 : ℝ) < 8 ^ (T * (j + 1)) := by positivity
  unfold rate3
  rw [e]
  field_simp
  linarith

/-- **The win rates of repeated resets tend to
`(W - 1) / (8 ^ T - 3 * 2 ^ T - 2)`**, for a proper table on at least two
hats. -/
theorem tendsto_rate3 (hT : 2 ≤ T) :
    Tendsto (rate3 T S) atTop (𝓝 (limit3 T S)) := by
  have hc : (3 * 2 ^ T + 2 : ℝ) < 8 ^ T := by
    have h : ∀ T : ℕ, 2 ≤ T → 3 * 2 ^ T + 2 < 8 ^ T := by
      intro T hT
      induction T, hT using Nat.le_induction with
      | base => norm_num
      | succ m _ ih => rw [pow_succ, pow_succ]; omega
    exact_mod_cast h T hT
  have p1 : (0 : ℝ) < 8 ^ T := by positivity
  have q0 : (0 : ℝ) ≤ (3 * 2 ^ T + 2) / 8 ^ T := by positivity
  have q1 : (3 * 2 ^ T + 2 : ℝ) / 8 ^ T < 1 := by rw [div_lt_one p1]; exact hc
  have closed : ∀ j, rate3 T S j
      = limit3 T S + ((3 * 2 ^ T + 2) / 8 ^ T) ^ j * (rate3 T S 0 - limit3 T S) := by
    intro j
    induction j with
    | zero => simp
    | succ j ih =>
      rw [rate3_succ hS, ih, pow_succ]
      have hd : (8 : ℝ) ^ T - (3 * 2 ^ T + 2) ≠ 0 := by linarith
      unfold limit3
      field_simp
      ring
  have t := (tendsto_pow_atTop_nhds_zero_of_lt_one q0 q1).mul_const
    (rate3 T S 0 - limit3 T S)
  have t' := t.const_add (limit3 T S)
  simp only [zero_mul, add_zero] at t'
  exact t'.congr fun j => (closed j).symm

end

end Hats
