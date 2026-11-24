-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.LimitStrategies
import Mathlib.SetTheory.Cardinal.Continuum
import Mathlib.Topology.Instances.Discrete

/-!
# Remarks of the third article on infinite stacks

How many infinite stacks and strategies there are; an infinite stack is
the limit of its lowest hats; a strategy that looks at finitely many hats
is continuous; what the limit strategies do where no finite strategy
settles.
-/

namespace Hats

open Filter Topology Cardinal

/-! ### Cardinalities -/

/-- There are as many infinite stacks as real numbers. -/
theorem mk_stack : #Stack = 𝔠 := by
  simp [Stack]

/-- There are more strategies on infinite stacks than real numbers. -/
theorem continuum_lt_mk_strategies : 𝔠 < #(Stack → ℤ) := by
  have h1 : (2 : Cardinal) ^ (#Stack) ≤ #(Stack → ℤ) := by
    have : #(Stack → Bool) ≤ #(Stack → ℤ) :=
      Cardinal.mk_le_of_injective (f := fun (f : Stack → Bool) (t : Stack) => if f t then (1 : ℤ) else 0)
        (by
          intro f g h
          funext t
          have := congrFun h t
          cases hf : f t <;> cases hg : g t <;> simp_all)
    simpa using this
  calc 𝔠 = #Stack := mk_stack.symm
    _ < 2 ^ #Stack := Cardinal.cantor _
    _ ≤ #(Stack → ℤ) := h1

/-! ### Limits of finite stacks, continuity of finite strategies -/

/-- An infinite stack cut above its `n` lowest hats (white hats above). -/
def trunc (n : ℕ) (t : Stack) : Stack := fun i => decide (i < n) && t i

/-- Every infinite stack is the limit of its finite parts. -/
theorem tendsto_trunc (t : Stack) : Tendsto (fun n => trunc n t) atTop (𝓝 t) := by
  rw [tendsto_pi_nhds]
  intro i
  refine tendsto_const_nhds.congr' ?_
  filter_upwards [eventually_gt_atTop i] with n hn
  simp [trunc, hn]

/-- The `n` lowest hats depend continuously on the stack. -/
theorem continuous_code (n : ℕ) : Continuous (code n) := by
  induction n with
  | zero => exact continuous_const
  | succ n ih =>
    have h1 : Continuous fun t : Stack => (if t n then 1 else 0 : ℕ) :=
      (continuous_of_discreteTopology (f := fun b : Bool => (if b then 1 else 0 : ℕ))).comp
        (continuous_apply n)
    exact (continuous_const.mul h1).add ih

/-- A strategy that looks at finitely many hats is continuous. -/
theorem continuous_lift (n : ℕ) (s : ℕ → ℤ) : Continuous (lift n s) :=
  (continuous_of_discreteTopology (f := s)).comp (continuous_code n)

/-! ### Where the Carter strategies do not settle -/

/-- Seeing the all-white stack, every Carter strategy points at the bottom
hat. -/
theorem carterOdd_zero (k : ℕ) : carterOdd k 0 = 0 := by
  induction k with
  | zero => rfl
  | succ k ih =>
    have h1 : (0 : ℕ) ≠ 2 ^ (2 * k + 1 + 1) + 2 ^ (2 * k + 1) := by
      have := Nat.two_pow_pos (2 * k + 1); omega
    have h2 : (0 : ℕ) ≠ 2 ^ (2 * k + 1 + 1) := by
      have := Nat.two_pow_pos (2 * k + 1 + 1); omega
    have h3 : (0 : ℕ) ≠ 2 ^ (2 * k + 1) - 1 := by
      have : 2 ^ 1 ≤ 2 ^ (2 * k + 1) := Nat.pow_le_pow_right (by norm_num) (by omega)
      omega
    simp [carterOdd, ds, ls, rs, h1, h2, h3, ih]

/-- Seeing the all-black stack too. -/
theorem carterOdd_ones (k : ℕ) : carterOdd k (2 ^ (2 * k + 1) - 1) = 0 := by
  induction k with
  | zero => rfl
  | succ k ih =>
    set n := 2 * k + 1 with hn
    have e : 2 * (k + 1) + 1 = n + 2 := by omega
    have hP : 2 ≤ 2 ^ n := by
      have : 2 ^ 1 ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) (by omega)
      simpa using this
    have hQ : 2 ^ (n + 1) = 2 * 2 ^ n := by rw [pow_succ]; ring
    have hR : 2 ^ (n + 2) = 4 * 2 ^ n := by rw [pow_succ, pow_succ]; ring
    have h1 : 2 ^ (n + 2) - 1 ≠ 2 ^ (n + 1) + 2 ^ n := by omega
    have h2 : 2 ^ (n + 2) - 1 ≠ 2 ^ (n + 1) := by omega
    have h3 : (2 ^ (n + 2) - 1) % 2 ^ (n + 1) = 2 ^ (n + 1) - 1 := by
      have : 2 ^ (n + 2) - 1 = 2 ^ (n + 1) - 1 + 2 ^ (n + 1) * 1 := by omega
      rw [this, Nat.add_mul_mod_self_left, Nat.mod_eq_of_lt (by omega)]
    have h4 : 2 ^ (n + 1) - 1 ≠ 2 ^ n - 1 := by omega
    have h5 : (2 ^ (n + 1) - 1) % 2 ^ n = 2 ^ n - 1 := by
      have : 2 ^ (n + 1) - 1 = 2 ^ n - 1 + 2 ^ n * 1 := by omega
      rw [this, Nat.add_mul_mod_self_left, Nat.mod_eq_of_lt (by omega)]
    rw [e]
    simp [carterOdd, ← hn, ds, ls, rs, h1, h2, h3, h4, h5, ih]

end Hats
