-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Topology

/-!
# The limit strategies, computed by reading the hats one at a time

The third article says that the limit strategies are computable, and draws
each as an automaton that reads the stream of hats of a stack, from the
bottom up, and stops with the position to point at.  Here such a machine
is a *reader*: it has a state, and each hat either changes the state or
makes it stop with an output.  The three readers below have finitely many
kinds of states and one counter, as in the pictures.

For each limit strategy: on every stack where the strategy is defined, the
reader stops, and its output is what the strategy chooses.
-/

namespace Hats

/-- A machine that reads the hats of a stack from the bottom up.  From a
state and a hat, `step` gives the next state, or the output. -/
structure Reader (σ : Type) where
  init : σ
  step : σ → Bool → σ ⊕ ℤ

/-- Where the reader is after `k` hats of stack `t`: in a state, or stopped
with an output. -/
def Reader.after {σ : Type} (M : Reader σ) (t : Stack) : ℕ → σ ⊕ ℤ
  | 0 => .inl M.init
  | k + 1 =>
    match M.after t k with
    | .inl q => M.step q (t k)
    | .inr z => .inr z

/-- The reader stops on stack `t` with output `z`. -/
def Reader.Outputs {σ : Type} (M : Reader σ) (t : Stack) (z : ℤ) : Prop :=
  ∃ k, M.after t k = .inr z

theorem Reader.after_succ_of_inl {σ : Type} (M : Reader σ) (t : Stack) {k : ℕ} {q : σ}
    (h : M.after t k = .inl q) : M.after t (k + 1) = M.step q (t k) := by
  simp [Reader.after, h]

/-! ### Following the lowest black hat -/

/-- The reader of the first picture: it counts the white hats, and stops
at the first black one. -/
def lowBlackReader : Reader ℕ where
  init := 0
  step n b := if b then .inr n else .inl (n + 1)

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
  refine ⟨Nat.find h + 1, ?_⟩
  rw [lowBlackReader.after_succ_of_inl t (lowBlackReader_after hq), lowBlackInf_spec hb hq]
  simp [lowBlackReader, hb]

/-! ### The Reyes strategies -/

/-- The reader for the Reyes limit: `n` hats are behind, in blocks that
were all white or all black; of the current block, `c` hats were read,
which make the stack `v`. -/
def reyesReader : Reader (ℕ × ℕ × ℕ) where
  init := (0, 0, 0)
  step q b :=
    let v' := 2 ^ q.2.1 * (if b then 1 else 0) + q.2.2
    if q.2.1 = 2 then
      if v' = 0 ∨ v' = 7 then .inl (q.1 + 3, 0, 0) else .inr (q.1 + carterOdd 1 v')
    else .inl (q.1, q.2.1 + 1, v')

/-- One more hat of the block that starts at position `m`. -/
theorem step_code (m c : ℕ) (t : Stack) :
    2 ^ c * (if t (m + c) = true then 1 else 0) + code c (drop m t) = code (c + 1) (drop m t) := by
  simp only [code, drop, Nat.add_comm c m]

theorem reyesReader_after {t : Stack} {i : ℕ}
    (h : ∀ i' < i, code 3 (drop (3 * i') t) = 0 ∨ code 3 (drop (3 * i') t) = 7) :
    ∀ c ≤ 2, reyesReader.after t (3 * i + c) = .inl (3 * i, c, code c (drop (3 * i) t)) := by
  induction i with
  | zero =>
    intro c hc
    induction c with
    | zero => rfl
    | succ c ihc =>
      rw [← add_assoc, reyesReader.after_succ_of_inl t (ihc (by omega))]
      have : c ≠ 2 := by omega
      simp only [reyesReader, this, ↓reduceIte, step_code]
  | succ i ih =>
    have hprev := ih (fun i' hi' => h i' (by omega)) 2 le_rfl
    have hu := h i (Nat.lt_succ_self i)
    have hstart : reyesReader.after t (3 * (i + 1)) = .inl (3 * (i + 1), 0, 0) := by
      rw [show 3 * (i + 1) = 3 * i + 2 + 1 by ring, reyesReader.after_succ_of_inl t hprev]
      simp only [reyesReader, ↓reduceIte, step_code, hu]
    intro c hc
    induction c with
    | zero => simpa [code] using hstart
    | succ c ihc =>
      rw [← add_assoc, reyesReader.after_succ_of_inl t (ihc (by omega))]
      have : c ≠ 2 := by omega
      simp only [reyesReader, this, ↓reduceIte, step_code]

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
  refine ⟨3 * Nat.find h + 2 + 1, ?_⟩
  rw [reyesReader.after_succ_of_inl t (reyesReader_after hlt 2 le_rfl), reyesInf_spec hi hlt]
  simp only [reyesReader, ↓reduceIte, step_code, hi]
  push_cast
  rfl

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

/-- The states of the reader for the Carter limit, as in the picture of
the article.  In `white n` the reader has seen `n + 1` hats, all white, in
`white2 n` one more white hat, in `whiteBlack n` a black hat after them;
and the same with the colors exchanged for `black n` and `black2 n`. -/
inductive CarterState
  | start
  | white (n : ℕ)
  | white2 (n : ℕ)
  | whiteBlack (n : ℕ)
  | black (n : ℕ)
  | black2 (n : ℕ)

/-- The reader for the Carter limit. -/
def carterReader : Reader CarterState where
  init := .start
  step q b :=
    match q, b with
    | .start, false => .inl (.white 0)
    | .start, true => .inl (.black 0)
    | .white n, false => .inl (.white2 n)
    | .white n, true => .inl (.whiteBlack n)
    | .white2 n, false => .inl (.white (n + 2))
    | .white2 n, true => .inr (n + 2)
    | .whiteBlack _, false => .inr 0
    | .whiteBlack n, true => .inr (n + 2)
    | .black n, false => .inr (n + 1)
    | .black n, true => .inl (.black2 n)
    | .black2 _, false => .inr 0
    | .black2 n, true => .inl (.black (n + 2))

theorem carterReader_after_white {t : Stack} (j : ℕ) (h : ∀ i < 2 * j + 1, t i = false) :
    carterReader.after t (2 * j + 1) = .inl (.white (2 * j)) := by
  induction j with
  | zero =>
    rw [carterReader.after_succ_of_inl t (q := .start) rfl]
    simp [carterReader, h 0 (by omega)]
  | succ j ih =>
    have h1 := ih fun i hi => h i (by omega)
    have h2 : carterReader.after t (2 * j + 1 + 1) = .inl (.white2 (2 * j)) := by
      rw [carterReader.after_succ_of_inl t h1]
      simp [carterReader, h (2 * j + 1) (by omega)]
    rw [show 2 * (j + 1) + 1 = 2 * j + 1 + 1 + 1 by ring, carterReader.after_succ_of_inl t h2]
    simp [carterReader, h (2 * j + 1 + 1) (by omega), mul_add]

theorem carterReader_after_black {t : Stack} (j : ℕ) (h : ∀ i < 2 * j + 1, t i = true) :
    carterReader.after t (2 * j + 1) = .inl (.black (2 * j)) := by
  induction j with
  | zero =>
    rw [carterReader.after_succ_of_inl t (q := .start) rfl]
    simp [carterReader, h 0 (by omega)]
  | succ j ih =>
    have h1 := ih fun i hi => h i (by omega)
    have h2 : carterReader.after t (2 * j + 1 + 1) = .inl (.black2 (2 * j)) := by
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
    · refine ⟨2 * j + 1 + 1 + 1, ?_⟩
      have s1 : carterReader.after t (2 * j + 1 + 1) = .inl (.white2 (2 * j)) := by
        rw [carterReader.after_succ_of_inl t hs]; simp [carterReader, hx]
      rw [carterReader.after_succ_of_inl t s1, hval, hcode]
      simp only [hx, hy, Bool.false_eq_true, ↓reduceIte, zero_add, mul_one, v2, carterReader]
      push_cast; ring_nf
    · refine ⟨2 * j + 1 + 1 + 1, ?_⟩
      have s1 : carterReader.after t (2 * j + 1 + 1) = .inl (.whiteBlack (2 * j)) := by
        rw [carterReader.after_succ_of_inl t hs]; simp [carterReader, hx]
      rw [carterReader.after_succ_of_inl t s1, hval, hcode]
      simp only [hx, hy, Bool.false_eq_true, ↓reduceIte, mul_zero, add_zero, v1, carterReader]
    · refine ⟨2 * j + 1 + 1 + 1, ?_⟩
      have s1 : carterReader.after t (2 * j + 1 + 1) = .inl (.whiteBlack (2 * j)) := by
        rw [carterReader.after_succ_of_inl t hs]; simp [carterReader, hx]
      rw [carterReader.after_succ_of_inl t s1, hval, hcode]
      simp only [hx, hy, ↓reduceIte, mul_one, show (1 : ℕ) + 2 = 3 by norm_num, v3, carterReader]
      push_cast; ring_nf
  · -- the hats below are black
    have hb := (code_eq_ones_iff _ _).mp h1
    have hs := carterReader_after_black j hb
    rw [h1] at hcode
    cases hx : t (2 * j + 1) <;> cases hy : t (2 * j + 1 + 1)
    · refine ⟨2 * j + 1 + 1, ?_⟩
      rw [carterReader.after_succ_of_inl t hs, hval, hcode]
      simp only [hx, hy, Bool.false_eq_true, ↓reduceIte, mul_zero, add_zero, zero_add, v4,
        carterReader]
      push_cast; ring_nf
    · refine ⟨2 * j + 1 + 1, ?_⟩
      rw [carterReader.after_succ_of_inl t hs, hval, hcode]
      simp only [hx, hy, Bool.false_eq_true, ↓reduceIte, zero_add, mul_one, v5, carterReader]
      push_cast; ring_nf
    · refine ⟨2 * j + 1 + 1 + 1, ?_⟩
      have s1 : carterReader.after t (2 * j + 1 + 1) = .inl (.black2 (2 * j)) := by
        rw [carterReader.after_succ_of_inl t hs]; simp [carterReader, hx]
      rw [carterReader.after_succ_of_inl t s1, hval, hcode]
      simp only [hx, hy, Bool.false_eq_true, ↓reduceIte, mul_zero, add_zero, v6, carterReader]
    · exfalso
      apply hk.2
      rw [hcode]
      simp only [hx, hy, ↓reduceIte, mul_one]
      have e : 2 ^ (2 * (j + 1) + 1) = 2 ^ (2 * j + 1) * 4 := by
        rw [show 2 * (j + 1) + 1 = 2 * j + 1 + 2 by ring, pow_add]; norm_num
      have := Nat.two_pow_pos (2 * j + 1)
      omega

end Hats
