-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import RosaryReal.Track

/-!
# Theorem 5, part 1: the books of the rounding errors

`|u(t) log₂ 3 - t - log₂ ρ(t)| ≤ (3/2)(1 + ln t)` for `t ≥ 1`.
-/

namespace Rosary

open Real Finset

/-- The sum of the inverses of `n` different positive integers is at most
`1 + 1/2 + ⋯ + 1/n`. -/
theorem sum_inv_le (n : ℕ) : ∀ S : Finset ℕ, S.card = n → (∀ x ∈ S, 1 ≤ x) →
    ∑ x ∈ S, (1 / (x : ℝ)) ≤ ∑ i ∈ range n, 1 / ((i : ℝ) + 1) := by
  induction n with
  | zero =>
    intro S hS _
    rw [Finset.card_eq_zero.mp hS]; simp
  | succ n ih =>
    intro S hS hpos
    have hne : S.Nonempty := Finset.card_pos.mp (by omega)
    -- the largest element of `S` is at least `n + 1`
    have hM : n + 1 ≤ S.max' hne := by
      have hsub : S ⊆ Finset.Icc 1 (S.max' hne) := fun x hx =>
        Finset.mem_Icc.mpr ⟨hpos x hx, Finset.le_max' S x hx⟩
      have := Finset.card_le_card hsub
      rw [Nat.card_Icc, hS] at this
      omega
    have hmem := Finset.max'_mem S hne
    have hcard : (S.erase (S.max' hne)).card = n := by
      rw [Finset.card_erase_of_mem hmem, hS]; rfl
    have ih' := ih (S.erase (S.max' hne)) hcard
      (fun x hx => hpos x (Finset.mem_of_mem_erase hx))
    rw [← Finset.add_sum_erase S _ hmem, Finset.sum_range_succ]
    have h1 : (1 : ℝ) / (S.max' hne : ℝ) ≤ 1 / ((n : ℝ) + 1) := by
      apply one_div_le_one_div_of_le (by positivity)
      exact_mod_cast hM
    linarith

/-- `1 + 1/2 + ⋯ + 1/n ≤ 1 + ln n`. -/
theorem harmonic_bound (n : ℕ) : ∑ i ∈ range n, 1 / ((i : ℝ) + 1) ≤ 1 + Real.log n := by
  have h := harmonic_le_one_add_log n
  have e : ((harmonic n : ℚ) : ℝ) = ∑ i ∈ range n, 1 / ((i : ℝ) + 1) := by
    simp [harmonic]
  rw [← e]; exact h

/-- The sum of `1/ρ(s)` over `t` different times is at most `1 + ln t`. -/
theorem sum_inv_rho_le (t a : ℕ) :
    ∑ s ∈ range t, (1 / (rho (s + a) : ℝ)) ≤ 1 + Real.log t := by
  have hinj : Function.Injective (fun s => rho (s + a)) := fun i j h => by
    have := theorem2_injective _ _ h; omega
  have himg : ∑ x ∈ (range t).image (fun s => rho (s + a)), (1 / (x : ℝ))
      = ∑ s ∈ range t, (1 / (rho (s + a) : ℝ)) :=
    Finset.sum_image (fun i _ j _ h => hinj h)
  rw [← himg]
  refine le_trans (sum_inv_le t _ ?_ ?_) (harmonic_bound t)
  · rw [Finset.card_image_of_injective _ hinj, Finset.card_range]
  · intro x hx
    obtain ⟨s, _, rfl⟩ := Finset.mem_image.mp hx
    exact rho_pos _

/-- The rounding errors, move by move: `log₂ ρ(t) = u(t) α - (t - u(t)) + E`
with `-(3/2) Σ 1/ρ(s+1) ≤ E ≤ (1/2) Σ 1/ρ(s)`, the sums over `s < t`. -/
theorem error_bounds (t : ℕ) :
    -(3 / 2 * ∑ s ∈ range t, (1 / (rho (s + 1) : ℝ)))
        ≤ logb 2 (rho t) - ups t * alpha + (t - ups t) ∧
    logb 2 (rho t) - ups t * alpha + (t - ups t)
        ≤ 1 / 2 * ∑ s ∈ range t, (1 / (rho s : ℝ)) := by
  induction t with
  | zero => simp [rho_zero, ups]
  | succ t ih =>
    have hpos : 1 ≤ rho t := rho_pos t
    have hpos' : 1 ≤ rho (t + 1) := rho_pos (t + 1)
    have p0 : (0 : ℝ) < rho t := by exact_mod_cast hpos
    have p1 : (0 : ℝ) < rho (t + 1) := by exact_mod_cast hpos'
    have q0 : (0 : ℝ) ≤ 1 / (rho t : ℝ) := by positivity
    have q1 : (0 : ℝ) ≤ 1 / (rho (t + 1) : ℝ) := by positivity
    rw [Finset.sum_range_succ, Finset.sum_range_succ]
    rcases rho_move t with hup | ⟨_, hd⟩
    · have l := lemma5_up (rho t) hpos
      rw [← hup] at l
      rw [ups_succ_up t hup]
      have e : (1 : ℝ) / (2 * rho t) = 1 / 2 * (1 / rho t) := by field_simp
      rw [e] at l
      push_cast
      constructor <;> linarith [ih.1, ih.2, l.1, l.2]
    · have l := lemma5_down (rho t) 1 (rho (t + 1)) hpos'
        (by rw [hd, down_eq, pow_one])
      rw [ups_succ_down t hd]
      have e : (3 : ℝ) / (2 * rho (t + 1)) = 3 / 2 * (1 / rho (t + 1)) := by field_simp
      rw [e] at l
      push_cast at l ⊢
      constructor <;> linarith [ih.1, ih.2, l.1, l.2]

/-- **Theorem 5, part 1.**  For all `t ≥ 1`,
`|u(t) log₂ 3 - t - log₂ ρ(t)| ≤ (3/2)(1 + ln t)`. -/
theorem theorem5_part1 (t : ℕ) (ht : 1 ≤ t) :
    |ups t * logb 2 3 - t - logb 2 (rho t)| ≤ 3 / 2 * (1 + Real.log t) := by
  have h3 : logb 2 3 = alpha + 1 := by
    rw [alpha, show (3 : ℝ) / 2 = 3 / 2 from rfl, Real.logb_div (by norm_num) (by norm_num),
      Real.logb_self_eq_one (by norm_num)]
    ring
  have hb := error_bounds t
  have s1 := sum_inv_rho_le t 1
  have s0 : ∑ s ∈ range t, (1 / (rho s : ℝ)) ≤ 1 + Real.log t := by
    simpa using sum_inv_rho_le t 0
  have hlog : 0 ≤ Real.log t := Real.log_nonneg (by exact_mod_cast ht)
  have hs0 : 0 ≤ ∑ s ∈ range t, (1 / (rho s : ℝ)) :=
    Finset.sum_nonneg fun s _ => by positivity
  rw [h3, abs_le]
  constructor <;> linarith [hb.1, hb.2]

end Rosary
