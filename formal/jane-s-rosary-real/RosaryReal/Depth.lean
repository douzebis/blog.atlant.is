-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import RosaryReal.Theorem6

/-!
# Theorem 5, part 2: how far Jane can be

The *depth* of a bead `n` is `⌊log₂ n⌋`, written `Nat.log 2 n`.  A down
move decreases the depth by exactly 1 and an up move increases it by 0
or 1.
-/

namespace Rosary

open Real

/-! ## Depth -/

theorem depth_up_le (n : ℕ) (hn : 1 ≤ n) : Nat.log 2 (up n) ≤ Nat.log 2 n + 1 := by
  have h : up n ≤ n * 2 := by simp only [up, label]; omega
  calc Nat.log 2 (up n) ≤ Nat.log 2 (n * 2) := Nat.log_mono_right h
    _ = Nat.log 2 n + 1 := Nat.log_mul_base (by norm_num) (by omega)

theorem depth_down (n : ℕ) : Nat.log 2 (down n) = Nat.log 2 n - 1 := by
  rw [down_eq]; exact Nat.log_div_base 2 n

theorem two_pow_depth_le (n : ℕ) (hn : 1 ≤ n) : 2 ^ Nat.log 2 n ≤ n :=
  Nat.pow_log_le_self 2 (by omega)

theorem lt_two_pow_depth (n : ℕ) : n < 2 ^ (Nat.log 2 n + 1) :=
  Nat.lt_pow_succ_log_self (by norm_num) n

/-- The depth increases by at most 1 at each up move, and never otherwise. -/
theorem depth_le_ups (a : ℕ) : ∀ b, a ≤ b →
    Nat.log 2 (rho b) + ups a ≤ Nat.log 2 (rho a) + ups b := by
  intro b hab
  induction b, hab using Nat.le_induction with
  | base => exact le_refl _
  | succ b _ ih =>
    rcases rho_move b with h | ⟨_, h⟩
    · have := depth_up_le (rho b) (rho_pos b)
      rw [ups_succ_up b h, h]; omega
    · rw [ups_succ_down b h, h, depth_down]; omega

/-! ## The beads told, at a time when Jane is about to move up -/

theorem told_length (t : ℕ) : (told t).length = t + 1 := by
  induction t with
  | zero => rfl
  | succ t ih => rw [told_succ, List.length_cons, ih]

/-- When Jane is about to move up, the beads told are closed under down
moves (Lemma 3): they form a subtree. -/
theorem told_closed (t : ℕ) (hup : rho (t + 1) = up (rho t)) (n : ℕ) (hn : n ∈ told t)
    (h2 : 2 ≤ n) : down n ∈ told t := by
  by_cases hne : n = rho t
  · -- she does not move down from `n`: so `nD` has been told
    by_contra hnot
    have hd : rho (t + 1) = down (rho t) := by
      rw [rho_succ, if_pos ⟨by omega, by rw [← hne]; exact hnot⟩]
    have hp := rho_pos t
    rw [hup] at hd
    simp only [up, down, label] at hd
    omega
  · exact lemma3 t n hn h2 hne

theorem told_closed_pow (t : ℕ) (hup : rho (t + 1) = up (rho t)) (p : ℕ) :
    ∀ n, n ∈ told t → 1 ≤ n / 2 ^ p → n / 2 ^ p ∈ told t := by
  induction p with
  | zero => intro n hn _; simpa using hn
  | succ p ih =>
    intro n hn h1
    have hdiv : n / 2 ^ (p + 1) = (n / 2 ^ p) / 2 := by
      rw [pow_succ, Nat.div_div_eq_div_mul]
    rw [hdiv] at h1 ⊢
    have := told_closed t hup (n / 2 ^ p) (ih n hn (by omega)) (by omega)
    rwa [down_eq] at this

/-- Every bead of Jane's is at most twice a bead from which she moved up,
earlier or now. -/
theorem le_twice_up_time (t : ℕ) :
    ∃ t', t' ≤ t ∧ rho (t' + 1) = up (rho t') ∧ rho t ≤ 2 * rho t' := by
  induction t with
  | zero =>
    refine ⟨0, le_refl 0, ?_, by omega⟩
    rw [rho_succ, if_neg (by rw [rho_zero]; omega)]
  | succ t ih =>
    by_cases hup : rho (t + 1 + 1) = up (rho (t + 1))
    · exact ⟨t + 1, le_refl _, hup, by omega⟩
    · obtain ⟨t', ht', hup', hle⟩ := ih
      rcases rho_move t with h | ⟨_, h⟩
      · -- she has just moved up, from time `t`
        have hp := rho_pos t
        refine ⟨t, by omega, h, ?_⟩
        rw [h]; simp only [up, label]; omega
      · refine ⟨t', by omega, hup', ?_⟩
        rw [h, down_eq]; omega

/-! ## Ancestors -/

/-- The ancestor of the bead `b` at depth `d`. -/
def anc (b d : ℕ) : ℕ := b / 2 ^ (Nat.log 2 b - d)

theorem two_pow_le_anc (b d : ℕ) (hb : 1 ≤ b) (hd : d ≤ Nat.log 2 b) : 2 ^ d ≤ anc b d := by
  unfold anc
  rw [Nat.le_div_iff_mul_le (by positivity), ← pow_add, show d + (Nat.log 2 b - d) = Nat.log 2 b by omega]
  exact two_pow_depth_le b hb

theorem depth_anc (b d : ℕ) (hd : d ≤ Nat.log 2 b) : Nat.log 2 (anc b d) = d := by
  unfold anc
  rw [Nat.log_div_base_pow]
  omega

/-! ## The count -/

/-- **The inequality `(∗∗)` of the proof of Theorem 5.**  Let `K ≥ 2`, let
`η > 0` be at most `‖q α‖` for `1 ≤ q < K`, and let `2^D ≥ 16 K / η`.  At
a time `t` when Jane is about to move up, at depth `E`:
`K (E - K - D) ≤ t + 1`.

Proof: after the last time at depth `≤ E - K`, Jane makes at least `K - 1`
up moves; the `K` beads she reaches by them have phases that are pairwise
far apart, hence different ancestors at every depth from `D` to `E - K`;
and all these ancestors have been told. -/
theorem depth_bound_up (K D : ℕ) (hK : 2 ≤ K) (η : ℝ) (hη : 0 < η)
    (Hη : ∀ q : ℕ, 1 ≤ q → q < K → ∀ p : ℤ, η ≤ |q * alpha - p|)
    (hD : 16 * (K : ℝ) ≤ η * 2 ^ D) (t : ℕ) (hup : rho (t + 1) = up (rho t)) :
    K * (Nat.log 2 (rho t) - K - D) ≤ t + 1 := by
  by_cases hsmall : Nat.log 2 (rho t) ≤ K + D
  · rw [show Nat.log 2 (rho t) - K - D = 0 by omega]; omega
  obtain ⟨e0, he0⟩ : ∃ e0, Nat.log 2 (rho t) = e0 + K := ⟨Nat.log 2 (rho t) - K, by omega⟩
  have he0D : D + 1 ≤ e0 := by omega
  -- `T`: the first time from which Jane stays at depth `> e0` until `t`
  have hex : ∃ T, T ≤ t ∧ ∀ r, T ≤ r → r ≤ t → e0 + 1 ≤ Nat.log 2 (rho r) :=
    ⟨t, le_refl t, fun r h1 h2 => by rw [show r = t by omega]; omega⟩
  classical
  obtain ⟨hTt, hwin⟩ := Nat.find_spec hex
  have hTmin := fun T' (h : T' < Nat.find hex) => Nat.find_min hex h
  generalize Nat.find hex = T at hTt hwin hTmin
  have hT0 : T ≠ 0 := by
    intro h0
    have := hwin 0 (by omega) (by omega)
    rw [rho_zero] at this
    simp at this
  have hprev : Nat.log 2 (rho (T - 1)) ≤ e0 := by
    by_contra hc
    refine hTmin (T - 1) (by omega) ⟨by omega, fun r h1 h2 => ?_⟩
    by_cases e : r = T - 1
    · rw [e]; omega
    · exact hwin r (by omega) h2
  have hTdepth : Nat.log 2 (rho T) ≤ e0 + 1 := by
    have h1 := depth_le_ups (T - 1) T (by omega)
    have h2 := ups_le_succ (T - 1)
    rw [show T - 1 + 1 = T by omega] at h2
    omega
  have hups : ups T + (K - 1) ≤ ups t := by
    have := depth_le_ups T t hTt
    omega
  -- all beads from `T` to `t` are larger than `N = 2^(e0+1) - 1`
  have hNge : 2 ^ (D + 1) + 1 ≤ 2 ^ (e0 + 1) :=
    Nat.succ_le_of_lt (Nat.pow_lt_pow_right (by norm_num) (by omega))
  have h2D : 2 ≤ 2 ^ (D + 1) := by
    calc 2 = 2 ^ 1 := rfl
      _ ≤ 2 ^ (D + 1) := Nat.pow_le_pow_right (by norm_num) (by omega)
  obtain ⟨N, hNdef⟩ : ∃ N, N + 1 = 2 ^ (e0 + 1) := ⟨2 ^ (e0 + 1) - 1, by omega⟩
  have hPr : ((2 ^ (D + 1) : ℕ) : ℝ) = (2 : ℝ) ^ (D + 1) := by push_cast; rfl
  generalize hP : 2 ^ (D + 1) = P at hNge h2D hPr
  generalize hQ : 2 ^ (e0 + 1) = Q at hNge hNdef
  have hN1 : 1 ≤ N := by omega
  have hNhigh : ∀ s, T ≤ s → s ≤ t → N < rho s := by
    intro s h1 h2
    have h3 := two_pow_depth_le (rho s) (rho_pos s)
    have h4 : 2 ^ (e0 + 1) ≤ 2 ^ Nat.log 2 (rho s) :=
      Nat.pow_le_pow_right (by norm_num) (hwin s h1 h2)
    rw [hQ] at h4
    omega
  -- the `K` beads reached by the up moves, with their phases
  have hanchor : ∀ j, j < K → ∃ b : ℕ, ∃ z : ℤ, b ∈ told t ∧ N < b ∧
      |logb 2 b - logb 2 (rho T) - j * alpha - z| ≤ j * (2 / N) := by
    intro j hj
    obtain ⟨tj, h1, h2, hu⟩ := ups_ivt T j t hTt (by omega)
    obtain ⟨b, k, u, z, hb, hrho, hu', herr⟩ :=
      phase_track N T hN1 tj h1 (fun s a c => hNhigh s a (by omega))
    have huj : u = j := by omega
    subst huj
    exact ⟨b, z, told_mono h2 hb,
      lt_of_lt_of_le (hNhigh tj h1 h2) (by rw [hrho]; exact Nat.div_le_self b _), herr⟩
  choose! b z hbt hbN hberr using hanchor
  have hbdepth : ∀ j, j < K → e0 + 1 ≤ Nat.log 2 (b j) := by
    intro j hj
    rw [Nat.le_log_iff_pow_le (by norm_num) (by have := hbN j hj; omega), hQ]
    have := hbN j hj
    omega
  -- the sizes of the errors
  have hK0 : (0 : ℝ) < K := by exact_mod_cast (by omega : 0 < K)
  have hK2 : (2 : ℝ) ≤ K := by exact_mod_cast hK
  have hNr : (2 : ℝ) ^ (D + 1) ≤ N := by
    rw [← hPr]
    exact_mod_cast (by omega : P ≤ N)
  have hN0 : (0 : ℝ) < N := by exact_mod_cast hN1
  have hηN : 32 * (K : ℝ) ≤ η * N := by
    have := mul_le_mul_of_nonneg_left hNr hη.le
    rw [pow_succ] at this
    linarith
  have herrK : (K : ℝ) * (2 / N) ≤ η / 16 := by
    rw [mul_div_assoc', div_le_div_iff₀ hN0 (by norm_num)]
    linarith
  -- different beads among them have different ancestors at each depth `d ≥ D`
  have hdistinct : ∀ i j d, i < j → j < K → D ≤ d → d ≤ e0 + 1 →
      anc (b i) d ≠ anc (b j) d := by
    intro i j d hij hjK hDd hde heq
    have hiK : i < K := by omega
    have hdi : d ≤ Nat.log 2 (b i) := le_trans hde (hbdepth i hiK)
    have hdj : d ≤ Nat.log 2 (b j) := le_trans hde (hbdepth j hjK)
    have hbi1 : 1 ≤ b i := by have := hbN i hiK; omega
    have hbj1 : 1 ≤ b j := by have := hbN j hjK; omega
    have ha := two_pow_le_anc (b i) d hbi1 hdi
    have ha1 : 1 ≤ anc (b i) d := le_trans Nat.one_le_two_pow ha
    have li := lemma5_down (b i) (Nat.log 2 (b i) - d) (anc (b i) d) ha1 rfl
    have lj := lemma5_down (b j) (Nat.log 2 (b j) - d) (anc (b i) d) ha1 heq.symm
    have har : (2 : ℝ) ^ D ≤ anc (b i) d := by
      have : 2 ^ D ≤ anc (b i) d := le_trans (Nat.pow_le_pow_right (by norm_num) hDd) ha
      exact_mod_cast this
    have ha0 : (0 : ℝ) < anc (b i) d := by exact_mod_cast ha1
    have hηa : 32 ≤ η * (anc (b i) d : ℝ) := by
      have := mul_le_mul_of_nonneg_left har hη.le
      linarith
    have hsmall' : 3 / (2 * (anc (b i) d : ℝ)) ≤ 3 * η / 64 := by
      rw [div_le_div_iff₀ (by positivity) (by norm_num)]
      linarith
    have ei := abs_le.mp (hberr i hiK)
    have ej := abs_le.mp (hberr j hjK)
    have hi' : (i : ℝ) * (2 / N) ≤ η / 16 :=
      le_trans (mul_le_mul_of_nonneg_right (by exact_mod_cast hiK.le) (by positivity)) herrK
    have hj' : (j : ℝ) * (2 / N) ≤ η / 16 :=
      le_trans (mul_le_mul_of_nonneg_right (by exact_mod_cast hjK.le) (by positivity)) herrK
    have hH := Hη (j - i) (by omega) (by omega)
      ((Nat.log 2 (b j) - d : ℕ) - (Nat.log 2 (b i) - d : ℕ) - (z j - z i))
    have hcast : ((j - i : ℕ) : ℝ) = (j : ℝ) - i := by
      rw [Nat.cast_sub hij.le]
    rw [hcast] at hH
    have habs : |((j : ℝ) - i) * alpha
        - (((Nat.log 2 (b j) - d : ℕ) - (Nat.log 2 (b i) - d : ℕ) - (z j - z i) : ℤ) : ℝ)|
        < η := by
      rw [abs_lt]
      push_cast
      constructor <;> linarith [ei.1, ei.2, ej.1, ej.2, li.1, li.2, lj.1, lj.2]
    linarith
  -- count: `K` beads, the depths from `D` to `e0 + 1`
  have hmaps : ∀ p ∈ (Finset.range K) ×ˢ (Finset.Icc D (e0 + 1)),
      anc (b p.1) p.2 ∈ (told t).toFinset := by
    intro p hp
    rw [Finset.mem_product, Finset.mem_range, Finset.mem_Icc] at hp
    rw [List.mem_toFinset]
    have hb1 : 1 ≤ b p.1 := by have := hbN p.1 hp.1; omega
    have hd := le_trans hp.2.2 (hbdepth p.1 hp.1)
    exact told_closed_pow t hup _ (b p.1) (hbt p.1 hp.1)
      (le_trans Nat.one_le_two_pow (two_pow_le_anc (b p.1) p.2 hb1 hd))
  have hinj : Set.InjOn (fun p : ℕ × ℕ => anc (b p.1) p.2)
      ((Finset.range K) ×ˢ (Finset.Icc D (e0 + 1)) : Finset (ℕ × ℕ)) := by
    rintro ⟨i, d⟩ hi ⟨j, d'⟩ hj h
    rw [Finset.mem_coe, Finset.mem_product, Finset.mem_range, Finset.mem_Icc] at hi hj
    simp only at hi hj h
    have hdd : d = d' := by
      have h1 := depth_anc (b i) d (le_trans hi.2.2 (hbdepth i hi.1))
      have h2 := depth_anc (b j) d' (le_trans hj.2.2 (hbdepth j hj.1))
      rw [h] at h1
      omega
    subst hdd
    rcases Nat.lt_trichotomy i j with hlt | heq | hgt
    · exact absurd h (hdistinct i j d hlt hj.1 hi.2.1 hi.2.2)
    · rw [heq]
    · exact absurd h.symm (hdistinct j i d hgt hi.1 hi.2.1 hi.2.2)
  have hcard := Finset.card_le_card_of_injOn _ hmaps hinj
  rw [Finset.card_product, Finset.card_range, Nat.card_Icc] at hcard
  have hlen := List.toFinset_card_le (told t)
  rw [told_length] at hlen
  have hfin : K * (Nat.log 2 (rho t) - K - D) ≤ K * (e0 + 1 + 1 - D) :=
    Nat.mul_le_mul_left K (by omega)
  omega

/-- The same at any time: Jane's bead is at most twice a bead from which
she moved up, so its depth is at most one more. -/
theorem depth_bound (K D : ℕ) (hK : 2 ≤ K) (η : ℝ) (hη : 0 < η)
    (Hη : ∀ q : ℕ, 1 ≤ q → q < K → ∀ p : ℤ, η ≤ |q * alpha - p|)
    (hD : 16 * (K : ℝ) ≤ η * 2 ^ D) (t : ℕ) :
    K * (Nat.log 2 (rho t) - 1 - K - D) ≤ t + 1 := by
  obtain ⟨t', ht', hup, hle⟩ := le_twice_up_time t
  have h1 := depth_bound_up K D hK η hη Hη hD t' hup
  have h2 : Nat.log 2 (rho t) ≤ Nat.log 2 (rho t') + 1 := by
    calc Nat.log 2 (rho t) ≤ Nat.log 2 (rho t' * 2) :=
          Nat.log_mono_right (by omega)
      _ = Nat.log 2 (rho t') + 1 :=
          Nat.log_mul_base (by norm_num) (by have := rho_pos t'; omega)
  have h3 : K * (Nat.log 2 (rho t) - 1 - K - D) ≤ K * (Nat.log 2 (rho t') - K - D) :=
    Nat.mul_le_mul_left K (by omega)
  omega

/-- **Theorem 5, part 2, without any hypothesis on `log₂ 3`:** the depth
of Jane's bead is `o(t)`.  For every `K ≥ 2` there is a constant `C` such
that `K ⌊log₂ ρ(t)⌋ ≤ t + C` for all `t`. -/
theorem depth_sublinear (K : ℕ) (hK : 2 ≤ K) :
    ∃ C : ℕ, ∀ t, K * Nat.log 2 (rho t) ≤ t + C := by
  -- `η`: the smallest `‖q α‖` for `1 ≤ q < K`
  obtain ⟨q0, hq0, hmin⟩ := Finset.exists_min_image (Finset.Icc 1 (K - 1))
    (fun q : ℕ => ThreeDistance.nn alpha q) ⟨1, Finset.mem_Icc.mpr ⟨le_refl 1, by omega⟩⟩
  rw [Finset.mem_Icc] at hq0
  have hη : 0 < ThreeDistance.nn alpha q0 := by
    have h1 := ThreeDistance.fr_pos alpha_irr (show ((q0 : ℕ) : ℤ) ≠ 0 by omega)
    have h2 := ThreeDistance.fr_lt_one (α := alpha) (q0 : ℤ)
    exact lt_min h1 (by linarith)
  have Hη : ∀ q : ℕ, 1 ≤ q → q < K → ∀ p : ℤ, ThreeDistance.nn alpha q0 ≤ |q * alpha - p| :=
    fun q h1 h2 p => le_trans (hmin q (Finset.mem_Icc.mpr ⟨h1, by omega⟩))
      (by have := ThreeDistance.nn_le_abs (α := alpha) (q : ℤ) p; simpa using this)
  generalize ThreeDistance.nn alpha q0 = η at hη Hη
  obtain ⟨D, hDlt⟩ := pow_unbounded_of_one_lt (16 * (K : ℝ) / η) (one_lt_two)
  have hD : 16 * (K : ℝ) ≤ η * 2 ^ D := by
    have := (div_lt_iff₀ hη).mp hDlt
    linarith
  refine ⟨1 + K * (1 + K + D), fun t => ?_⟩
  have h := depth_bound K D hK η hη Hη hD t
  by_cases hsmall : Nat.log 2 (rho t) ≤ 1 + K + D
  · have := Nat.mul_le_mul_left K hsmall
    omega
  · obtain ⟨r, hr⟩ : ∃ r, Nat.log 2 (rho t) = (1 + K + D) + r :=
      ⟨Nat.log 2 (rho t) - (1 + K + D), by omega⟩
    rw [hr] at h ⊢
    rw [show 1 + K + D + r - 1 - K - D = r by omega] at h
    rw [Nat.mul_add]
    omega

end Rosary
