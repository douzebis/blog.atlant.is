-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import RosaryReal.Theorem3
import RosaryReal.Lemma9

/-!
# Theorem 6: bead `m` is told in polynomial time

The proof of the paper: rerun the proof of Theorem 3 with a clock.
-/

namespace Rosary

open Real

/-! ## Clocks -/

theorem ups_le_succ (t : ℕ) : ups (t + 1) ≤ ups t + 1 := by
  simp only [ups]; split <;> omega

theorem ups_mono {a b : ℕ} (h : a ≤ b) : ups a ≤ ups b := by
  induction b, h using Nat.le_induction with
  | base => exact le_refl _
  | succ b _ ih => exact le_trans ih (by simp only [ups]; omega)

/-- Between two times, the number of up moves takes every value. -/
theorem ups_ivt (T j : ℕ) : ∀ t, T ≤ t → ups T + j ≤ ups t →
    ∃ t', T ≤ t' ∧ t' ≤ t ∧ ups t' = ups T + j := by
  intro t ht
  induction t, ht using Nat.le_induction with
  | base => intro h; exact ⟨T, le_refl T, le_refl T, by omega⟩
  | succ t ht ih =>
    intro h
    by_cases h' : ups T + j ≤ ups t
    · obtain ⟨t', a, b, c⟩ := ih h'
      exact ⟨t', a, by omega, c⟩
    · have := ups_le_succ t
      exact ⟨t + 1, by omega, le_refl _, by omega⟩

/-- An up move at most doubles the bead: `ρ(t) ≤ 2^t`. -/
theorem rho_le_two_pow (t : ℕ) : rho t ≤ 2 ^ t := by
  induction t with
  | zero => simp [rho_zero]
  | succ t ih =>
    have hp := rho_pos t
    rcases rho_move t with h | ⟨_, h⟩
    · rw [h, pow_succ]; simp only [up, label]; omega
    · rw [h, pow_succ, down_eq]; omega

/-- At any time, the down moves are at most as many as the up moves:
`t ≤ 2 u(t)`. -/
theorem time_le_two_ups (t : ℕ) : t ≤ 2 * ups t := by
  have aux : rho t * 2 ^ t ≤ 2 ^ (2 * ups t) := by
    induction t with
    | zero => simp [rho_zero, ups]
    | succ t ih =>
      have hp := rho_pos t
      rcases rho_move t with h | ⟨_, h⟩
      · rw [ups_succ_up t h, h]
        have h2 : up (rho t) ≤ 2 * rho t := by simp only [up, label]; omega
        calc up (rho t) * 2 ^ (t + 1) ≤ 2 * rho t * 2 ^ (t + 1) :=
              Nat.mul_le_mul_right _ h2
          _ = 4 * (rho t * 2 ^ t) := by ring
          _ ≤ 4 * 2 ^ (2 * ups t) := Nat.mul_le_mul_left _ ih
          _ = 2 ^ (2 * (ups t + 1)) := by ring
      · rw [ups_succ_down t h, h, down_eq]
        calc rho t / 2 * 2 ^ (t + 1) = (2 * (rho t / 2)) * 2 ^ t := by ring
          _ ≤ rho t * 2 ^ t := Nat.mul_le_mul_right _ (by omega)
          _ ≤ 2 ^ (2 * ups t) := ih
  have h1 : 2 ^ t ≤ rho t * 2 ^ t := Nat.le_mul_of_pos_left _ (rho_pos t)
  exact (Nat.pow_le_pow_iff_right (by norm_num)).mp (le_trans h1 aux)

theorem told_down_time (n i : ℕ) (hn : n ∈ told i) (h2 : 2 ≤ n) :
    down n ∈ told (i + 1) := by
  obtain ⟨j, hj, hr⟩ := (mem_told i n).mp hn
  refine told_mono (show j + 1 ≤ i + 1 by omega)
    (lemma3 (j + 1) n (told_mono (Nat.le_succ j) (hr ▸ rho_mem j)) h2 ?_)
  intro e
  have := theorem2_injective j (j + 1) (hr.trans e)
  omega

/-- **Step 1, with a clock.**  If `b` is told by time `i`, then `bD^p` is
told by time `i + p`. -/
theorem told_div_time (p : ℕ) :
    ∀ b i, b ∈ told i → 1 ≤ b / 2 ^ p → b / 2 ^ p ∈ told (i + p) := by
  induction p with
  | zero => intro b i hb _; simpa using hb
  | succ p ih =>
    intro b i hb h1
    have hdiv : b / 2 ^ (p + 1) = (b / 2 ^ p) / 2 := by
      rw [pow_succ, Nat.div_div_eq_div_mul]
    rw [hdiv] at h1 ⊢
    have := told_down_time (b / 2 ^ p) (i + p) (ih b i hb (by omega)) (by omega)
    rw [down_eq] at this
    exact this

/-! ## An excursion above `N` that lasts `J` up moves enters the cone -/

/-- The data of the proof for a bead `m`: the length `w` of its arc, a
covering time `J` for the middle third of the arc, and a bound `N` beyond
which the errors of `J` steps stay below `w/3`. -/
structure Setup (m N J : ℕ) (w : ℝ) : Prop where
  hm : 1 ≤ m
  hNm : m ≤ N
  hw : logb 2 ((m : ℝ) + 1) - logb 2 m = w
  hJ : ∀ θ : ℝ, ∃ j : ℕ, j < J ∧ ∃ z : ℤ,
    logb 2 m + w / 3 ≤ θ + j * alpha - z ∧ θ + j * alpha - z ≤ logb 2 m + w / 3 + w / 3
  hNJ : (J : ℝ) * (2 / N) < w / 3

/-- **Step 4, with a clock.**  If from time `T` to time `t` Jane stays
above `N` and makes at least `J` up moves, then `m` is told by time `2t`. -/
theorem window_reach {m N J : ℕ} {w : ℝ} (S : Setup m N J w) (T t : ℕ) (hTt : T ≤ t)
    (hhigh : ∀ s, T ≤ s → s ≤ t → N < rho s) (hups : ups T + J ≤ ups t) :
    ∃ i, i ≤ 2 * t ∧ rho i = m := by
  obtain ⟨hm, hNm, hwdef, hJ, hNJ⟩ := S
  have hN1 : 1 ≤ N := le_trans hm hNm
  have hw : 0 < w := by
    have hm0 : (0 : ℝ) < m := by exact_mod_cast hm
    have := Real.logb_lt_logb (b := 2) (by norm_num) hm0 (show (m : ℝ) < m + 1 by linarith)
    linarith
  obtain ⟨j, hj, z1, hz1, hz2⟩ := hJ (logb 2 (rho T))
  obtain ⟨t', h1, h2, hu'⟩ := ups_ivt T j t hTt (by omega)
  obtain ⟨b, k, u, z, hb, hrho, hu, herr⟩ :=
    phase_track N T hN1 t' h1 fun s a c => hhigh s a (by omega)
  have huj : u = j := by omega
  subst huj
  have herr' : |logb 2 b - logb 2 (rho T) - u * alpha - z| < w / 3 := by
    refine lt_of_le_of_lt herr (lt_of_le_of_lt ?_ hNJ)
    have : (u : ℝ) ≤ J := by exact_mod_cast hj.le
    exact mul_le_mul_of_nonneg_right this (by positivity)
  rw [abs_lt] at herr'
  have hlo : logb 2 m < logb 2 b - ((z + z1 : ℤ) : ℝ) := by
    push_cast; linarith [herr'.1]
  have hhi : logb 2 b - ((z + z1 : ℤ) : ℝ) < logb 2 ((m : ℝ) + 1) := by
    push_cast; linarith [herr'.2]
  have hbN : N < b :=
    lt_of_lt_of_le (hhigh t' h1 h2) (by rw [hrho]; exact Nat.div_le_self b _)
  obtain ⟨p, hdiv⟩ := cone_of_phase m N b hm hNm hbN _ hlo hhi
  -- `b ≤ 2^t'`, so `p ≤ t'`: Jane comes down from `b` to `m` in at most `t'` moves
  have hb2 : b ≤ 2 ^ t' := by
    obtain ⟨s, hs, hr⟩ := (mem_told t' b).mp hb
    rw [← hr]
    exact le_trans (rho_le_two_pow s) (Nat.pow_le_pow_right (by norm_num) hs)
  have hp : p ≤ t' := by
    have h3 : b / 2 ^ p * 2 ^ p ≤ b := Nat.div_mul_le_self b _
    rw [hdiv] at h3
    have h4 : 2 ^ p ≤ m * 2 ^ p := Nat.le_mul_of_pos_left _ hm
    exact (Nat.pow_le_pow_iff_right (by norm_num)).mp (le_trans h4 (le_trans h3 hb2))
  have hmem := told_div_time p b t' hb (by omega)
  rw [hdiv] at hmem
  obtain ⟨i, hi, hri⟩ := (mem_told _ m).mp hmem
  exact ⟨i, by omega, hri⟩

/-! ## Counting the visits below `N` -/

/-- `lows N a n`: how many of the times `a, a + 1, …, a + n - 1` find Jane
on a bead `≤ N`. -/
def lows (N : ℕ) : ℕ → ℕ → ℕ
  | _, 0 => 0
  | a, n + 1 => (if rho a ≤ N then 1 else 0) + lows N (a + 1) n

theorem lows_add (N : ℕ) (i j : ℕ) : ∀ a, lows N a (i + j) = lows N a i + lows N (a + i) j := by
  induction i with
  | zero => intro a; simp [lows]
  | succ i ih =>
    intro a
    rw [show i + 1 + j = (i + j) + 1 by ring]
    simp only [lows]
    rw [ih (a + 1), show a + 1 + i = a + (i + 1) by ring]
    ring

theorem lows_zero (N : ℕ) (n : ℕ) : ∀ a, (∀ k, k < n → N < rho (a + k)) → lows N a n = 0 := by
  induction n with
  | zero => intro a _; rfl
  | succ n ih =>
    intro a h
    have h0 := h 0 (Nat.succ_pos n)
    simp only [lows, add_zero] at h0 ⊢
    rw [if_neg (by omega), ih (a + 1) fun k hk => by
      have := h (k + 1) (by omega)
      rwa [show a + (k + 1) = a + 1 + k by ring] at this]

/-- Jane is on a bead `≤ N` at most `N` times, since she never tells a
bead twice. -/
theorem lows_le (N : ℕ) (n a : ℕ) : lows N a n ≤ N := by
  have aux : ∀ n a, ∃ S : Finset ℕ, S.card = lows N a n ∧
      ∀ x ∈ S, (1 ≤ x ∧ x ≤ N) ∧ ∃ k, a ≤ k ∧ rho k = x := by
    intro n
    induction n with
    | zero => intro a; exact ⟨∅, rfl, by simp⟩
    | succ n ih =>
      intro a
      obtain ⟨S, hcard, hS⟩ := ih (a + 1)
      by_cases hlow : rho a ≤ N
      · have hnot : rho a ∉ S := by
          intro hmem
          obtain ⟨_, k, hk, hr⟩ := hS _ hmem
          have := theorem2_injective k a hr
          omega
        refine ⟨insert (rho a) S, ?_, ?_⟩
        · rw [Finset.card_insert_of_notMem hnot, hcard]
          simp only [lows, if_pos hlow]; ring
        · intro x hx
          rcases Finset.mem_insert.mp hx with rfl | hx
          · exact ⟨⟨rho_pos a, hlow⟩, a, le_refl a, rfl⟩
          · obtain ⟨hb, k, hk, hr⟩ := hS x hx
            exact ⟨hb, k, by omega, hr⟩
      · refine ⟨S, ?_, ?_⟩
        · rw [hcard]; simp only [lows, if_neg hlow]; ring
        · intro x hx
          obtain ⟨hb, k, hk, hr⟩ := hS x hx
          exact ⟨hb, k, by omega, hr⟩
  obtain ⟨S, hcard, hS⟩ := aux n a
  have hsub : S ⊆ Finset.Icc 1 N := fun x hx =>
    Finset.mem_Icc.mpr (hS x hx).1
  have := Finset.card_le_card hsub
  rw [Nat.card_Icc, hcard] at this
  omega

/-- **The count of the proof of Theorem 6.**  Suppose that, up to time
`tmax`, Jane never makes `J` up moves in a row of times spent above `N`.
Then her up moves are at most `J + 1` per visit below `N`, plus `J + 1`. -/
theorem ups_count (N J tmax : ℕ)
    (hwin : ∀ T t, T ≤ t → t ≤ tmax → (∀ s, T ≤ s → s ≤ t → N < rho s) →
      ups t < ups T + J) :
    ∀ n a, a + n ≤ tmax + 1 → ups (a + n) ≤ ups a + (lows N a n + 1) * (J + 1) := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    intro a han
    by_cases hlow : ∃ k, k < n ∧ rho (a + k) ≤ N
    · -- the first visit below `N`, at time `a + k`
      have hk := Nat.find_spec hlow
      have hmin := fun k' (h : k' < Nat.find hlow) => Nat.find_min hlow h
      generalize Nat.find hlow = k at hk hmin
      obtain ⟨hkn, hkl⟩ := hk
      have hhigh : ∀ k', k' < k → N < rho (a + k') := by
        intro k' hk'
        have := hmin k' hk'
        by_contra hc
        exact this ⟨by omega, by omega⟩
      -- before it, fewer than `J` up moves
      have h1 : ups (a + k) ≤ ups a + J := by
        by_cases hk0 : k = 0
        · rw [hk0]; simp
        · have hw := hwin a (a + (k - 1)) (by omega) (by omega) fun s hs1 hs2 => by
            have := hhigh (s - a) (by omega)
            rwa [show a + (s - a) = s by omega] at this
          have := ups_le_succ (a + (k - 1))
          rw [show a + (k - 1) + 1 = a + k by omega] at this
          omega
      -- after it, by induction
      obtain ⟨r, hr⟩ : ∃ r, n - k = r + 1 := ⟨n - k - 1, by omega⟩
      have h2 := ih r (by omega) (a + k + 1) (by omega)
      rw [show a + k + 1 + r = a + n by omega] at h2
      have h3 := ups_le_succ (a + k)
      have e1 : lows N a n = lows N a k + lows N (a + k) (n - k) := by
        rw [← lows_add]; congr 1; omega
      have e2 : lows N (a + k) (n - k) = 1 + lows N (a + k + 1) r := by
        rw [hr]; simp only [lows, if_pos hkl]
      rw [e1, lows_zero N k a hhigh, e2]
      generalize lows N (a + k + 1) r = L at h2 ⊢
      have e3 : (0 + (1 + L) + 1) * (J + 1) = (L + 1) * (J + 1) + (J + 1) := by ring
      rw [e3]
      omega
    · -- no visit below `N`: one excursion
      have hhigh : ∀ k, k < n → N < rho (a + k) := by
        intro k hk
        by_contra hc
        exact hlow ⟨k, hk, by omega⟩
      rw [lows_zero N n a hhigh]
      by_cases hn0 : n = 0
      · rw [hn0]; simp
      · have hw := hwin a (a + (n - 1)) (by omega) (by omega) fun s hs1 hs2 => by
          have := hhigh (s - a) (by omega)
          rwa [show a + (s - a) = s by omega] at this
        have := ups_le_succ (a + (n - 1))
        rw [show a + (n - 1) + 1 = a + n by omega] at this
        have e : (0 + 1) * (J + 1) = J + 1 := by ring
        rw [e]
        omega

/-- **Theorem 6, the count.**  With the data of the proof for the bead
`m`: if `m` is told at time `i`, then `i ≤ 4 (N + 1)(J + 1)`. -/
theorem time_bound {m N J : ℕ} {w : ℝ} (S : Setup m N J w) (i : ℕ) (hi : rho i = m) :
    i ≤ 4 * ((N + 1) * (J + 1)) := by
  by_cases hi0 : i = 0
  · omega
  -- up to time `tmax = (i - 1)/2`, no excursion above `N` has `J` up moves
  have hwin : ∀ T t, T ≤ t → t ≤ (i - 1) / 2 → (∀ s, T ≤ s → s ≤ t → N < rho s) →
      ups t < ups T + J := by
    intro T t hTt ht hhigh
    by_contra hc
    obtain ⟨i', hi', hr⟩ := window_reach S T t hTt hhigh (by omega)
    have := theorem2_injective i' i (hr.trans hi.symm)
    omega
  have h1 := ups_count N J ((i - 1) / 2) hwin ((i - 1) / 2 + 1) 0 (by omega)
  have h2 := lows_le N ((i - 1) / 2 + 1) 0
  have h3 := time_le_two_ups (0 + ((i - 1) / 2 + 1))
  have h4 : (lows N 0 ((i - 1) / 2 + 1) + 1) * (J + 1) ≤ (N + 1) * (J + 1) :=
    Nat.mul_le_mul_right _ (by omega)
  have h5 : ups 0 = 0 := rfl
  omega

/-! ## Theorem 6 -/

/-- The arc of `m` has length at least `1/(2m)`. -/
theorem arc_lower (m : ℕ) (hm : 1 ≤ m) :
    1 / (2 * (m : ℝ)) ≤ logb 2 ((m : ℝ) + 1) - logb 2 m := by
  have hm0 : (0 : ℝ) < m := by exact_mod_cast hm
  have hl2 : Real.log 2 < 0.6931471808 := Real.log_two_lt_d9
  have hl0 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have h1 : 1 - (((m : ℝ) + 1) / m)⁻¹ ≤ Real.log (((m : ℝ) + 1) / m) :=
    Real.one_sub_inv_le_log_of_pos (by positivity)
  have e2 : 1 - (((m : ℝ) + 1) / m)⁻¹ = 1 / ((m : ℝ) + 1) := by field_simp; ring
  rw [e2] at h1
  have e : logb 2 ((m : ℝ) + 1) - logb 2 m = Real.log (((m : ℝ) + 1) / m) / Real.log 2 := by
    rw [← Real.logb_div (by positivity) hm0.ne']; rfl
  rw [e, le_div_iff₀ hl0]
  have h3 : 1 / (2 * (m : ℝ)) * Real.log 2 ≤ 1 / ((m : ℝ) + 1) := by
    rw [div_mul_eq_mul_div, div_le_div_iff₀ (by positivity) (by positivity)]
    have : (1 : ℝ) ≤ m := by exact_mod_cast hm
    nlinarith
  linarith

/-- **Theorem 6.**  If `α` is badly approximable to the order `ν`, there
is a constant `κ` such that every bead `m` is told within `κ m^(2ν+1)`
moves. -/
theorem theorem6 (c ν : ℝ) (hν : 0 < ν) (H : BadlyApproximable c ν) :
    ∃ κ : ℝ, ∀ m i : ℕ, 1 ≤ m → rho i = m → (i : ℝ) ≤ κ * (m : ℝ) ^ (2 * ν + 1) := by
  have hc := H.1
  have hA : (0 : ℝ) < 24 ^ ν / c + 1 := by positivity
  generalize hAdef : (24 : ℝ) ^ ν / c + 1 = A at hA
  refine ⟨4 * ((4 + 12 * A) * (A + 1)), fun m i hm hi => ?_⟩
  have hm0 : (0 : ℝ) < m := by exact_mod_cast hm
  have hm1 : (1 : ℝ) ≤ m := by exact_mod_cast hm
  -- the arc of `m`
  have hwl := arc_lower m hm
  generalize hwdef : logb 2 ((m : ℝ) + 1) - logb 2 m = w at hwl
  have hw : 0 < w := lt_of_lt_of_le (by positivity) hwl
  have hinv : 1 / w ≤ 2 * m := (one_div_le hw (by positivity)).mpr hwl
  -- Lemma 9 for its middle third
  obtain ⟨J, hJle, hJ⟩ := lemma9 c ν hν H (w / 3) (by positivity)
  have hX1 : (1 : ℝ) ≤ (m : ℝ) ^ ν := Real.one_le_rpow hm1 hν.le
  have hJA : (J : ℝ) ≤ A * (m : ℝ) ^ ν := by
    have e : 4 / (w / 3) = 12 * (1 / w) := by field_simp; ring
    have h1 : (4 / (w / 3)) ^ ν ≤ (24 * (m : ℝ)) ^ ν := by
      rw [e]
      exact Real.rpow_le_rpow (by positivity) (by linarith) hν.le
    rw [Real.mul_rpow (by norm_num) hm0.le] at h1
    have h2 : (4 / (w / 3)) ^ ν / c ≤ 24 ^ ν * (m : ℝ) ^ ν / c :=
      div_le_div_of_nonneg_right h1 hc.le
    have e3 : A * (m : ℝ) ^ ν = 24 ^ ν * (m : ℝ) ^ ν / c + (m : ℝ) ^ ν := by
      rw [← hAdef]; ring
    rw [e3]; linarith
  -- the bound `N`
  have hNJ : (J : ℝ) * (2 / ((m + ⌈6 * J / w⌉₊ + 1 : ℕ) : ℝ)) < w / 3 := by
    have h1 : 6 * J / w ≤ (⌈6 * J / w⌉₊ : ℝ) := Nat.le_ceil _
    have h2 : 6 * (J : ℝ) ≤ ⌈6 * J / w⌉₊ * w := by rwa [div_le_iff₀ hw] at h1
    have hpos : (0 : ℝ) < ((m + ⌈6 * J / w⌉₊ + 1 : ℕ) : ℝ) := by positivity
    rw [mul_div_assoc', div_lt_iff₀ hpos]
    push_cast
    nlinarith
  have hNle : ((m + ⌈6 * J / w⌉₊ + 1 : ℕ) : ℝ) ≤ m + 12 * (J * m) + 2 := by
    have h1 : (⌈6 * J / w⌉₊ : ℝ) < 6 * J / w + 1 :=
      Nat.ceil_lt_add_one (by positivity)
    have h2 : 6 * (J : ℝ) / w ≤ 12 * (J * m) := by
      have : 6 * (J : ℝ) / w = 6 * J * (1 / w) := by ring
      rw [this]
      have := mul_le_mul_of_nonneg_left hinv (show (0 : ℝ) ≤ 6 * J by positivity)
      linarith
    push_cast
    linarith
  have hNm : m ≤ m + ⌈6 * J / w⌉₊ + 1 := by omega
  generalize m + ⌈6 * J / w⌉₊ + 1 = N at hNJ hNle hNm
  · have S : Setup m N J w := ⟨hm, hNm, hwdef, fun θ => hJ θ (logb 2 m + w / 3), hNJ⟩
    have hb := time_bound S i hi
    have hb' : (i : ℝ) ≤ 4 * (((N : ℝ) + 1) * ((J : ℝ) + 1)) := by exact_mod_cast hb
    -- the arithmetic
    have hJ0 : (0 : ℝ) ≤ J := by positivity
    have hN0 : (0 : ℝ) ≤ N := by positivity
    have e : (m : ℝ) ^ (2 * ν + 1) = (m : ℝ) ^ ν * (m : ℝ) ^ ν * m := by
      rw [show 2 * ν + 1 = ν + ν + 1 by ring, Real.rpow_add hm0, Real.rpow_add hm0,
        Real.rpow_one]
    rw [e]
    generalize (m : ℝ) ^ ν = X at hX1 hJA ⊢
    have hXM : 1 ≤ X * m := by nlinarith
    have ha : (J : ℝ) + 1 ≤ (A + 1) * X := by nlinarith
    have hJm : (J : ℝ) * m ≤ A * (X * m) := by
      have := mul_le_mul_of_nonneg_right hJA hm0.le
      linarith
    have hb2 : (N : ℝ) + 1 ≤ (4 + 12 * A) * (X * m) := by nlinarith
    have hprod : ((N : ℝ) + 1) * ((J : ℝ) + 1) ≤ (4 + 12 * A) * (X * m) * ((A + 1) * X) :=
      mul_le_mul hb2 ha (by positivity) (by positivity)
    have efin : 4 * ((4 + 12 * A) * (A + 1)) * (X * X * m)
        = 4 * ((4 + 12 * A) * (X * m) * ((A + 1) * X)) := by ring
    rw [efin]
    linarith
/-! ## Theorem 6, as stated in the paper -/

theorem logb_two_three : logb 2 3 = alpha + 1 := by
  rw [alpha, Real.logb_div (by norm_num) (by norm_num), Real.logb_self_eq_one (by norm_num)]
  ring

/-- `μ` is an irrationality exponent of `log₂ 3`, with constant `c`:
`|log₂ 3 - p/q| ≥ c q^(-μ)` for all integers `p` and `q ≥ 1`. -/
def IrrationalityExponent (c μ : ℝ) : Prop :=
  0 < c ∧ ∀ p : ℤ, ∀ q : ℕ, 1 ≤ q → c * (q : ℝ) ^ (-μ) ≤ |logb 2 3 - (p : ℝ) / (q : ℝ)|

theorem badly_of_exponent (c μ : ℝ) (H : IrrationalityExponent c μ) :
    BadlyApproximable c (μ - 1) := by
  obtain ⟨hc, H⟩ := H
  refine ⟨hc, fun q hq p => ?_⟩
  have hq0 : (0 : ℝ) < q := by exact_mod_cast hq
  have h := H (p + q) q hq
  have e : (q : ℝ) * alpha - p = q * (logb 2 3 - ((p + q : ℤ) : ℝ) / q) := by
    rw [logb_two_three]; push_cast; field_simp; ring
  rw [e, abs_mul, abs_of_pos hq0]
  have e2 : c * (q : ℝ) ^ (-(μ - 1)) = q * (c * (q : ℝ) ^ (-μ)) := by
    rw [show -(μ - 1) = 1 + -μ by ring, Real.rpow_add hq0, Real.rpow_one]; ring
  rw [e2]
  exact mul_le_mul_of_nonneg_left h hq0.le

/-- **Theorem 6, in the paper's words.**  Let `μ₀ > 1` be an irrationality
exponent of `log₂ 3`.  There is a constant `κ` such that for every bead
`m`, `ρ⁻¹(m) ≤ κ m^(2μ₀ - 1)`: if `m` is told at time `i`, then
`i ≤ κ m^(2μ₀ - 1)`. -/
theorem theorem6_exponent (c μ₀ : ℝ) (hμ : 1 < μ₀) (H : IrrationalityExponent c μ₀) :
    ∃ κ : ℝ, ∀ m i : ℕ, 1 ≤ m → rho i = m → (i : ℝ) ≤ κ * (m : ℝ) ^ (2 * μ₀ - 1) := by
  obtain ⟨κ, h⟩ := theorem6 c (μ₀ - 1) (by linarith) (badly_of_exponent c μ₀ H)
  refine ⟨κ, fun m i hm hi => ?_⟩
  have := h m i hm hi
  rwa [show 2 * (μ₀ - 1) + 1 = 2 * μ₀ - 1 by ring] at this

end Rosary
