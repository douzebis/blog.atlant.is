-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import RosaryReal.Theorem6
import RosaryReal.Theorem5b
import LogarithmExtension.LogRatioMain

/-!
# Theorem 6 without a hypothesis

`Rosary.theorem6_exponent` (in `jane-s-rosary-real`) proves Theorem 6 for
any irrationality exponent `μ₀` of `log₂ 3`, given as a hypothesis.

Rohit Kumar Jha's formalization
(`LogarithmExtension.LogRatio.Main.logRatio_approximation_bound`) proves
that for every `ε > 0`, `|log 3 / log 2 - p/q| ≥ q^(-(3+ε))` for all
large `q`.  This file bridges the two: the finitely many small `q` are
covered by the irrationality of `log₂ 3`, at the price of a constant.

The bound on `log 3 / log 2` is Jha's result, not ours.
-/

namespace Rosary

open Real

/-- For each `q ≥ 1`, the distance from `log₂ 3` to the fractions `p/q` is
bounded below. -/
theorem dist_pos (q : ℕ) (hq : 1 ≤ q) :
    ∃ d : ℝ, 0 < d ∧ ∀ p : ℤ, d ≤ |logb 2 3 - (p : ℝ) / (q : ℝ)| := by
  have hq0 : (0 : ℝ) < q := by exact_mod_cast hq
  refine ⟨|q * logb 2 3 - round ((q : ℝ) * logb 2 3)| / q, ?_, fun p => ?_⟩
  · apply div_pos _ hq0
    apply abs_pos.mpr
    intro h
    apply alpha_irrational q hq (round ((q : ℝ) * logb 2 3) - q)
    rw [logb_two_three] at h ⊢
    push_cast
    linarith
  · have e : logb 2 3 - (p : ℝ) / q = (q * logb 2 3 - p) / q := by field_simp
    rw [e, abs_div, abs_of_pos hq0]
    exact div_le_div_of_nonneg_right (round_le _ p) hq0.le

/-- Finitely many `q`: one constant for all `q < Q`. -/
theorem dist_pos_below (Q : ℕ) :
    ∃ d : ℝ, 0 < d ∧ ∀ q : ℕ, 1 ≤ q → q < Q → ∀ p : ℤ,
      d ≤ |logb 2 3 - (p : ℝ) / (q : ℝ)| := by
  induction Q with
  | zero => exact ⟨1, one_pos, fun q _ h => by omega⟩
  | succ Q ih =>
    obtain ⟨d, hd, h⟩ := ih
    by_cases hQ : 1 ≤ Q
    · obtain ⟨d', hd', h'⟩ := dist_pos Q hQ
      refine ⟨min d d', lt_min hd hd', fun q hq1 hq p => ?_⟩
      by_cases e : q = Q
      · rw [e]; exact le_trans (min_le_right _ _) (h' p)
      · exact le_trans (min_le_left _ _) (h q hq1 (by omega) p)
    · exact ⟨d, hd, fun q hq1 hq p => h q hq1 (by omega) p⟩

/-- **The bridge.**  Every `μ > 3` is an irrationality exponent of
`log₂ 3`, for some constant `c > 0`.  (From Jha's theorem.) -/
theorem irrationalityExponent_log23 (ε : ℝ) (hε : 0 < ε) :
    ∃ c : ℝ, IrrationalityExponent c (3 + ε) := by
  obtain ⟨Q, -, hQ⟩ :=
    LogarithmExtension.LogRatio.Main.logRatio_approximation_bound ε hε
  obtain ⟨d, hd, hsmall⟩ := dist_pos_below Q
  refine ⟨min 1 d, lt_min one_pos hd, fun p q hq => ?_⟩
  have hq1 : (1 : ℝ) ≤ q := by exact_mod_cast hq
  have hpow0 : 0 < (q : ℝ) ^ (-(3 + ε)) := Real.rpow_pos_of_pos (by linarith) _
  have hpow1 : (q : ℝ) ^ (-(3 + ε)) ≤ 1 :=
    Real.rpow_le_one_of_one_le_of_nonpos hq1 (by linarith)
  by_cases hbig : Q ≤ q
  · have h := hQ p q hbig
    rw [Real.log_div_log] at h
    calc min 1 d * (q : ℝ) ^ (-(3 + ε)) ≤ 1 * (q : ℝ) ^ (-(3 + ε)) :=
          mul_le_mul_of_nonneg_right (min_le_left _ _) hpow0.le
      _ = (q : ℝ) ^ (-(3 + ε)) := one_mul _
      _ ≤ _ := h
  · have h := hsmall q hq (by omega) p
    calc min 1 d * (q : ℝ) ^ (-(3 + ε)) ≤ d * 1 :=
          mul_le_mul (min_le_right _ _) hpow1 hpow0.le hd.le
      _ = d := mul_one _
      _ ≤ _ := h

/-- **Theorem 6, without a hypothesis.**  For every `ε > 0` there is a
constant `κ` such that every bead `m` is told within `κ m^(5 + 2ε)` moves. -/
theorem theorem6_log23 (ε : ℝ) (hε : 0 < ε) :
    ∃ κ : ℝ, ∀ m i : ℕ, 1 ≤ m → rho i = m → (i : ℝ) ≤ κ * (m : ℝ) ^ (5 + 2 * ε) := by
  obtain ⟨c, hc⟩ := irrationalityExponent_log23 ε hε
  obtain ⟨κ, h⟩ := theorem6_exponent c (3 + ε) (by linarith) hc
  refine ⟨κ, fun m i hm hi => ?_⟩
  have := h m i hm hi
  rwa [show 2 * (3 + ε) - 1 = 5 + 2 * ε by ring] at this

/-- **Theorem 6, the frontier, without a hypothesis.**  For every `ε > 0`
there is a `κ > 0` with `F(t) > (t/κ)^(1/(5 + 2ε))` for all `t`. -/
theorem theorem6_frontier_log23 (ε : ℝ) (hε : 0 < ε) :
    ∃ κ : ℝ, 0 < κ ∧ ∀ t : ℕ, ((t : ℝ) / κ) ^ (1 / (5 + 2 * ε)) < frontier t := by
  obtain ⟨c, hc⟩ := irrationalityExponent_log23 ε hε
  obtain ⟨κ, hκ, h⟩ := theorem6_frontier c (3 + ε) (by linarith) hc
  refine ⟨κ, hκ, fun t => ?_⟩
  have := h t
  rwa [show 2 * (3 + ε) - 1 = 5 + 2 * ε by ring] at this

/-- **Theorem 5, part 2, without a hypothesis:**
`log₂ ρ(t) ≤ 2 √t + C log t` for all `t ≥ 2`. -/
theorem theorem5_part2_log23 :
    ∃ C : ℝ, ∀ t : ℕ, 2 ≤ t → logb 2 (rho t) ≤ 2 * √t + C * Real.log t := by
  obtain ⟨c, hc⟩ := irrationalityExponent_log23 1 one_pos
  exact theorem5_part2 c (3 + 1 - 1) (by norm_num) (badly_of_exponent c (3 + 1) hc)

/-- **Theorem 5, part 3, without a hypothesis:**
`|u(t)/t - log₃ 2| ≤ C/√t` for all `t ≥ 2`. -/
theorem theorem5_part3_log23 :
    ∃ C : ℝ, ∀ t : ℕ, 2 ≤ t → |(ups t : ℝ) / t - logb 3 2| ≤ C / √t := by
  obtain ⟨c, hc⟩ := irrationalityExponent_log23 1 one_pos
  exact theorem5_part3 c (3 + 1 - 1) (by norm_num) (badly_of_exponent c (3 + 1) hc)

end Rosary

#print axioms Rosary.theorem6_frontier_log23
#print axioms Rosary.theorem5_part2_log23
#print axioms Rosary.theorem5_part3_log23
#print axioms Rosary.irrationalityExponent_log23
#print axioms Rosary.theorem6_log23
