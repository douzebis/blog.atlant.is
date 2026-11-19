-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import RosaryReal.Rotation
import Rosary.Theorem3

/-!
# Following Jane's logarithm (Steps 2, 3 and 4 of the proof of Theorem 3)
-/

namespace Rosary

open Real

/-- **Step 2: Jane drifts away.**  For every `N` there is a time after
which all the beads told are larger than `N`. -/
theorem eventually_large (N : ℕ) : ∃ T, ∀ t, T ≤ t → N < rho t := by
  induction N with
  | zero => exact ⟨0, fun t _ => rho_pos t⟩
  | succ N ih =>
    obtain ⟨T, hT⟩ := ih
    by_cases h : ∃ t0, rho t0 = N + 1
    · obtain ⟨t0, ht0⟩ := h
      refine ⟨max T (t0 + 1), fun t ht => ?_⟩
      have h1 := hT t (le_trans (le_max_left _ _) ht)
      have h2 : rho t ≠ N + 1 := fun e => by
        have := theorem2_injective t t0 (e.trans ht0.symm)
        have := le_trans (le_max_right T (t0 + 1)) ht
        omega
      omega
    · refine ⟨T, fun t ht => ?_⟩
      have h1 := hT t ht
      have h2 : rho t ≠ N + 1 := fun e => h ⟨t, e⟩
      omega

/-- **Step 3: Jane makes infinitely many up moves.** -/
theorem exists_up (t : ℕ) : ∃ t', t ≤ t' ∧ rho (t' + 1) = up (rho t') := by
  by_contra hno
  have hdown : ∀ s, rho (t + s) + s ≤ rho t := by
    intro s
    induction s with
    | zero => simp
    | succ s ih =>
      rcases rho_move (t + s) with hup | ⟨h2, hd⟩
      · exact absurd ⟨t + s, Nat.le_add_right t s, hup⟩ hno
      · have : rho (t + (s + 1)) = down (rho (t + s)) := hd
        rw [this, down_eq]
        omega
  have := hdown (rho t)
  have := rho_pos (t + rho t)
  omega

/-- `ups t`: the number of up moves among Jane's first `t` moves (the
paper's `u(t)`). -/
def ups : ℕ → ℕ
  | 0 => 0
  | t + 1 => ups t + (if rho (t + 1) = up (rho t) then 1 else 0)

theorem ups_succ_up (t : ℕ) (h : rho (t + 1) = up (rho t)) : ups (t + 1) = ups t + 1 := by
  simp [ups, h]

theorem ups_succ_down (t : ℕ) (h : rho (t + 1) = down (rho t)) : ups (t + 1) = ups t := by
  have hp := rho_pos t
  have : rho (t + 1) ≠ up (rho t) := by
    rw [h]; simp only [up, down, label]; omega
  simp [ups, this]

/-- Jane's number of up moves takes every value. -/
theorem exists_ups (T j : ℕ) : ∃ t, T ≤ t ∧ ups t = ups T + j := by
  induction j with
  | zero => exact ⟨T, le_refl T, rfl⟩
  | succ j ih =>
    obtain ⟨t, ht, hu⟩ := ih
    -- the first up move at or after time `t`
    have hex : ∃ s, rho (t + s + 1) = up (rho (t + s)) := by
      obtain ⟨t', ht', h⟩ := exists_up t
      exact ⟨t' - t, by rw [show t + (t' - t) = t' by omega]; exact h⟩
    have hmin : ∀ s, s ≤ Nat.find hex → ups (t + s) = ups t := by
      intro s
      induction s with
      | zero => intro _; rfl
      | succ s ih' =>
        intro hs
        have hnot := Nat.find_min hex (show s < Nat.find hex by omega)
        rcases rho_move (t + s) with hup | ⟨_, hd⟩
        · exact absurd hup hnot
        · rw [show t + (s + 1) = t + s + 1 by ring, ups_succ_down _ hd]
          exact ih' (by omega)
    refine ⟨t + Nat.find hex + 1, by omega, ?_⟩
    rw [ups_succ_up _ (Nat.find_spec hex), hmin _ (le_refl _), hu]
    ring

/-- **Step 4, the bookkeeping.**  After time `T` all beads are larger than
`N`.  At any later time `t`, Jane's bead lies below a told bead `b` (the
bead she reached by her last up move): `ρ(t) = bD^k`.  If she has made `u`
up moves since `T`, then `log₂ b` is `log₂ ρ(T) + u α`, up to an integer
and an error of at most `2u/N`. -/
theorem phase_track (N T : ℕ) (hN : 1 ≤ N) (hT : ∀ t, T ≤ t → N < rho t) :
    ∀ t, T ≤ t → ∃ b k u : ℕ, ∃ z : ℤ,
      b ∈ told t ∧ rho t = b / 2 ^ k ∧ ups t = ups T + u ∧
      |logb 2 b - logb 2 (rho T) - u * alpha - z| ≤ u * (2 / N) := by
  intro t ht
  induction t, ht using Nat.le_induction with
  | base => exact ⟨rho T, 0, 0, 0, rho_mem T, by simp, rfl, by simp⟩
  | succ t ht ih =>
    obtain ⟨b, k, u, z, hb, hrho, hu, herr⟩ := ih
    rcases rho_move t with hup | ⟨_, hd⟩
    · -- an up move: the new bead is the new anchor
      have hm : N < rho t := hT t ht
      have hpos : 1 ≤ rho t := rho_pos t
      have l1 := lemma5_up (rho t) hpos
      have l2 := lemma5_down b k (rho t) hpos hrho.symm
      rw [← hup] at l1
      have hN0 : (0 : ℝ) < N := by exact_mod_cast hN
      have hmr : (N : ℝ) < rho t := by exact_mod_cast hm
      have hm0 : (0 : ℝ) < rho t := by linarith
      have e1 : (1 : ℝ) / (2 * rho t) ≤ 2 / N := by
        rw [div_le_div_iff₀ (by positivity) hN0]; nlinarith
      have e2 : (3 : ℝ) / (2 * rho t) ≤ 2 / N := by
        rw [div_le_div_iff₀ (by positivity) hN0]; nlinarith
      refine ⟨rho (t + 1), 0, u + 1, z - k, rho_mem (t + 1), by simp,
        by rw [ups_succ_up t hup, hu]; ring, ?_⟩
      rw [abs_le] at herr ⊢
      push_cast
      constructor <;> nlinarith [herr.1, herr.2, l1.1, l1.2, l2.1, l2.2]
    · -- a down move: same anchor, one level lower
      refine ⟨b, k + 1, u, z, told_mono (Nat.le_succ t) hb, ?_,
        by rw [ups_succ_down t hd, hu], herr⟩
      rw [hd, down_eq, hrho, pow_succ, Nat.div_div_eq_div_mul]

end Rosary
