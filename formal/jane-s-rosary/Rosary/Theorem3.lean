-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Rosary.Reluctant
import Rosary.Theorem1

/-!
# Theorem 3: the reluctant recitation tells every bead

The proof below is not the one of the paper.  It uses no logarithm and no
real number, only integers.

Suppose that some bead `m` is never told.  Then:

1. the beads never told are closed under two operations on intervals: if
   no bead of `[A, C)` is ever told, the same holds for `[2A, 2C)` (by
   Lemma 3) and for `[3A, 3C)` (by the no-gap property of Theorem 2);
2. so no bead of `[m s, (m + 1) s)` is ever told, for every `s` of the
   form `2^e 3^j`;
3. these intervals cover all large integers, because some `2^e 3^j` and
   some `2^e' 3^j'` are as close to each other as we like (pigeonhole);
4. but Jane tells arbitrarily large beads, since she never tells a bead
   twice.
-/

namespace Rosary

/-! ## Two tools: the pigeonhole principle, and powers of two -/

/-- The pigeonhole principle: `a + 1` numbers below `a` are not all
different. -/
theorem pigeonhole (a : Nat) : ∀ f : Nat → Nat, (∀ i, i ≤ a → f i < a) →
    ∃ i j, i < j ∧ j ≤ a ∧ f i = f j := by
  induction a with
  | zero => intro f h; have := h 0 (Nat.le_refl 0); omega
  | succ a ih =>
    intro f h
    by_cases hex : ∃ i, i ≤ a ∧ f i = f (a + 1)
    · obtain ⟨i, hi, he⟩ := hex
      exact ⟨i, a + 1, by omega, Nat.le_refl _, he⟩
    · have hg : ∀ i, i ≤ a → (if f i = a then f (a + 1) else f i) < a := by
        intro i hi
        have h1 := h i (by omega)
        have h2 := h (a + 1) (Nat.le_refl _)
        by_cases c : f i = a
        · rw [if_pos c]
          have : f (a + 1) ≠ a := fun e => hex ⟨i, hi, by rw [c, e]⟩
          omega
        · rw [if_neg c]; omega
      obtain ⟨i, j, hij, hj, he⟩ :=
        ih (fun i => if f i = a then f (a + 1) else f i) hg
      have he' : (if f i = a then f (a + 1) else f i)
          = (if f j = a then f (a + 1) else f j) := he
      by_cases ci : f i = a
      · by_cases cj : f j = a
        · exact ⟨i, j, hij, by omega, by rw [ci, cj]⟩
        · rw [if_pos ci, if_neg cj] at he'
          exact absurd ⟨j, hj, he'.symm⟩ hex
      · by_cases cj : f j = a
        · rw [if_neg ci, if_pos cj] at he'
          exact absurd ⟨i, by omega, he'⟩ hex
        · rw [if_neg ci, if_neg cj] at he'
          exact ⟨i, j, hij, by omega, he'⟩

/-- Every `y ≥ x ≥ 1` lies between `x 2^r` and `x 2^(r+1)` for some `r`. -/
theorem two_pow_bracket (x : Nat) (hx : 1 ≤ x) :
    ∀ y, x ≤ y → ∃ r, x * 2 ^ r ≤ y ∧ y < x * 2 ^ (r + 1) := by
  intro y
  induction y using Nat.strongRecOn with
  | _ y ih =>
    intro hxy
    by_cases h : y < 2 * x
    · refine ⟨0, ?_, ?_⟩
      · show x * 1 ≤ y; omega
      · show y < x * 2; omega
    · obtain ⟨r, h1, h2⟩ := ih (y / 2) (by omega) (by omega)
      refine ⟨r + 1, ?_, ?_⟩
      · rw [Nat.pow_succ, ← Nat.mul_assoc]; omega
      · rw [Nat.pow_succ, ← Nat.mul_assoc]; omega

/-! ## The numbers `2^e 3^j` -/

/-- `Smooth s`: `s` is a product of twos and threes. -/
inductive Smooth : Nat → Prop
  | one : Smooth 1
  | two {s : Nat} : Smooth s → Smooth (2 * s)
  | three {s : Nat} : Smooth s → Smooth (3 * s)

theorem Smooth.pos {s : Nat} (h : Smooth s) : 1 ≤ s := by
  induction h with
  | one => exact Nat.le_refl 1
  | two _ ih => omega
  | three _ ih => omega

theorem Smooth.mul {s t : Nat} (h : Smooth s) (h' : Smooth t) : Smooth (s * t) := by
  induction h with
  | one => rw [Nat.one_mul]; exact h'
  | two _ ih => rw [Nat.mul_assoc]; exact ih.two
  | three _ ih => rw [Nat.mul_assoc]; exact ih.three

theorem smooth_two_pow (e : Nat) : Smooth (2 ^ e) := by
  induction e with
  | zero => exact Smooth.one
  | succ e ih => rw [Nat.pow_succ, Nat.mul_comm]; exact ih.two

theorem smooth_three_pow (j : Nat) : Smooth (3 ^ j) := by
  induction j with
  | zero => exact Smooth.one
  | succ j ih => rw [Nat.pow_succ, Nat.mul_comm]; exact ih.three

theorem Smooth.pow {s : Nat} (h : Smooth s) (k : Nat) : Smooth (s ^ k) := by
  induction k with
  | zero => exact Smooth.one
  | succ k ih => rw [Nat.pow_succ]; exact ih.mul h

/-! ## Two smooth numbers as close as we like -/

/-- If `X/Y < 1 + 1/q` and `M ≤ q` then `X/Y < 1 + 1/M`. -/
theorem tighten (M q X Y : Nat) (hM : M ≤ q) (h : q * X < (q + 1) * Y) :
    M * X < (M + 1) * Y := by
  rw [Nat.add_mul, Nat.one_mul] at h ⊢
  by_cases c : X ≤ Y
  · have := Nat.mul_le_mul_left M c
    have : 0 < Y := by
      apply Classical.byContradiction
      intro h0
      have hy : Y = 0 := by omega
      rw [hy] at c h
      have hx : X = 0 := by omega
      rw [hx] at h
      simp at h
    omega
  · obtain ⟨d, rfl⟩ : ∃ d, X = Y + d := ⟨X - Y, by omega⟩
    rw [Nat.mul_add] at h ⊢
    have := Nat.mul_le_mul_right d hM
    omega

/-- For every `M ≥ 1` there are two smooth numbers `P < Q` with
`Q/P < 1 + 1/M`.  Proof: among the `M + 1` numbers `3^0, …, 3^M`, each
divided by the largest power of 2 below it, two fall in the same one of
the `M` intervals `[1 + v/M, 1 + (v+1)/M)`. -/
theorem small_ratio (M : Nat) (hM : 1 ≤ M) :
    ∃ P Q, Smooth P ∧ Smooth Q ∧ P < Q ∧ M * Q < (M + 1) * P := by
  have hbin : ∀ i, i ≤ M → ∃ v, v < M ∧
      ∃ e, (M + v) * 2 ^ e ≤ M * 3 ^ i ∧ M * 3 ^ i < (M + v + 1) * 2 ^ e := by
    intro i _
    obtain ⟨e, h1, h2⟩ := two_pow_bracket 1 (Nat.le_refl 1) (3 ^ i)
      (Nat.pow_pos (by decide))
    rw [Nat.one_mul] at h1 h2
    rw [Nat.pow_succ] at h2
    have hD : 0 < 2 ^ e := Nat.pow_pos (by decide)
    have d1 := Nat.div_add_mod (M * 3 ^ i) (2 ^ e)
    have d2 := Nat.mod_lt (M * 3 ^ i) hD
    generalize M * 3 ^ i / 2 ^ e = q at d1
    have hT1 : M * 2 ^ e ≤ M * 3 ^ i := Nat.mul_le_mul_left M h1
    have hT2 : M * 3 ^ i < M * (2 ^ e * 2) := Nat.mul_lt_mul_of_pos_left h2 (by omega)
    have e2 : M * (2 ^ e * 2) = 2 ^ e * (2 * M) := by ac_rfl
    rw [Nat.mul_comm M (2 ^ e)] at hT1
    have q1 : M ≤ q := by
      apply Classical.byContradiction
      intro hc
      have hle : q + 1 ≤ M := by omega
      have := Nat.mul_le_mul_left (2 ^ e) hle
      rw [Nat.mul_add, Nat.mul_one] at this
      omega
    have q2 : q < 2 * M := by
      apply Classical.byContradiction
      intro hc
      have hle : 2 * M ≤ q := by omega
      have := Nat.mul_le_mul_left (2 ^ e) hle
      omega
    refine ⟨q - M, by omega, e, ?_, ?_⟩
    · rw [show M + (q - M) = q by omega, Nat.mul_comm]; omega
    · rw [show M + (q - M) + 1 = q + 1 by omega, Nat.add_mul, Nat.one_mul,
        Nat.mul_comm q]
      omega
  have hchoice : ∃ f : Nat → Nat, ∀ i, i ≤ M → f i < M ∧
      ∃ e, (M + f i) * 2 ^ e ≤ M * 3 ^ i ∧ M * 3 ^ i < (M + f i + 1) * 2 ^ e :=
    ⟨fun i => if h : i ≤ M then Classical.choose (hbin i h) else 0, fun i hi => by
      simp only [dif_pos hi]; exact Classical.choose_spec (hbin i hi)⟩
  obtain ⟨f, hf⟩ := hchoice
  obtain ⟨i, j, hij, hj, he⟩ := pigeonhole M f (fun i hi => (hf i hi).1)
  obtain ⟨_, e, a1, a2⟩ := hf i (by omega)
  obtain ⟨_, e', b1, b2⟩ := hf j hj
  rw [← he] at b1 b2
  have hq : M ≤ M + f i := Nat.le_add_right M (f i)
  generalize M + f i = q at *
  have hM3i : 0 < M * 3 ^ i := Nat.mul_pos hM (Nat.pow_pos (by decide))
  have hM3j : 0 < M * 3 ^ j := Nat.mul_pos hM (Nat.pow_pos (by decide))
  have c1 : q * (3 ^ j * 2 ^ e) < (q + 1) * (3 ^ i * 2 ^ e') := by
    have := Nat.mul_lt_mul_of_le_of_lt a1 b2 hM3i
    have l : q * 2 ^ e * (M * 3 ^ j) = M * (q * (3 ^ j * 2 ^ e)) := by ac_rfl
    have r : M * 3 ^ i * ((q + 1) * 2 ^ e')
        = M * ((q + 1) * (3 ^ i * 2 ^ e')) := by ac_rfl
    rw [l, r] at this
    exact Nat.lt_of_mul_lt_mul_left this
  have c2 : q * (3 ^ i * 2 ^ e') < (q + 1) * (3 ^ j * 2 ^ e) := by
    have := Nat.mul_lt_mul_of_le_of_lt b1 a2 hM3j
    have l : q * 2 ^ e' * (M * 3 ^ i) = M * (q * (3 ^ i * 2 ^ e')) := by ac_rfl
    have r : M * 3 ^ j * ((q + 1) * 2 ^ e)
        = M * ((q + 1) * (3 ^ j * 2 ^ e)) := by ac_rfl
    rw [l, r] at this
    exact Nat.lt_of_mul_lt_mul_left this
  have t1 := tighten M q _ _ hq c1
  have t2 := tighten M q _ _ hq c2
  -- the two numbers are different: one has more threes
  have hne : 3 ^ j * 2 ^ e ≠ 3 ^ i * 2 ^ e' := by
    intro h
    obtain ⟨d, rfl⟩ : ∃ d, j = i + d + 1 := ⟨j - i - 1, by omega⟩
    rw [Nat.pow_succ, Nat.pow_add] at h
    have h' : 3 ^ i * (3 * (3 ^ d * 2 ^ e)) = 3 ^ i * 2 ^ e' := by
      rw [← h]; ac_rfl
    have h3 := Nat.eq_of_mul_eq_mul_left (Nat.pow_pos (by decide)) h'
    have := two_pow_mul_mod3 e' 1 (by decide)
    rw [Nat.mul_one] at this
    omega
  have sX : Smooth (3 ^ j * 2 ^ e) := (smooth_three_pow j).mul (smooth_two_pow e)
  have sY : Smooth (3 ^ i * 2 ^ e') := (smooth_three_pow i).mul (smooth_two_pow e')
  by_cases c : 3 ^ j * 2 ^ e < 3 ^ i * 2 ^ e'
  · exact ⟨_, _, sX, sY, c, t2⟩
  · exact ⟨_, _, sY, sX, by omega, t1⟩

/-! ## The intervals `[m s, (m + 1) s)` cover all large integers -/

/-- `P^k (P + k) ≤ P (P + 1)^k`: Bernoulli's inequality, without fractions. -/
theorem bernoulli (P k : Nat) : P ^ k * (P + k) ≤ P * (P + 1) ^ k := by
  induction k with
  | zero => simp
  | succ k ih =>
    have hp : P ^ k ≤ (P + 1) ^ k := Nat.pow_le_pow_left (Nat.le_succ P) k
    rw [Nat.pow_succ, Nat.pow_succ]
    generalize P ^ k = A at *
    generalize (P + 1) ^ k = B at *
    have e1 : A * P * (P + (k + 1)) = P * (A * (P + k)) + P * A := by grind
    have e2 : P * (B * (P + 1)) = P * (P * B) + P * B := by grind
    rw [e1, e2]
    exact Nat.add_le_add (Nat.mul_le_mul_left P ih) (Nat.mul_le_mul_left P hp)

/-- If `1 ≤ P < Q` then `(Q/P)^P ≥ 2`. -/
theorem pow_ratio (P Q : Nat) (hP : 1 ≤ P) (h : P < Q) : 2 * P ^ P ≤ Q ^ P := by
  have hb := bernoulli P P
  have e : P ^ P * (P + P) = P * (2 * P ^ P) := by grind
  rw [e] at hb
  have h1 : 2 * P ^ P ≤ (P + 1) ^ P := Nat.le_of_mul_le_mul_left hb hP
  exact Nat.le_trans h1 (Nat.pow_le_pow_left h P)

/-- From `s P^k` to `s Q^k` by steps of ratio `Q/P < 1 + 1/m`: one of the
steps lands on an `s'` with `m s' ≤ n < (m + 1) s'`. -/
theorem chain (m P Q n : Nat) (hP : Smooth P) (hQ : Smooth Q)
    (hr : m * Q < (m + 1) * P) (k : Nat) :
    ∀ s, Smooth s → m * (P ^ k * s) ≤ n → n < m * (Q ^ k * s) →
      ∃ s', Smooth s' ∧ m * s' ≤ n ∧ n < (m + 1) * s' := by
  induction k with
  | zero =>
    intro s _ h1 h2
    simp only [Nat.pow_zero, Nat.one_mul] at h1 h2
    omega
  | succ k ih =>
    intro s hs h1 h2
    rw [Nat.pow_succ, Nat.mul_assoc] at h1 h2
    by_cases c : m * (P ^ k * (Q * s)) ≤ n
    · exact ih (Q * s) (hQ.mul hs) c h2
    · refine ⟨P ^ k * (P * s), (hP.pow k).mul (hP.mul hs), h1, ?_⟩
      have c' : n < m * (P ^ k * (Q * s)) := by omega
      have l : m * (P ^ k * (Q * s)) = m * Q * (P ^ k * s) := by ac_rfl
      have r : (m + 1) * (P ^ k * (P * s)) = (m + 1) * P * (P ^ k * s) := by ac_rfl
      have pos : 0 < P ^ k * s := Nat.mul_pos (Nat.pow_pos hP.pos) hs.pos
      have := Nat.mul_lt_mul_of_pos_right hr pos
      omega

/-- Every large `n` lies in `[m s, (m + 1) s)` for some smooth `s`. -/
theorem cover (m : Nat) (hm : 1 ≤ m) :
    ∃ N, ∀ n, N ≤ n → ∃ s, Smooth s ∧ m * s ≤ n ∧ n < (m + 1) * s := by
  obtain ⟨P, Q, hP, hQ, hlt, hr⟩ := small_ratio m hm
  refine ⟨m * P ^ P, fun n hn => ?_⟩
  have hpos : 1 ≤ m * P ^ P := Nat.mul_pos hm (Nat.pow_pos hP.pos)
  obtain ⟨r, h1, h2⟩ := two_pow_bracket (m * P ^ P) hpos n hn
  have hb := pow_ratio P Q hP.pos hlt
  refine chain m P Q n hP hQ hr P (2 ^ r) (smooth_two_pow r) ?_ ?_
  · rw [Nat.mul_assoc] at h1; exact h1
  · calc n < m * P ^ P * 2 ^ (r + 1) := h2
      _ = m * (2 * P ^ P * 2 ^ r) := by rw [Nat.pow_succ]; ac_rfl
      _ ≤ m * (Q ^ P * 2 ^ r) :=
          Nat.mul_le_mul_left _ (Nat.mul_le_mul_right _ hb)

/-! ## The beads that are never told -/

/-- `Untold n`: Jane never tells bead `n`. -/
def Untold (n : Nat) : Prop := ∀ i, n ∉ told i

/-- If `n > 1` is told then so is `nD` (Lemma 3, one move later). -/
theorem told_down (n i : Nat) (hn : n ∈ told i) (h2 : 2 ≤ n) :
    ∃ i', down n ∈ told i' := by
  obtain ⟨j, hj, hr⟩ := (mem_told i n).mp hn
  refine ⟨j + 1, lemma3 (j + 1) n (told_mono (Nat.le_succ j) (hr ▸ rho_mem j)) h2 ?_⟩
  intro e
  have := theorem2_injective j (j + 1) (hr.trans e)
  omega

/-- If no bead of `[A, C)` is ever told, no bead of `[2A, 2C)` is. -/
theorem untold_double (A C : Nat) (hA : 1 ≤ A)
    (h : ∀ n, A ≤ n → n < C → Untold n) :
    ∀ n, 2 * A ≤ n → n < 2 * C → Untold n := by
  intro n h1 h2 i hn
  obtain ⟨i', hd⟩ := told_down n i hn (by omega)
  exact h (down n) (by rosary) (by rosary) i' hd

/-- If no bead of `[A, C)` is ever told, no bead of `[3A, 3C)` is.  A white
bead `n` there would have `nλ` told, in `[2A, 2C)`.  A black bead `n` there
would have been reached by a down move from `p = 2n` or `2n + 1`, which is
white, and `pλ` would be told, in `[4A, 4C)`. -/
theorem untold_triple (A C : Nat) (hA : 1 ≤ A)
    (h : ∀ n, A ≤ n → n < C → Untold n) :
    ∀ n, 3 * A ≤ n → n < 3 * C → Untold n := by
  have h2 := untold_double A C hA h
  have h4 := untold_double (2 * A) (2 * C) (by omega) h2
  intro n h1 hn i hmem
  by_cases hw : White n
  · exact h2 (lam n) (by rosary) (by rosary) i (theorem2_no_gap i n hmem hw)
  · have hb : Black n := by rosary
    obtain ⟨j, hj, hr⟩ := (mem_told i n).mp hmem
    cases j with
    | zero => rw [rho_zero] at hr; omega
    | succ j =>
      rcases rho_move j with hup | ⟨hp2, hdown⟩
      · exact black_not_up n (rho j) hb (hup.symm.trans hr)
      · rw [hr] at hdown
        have hp : rho j = mu n ∨ rho j = nu n := (down_eq_iff _ n).mp hdown.symm
        have hpw : White (rho j) := by rosary
        have := theorem2_no_gap j (rho j) (rho_mem j) hpw
        exact h4 (lam (rho j)) (by rosary) (by rosary) j this

/-- If bead `m` is never told, no bead of `[m s, (m + 1) s)` is, for every
smooth `s`. -/
theorem untold_smooth (m : Nat) (hm : 1 ≤ m) (hu : Untold m) :
    ∀ s, Smooth s → ∀ n, m * s ≤ n → n < (m + 1) * s → Untold n := by
  intro s hs
  induction hs with
  | one =>
    intro n h1 h2
    have : n = m := by omega
    rw [this]; exact hu
  | @two s hs ih =>
    intro n h1 h2
    rw [Nat.mul_left_comm] at h1 h2
    exact untold_double (m * s) ((m + 1) * s) (Nat.mul_pos hm hs.pos) ih n h1 h2
  | @three s hs ih =>
    intro n h1 h2
    rw [Nat.mul_left_comm] at h1 h2
    exact untold_triple (m * s) ((m + 1) * s) (Nat.mul_pos hm hs.pos) ih n h1 h2

/-- Jane tells arbitrarily large beads, since she never tells a bead twice. -/
theorem rho_unbounded (a : Nat) : ∃ i, a ≤ rho i := by
  apply Classical.byContradiction
  intro h
  have hlt : ∀ i, i ≤ a → rho i < a := fun i _ => by
    apply Classical.byContradiction
    intro hc
    exact h ⟨i, by omega⟩
  obtain ⟨i, j, hij, _, he⟩ := pigeonhole a rho hlt
  have := theorem2_injective i j he
  omega

/-- **Theorem 3.**  The reluctant recitation tells every bead. -/
theorem theorem3 (m : Nat) (hm : 1 ≤ m) : ∃ i, rho i = m := by
  apply Classical.byContradiction
  intro hno
  have hu : Untold m := fun i hmem => by
    obtain ⟨j, _, hr⟩ := (mem_told i m).mp hmem
    exact hno ⟨j, hr⟩
  obtain ⟨N, hN⟩ := cover m hm
  obtain ⟨i, hi⟩ := rho_unbounded N
  obtain ⟨s, hs, h1, h2⟩ := hN (rho i) hi
  exact untold_smooth m hm hu s hs (rho i) h1 h2 i (rho_mem i)

/-- **Theorem 3, in full.**  `ρ` is a permutation of the positive
integers: its values are beads, no bead is told twice, and every bead is
told. -/
theorem theorem3_permutation :
    (∀ i, 1 ≤ rho i) ∧ (∀ i j, rho i = rho j → i = j) ∧
    (∀ m, 1 ≤ m → ∃ i, rho i = m) :=
  ⟨rho_pos, theorem2_injective, theorem3⟩

end Rosary
