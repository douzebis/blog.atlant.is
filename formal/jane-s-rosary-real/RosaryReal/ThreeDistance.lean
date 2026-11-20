-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Mathlib

/-!
# The three-distance theorem

Take an irrational `α` and mark the `N` points `0, α, 2α, …, (N-1) α` on a
circle of length 1.  They cut the circle into `N` arcs.  **The arcs have at
most three different lengths**, and when there are three, the longest is
the sum of the other two.

More precisely, let `A` be the smallest of the distances from `0` forward
to a point `k α` (`1 ≤ k < N`), reached at `k = a`, and `B` the smallest
distance backward, reached at `k = b`.  Then the arc that starts at the
point `i α` has length

- `A`, if `i + a < N` (it ends at the point `(i + a) α`);
- `B`, if `b ≤ i` (it ends at the point `(i - b) α`);
- `A + B` otherwise (it ends at the point `(i + a - b) α`).

(Conjectured by Steinhaus; proved by Sós, Świerczkowski, Surányi and
others in 1957-58.  The proof below is elementary.)
-/

namespace ThreeDistance

/-- The position of the point `d α` on the circle of length 1: the
fractional part of `d α`.  It is also the distance from `0` forward to
that point. -/
noncomputable def fr (α : ℝ) (d : ℤ) : ℝ := Int.fract ((d : ℝ) * α)

variable {α : ℝ}

theorem fr_nonneg (d : ℤ) : 0 ≤ fr α d := Int.fract_nonneg _

theorem fr_lt_one (d : ℤ) : fr α d < 1 := Int.fract_lt_one _

/-- The points are all different from the point `0`. -/
theorem fr_pos (hα : Irrational α) {d : ℤ} (hd : d ≠ 0) : 0 < fr α d := by
  rcases (fr_nonneg (α := α) d).lt_or_eq with h | h
  · exact h
  · exfalso
    have hirr : Irrational ((d : ℝ) * α) := hα.intCast_mul hd
    have e : (d : ℝ) * α = (⌊(d : ℝ) * α⌋ : ℤ) := by
      have := Int.self_sub_floor ((d : ℝ) * α)
      unfold fr at h
      linarith
    exact hirr.ne_int _ e

/-- Adding two steps: the positions add, modulo one turn. -/
theorem fr_add (d e : ℤ) :
    fr α (d + e) = fr α d + fr α e ∨ fr α (d + e) = fr α d + fr α e - 1 := by
  obtain ⟨z, hz⟩ := Int.fract_add ((d : ℝ) * α) ((e : ℝ) * α)
  have e1 : fr α (d + e) = Int.fract ((d : ℝ) * α + (e : ℝ) * α) := by
    unfold fr; push_cast; ring_nf
  have h1 := fr_nonneg (α := α) (d + e)
  have h2 := fr_lt_one (α := α) (d + e)
  have h3 := fr_nonneg (α := α) d
  have h4 := fr_lt_one (α := α) d
  have h5 := fr_nonneg (α := α) e
  have h6 := fr_lt_one (α := α) e
  rw [← e1] at hz
  change fr α (d + e) - fr α d - fr α e = z at hz
  have hz1 : (-2 : ℝ) < z := by linarith
  have hz2 : (z : ℝ) < 1 := by linarith
  have hz1' : -2 < z := by exact_mod_cast hz1
  have hz2' : z < 1 := by exact_mod_cast hz2
  have : z = 0 ∨ z = -1 := by omega
  rcases this with rfl | rfl
  · left; push_cast at hz; linarith
  · right; push_cast at hz; linarith

/-- A step backward. -/
theorem fr_neg (hα : Irrational α) {d : ℤ} (hd : d ≠ 0) : fr α (-d) = 1 - fr α d := by
  unfold fr
  rw [Int.cast_neg, neg_mul]
  exact Int.fract_neg (fr_pos hα hd).ne'

/-- Different steps lead to different points. -/
theorem fr_injective (hα : Irrational α) {d e : ℤ} (h : fr α d = fr α e) : d = e := by
  by_contra hne
  have hpos := fr_pos hα (sub_ne_zero.mpr hne)
  have hlt := fr_lt_one (α := α) (d - e)
  rcases fr_add (α := α) (d - e) e with h' | h' <;>
    (rw [sub_add_cancel] at h'; linarith)

/-- **The three-distance theorem.** -/
theorem three_distance (hα : Irrational α) (N : ℕ) (hN : 2 ≤ N) :
    ∃ a b : ℕ, 1 ≤ a ∧ a < N ∧ 1 ≤ b ∧ b < N ∧ N ≤ a + b ∧
      (∀ k : ℕ, 1 ≤ k → k < N → fr α a ≤ fr α k) ∧
      (∀ k : ℕ, 1 ≤ k → k < N → fr α k ≤ fr α b) ∧
      ∀ i : ℕ, i < N →
        IsLeast {x | ∃ j : ℕ, j < N ∧ j ≠ i ∧ x = fr α ((j : ℤ) - i)}
          (if i + a < N then fr α a
           else if b ≤ i then 1 - fr α b
           else fr α a + (1 - fr α b)) := by
  -- the closest point forward, `a α`, and the closest point backward, `b α`
  have hne : (Finset.Icc 1 (N - 1)).Nonempty := ⟨1, Finset.mem_Icc.mpr ⟨le_refl 1, by omega⟩⟩
  obtain ⟨a, ha, hmin⟩ :=
    Finset.exists_min_image (Finset.Icc 1 (N - 1)) (fun k : ℕ => fr α k) hne
  obtain ⟨b, hb, hmax⟩ :=
    Finset.exists_max_image (Finset.Icc 1 (N - 1)) (fun k : ℕ => fr α k) hne
  rw [Finset.mem_Icc] at ha hb
  have hA : ∀ k : ℕ, 1 ≤ k → k < N → fr α a ≤ fr α k := fun k h1 h2 =>
    hmin k (Finset.mem_Icc.mpr ⟨h1, by omega⟩)
  have hB : ∀ k : ℕ, 1 ≤ k → k < N → fr α k ≤ fr α b := fun k h1 h2 =>
    hmax k (Finset.mem_Icc.mpr ⟨h1, by omega⟩)
  have pos : ∀ k : ℕ, 1 ≤ k → 0 < fr α k := fun k hk =>
    fr_pos hα (by exact_mod_cast (by omega : k ≠ 0))
  have lt1 : ∀ k : ℕ, fr α k < 1 := fun k => fr_lt_one _
  -- `a + b ≥ N`: otherwise the point `(a + b) α` would be closer than one of them
  have hsum : N ≤ a + b := by
    by_contra hlt
    have h1 := hA (a + b) (by omega) (by omega)
    have h2 := hB (a + b) (by omega) (by omega)
    have := pos a ha.1
    have := lt1 b
    rcases fr_add (α := α) a b with h | h <;>
      (rw [← Nat.cast_add] at h; linarith)
  -- four comparisons, each by adding two steps
  have back1 : ∀ k : ℕ, 1 ≤ k → k + a < N → fr α a ≤ 1 - fr α k := by
    intro k hk hka
    have h1 := hA (k + a) (by omega) hka
    have := lt1 k
    rcases fr_add (α := α) k a with h | h <;>
      (rw [← Nat.cast_add] at h; have := lt1 (k + a); linarith)
  have fwd2 : ∀ k : ℕ, 1 ≤ k → k + b < N → 1 - fr α b ≤ fr α k := by
    intro k hk hkb
    have h1 := hB (k + b) (by omega) hkb
    have := pos k hk
    rcases fr_add (α := α) k b with h | h <;>
      (rw [← Nat.cast_add] at h; have := fr_nonneg (α := α) ((k + b : ℕ) : ℤ); linarith)
  have fwd3 : ∀ k : ℕ, 1 ≤ k → k < a → fr α a + (1 - fr α b) ≤ fr α k := by
    intro k hk hka
    have h1 := hA (a - k) (by omega) (by omega)
    have h2 := hB (a - k) (by omega) (by omega)
    have := pos k hk
    rcases fr_add (α := α) k ((a - k : ℕ) : ℤ) with h | h <;>
      (rw [← Nat.cast_add, show k + (a - k) = a by omega] at h; linarith)
  have back3 : ∀ k : ℕ, 1 ≤ k → k < b → fr α a + (1 - fr α b) ≤ 1 - fr α k := by
    intro k hk hkb
    have h1 := hA (b - k) (by omega) (by omega)
    have h2 := hB k hk (by omega)
    have := lt1 (b - k)
    rcases fr_add (α := α) k ((b - k : ℕ) : ℤ) with h | h <;>
      (rw [← Nat.cast_add, show k + (b - k) = b by omega] at h; linarith)
  refine ⟨a, b, ha.1, by omega, hb.1, by omega, hsum, hA, hB, fun i hi => ?_⟩
  -- the differences `j - i`, as a step forward or a step backward
  have fwd : ∀ j : ℕ, i < j → fr α ((j : ℤ) - i) = fr α ((j - i : ℕ) : ℤ) := by
    intro j hj; congr 1; omega
  have back : ∀ j : ℕ, j < i → fr α ((j : ℤ) - i) = 1 - fr α ((i - j : ℕ) : ℤ) := by
    intro j hj
    rw [← fr_neg hα (by exact_mod_cast (by omega : i - j ≠ 0))]
    congr 1; omega
  split_ifs with h1 h2
  · -- the arc from `i α` ends at `(i + a) α`
    refine ⟨⟨i + a, h1, by omega, by congr 1; push_cast; ring⟩, ?_⟩
    rintro x ⟨j, hj, hji, rfl⟩
    rcases Nat.lt_or_gt_of_ne hji with hlt | hgt
    · rw [back j hlt]; exact back1 (i - j) (by omega) (by omega)
    · rw [fwd j hgt]; exact hA (j - i) (by omega) (by omega)
  · -- the arc from `i α` ends at `(i - b) α`
    refine ⟨⟨i - b, by omega, by omega, ?_⟩, ?_⟩
    · rw [← fr_neg hα (by exact_mod_cast (by omega : b ≠ 0))]
      congr 1; omega
    · rintro x ⟨j, hj, hji, rfl⟩
      rcases Nat.lt_or_gt_of_ne hji with hlt | hgt
      · rw [back j hlt]
        have := hB (i - j) (by omega) (by omega)
        linarith
      · rw [fwd j hgt]; exact fwd2 (j - i) (by omega) (by omega)
  · -- the arc from `i α` ends at `(i + a - b) α`
    have hab : a ≠ b := by
      intro e
      rw [e] at hA
      by_cases hN3 : 3 ≤ N
      · have e1 : fr α ((1 : ℕ) : ℤ) = fr α ((2 : ℕ) : ℤ) :=
          le_antisymm (le_trans (hB 1 (le_refl 1) (by omega)) (hA 2 (by omega) (by omega)))
            (le_trans (hB 2 (by omega) (by omega)) (hA 1 (le_refl 1) (by omega)))
        have := fr_injective hα e1
        omega
      · omega
    have hmem : fr α ((a : ℤ) - b) = fr α a + (1 - fr α b) := by
      have hp := fr_pos hα (show (a : ℤ) - b ≠ 0 by omega)
      have hneg := fr_neg hα (show (b : ℤ) ≠ 0 by omega)
      have := hA b hb.1 (by omega)
      rcases fr_add (α := α) a (-(b : ℤ)) with h | h <;>
        (rw [← sub_eq_add_neg] at h; linarith)
    refine ⟨⟨i + a - b, by omega, by omega, ?_⟩, ?_⟩
    · rw [← hmem]; congr 1; omega
    · rintro x ⟨j, hj, hji, rfl⟩
      rcases Nat.lt_or_gt_of_ne hji with hlt | hgt
      · rw [back j hlt]; exact back3 (i - j) (by omega) (by omega)
      · rw [fwd j hgt]; exact fwd3 (j - i) (by omega) (by omega)

end ThreeDistance
