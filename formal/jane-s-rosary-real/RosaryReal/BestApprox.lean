-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import RosaryReal.ThreeDistance

/-!
# Best approximations and the arcs they leave

`nn α k` is the distance from `k α` to the nearest integer, written
`‖k α‖` in the paper.  A denominator `q` is a *best approximation* when
`‖q α‖ < ‖k α‖` for all `1 ≤ k < q`.  (These are the denominators of the
convergents of the continued fraction of `α`; only the property is used
here.)

For such a `q`, the three-distance theorem gives: the `q` points
`0, α, …, (q-1) α` leave arcs of two lengths only, each at most
`‖k α‖ + ‖q α‖` for every `1 ≤ k < q`.
-/

namespace ThreeDistance

variable {α : ℝ}

/-- `‖k α‖`: the distance from `k α` to the nearest integer. -/
noncomputable def nn (α : ℝ) (k : ℤ) : ℝ := min (fr α k) (1 - fr α k)

theorem nn_le_fr (k : ℤ) : nn α k ≤ fr α k := min_le_left _ _

theorem nn_le_one_sub (k : ℤ) : nn α k ≤ 1 - fr α k := min_le_right _ _

theorem nn_cases (k : ℤ) : fr α k = nn α k ∨ fr α k = 1 - nn α k := by
  unfold nn
  rcases le_total (fr α k) (1 - fr α k) with h | h
  · left; rw [min_eq_left h]
  · right; rw [min_eq_right h]; ring

/-- `‖k α‖` is at most the distance from `k α` to any integer. -/
theorem nn_le_abs (k j : ℤ) : nn α k ≤ |(k : ℝ) * α - j| := by
  have hf : fr α k = (k : ℝ) * α - ⌊(k : ℝ) * α⌋ := (Int.self_sub_floor _).symm
  rcases le_or_gt j ⌊(k : ℝ) * α⌋ with h | h
  · have : (j : ℝ) ≤ ⌊(k : ℝ) * α⌋ := by exact_mod_cast h
    calc nn α k ≤ fr α k := nn_le_fr k
      _ ≤ (k : ℝ) * α - j := by linarith
      _ ≤ _ := le_abs_self _
  · have : ((⌊(k : ℝ) * α⌋ : ℤ) : ℝ) + 1 ≤ j := by exact_mod_cast h
    calc nn α k ≤ 1 - fr α k := nn_le_one_sub k
      _ ≤ -((k : ℝ) * α - j) := by linarith
      _ ≤ _ := neg_le_abs _

/-- `‖k α‖` is the distance from `k α` to some integer. -/
theorem nn_eq_abs (k : ℤ) : ∃ j : ℤ, nn α k = |(k : ℝ) * α - j| := by
  have hf : fr α k = (k : ℝ) * α - ⌊(k : ℝ) * α⌋ := (Int.self_sub_floor _).symm
  have h0 := fr_nonneg (α := α) k
  have h1 := fr_lt_one (α := α) k
  rcases nn_cases (α := α) k with h | h
  · exact ⟨⌊(k : ℝ) * α⌋, by rw [← hf, abs_of_nonneg h0]; exact h.symm⟩
  · refine ⟨⌊(k : ℝ) * α⌋ + 1, ?_⟩
    have e : (k : ℝ) * α - ((⌊(k : ℝ) * α⌋ + 1 : ℤ) : ℝ) = -(1 - fr α k) := by
      push_cast; linarith
    rw [e, abs_neg, abs_of_nonneg (by linarith)]; linarith

/-- **The arcs left by a best approximation.**  Let `q ≥ 2` be a best
approximation.  Then every arc between the `q` points `0, α, …, (q-1) α`
has length at most `‖k α‖ + ‖q α‖`, for every `1 ≤ k < q`. -/
theorem best_approx_gaps (hα : Irrational α) (q : ℕ) (hq : 2 ≤ q)
    (hbest : ∀ k : ℕ, 1 ≤ k → k < q → nn α q < nn α k) :
    ∀ i : ℕ, i < q → ∃ j : ℕ, j < q ∧ j ≠ i ∧
      ∀ k : ℕ, 1 ≤ k → k < q → fr α ((j : ℤ) - i) ≤ nn α k + nn α q := by
  obtain ⟨a, b, ha1, haq, hb1, hbq, hsum, hA, hB, hgap⟩ := three_distance hα q hq
  have pos : ∀ k : ℕ, 1 ≤ k → 0 < fr α k := fun k hk =>
    fr_pos hα (by exact_mod_cast (by omega : k ≠ 0))
  have lt1 : ∀ k : ℕ, fr α k < 1 := fun k => fr_lt_one _
  -- `ε = ‖q α‖` is smaller than both `A` and `B`
  have hεA : nn α q < fr α a := lt_of_lt_of_le (hbest a ha1 haq) (nn_le_fr _)
  have hεB : nn α q < 1 - fr α b := lt_of_lt_of_le (hbest b hb1 hbq) (nn_le_one_sub _)
  have hAB : fr α a ≤ fr α b := hA b hb1 hbq
  have hq' := nn_cases (α := α) q
  have hApos := pos a ha1
  have hε0 : 0 ≤ nn α q := le_min (fr_nonneg _) (by linarith [lt1 q])
  -- `a + b = q`: otherwise the point `(a + b - q) α` would be too close
  have hsum' : a + b ≤ q := by
    by_contra hlt
    have h1 := hA (a + b - q) (by omega) (by omega)
    have h2 := hB (a + b - q) (by omega) (by omega)
    have h3 := lt1 (a + b - q)
    have e : ((a + b - q : ℕ) : ℤ) + (q : ℤ) = (a : ℤ) + b := by omega
    have hx := fr_add (α := α) ((a + b - q : ℕ) : ℤ) q
    rw [e] at hx
    rcases fr_add (α := α) a b with h | h <;> rcases hx with h' | h' <;>
      rcases hq' with hq' | hq' <;> linarith
  -- `B ≤ A + ε` and `A ≤ B + ε`, from the points `(q - a) α` and `(q - b) α`
  have hBA : 1 - fr α b ≤ fr α a + nn α q := by
    have h1 := hA (q - a) (by omega) (by omega)
    have h2 := hB (q - a) (by omega) (by omega)
    have h3 := lt1 (q - a)
    have h4 := pos (q - a) (by omega)
    have e : ((q - a : ℕ) : ℤ) + (a : ℤ) = q := by omega
    have hx := fr_add (α := α) ((q - a : ℕ) : ℤ) a
    rw [e] at hx
    rcases hx with h' | h' <;> rcases hq' with hq' | hq' <;> linarith
  have hAB' : fr α a ≤ 1 - fr α b + nn α q := by
    have h1 := hA (q - b) (by omega) (by omega)
    have h2 := hB (q - b) (by omega) (by omega)
    have h3 := lt1 (q - b)
    have h4 := pos (q - b) (by omega)
    have e : ((q - b : ℕ) : ℤ) + (b : ℤ) = q := by omega
    have hx := fr_add (α := α) ((q - b : ℕ) : ℤ) b
    rw [e] at hx
    rcases hx with h' | h' <;> rcases hq' with hq' | hq' <;> linarith
  -- every `‖k α‖` is at least `min A B`
  have hmin : ∀ k : ℕ, 1 ≤ k → k < q → min (fr α a) (1 - fr α b) ≤ nn α k := by
    intro k hk hkq
    have h1 := hA k hk hkq
    have h2 := hB k hk hkq
    unfold nn
    exact le_min (le_trans (min_le_left _ _) h1) (le_trans (min_le_right _ _) (by linarith))
  intro i hi
  have hg := hgap i hi
  by_cases h1 : i + a < q
  · rw [if_pos h1] at hg
    obtain ⟨j, hj, hji, hje⟩ := hg.1
    refine ⟨j, hj, hji, fun k hk hkq => ?_⟩
    have := hmin k hk hkq
    rw [← hje]
    rcases le_total (fr α a) (1 - fr α b) with h | h
    · rw [min_eq_left h] at this; linarith
    · rw [min_eq_right h] at this; linarith
  · have h2 : b ≤ i := by omega
    rw [if_neg h1, if_pos h2] at hg
    obtain ⟨j, hj, hji, hje⟩ := hg.1
    refine ⟨j, hj, hji, fun k hk hkq => ?_⟩
    have := hmin k hk hkq
    rw [← hje]
    rcases le_total (fr α a) (1 - fr α b) with h | h
    · rw [min_eq_left h] at this; linarith
    · rw [min_eq_right h] at this; linarith

end ThreeDistance
