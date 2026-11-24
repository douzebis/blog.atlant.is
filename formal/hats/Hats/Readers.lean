-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Topology
import Mathlib.Computability.Primrec.List
import Mathlib.Computability.Partrec

/-!
# The limit strategies, computed by reading the hats one at a time

The third article says that the limit strategies are computable, and draws
each as an automaton that reads the stream of hats of a stack, from the
bottom up, and stops with the position to point at.  Here such a machine
is a *reader*: it has a state, and each hat either changes the state or
makes it stop with an output.  The three readers below have finitely many
kinds of states and one counter, as in the pictures.

For each limit strategy: on every stack where the strategy is defined, the
reader stops, and its output is what the strategy chooses.  And each
reader is computable in the sense of recursion theory: what it has done
after a list of hats is a computable function of the list (its steps are
primitive recursive).
-/

namespace Hats

/-- A machine that reads the hats of a stack from the bottom up.  From a
state and a hat, `step` gives the next state, or the output: a position. -/
structure Reader (σ : Type) where
  init : σ
  step : σ → Bool → σ ⊕ ℕ

/-- Where the reader is after a list of hats (the lowest first): in a
state, or stopped with an output. -/
def Reader.run {σ : Type} (M : Reader σ) (l : List Bool) : σ ⊕ ℕ :=
  l.foldl (fun r b => Sum.casesOn r (fun q => M.step q b) (fun z => .inr z)) (.inl M.init)

/-- Where the reader is after the `k` lowest hats of stack `t`. -/
def Reader.after {σ : Type} (M : Reader σ) (t : Stack) (k : ℕ) : σ ⊕ ℕ :=
  M.run ((List.range k).map t)

/-- The reader stops on stack `t` and its output is the position `z`. -/
def Reader.Outputs {σ : Type} (M : Reader σ) (t : Stack) (z : ℤ) : Prop :=
  ∃ k m, M.after t k = .inr m ∧ (m : ℤ) = z

theorem Reader.after_succ_of_inl {σ : Type} (M : Reader σ) (t : Stack) {k : ℕ} {q : σ}
    (h : M.after t k = .inl q) : M.after t (k + 1) = M.step q (t k) := by
  unfold Reader.after Reader.run at h ⊢
  rw [List.range_succ, List.map_append, List.foldl_append, h]
  rfl

/-- A reader whose steps are primitive recursive is a computable function
of the hats it has read. -/
theorem Reader.computable_run {σ : Type} [Primcodable σ] (M : Reader σ)
    (h : Primrec₂ M.step) : Computable M.run := by
  have hstep : Primrec₂ fun (_ : List Bool) (p : (σ ⊕ ℕ) × Bool) =>
      (Sum.casesOn p.1 (fun q => M.step q p.2) (fun z => .inr z) : σ ⊕ ℕ) := by
    refine Primrec.sumCasesOn (Primrec.fst.comp Primrec.snd) ?_ ?_
    · exact (h.comp Primrec.snd (Primrec.snd.comp (Primrec.snd.comp Primrec.fst))).to₂
    · exact (Primrec.sumInr.comp Primrec.snd).to₂
  exact (Primrec.list_foldl Primrec.id (Primrec.const _) hstep).to_comp

/-! ### Following the lowest black hat -/

/-- The reader of the first picture: it counts the white hats, and stops
at the first black one. -/
def lowBlackReader : Reader ℕ where
  init := 0
  step n b := if b = true then .inr n else .inl (n + 1)

theorem lowBlackReader_after {t : Stack} {k : ℕ} (h : ∀ i < k, t i = false) :
    lowBlackReader.after t k = .inl k := by
  induction k with
  | zero => rfl
  | succ k ih =>
    rw [lowBlackReader.after_succ_of_inl t (ih fun i hi => h i (by omega))]
    simp [lowBlackReader, h k (by omega)]

/-- **The reader computes "follow the lowest black hat"** on every stack
that has a black hat. -/
theorem lowBlackReader_outputs {t : Stack} (h : ∃ i, t i = true) :
    lowBlackReader.Outputs t (lowBlackInf t) := by
  classical
  have hb := Nat.find_spec h
  have hq : ∀ q < Nat.find h, t q = false := fun q hq => by
    simpa using Nat.find_min h hq
  refine ⟨Nat.find h + 1, Nat.find h, ?_, (lowBlackInf_spec hb hq).symm⟩
  rw [lowBlackReader.after_succ_of_inl t (lowBlackReader_after hq)]
  simp [lowBlackReader, hb]

theorem lowBlackReader_computable : Computable lowBlackReader.run := by
  refine lowBlackReader.computable_run ?_
  exact Primrec.ite (Primrec.eq.comp Primrec.snd (Primrec.const true))
    (Primrec.sumInr.comp Primrec.fst) (Primrec.sumInl.comp (Primrec.succ.comp Primrec.fst))

/-! ### The Reyes strategies -/

/-- The choices of the Carter strategy on three hats. -/
def carter3 : List ℕ := [0, 1, 0, 0, 2, 1, 2, 0]

theorem carter3_eq {v : ℕ} (hv : v < 8) : (carter3.getD v 0 : ℤ) = carterOdd 1 v := by
  interval_cases v <;> decide

/-- The reader for the Reyes limit: `n` hats are behind, in blocks that
were all white or all black; the hats read in the current block make the
stack `v`, and the next one has weight `w` (1, 2 or 4). -/
def reyesReader : Reader (ℕ × ℕ × ℕ) where
  init := (0, 1, 0)
  step q b :=
    if q.2.1 = 4 then
      if q.2.1 * (if b = true then 1 else 0) + q.2.2 = 0
          ∨ q.2.1 * (if b = true then 1 else 0) + q.2.2 = 7 then .inl (q.1 + 3, 1, 0)
      else .inr (q.1 + carter3.getD (q.2.1 * (if b = true then 1 else 0) + q.2.2) 0)
    else .inl (q.1, 2 * q.2.1, q.2.1 * (if b = true then 1 else 0) + q.2.2)

/-- One more hat of the block that starts at position `m`. -/
theorem step_code (m c : ℕ) (t : Stack) :
    2 ^ c * (if t (m + c) = true then 1 else 0) + code c (drop m t) = code (c + 1) (drop m t) := by
  simp only [code, drop, Nat.add_comm c m]

theorem reyesReader_after {t : Stack} {i : ℕ}
    (h : ∀ i' < i, code 3 (drop (3 * i') t) = 0 ∨ code 3 (drop (3 * i') t) = 7) :
    ∀ c ≤ 2, reyesReader.after t (3 * i + c) = .inl (3 * i, 2 ^ c, code c (drop (3 * i) t)) := by
  have hne : ∀ c ≤ 1, (2 : ℕ) ^ c ≠ 4 := by
    intro c hc; interval_cases c <;> norm_num
  induction i with
  | zero =>
    intro c hc
    induction c with
    | zero => rfl
    | succ c ihc =>
      rw [← add_assoc, reyesReader.after_succ_of_inl t (ihc (by omega))]
      simp only [reyesReader, hne c (by omega), ↓reduceIte, step_code, pow_succ, mul_comm]
  | succ i ih =>
    have hprev := ih (fun i' hi' => h i' (by omega)) 2 le_rfl
    have hu := h i (Nat.lt_succ_self i)
    have hstart : reyesReader.after t (3 * (i + 1)) = .inl (3 * (i + 1), 1, 0) := by
      rw [show 3 * (i + 1) = 3 * i + 2 + 1 by ring, reyesReader.after_succ_of_inl t hprev]
      simp only [reyesReader, show (2 : ℕ) ^ 2 = 4 by norm_num, ↓reduceIte]
      rw [show (4 : ℕ) = 2 ^ 2 by norm_num, step_code]
      simp only [hu, ↓reduceIte]
    intro c hc
    induction c with
    | zero => simpa [code] using hstart
    | succ c ihc =>
      rw [← add_assoc, reyesReader.after_succ_of_inl t (ihc (by omega))]
      simp only [reyesReader, hne c (by omega), ↓reduceIte, step_code, pow_succ, mul_comm]

/-- **The reader computes the limit of the Reyes strategies** on every
stack with a block that is neither all white nor all black. -/
theorem reyesReader_outputs {t : Stack}
    (h : ∃ i, ¬ (code 3 (drop (3 * i) t) = 0 ∨ code 3 (drop (3 * i) t) = 7)) :
    reyesReader.Outputs t (reyesInf t) := by
  classical
  have hi := Nat.find_spec h
  have hlt : ∀ i' < Nat.find h,
      code 3 (drop (3 * i') t) = 0 ∨ code 3 (drop (3 * i') t) = 7 := fun i' hi' => by
    by_contra hn
    exact Nat.find_min h hi' hn
  refine ⟨3 * Nat.find h + 2 + 1,
    3 * Nat.find h + carter3.getD (code 3 (drop (3 * Nat.find h) t)) 0, ?_, ?_⟩
  · rw [reyesReader.after_succ_of_inl t (reyesReader_after hlt 2 le_rfl)]
    simp only [reyesReader, show (2 : ℕ) ^ 2 = 4 by norm_num, ↓reduceIte]
    rw [show (4 : ℕ) = 2 ^ 2 by norm_num, step_code]
    simp only [hi, ↓reduceIte]
  · rw [reyesInf_spec hi hlt]
    push_cast
    rw [carter3_eq (code_lt 3 _)]

theorem reyesReader_computable : Computable reyesReader.run := by
  refine reyesReader.computable_run ?_
  have n : Primrec fun p : (ℕ × ℕ × ℕ) × Bool => p.1.1 := Primrec.fst.comp Primrec.fst
  have w : Primrec fun p : (ℕ × ℕ × ℕ) × Bool => p.1.2.1 :=
    Primrec.fst.comp (Primrec.snd.comp Primrec.fst)
  have v : Primrec fun p : (ℕ × ℕ × ℕ) × Bool => p.1.2.2 :=
    Primrec.snd.comp (Primrec.snd.comp Primrec.fst)
  have bit : Primrec fun p : (ℕ × ℕ × ℕ) × Bool => (if p.2 = true then 1 else 0 : ℕ) :=
    Primrec.ite (Primrec.eq.comp Primrec.snd (Primrec.const true)) (Primrec.const 1)
      (Primrec.const 0)
  have v' : Primrec fun p : (ℕ × ℕ × ℕ) × Bool =>
      p.1.2.1 * (if p.2 = true then 1 else 0) + p.1.2.2 :=
    Primrec.nat_add.comp (Primrec.nat_mul.comp w bit) v
  refine Primrec.ite (Primrec.eq.comp w (Primrec.const 4)) ?_ ?_
  · refine Primrec.ite ((Primrec.eq.comp v' (Primrec.const 0)).or
      (Primrec.eq.comp v' (Primrec.const 7))) ?_ ?_
    · exact Primrec.sumInl.comp (Primrec.pair (Primrec.nat_add.comp n (Primrec.const 3))
        (Primrec.const (1, 0)))
    · exact Primrec.sumInr.comp (Primrec.nat_add.comp n
        ((Primrec.list_getD 0).comp (Primrec.const carter3) v'))
  · exact Primrec.sumInl.comp (Primrec.pair n
      (Primrec.pair (Primrec.nat_mul.comp (Primrec.const 2) w) v'))

/-! ### The Carter strategies -/

/-- What the Carter strategy on two more hats chooses, when the hats below
are all white or all black: the six stacks that the reader tells apart.
`2 ^ (2 * j + 1) * c` puts the stack `c` of two hats on top of white
hats. -/
theorem carterOdd_succ_values (j : ℕ) :
    carterOdd (j + 1) (2 ^ (2 * j + 1) * 1) = 0
    ∧ carterOdd (j + 1) (2 ^ (2 * j + 1) * 2) = 2 * j + 2
    ∧ carterOdd (j + 1) (2 ^ (2 * j + 1) * 3) = 2 * j + 2
    ∧ carterOdd (j + 1) (2 ^ (2 * j + 1) - 1) = 2 * j + 1
    ∧ carterOdd (j + 1) (2 ^ (2 * j + 1) * 2 + (2 ^ (2 * j + 1) - 1)) = 2 * j + 1
    ∧ carterOdd (j + 1) (2 ^ (2 * j + 1) * 1 + (2 ^ (2 * j + 1) - 1)) = 0 := by
  set n := 2 * j + 1 with hn
  have hP : 2 ≤ 2 ^ n := by
    have : 2 ^ 1 ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) (by omega)
    simpa using this
  have hQ : 2 ^ (n + 1) = 2 * 2 ^ n := by rw [pow_succ]; ring
  have z := carterOdd_zero j
  have o := carterOdd_ones j
  rw [← hn] at o
  have m1 : 2 ^ n % (2 * 2 ^ n) = 2 ^ n := Nat.mod_eq_of_lt (by omega)
  have m2 : (2 ^ n - 1) % (2 * 2 ^ n) = 2 ^ n - 1 := Nat.mod_eq_of_lt (by omega)
  have m3 : (2 ^ n * 2 + (2 ^ n - 1)) % (2 * 2 ^ n) = 2 ^ n - 1 := by
    rw [show 2 ^ n * 2 + (2 ^ n - 1) = 2 ^ n - 1 + 2 * 2 ^ n * 1 by ring,
      Nat.add_mul_mod_self_left, m2]
  have m4 : (2 ^ n * 1 + (2 ^ n - 1)) % (2 * 2 ^ n) = 2 ^ n * 1 + (2 ^ n - 1) :=
    Nat.mod_eq_of_lt (by omega)
  have m5 : (2 ^ n * 1 + (2 ^ n - 1)) % 2 ^ n = 2 ^ n - 1 := by
    rw [Nat.mul_add_mod, Nat.mod_eq_of_lt (by omega)]
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
  · have a1 : 2 ^ n * 1 ≠ 2 * 2 ^ n + 2 ^ n := by omega
    have a2 : 2 ^ n * 1 ≠ 2 * 2 ^ n := by omega
    have a3 : 2 ^ n ≠ 2 ^ n - 1 := by omega
    have a4 : 2 ^ n * 1 % (2 * 2 ^ n) = 2 ^ n := by rw [mul_one, m1]
    simp only [carterOdd, ← hn, ds, ls, rs, hQ, a1, a2, a4, a3, ↓reduceIte, Nat.mod_self, z]
  · have a2 : 2 ^ n * 2 = 2 * 2 ^ n := by ring
    simp only [carterOdd, ← hn, ds, ls, hQ, a2, ↓reduceIte]
    split_ifs <;> (rw [hn]; push_cast; ring)
  · have a1 : 2 ^ n * 3 = 2 * 2 ^ n + 2 ^ n := by ring
    simp only [carterOdd, ← hn, ds, hQ, a1, ↓reduceIte]
    rw [hn]; push_cast; ring
  · have a1 : 2 ^ n - 1 ≠ 2 * 2 ^ n + 2 ^ n := by omega
    have a2 : 2 ^ n - 1 ≠ 2 * 2 ^ n := by omega
    simp only [carterOdd, ← hn, ds, ls, rs, hQ, a1, a2, m2, ↓reduceIte]
    rw [hn]; push_cast; ring
  · have a1 : 2 ^ n * 2 + (2 ^ n - 1) ≠ 2 * 2 ^ n + 2 ^ n := by omega
    have a2 : 2 ^ n * 2 + (2 ^ n - 1) ≠ 2 * 2 ^ n := by omega
    simp only [carterOdd, ← hn, ds, ls, rs, hQ, a1, a2, m3, ↓reduceIte]
    rw [hn]; push_cast; ring
  · have a1 : 2 ^ n * 1 + (2 ^ n - 1) ≠ 2 * 2 ^ n + 2 ^ n := by omega
    have a2 : 2 ^ n * 1 + (2 ^ n - 1) ≠ 2 * 2 ^ n := by omega
    have a3 : 2 ^ n * 1 + (2 ^ n - 1) ≠ 2 ^ n - 1 := by omega
    simp only [carterOdd, ← hn, ds, ls, rs, hQ, a1, a2, m4, a3, m5, ↓reduceIte, o]

/-- The reader for the Carter limit, as in the picture of the article.  A
state is a kind and a counter `n`.  The kinds: `0` at the start; `1` after
`n + 1` hats, all white; `2` after one more white hat; `3` after a black
hat instead; `4` and `5` like `1` and `2` with the colors exchanged. -/
def carterReader : Reader (ℕ × ℕ) where
  init := (0, 0)
  step q b :=
    if q.1 = 0 then (if b = true then .inl (4, 0) else .inl (1, 0))
    else if q.1 = 1 then (if b = true then .inl (3, q.2) else .inl (2, q.2))
    else if q.1 = 2 then (if b = true then .inr (q.2 + 2) else .inl (1, q.2 + 2))
    else if q.1 = 3 then (if b = true then .inr (q.2 + 2) else .inr 0)
    else if q.1 = 4 then (if b = true then .inl (5, q.2) else .inr (q.2 + 1))
    else (if b = true then .inl (4, q.2 + 2) else .inr 0)

theorem carterReader_after_white {t : Stack} (j : ℕ) (h : ∀ i < 2 * j + 1, t i = false) :
    carterReader.after t (2 * j + 1) = .inl (1, 2 * j) := by
  induction j with
  | zero =>
    rw [carterReader.after_succ_of_inl t (q := (0, 0)) rfl]
    simp [carterReader, h 0 (by omega)]
  | succ j ih =>
    have h1 := ih fun i hi => h i (by omega)
    have h2 : carterReader.after t (2 * j + 1 + 1) = .inl (2, 2 * j) := by
      rw [carterReader.after_succ_of_inl t h1]
      simp [carterReader, h (2 * j + 1) (by omega)]
    rw [show 2 * (j + 1) + 1 = 2 * j + 1 + 1 + 1 by ring, carterReader.after_succ_of_inl t h2]
    simp [carterReader, h (2 * j + 1 + 1) (by omega), mul_add]

theorem carterReader_after_black {t : Stack} (j : ℕ) (h : ∀ i < 2 * j + 1, t i = true) :
    carterReader.after t (2 * j + 1) = .inl (4, 2 * j) := by
  induction j with
  | zero =>
    rw [carterReader.after_succ_of_inl t (q := (0, 0)) rfl]
    simp [carterReader, h 0 (by omega)]
  | succ j ih =>
    have h1 := ih fun i hi => h i (by omega)
    have h2 : carterReader.after t (2 * j + 1 + 1) = .inl (5, 2 * j) := by
      rw [carterReader.after_succ_of_inl t h1]
      simp [carterReader, h (2 * j + 1) (by omega)]
    rw [show 2 * (j + 1) + 1 = 2 * j + 1 + 1 + 1 by ring, carterReader.after_succ_of_inl t h2]
    simp [carterReader, h (2 * j + 1 + 1) (by omega), mul_add]

/-- The two hats above the `2 * j + 1` lowest, as a stack of two hats. -/
theorem code_two_above (j : ℕ) (t : Stack) :
    code (2 * (j + 1) + 1) t
      = 2 ^ (2 * j + 1) * ((if t (2 * j + 1) = true then 1 else 0)
          + 2 * (if t (2 * j + 1 + 1) = true then 1 else 0)) + code (2 * j + 1) t := by
  rw [show 2 * (j + 1) + 1 = 2 * j + 1 + 2 by ring, code_add]
  have : code 2 (drop (2 * j + 1) t)
      = (if t (2 * j + 1) = true then 1 else 0) + 2 * (if t (2 * j + 1 + 1) = true then 1 else 0) := by
    simp only [code, drop, Nat.zero_add, pow_zero, pow_one, one_mul, add_zero,
      Nat.add_comm 1 (2 * j + 1)]
    ring
  rw [this]

/-- **The reader computes the limit of the Carter strategies** on every
stack that is neither all white nor all black. -/
theorem carterReader_outputs {t : Stack}
    (h : ∃ k, code (2 * k + 1) t ∉ ({0, 2 ^ (2 * k + 1) - 1} : Finset ℕ)) :
    carterReader.Outputs t (carterInf t) := by
  classical
  have hk := Nat.find_spec h
  obtain ⟨j, hj⟩ : ∃ j, Nat.find h = j + 1 := by
    rcases Nat.exists_eq_succ_of_ne_zero (n := Nat.find h) (fun h0 => by
      rw [h0] at hk
      have := code_lt 1 t
      simp at hk
      omega) with ⟨j, hj⟩
    exact ⟨j, hj⟩
  rw [hj] at hk
  have hprev : code (2 * j + 1) t ∈ ({0, 2 ^ (2 * j + 1) - 1} : Finset ℕ) := by
    by_contra hn
    exact Nat.find_min h (by omega : j < Nat.find h) hn
  have hval : carterInf t = carterOdd (j + 1) (code (2 * (j + 1) + 1) t) :=
    (limitOf_eq carter_settles hk (j + 1) le_rfl).symm
  obtain ⟨v1, v2, v3, v4, v5, v6⟩ := carterOdd_succ_values j
  have hcode := code_two_above j t
  simp only [Finset.mem_insert, Finset.mem_singleton, not_or] at hk hprev
  rcases hprev with h0 | h1
  · -- the hats below are white
    have hw := (code_eq_zero_iff _ _).mp h0
    have hs := carterReader_after_white j hw
    rw [h0, add_zero] at hcode
    cases hx : t (2 * j + 1) <;> cases hy : t (2 * j + 1 + 1)
    · exfalso
      apply hk.1
      rw [hcode]; simp [hx, hy]
    · have s1 : carterReader.after t (2 * j + 1 + 1) = .inl (2, 2 * j) := by
        rw [carterReader.after_succ_of_inl t hs]; simp [carterReader, hx]
      refine ⟨2 * j + 1 + 1 + 1, 2 * j + 2, ?_, ?_⟩
      · rw [carterReader.after_succ_of_inl t s1]; simp [carterReader, hy]
      · rw [hval, hcode]
        simp only [hx, hy, Bool.false_eq_true, ↓reduceIte, zero_add, mul_one, v2]
        push_cast; ring
    · have s1 : carterReader.after t (2 * j + 1 + 1) = .inl (3, 2 * j) := by
        rw [carterReader.after_succ_of_inl t hs]; simp [carterReader, hx]
      refine ⟨2 * j + 1 + 1 + 1, 0, ?_, ?_⟩
      · rw [carterReader.after_succ_of_inl t s1]; simp [carterReader, hy]
      · rw [hval, hcode]
        simp only [hx, hy, Bool.false_eq_true, ↓reduceIte, mul_zero, add_zero, v1]
        rfl
    · have s1 : carterReader.after t (2 * j + 1 + 1) = .inl (3, 2 * j) := by
        rw [carterReader.after_succ_of_inl t hs]; simp [carterReader, hx]
      refine ⟨2 * j + 1 + 1 + 1, 2 * j + 2, ?_, ?_⟩
      · rw [carterReader.after_succ_of_inl t s1]; simp [carterReader, hy]
      · rw [hval, hcode]
        simp only [hx, hy, ↓reduceIte, mul_one, show (1 : ℕ) + 2 = 3 by norm_num, v3]
        push_cast; ring
  · -- the hats below are black
    have hb := (code_eq_ones_iff _ _).mp h1
    have hs := carterReader_after_black j hb
    rw [h1] at hcode
    cases hx : t (2 * j + 1) <;> cases hy : t (2 * j + 1 + 1)
    · refine ⟨2 * j + 1 + 1, 2 * j + 1, ?_, ?_⟩
      · rw [carterReader.after_succ_of_inl t hs]; simp [carterReader, hx]
      · rw [hval, hcode]
        simp only [hx, hy, Bool.false_eq_true, ↓reduceIte, mul_zero, add_zero, zero_add, v4]
        push_cast; ring
    · refine ⟨2 * j + 1 + 1, 2 * j + 1, ?_, ?_⟩
      · rw [carterReader.after_succ_of_inl t hs]; simp [carterReader, hx]
      · rw [hval, hcode]
        simp only [hx, hy, Bool.false_eq_true, ↓reduceIte, zero_add, mul_one, v5]
        push_cast; ring
    · have s1 : carterReader.after t (2 * j + 1 + 1) = .inl (5, 2 * j) := by
        rw [carterReader.after_succ_of_inl t hs]; simp [carterReader, hx]
      refine ⟨2 * j + 1 + 1 + 1, 0, ?_, ?_⟩
      · rw [carterReader.after_succ_of_inl t s1]; simp [carterReader, hy]
      · rw [hval, hcode]
        simp only [hx, hy, Bool.false_eq_true, ↓reduceIte, mul_zero, add_zero, v6]
        rfl
    · exfalso
      apply hk.2
      rw [hcode]
      simp only [hx, hy, ↓reduceIte, mul_one]
      have e : 2 ^ (2 * (j + 1) + 1) = 2 ^ (2 * j + 1) * 4 := by
        rw [show 2 * (j + 1) + 1 = 2 * j + 1 + 2 by ring, pow_add]; norm_num
      have := Nat.two_pow_pos (2 * j + 1)
      omega

theorem carterReader_computable : Computable carterReader.run := by
  refine carterReader.computable_run ?_
  have k : Primrec fun p : (ℕ × ℕ) × Bool => p.1.1 := Primrec.fst.comp Primrec.fst
  have n : Primrec fun p : (ℕ × ℕ) × Bool => p.1.2 := Primrec.snd.comp Primrec.fst
  have b : PrimrecPred fun p : (ℕ × ℕ) × Bool => p.2 = true :=
    Primrec.eq.comp Primrec.snd (Primrec.const true)
  have n1 : Primrec fun p : (ℕ × ℕ) × Bool => p.1.2 + 1 :=
    Primrec.nat_add.comp n (Primrec.const 1)
  have n2 : Primrec fun p : (ℕ × ℕ) × Bool => p.1.2 + 2 :=
    Primrec.nat_add.comp n (Primrec.const 2)
  have st : ∀ c : ℕ, ∀ {f : (ℕ × ℕ) × Bool → ℕ}, Primrec f →
      Primrec fun p : (ℕ × ℕ) × Bool => (Sum.inl (c, f p) : (ℕ × ℕ) ⊕ ℕ) := fun c _ hf =>
    Primrec.sumInl.comp (Primrec.pair (Primrec.const c) hf)
  have out : ∀ {f : (ℕ × ℕ) × Bool → ℕ}, Primrec f →
      Primrec fun p : (ℕ × ℕ) × Bool => (Sum.inr (f p) : (ℕ × ℕ) ⊕ ℕ) := fun hf =>
    Primrec.sumInr.comp hf
  have z0 : Primrec fun _ : (ℕ × ℕ) × Bool => (0 : ℕ) := Primrec.const 0
  refine Primrec.ite (Primrec.eq.comp k (Primrec.const 0))
    (Primrec.ite b (st 4 z0) (st 1 z0)) ?_
  refine Primrec.ite (Primrec.eq.comp k (Primrec.const 1))
    (Primrec.ite b (st 3 n) (st 2 n)) ?_
  refine Primrec.ite (Primrec.eq.comp k (Primrec.const 2))
    (Primrec.ite b (out n2) (st 1 n2)) ?_
  refine Primrec.ite (Primrec.eq.comp k (Primrec.const 3))
    (Primrec.ite b (out n2) (out z0)) ?_
  refine Primrec.ite (Primrec.eq.comp k (Primrec.const 4))
    (Primrec.ite b (st 5 n) (out n1)) ?_
  exact Primrec.ite b (st 4 n2) (out z0)

end Hats
