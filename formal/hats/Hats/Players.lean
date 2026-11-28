-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Substitute

/-!
# Any number of players: the wins of a reset

The players are the elements of a finite type `ι`, at least two of them.
Each has a stack of hats, sees the stacks of the others and points at a
position of their own stack; they win when all the hats pointed at are
black.  A strategy `s` gives, for the player `i` and the stacks `a` of
everybody, the position `s i a`; it is *blind* when `s i a` does not depend
on the player's own stack `a i`.  Different players may play differently.

The reset of `S` (on `T` hats) by `M` (on `k` hats), after Buhler,
Freiling, Graham, Kariv, Roche, Tiefenbruck, Van Alten and Yeroshkin: a
player who sees a stack that is all white on its `T` lowest hats, or sees
only stacks that are all black there, plays `M` on the `k` hats above;
any other player plays `S` on the `T` lowest hats.

`winsN_reset`: the result has `(2 ^ k) ^ n * (wins S - 1) + R * wins M`
wins, where `n` is the number of players and `R` the number of ways to
choose the `T` lowest hats of everybody so that all the players go up.
-/

namespace Hats

open Finset Function

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- What the stacks `a` contribute to the wins of `s`. -/
def termN (s : ι → (ι → ℕ) → ℤ) (a : ι → ℕ) : ℕ := ∏ i, hat (a i) (s i a)

/-- The wins of `s` when every stack is a number below `N`. -/
def winsN (N : ℕ) (s : ι → (ι → ℕ) → ℤ) : ℕ :=
  ∑ a : ι → Fin N, termN s (fun i => (a i : ℕ))

/-- A strategy on `T` hats is proper when it always points inside the
stack. -/
def ProperN (T : ℕ) (s : ι → (ι → ℕ) → ℤ) : Prop :=
  ∀ i (a : ι → ℕ), (∀ j, a j < 2 ^ T) → 0 ≤ s i a ∧ s i a < T

/-- A strategy is blind when no player uses their own stack. -/
def Blind (s : ι → (ι → ℕ) → ℤ) : Prop :=
  ∀ i (a b : ι → ℕ), (∀ j, j ≠ i → a j = b j) → s i a = s i b

/-- The player `i`, who sees the lower parts `l` of the others, goes up. -/
def goN (T : ℕ) (i : ι) (l : ι → ℕ) : Prop :=
  (∃ j, j ≠ i ∧ l j = 0) ∨ ∀ j, j ≠ i → l j = 2 ^ T - 1

instance (T : ℕ) (i : ι) (l : ι → ℕ) : Decidable (goN T i l) := by
  unfold goN; infer_instance

/-- `S` (on `T` hats) reset by `M`. -/
def resetN (T : ℕ) (S M : ι → (ι → ℕ) → ℤ) : ι → (ι → ℕ) → ℤ := fun i a =>
  if goN T i (fun j => a j % 2 ^ T) then T + M i (fun j => a j / 2 ^ T)
  else S i (fun j => a j % 2 ^ T)

/-- What the stacks with given lower parts contribute. -/
def blockN (T k : ℕ) (s : ι → (ι → ℕ) → ℤ) (l : ι → ℕ) : ℕ :=
  ∑ x : ι → Fin (2 ^ k), termN s (fun i => 2 ^ T * (x i : ℕ) + l i)

/-- The wins on `T + k` hats, sorted by the `T` lowest hats of everybody. -/
theorem winsN_split (T k : ℕ) (s : ι → (ι → ℕ) → ℤ) :
    winsN (2 ^ (T + k)) s = ∑ l : ι → Fin (2 ^ T), blockN T k s (fun i => (l i : ℕ)) := by
  rw [show 2 ^ (T + k) = 2 ^ k * 2 ^ T by ring]
  unfold winsN blockN
  let e : ((ι → Fin (2 ^ k)) × (ι → Fin (2 ^ T))) ≃ (ι → Fin (2 ^ k * 2 ^ T)) :=
    (Equiv.arrowProdEquivProdArrow _ _ _).symm.trans
      (Equiv.piCongrRight fun _ => finProdFinEquiv)
  rw [← e.sum_comp, Fintype.sum_prod_type, sum_comm]
  refine sum_congr rfl fun l _ => sum_congr rfl fun x _ => ?_
  congr 1
  funext i
  simp [e, finProdFinEquiv]
  ring

section

variable {T k : ℕ} {S M : ι → (ι → ℕ) → ℤ}

omit [Fintype ι] [DecidableEq ι] in
theorem lower_eq {l : ι → ℕ} (hl : ∀ j, l j < 2 ^ T) (x : ι → ℕ) :
    (fun j => (2 ^ T * x j + l j) % 2 ^ T) = l := by
  funext j
  rw [Nat.mul_add_mod, Nat.mod_eq_of_lt (hl j)]

omit [Fintype ι] [DecidableEq ι] in
theorem upper_eq {l : ι → ℕ} (hl : ∀ j, l j < 2 ^ T) (x : ι → ℕ) :
    (fun j => (2 ^ T * x j + l j) / 2 ^ T) = x := by
  funext j
  rw [Nat.mul_add_div (Nat.two_pow_pos T), Nat.div_eq_of_lt (hl j), add_zero]

/-- The hat pointed at by a player who goes up. -/
theorem facN_up (S : ι → (ι → ℕ) → ℤ) (hM : ProperN k M) {l : ι → ℕ}
    (hl : ∀ j, l j < 2 ^ T) (x : ι → Fin (2 ^ k)) {i : ι} (h : goN T i l) :
    hat (2 ^ T * (x i : ℕ) + l i)
        (resetN T S M i (fun j => 2 ^ T * (x j : ℕ) + l j))
      = hat (x i) (M i (fun j => (x j : ℕ))) := by
  unfold resetN
  rw [lower_eq hl, upper_eq hl]
  simp only [h, ↓reduceIte]
  rw [hat_above _ (hl i) (hM i _ fun j => (x j).isLt).1]

/-- The hat pointed at by a player who stays. -/
theorem facN_stay (M : ι → (ι → ℕ) → ℤ) (hS : ProperN T S) {l : ι → ℕ}
    (hl : ∀ j, l j < 2 ^ T) (x : ι → Fin (2 ^ k)) {i : ι} (h : ¬ goN T i l) :
    hat (2 ^ T * (x i : ℕ) + l i)
        (resetN T S M i (fun j => 2 ^ T * (x j : ℕ) + l j))
      = hat (l i) (S i l) := by
  unfold resetN
  rw [lower_eq hl]
  simp only [h, ↓reduceIte]
  rw [hat_low _ (hl i) (hS i l hl).1 (hS i l hl).2]

/-- Everybody goes up. -/
theorem blockN_all (S : ι → (ι → ℕ) → ℤ) (hM : ProperN k M) {l : ι → ℕ}
    (hl : ∀ j, l j < 2 ^ T) (h : ∀ i, goN T i l) :
    blockN T k (resetN T S M) l = winsN (2 ^ k) M := by
  unfold blockN winsN termN
  exact sum_congr rfl fun x _ => prod_congr rfl fun i _ => facN_up S hM hl x (h i)

/-- Nobody goes up. -/
theorem blockN_none (M : ι → (ι → ℕ) → ℤ) (hS : ProperN T S) {l : ι → ℕ}
    (hl : ∀ j, l j < 2 ^ T) (h : ∀ i, ¬ goN T i l) :
    blockN T k (resetN T S M) l = (2 ^ k) ^ Fintype.card ι * termN S l := by
  have term : ∀ x : ι → Fin (2 ^ k),
      termN (resetN T S M) (fun i => 2 ^ T * (x i : ℕ) + l i) = termN S l := by
    intro x
    unfold termN
    exact prod_congr rfl fun i _ => facN_stay M hS hl x (h i)
  unfold blockN
  simp [term]

/-- A player whose lowest hats are all white stays: no win. -/
theorem blockN_zero (M : ι → (ι → ℕ) → ℤ) (hS : ProperN T S) {l : ι → ℕ}
    (hl : ∀ j, l j < 2 ^ T) {i : ι} (h : ¬ goN T i l) (h0 : l i = 0) :
    blockN T k (resetN T S M) l = 0 := by
  unfold blockN
  refine sum_eq_zero fun x _ => ?_
  unfold termN
  refine prod_eq_zero (mem_univ i) ?_
  rw [facN_stay M hS hl x h, h0, hat_zero]

omit [DecidableEq ι] in
theorem termN_zero (S : ι → (ι → ℕ) → ℤ) {l : ι → ℕ} {i : ι} (h0 : l i = 0) :
    termN S l = 0 := by
  unfold termN
  refine prod_eq_zero (mem_univ i) ?_
  rw [h0, hat_zero]

/-- A sum over the stacks of everybody, of the hat of one player at a
position that the others decide: half of the stacks. -/
theorem sum_coord (i : ι) (q : (ι → ℕ) → ℤ)
    (hblind : ∀ a b : ι → ℕ, (∀ j, j ≠ i → a j = b j) → q a = q b)
    (hq : ∀ a : ι → ℕ, (∀ j, a j < 2 ^ k) → 0 ≤ q a ∧ q a < k) :
    2 ^ k * ∑ x : ι → Fin (2 ^ k), hat (x i) (q fun j => (x j : ℕ))
      = (2 ^ k) ^ Fintype.card ι * 2 ^ (k - 1) := by
  -- exchange the stack of `i` with a spare one
  let φ : (ι → Fin (2 ^ k)) × Fin (2 ^ k) → (ι → Fin (2 ^ k)) × Fin (2 ^ k) :=
    fun p => (update p.1 i p.2, p.1 i)
  have hφ : Involutive φ := by
    intro p
    simp [φ]
  have e1 : ∑ p : (ι → Fin (2 ^ k)) × Fin (2 ^ k), hat (p.2 : ℕ) (q fun j => (p.1 j : ℕ))
      = ∑ p : (ι → Fin (2 ^ k)) × Fin (2 ^ k), hat (p.1 i : ℕ) (q fun j => (p.1 j : ℕ)) := by
    rw [← (hφ.toPerm φ).sum_comp]
    refine sum_congr rfl fun p _ => ?_
    have : (q fun j => ((φ p).1 j : ℕ)) = q fun j => (p.1 j : ℕ) := by
      apply hblind
      intro j hj
      simp [φ, update_of_ne hj]
    simp only [Involutive.coe_toPerm]
    rw [this]
    simp [φ]
  rw [Fintype.sum_prod_type, Fintype.sum_prod_type] at e1
  have e2 : ∀ x : ι → Fin (2 ^ k),
      ∑ v : Fin (2 ^ k), hat (v : ℕ) (q fun j => (x j : ℕ)) = 2 ^ (k - 1) := by
    intro x
    have b := hq (fun j => (x j : ℕ)) fun j => (x j).isLt
    rw [Fin.sum_univ_eq_sum_range (fun v => hat v (q fun j => (x j : ℕ))) (2 ^ k)]
    exact sum_hat b.1 b.2
  rw [sum_congr rfl fun x _ => e2 x] at e1
  simp only [sum_const, card_univ, smul_eq_mul, Fintype.card_fin, Fintype.card_fun] at e1
  rw [mul_sum]
  exact e1.symm

/-! ### One player goes up alone -/

variable [Nontrivial ι]

omit [Fintype ι] [Nontrivial ι] in
theorem update_lt (i : ι) {m : ℕ} (hm : m < 2 ^ T - 1) (j : ι) :
    update (fun _ : ι => 2 ^ T - 1) i m j < 2 ^ T := by
  have := Nat.two_pow_pos T
  by_cases h : j = i
  · subst h; simp; omega
  · simp [update_of_ne h]

omit [Fintype ι] [Nontrivial ι] in
theorem update_go (i : ι) (m : ℕ) : goN T i (update (fun _ : ι => 2 ^ T - 1) i m) :=
  Or.inr fun j hj => by simp [update_of_ne hj]

omit [Fintype ι] [Nontrivial ι] in
theorem update_stay (hT : 1 ≤ T) (i : ι) {m : ℕ} (h0 : 0 < m) (hm : m < 2 ^ T - 1) {j : ι}
    (hj : j ≠ i) : ¬ goN T j (update (fun _ : ι => 2 ^ T - 1) i m) := by
  have hP : 2 ≤ 2 ^ T := by
    have : 2 ^ 1 ≤ 2 ^ T := Nat.pow_le_pow_right (by norm_num) hT
    simpa using this
  rintro (⟨t, _, ht⟩ | h)
  · by_cases e : t = i
    · subst e; simp at ht; omega
    · simp [update_of_ne e] at ht; omega
  · have := h i (Ne.symm hj)
    simp at this
    omega

omit [Nontrivial ι] in
/-- All the others are all black below, and the player `i` is mixed. -/
theorem blockN_one (hS : ProperN T S) (hM : ProperN k M) (bM : Blind M) (hT : 1 ≤ T) (i : ι)
    {m : ℕ} (h0 : 0 < m) (hm : m < 2 ^ T - 1) :
    2 ^ k * blockN T k (resetN T S M) (update (fun _ : ι => 2 ^ T - 1) i m)
      = (2 ^ k) ^ Fintype.card ι * 2 ^ (k - 1) := by
  have hl := update_lt i hm
  have term : ∀ x : ι → Fin (2 ^ k),
      termN (resetN T S M)
          (fun j => 2 ^ T * (x j : ℕ) + update (fun _ : ι => 2 ^ T - 1) i m j)
        = hat (x i) (M i fun j => (x j : ℕ)) := by
    intro x
    unfold termN
    rw [prod_eq_single i]
    · exact facN_up S hM hl x (update_go i m)
    · intro j _ hj
      rw [facN_stay M hS hl x (update_stay hT i h0 hm hj), update_of_ne hj]
      have b := hS j _ hl
      exact hat_ones b.1 b.2
    · intro h; exact absurd (mem_univ i) h
  unfold blockN
  rw [sum_congr rfl fun x _ => term x]
  exact sum_coord i (M i) (bM i) (hM i)

omit [Nontrivial ι] in
theorem termN_one (hS : ProperN T S) (bS : Blind S) (i : ι)
    {m : ℕ} (hm : m < 2 ^ T - 1) :
    termN S (update (fun _ : ι => 2 ^ T - 1) i m) = hat m (S i fun _ => 2 ^ T - 1) := by
  have hl := update_lt i hm
  unfold termN
  rw [prod_eq_single i]
  · have : S i (update (fun _ : ι => 2 ^ T - 1) i m) = S i fun _ => 2 ^ T - 1 :=
      bS i _ _ fun j hj => by simp [update_of_ne hj]
    simp [this]
  · intro j _ hj
    rw [update_of_ne hj]
    have b := hS j _ hl
    exact hat_ones b.1 b.2
  · intro h; exact absurd (mem_univ i) h

/-! ### The kinds of lower parts -/

omit [Fintype ι] [DecidableEq ι] in
/-- When everybody goes up and somebody is not all black, somebody is all
white. -/
theorem white_of_all_go {l : ι → ℕ} (h : ∀ i, goN T i l) (hB : ¬ ∀ j, l j = 2 ^ T - 1) :
    ∃ i, l i = 0 := by
  by_contra hw
  push Not at hw
  obtain ⟨i, j, hij⟩ := exists_pair_ne ι
  have hi : ∀ t, t ≠ i → l t = 2 ^ T - 1 := by
    rcases h i with ⟨t, _, ht⟩ | h'
    · exact absurd ht (hw t)
    · exact h'
  have hj : ∀ t, t ≠ j → l t = 2 ^ T - 1 := by
    rcases h j with ⟨t, _, ht⟩ | h'
    · exact absurd ht (hw t)
    · exact h'
  apply hB
  intro t
  by_cases e : t = i
  · subst e; exact hj t hij
  · exact hi t e

omit [Fintype ι] [Nontrivial ι] in
/-- The other lower parts: a player who is all white stays, or nobody
goes up. -/
theorem rest_cases {l : ι → ℕ} (hl : ∀ j, l j < 2 ^ T) (h : ¬ ∀ i, goN T i l)
    (hB : ¬ ∃ i m, 0 < m ∧ m < 2 ^ T - 1 ∧ l = update (fun _ : ι => 2 ^ T - 1) i m) :
    (∃ i, ¬ goN T i l ∧ l i = 0) ∨ ∀ i, ¬ goN T i l := by
  push Not at h
  obtain ⟨i, hi⟩ := h
  by_cases h0 : l i = 0
  · exact Or.inl ⟨i, hi, h0⟩
  right
  have hw : ∀ t, l t ≠ 0 := by
    intro t ht
    by_cases e : t = i
    · subst e; exact h0 ht
    · exact hi (Or.inl ⟨t, e, ht⟩)
  intro j hj
  rcases hj with ⟨t, _, ht⟩ | hj
  · exact hw t ht
  · have hji : j ≠ i := by
      rintro rfl; exact hi (Or.inr hj)
    by_cases hb : l j = 2 ^ T - 1
    · apply hi
      right
      intro t _
      by_cases e : t = j
      · subst e; exact hb
      · exact hj t e
    · apply hB
      refine ⟨j, l j, Nat.pos_of_ne_zero (hw j), ?_, ?_⟩
      · have := hl j
        omega
      · funext t
        by_cases e : t = j
        · subst e; simp
        · simp [update_of_ne e, hj t e]

/-! ### The count -/

/-- The number of ways to choose the `T` lowest hats of everybody so that
all the players go up. -/
def resetCard (ι : Type*) [Fintype ι] [DecidableEq ι] (T : ℕ) : ℕ :=
  (univ.filter fun l : ι → Fin (2 ^ T) => ∀ i, goN T i fun j => (l j : ℕ)).card

omit [Fintype ι] [DecidableEq ι] [Nontrivial ι] in
/-- Sums over the mixed stacks of `T` hats, written with `Fin`. -/
theorem sum_fin_mid (hT : 1 ≤ T) (f : ℕ → ℕ) :
    ∑ m ∈ univ.filter (fun m : Fin (2 ^ T) => 0 < (m : ℕ) ∧ (m : ℕ) < 2 ^ T - 1), f m
      = ∑ t ∈ Ico 1 (2 ^ T - 1), f t := by
  have hP : 2 ≤ 2 ^ T := by
    have : 2 ^ 1 ≤ 2 ^ T := Nat.pow_le_pow_right (by norm_num) hT
    simpa using this
  rw [sum_filter,
    Fin.sum_univ_eq_sum_range (fun t => if 0 < t ∧ t < 2 ^ T - 1 then f t else 0) (2 ^ T),
    sum_ends hP]
  have e : ∀ t ∈ Ico 1 (2 ^ T - 1), (if 0 < t ∧ t < 2 ^ T - 1 then f t else 0) = f t := by
    intro t ht
    have := mem_Ico.mp ht
    have c : 0 < t ∧ t < 2 ^ T - 1 := by omega
    simp [c]
  rw [sum_congr rfl e]
  simp

/-- **Wins of a reset, any number of players.**  For proper blind
strategies `S` on `T` hats and `M` on `k` hats, with `n` players:
`(2 ^ k) ^ n * (wins S - 1) + resetCard * wins M` wins. -/
theorem winsN_reset (hS : ProperN T S) (hM : ProperN k M) (bS : Blind S) (bM : Blind M) :
    winsN (2 ^ (T + k)) (resetN T S M) + (2 ^ k) ^ Fintype.card ι
      = (2 ^ k) ^ Fintype.card ι * winsN (2 ^ T) S + resetCard ι T * winsN (2 ^ k) M := by
  obtain ⟨i0⟩ := (inferInstance : Nonempty ι)
  have hT : 1 ≤ T := by
    have := hS i0 (fun _ => 0) fun _ => Nat.two_pow_pos T
    omega
  have hk : 1 ≤ k := by
    have := hM i0 (fun _ => 0) fun _ => Nat.two_pow_pos k
    omega
  have hP : 2 ≤ 2 ^ T := by
    have : 2 ^ 1 ≤ 2 ^ T := Nat.pow_le_pow_right (by norm_num) hT
    simpa using this
  have hBlt : 2 ^ T - 1 < 2 ^ T := by omega
  -- notation
  set c : (ι → Fin (2 ^ T)) → ι → ℕ := fun l i => (l i : ℕ) with hc
  have clt : ∀ l j, c l j < 2 ^ T := fun l j => (l j).isLt
  set F1 : (ι → Fin (2 ^ T)) → ℕ := fun l => blockN T k (resetN T S M) (c l) with hF1
  set F2 : (ι → Fin (2 ^ T)) → ℕ := fun l => termN S (c l) with hF2
  let Bf : Fin (2 ^ T) := ⟨2 ^ T - 1, hBlt⟩
  let R : Finset (ι → Fin (2 ^ T)) := univ.filter fun l => ∀ i, goN T i (c l)
  let Mid : Finset (Fin (2 ^ T)) := univ.filter fun m => 0 < (m : ℕ) ∧ (m : ℕ) < 2 ^ T - 1
  let g : ι × Fin (2 ^ T) → ι → Fin (2 ^ T) := fun p => update (fun _ => Bf) p.1 p.2
  let Bi : Finset (ι → Fin (2 ^ T)) := (univ ×ˢ Mid).image g
  have cg : ∀ p : ι × Fin (2 ^ T), c (g p) = update (fun _ : ι => 2 ^ T - 1) p.1 (p.2 : ℕ) := by
    intro p
    funext j
    by_cases e : j = p.1
    · subst e; simp [c, g]
    · simp [c, g, update_of_ne e, Bf]
  -- the three kinds do not meet
  have hdisj : Disjoint R Bi := by
    rw [disjoint_left]
    intro l hR hB
    obtain ⟨p, hp, rfl⟩ := mem_image.mp hB
    have hm := (mem_filter.mp (mem_product.mp hp).2).2
    obtain ⟨j, hj⟩ := exists_ne p.1
    have := (mem_filter.mp hR).2 j
    rw [cg] at this
    exact update_stay hT p.1 hm.1 hm.2 hj this
  -- everybody goes up
  have r1 : ∑ l ∈ R, F1 l = resetCard ι T * winsN (2 ^ k) M := by
    rw [sum_congr rfl fun l hl => blockN_all S hM (clt l) (mem_filter.mp hl).2]
    simp [resetCard, c]
  have r2 : ∑ l ∈ R, F2 l = 1 := by
    have hall : (fun _ : ι => Bf) ∈ R := by
      refine mem_filter.mpr ⟨mem_univ _, fun i => Or.inr fun j _ => rfl⟩
    rw [sum_eq_single_of_mem _ hall]
    · simp only [F2, termN]
      refine prod_eq_one fun j _ => ?_
      have b := hS j (c fun _ => Bf) (clt _)
      exact hat_ones b.1 b.2
    · intro l hl hne
      have hnB : ¬ ∀ j, c l j = 2 ^ T - 1 := by
        intro h
        apply hne
        funext j
        exact Fin.ext (h j)
      obtain ⟨i, hi⟩ := white_of_all_go (mem_filter.mp hl).2 hnB
      exact termN_zero S hi
  -- one player goes up alone
  have ginj : Set.InjOn g ↑(univ ×ˢ Mid : Finset (ι × Fin (2 ^ T))) := by
    intro p hp q hq hpq
    have hm := (mem_filter.mp (mem_product.mp (mem_coe.mp hp)).2).2
    have hm' := (mem_filter.mp (mem_product.mp (mem_coe.mp hq)).2).2
    have h1 : p.1 = q.1 := by
      by_contra hne
      have := congrFun hpq p.1
      simp only [g, update_self, update_of_ne hne] at this
      have := congrArg Fin.val this
      simp only [Bf] at this
      omega
    have h2 : p.2 = q.2 := by
      have := congrFun hpq p.1
      simp only [g, update_self] at this
      rw [h1] at this
      simpa using this
    exact Prod.ext h1 h2
  have hmid := fun p : ℤ => fun (h0 : 0 ≤ p) (h1 : p < T) => sum_mid_hat hT h0 h1
  have b2 : ∑ l ∈ Bi, F2 l = Fintype.card ι * (2 ^ (T - 1) - 1) := by
    rw [sum_image ginj, sum_product]
    have row : ∀ i : ι, ∑ m ∈ Mid, F2 (g (i, m)) = 2 ^ (T - 1) - 1 := by
      intro i
      have b := hS i (fun _ => 2 ^ T - 1) fun _ => hBlt
      rw [← hmid _ b.1 b.2, ← sum_fin_mid hT fun t => hat t (S i fun _ => 2 ^ T - 1)]
      refine sum_congr rfl fun m hm => ?_
      have hm' := (mem_filter.mp hm).2
      simp only [F2]
      rw [cg]
      exact termN_one hS bS i hm'.2
    rw [sum_congr rfl fun i _ => row i]
    simp
  have cardMid : Mid.card = 2 ^ T - 1 - 1 := by
    have := sum_fin_mid hT fun _ => 1
    simpa [Mid] using this
  have b1 : 2 ^ k * ∑ l ∈ Bi, F1 l
      = Fintype.card ι * (2 ^ T - 1 - 1) * ((2 ^ k) ^ Fintype.card ι * 2 ^ (k - 1)) := by
    rw [sum_image ginj, sum_product, mul_sum]
    have row : ∀ i : ι, 2 ^ k * ∑ m ∈ Mid, F1 (g (i, m))
        = (2 ^ T - 1 - 1) * ((2 ^ k) ^ Fintype.card ι * 2 ^ (k - 1)) := by
      intro i
      rw [mul_sum, ← cardMid, card_eq_sum_ones, sum_mul]
      refine sum_congr rfl fun m hm => ?_
      have hm' := (mem_filter.mp hm).2
      simp only [F1]
      rw [cg, one_mul]
      exact blockN_one hS hM bM hT i hm'.1 hm'.2
    rw [sum_congr rfl fun i _ => row i]
    simp
    ring
  -- the other lower parts
  have rest : ∀ l ∈ (R ∪ Bi)ᶜ, F1 l = (2 ^ k) ^ Fintype.card ι * F2 l := by
    intro l hl
    rw [mem_compl, mem_union, not_or] at hl
    have h1 : ¬ ∀ i, goN T i (c l) := fun h => hl.1 (mem_filter.mpr ⟨mem_univ _, h⟩)
    have h2 : ¬ ∃ i m, 0 < m ∧ m < 2 ^ T - 1 ∧ c l = update (fun _ : ι => 2 ^ T - 1) i m := by
      rintro ⟨i, m, hm0, hm1, e⟩
      apply hl.2
      refine mem_image.mpr ⟨(i, ⟨m, by omega⟩), ?_, ?_⟩
      · exact mem_product.mpr ⟨mem_univ _, mem_filter.mpr ⟨mem_univ _, hm0, hm1⟩⟩
      · funext j
        apply Fin.ext
        have := congrFun e j
        have e2 := congrFun (cg (i, ⟨m, by omega⟩)) j
        simp only [c] at this e2
        rw [e2, this]
    rcases rest_cases (clt l) h1 h2 with ⟨i, hi, h0⟩ | hnone
    · simp only [F1, F2]
      rw [blockN_zero M hS (clt l) hi h0, termN_zero S h0, mul_zero]
    · exact blockN_none M hS (clt l) hnone
  -- together
  have s1 : winsN (2 ^ (T + k)) (resetN T S M)
      = ∑ l ∈ R, F1 l + ∑ l ∈ Bi, F1 l + ∑ l ∈ (R ∪ Bi)ᶜ, F1 l := by
    rw [winsN_split, ← sum_union hdisj, sum_add_sum_compl]
  have s2 : winsN (2 ^ T) S = ∑ l ∈ R, F2 l + ∑ l ∈ Bi, F2 l + ∑ l ∈ (R ∪ Bi)ᶜ, F2 l := by
    rw [← sum_union hdisj, sum_add_sum_compl]
    rfl
  rw [s1, s2, r1, r2, b2, sum_congr rfl rest, ← mul_sum]
  generalize ∑ l ∈ (R ∪ Bi)ᶜ, F2 l = X at *
  generalize ∑ l ∈ Bi, F1 l = Y at *
  generalize resetCard ι T * winsN (2 ^ k) M = Z
  generalize Fintype.card ι = n at *
  generalize (2 ^ k) ^ n = E at *
  have hK : 2 ^ k = 2 * 2 ^ (k - 1) := by
    obtain ⟨j, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
    simp [pow_succ]; ring
  have hc : 2 ^ T - 1 - 1 = 2 * (2 ^ (T - 1) - 1) := by
    obtain ⟨j, rfl⟩ : ∃ j, T = j + 1 := ⟨T - 1, by omega⟩
    have := Nat.two_pow_pos j
    simp [pow_succ]; omega
  rw [hc, hK] at b1
  have hpos : 0 < 2 ^ (k - 1) := Nat.two_pow_pos _
  have hY : Y = n * (2 ^ (T - 1) - 1) * E := by
    have : 2 * 2 ^ (k - 1) * Y = 2 * 2 ^ (k - 1) * (n * (2 ^ (T - 1) - 1) * E) := by
      rw [b1]; ring
    exact Nat.eq_of_mul_eq_mul_left (by positivity) this
  rw [hY]
  ring

/-! ### How many lower parts make everybody go up -/

omit [Fintype ι] [Nontrivial ι] in
/-- With two players all white below, everybody goes up. -/
theorem go_of_two_white {l : ι → ℕ} {i j : ι} (hij : i ≠ j) (hi : l i = 0) (hj : l j = 0)
    (t : ι) : goN T t l := by
  by_cases e : t = i
  · subst e; exact Or.inl ⟨j, Ne.symm hij, hj⟩
  · exact Or.inl ⟨i, Ne.symm e, hi⟩

/-- The number of ways to make everybody go up: all the lower parts,
less those without an all-white player (but the one where everybody is all
black) and those with one all-white player (but the ones where the others
are all black). -/
theorem resetCard_add (hT : 1 ≤ T) :
    resetCard ι T + (2 ^ T - 1) ^ Fintype.card ι
        + Fintype.card ι * (2 ^ T - 1) ^ (Fintype.card ι - 1)
      = (2 ^ T) ^ Fintype.card ι + Fintype.card ι + 1 := by
  have hP : 2 ≤ 2 ^ T := by
    have : 2 ^ 1 ≤ 2 ^ T := Nat.pow_le_pow_right (by norm_num) hT
    simpa using this
  let z : Fin (2 ^ T) := ⟨0, by omega⟩
  let bf : Fin (2 ^ T) := ⟨2 ^ T - 1, by omega⟩
  have hzb : z ≠ bf := by
    intro h; have := congrArg Fin.val h; simp only [z, bf] at this; omega
  let c : (ι → Fin (2 ^ T)) → ι → ℕ := fun l i => (l i : ℕ)
  let R : Finset (ι → Fin (2 ^ T)) := univ.filter fun l => ∀ i, goN T i (c l)
  let A0 : Finset (ι → Fin (2 ^ T)) := Fintype.piFinset fun _ => univ.erase z
  let A1 : ι → Finset (ι → Fin (2 ^ T)) := fun i =>
    Fintype.piFinset fun j => if j = i then {z} else univ.erase z
  have mem0 : ∀ l, l ∈ A0 ↔ ∀ j, l j ≠ z := by
    intro l; simp [A0, Fintype.mem_piFinset]
  have mem1 : ∀ i l, l ∈ A1 i ↔ l i = z ∧ ∀ j, j ≠ i → l j ≠ z := by
    intro i l
    simp only [A1, Fintype.mem_piFinset]
    constructor
    · intro h
      refine ⟨by simpa using h i, fun j hj => ?_⟩
      have := h j
      simpa [hj] using this
    · rintro ⟨h1, h2⟩ j
      by_cases e : j = i
      · subst e; simp [h1]
      · simp [e, h2 j e]
  have cz : ∀ (l : ι → Fin (2 ^ T)) j, c l j = 0 ↔ l j = z := by
    intro l j
    constructor
    · intro h; exact Fin.ext h
    · intro h; simp [c, h, z]
  have cb : ∀ (l : ι → Fin (2 ^ T)) j, c l j = 2 ^ T - 1 ↔ l j = bf := by
    intro l j
    constructor
    · intro h; exact Fin.ext h
    · intro h; simp [c, h, bf]
  -- each lower part is of exactly one kind
  have kinds : ∀ l : ι → Fin (2 ^ T),
      (if l ∈ R then 1 else 0) + (if l ∈ A0.erase (fun _ => bf) then 1 else 0)
        + ∑ i, (if l ∈ (A1 i).erase (update (fun _ => bf) i z) then 1 else 0) = 1 := by
    intro l
    have inR : l ∈ R ↔ ∀ i, goN T i (c l) := by simp [R]
    by_cases hw : ∃ i, l i = z
    · obtain ⟨i, hi⟩ := hw
      have n0 : l ∉ A0.erase (fun _ => bf) := by
        intro h; exact (mem0 l).mp (mem_of_mem_erase h) i hi
      have others : ∀ t ∈ (univ : Finset ι), t ≠ i →
          (if l ∈ (A1 t).erase (update (fun _ => bf) t z) then 1 else 0) = 0 := by
        intro t _ ht
        have : l ∉ (A1 t).erase (update (fun _ => bf) t z) := by
          intro h
          exact ((mem1 t l).mp (mem_of_mem_erase h)).2 i (Ne.symm ht) hi
        simp [this]
      rw [sum_eq_single i others (fun h => absurd (mem_univ i) h)]
      by_cases h2 : ∃ j, j ≠ i ∧ l j = z
      · obtain ⟨j, hji, hj⟩ := h2
        have r : l ∈ R :=
          inR.mpr (go_of_two_white (Ne.symm hji) ((cz l i).mpr hi) ((cz l j).mpr hj))
        have n1 : l ∉ (A1 i).erase (update (fun _ => bf) i z) := by
          intro h
          exact ((mem1 i l).mp (mem_of_mem_erase h)).2 j hji hj
        simp [r, n0, n1]
      · push Not at h2
        have a1 : l ∈ A1 i := (mem1 i l).mpr ⟨hi, h2⟩
        by_cases e : l = update (fun _ => bf) i z
        · have r : l ∈ R := by
            refine inR.mpr fun t => ?_
            by_cases et : t = i
            · subst et
              refine Or.inr fun j hj => ?_
              rw [cb, e, update_of_ne hj]
            · exact Or.inl ⟨i, Ne.symm et, (cz l i).mpr hi⟩
          have n1 : l ∉ (A1 i).erase (update (fun _ => bf) i z) := by
            intro h; exact (ne_of_mem_erase h) e
          simp [r, n0, n1]
        · have r : l ∉ R := by
            intro h
            apply e
            rcases inR.mp h i with ⟨j, hji, hj⟩ | hall
            · exact absurd ((cz l j).mp hj) (h2 j hji)
            · funext j
              by_cases ej : j = i
              · subst ej; simp [hi]
              · rw [update_of_ne ej]; exact (cb l j).mp (hall j ej)
          have y1 : l ∈ (A1 i).erase (update (fun _ => bf) i z) := mem_erase.mpr ⟨e, a1⟩
          simp [r, n0, y1]
    · push Not at hw
      have a0 : l ∈ A0 := (mem0 l).mpr hw
      have none : ∀ t ∈ (univ : Finset ι),
          (if l ∈ (A1 t).erase (update (fun _ => bf) t z) then 1 else 0) = 0 := by
        intro t _
        have : l ∉ (A1 t).erase (update (fun _ => bf) t z) := by
          intro h
          exact hw t ((mem1 t l).mp (mem_of_mem_erase h)).1
        simp [this]
      rw [sum_eq_zero none]
      by_cases e : l = fun _ => bf
      · have r : l ∈ R := inR.mpr fun t => Or.inr fun j _ => by rw [cb, e]
        have n0 : l ∉ A0.erase (fun _ => bf) := fun h => (ne_of_mem_erase h) e
        simp [r, n0]
      · have r : l ∉ R := by
          intro h
          have hnB : ¬ ∀ j, c l j = 2 ^ T - 1 := by
            intro hb
            apply e
            funext j
            exact (cb l j).mp (hb j)
          obtain ⟨i, hi⟩ := white_of_all_go (inR.mp h) hnB
          exact hw i ((cz l i).mp hi)
        have y0 : l ∈ A0.erase (fun _ => bf) := mem_erase.mpr ⟨e, a0⟩
        simp [r, y0]
  -- count
  have total := sum_congr (rfl : (univ : Finset (ι → Fin (2 ^ T))) = univ) fun l _ => kinds l
  rw [sum_add_distrib, sum_add_distrib, sum_comm] at total
  simp only [sum_boole, filter_mem_eq_inter, univ_inter, sum_const, card_univ, smul_eq_mul,
    mul_one, Fintype.card_fun, Fintype.card_fin, Nat.cast_id] at total
  have card0 : A0.card = (2 ^ T - 1) ^ Fintype.card ι := by
    simp [A0, Fintype.card_piFinset, card_erase_of_mem]
  have card1 : ∀ i, (A1 i).card = (2 ^ T - 1) ^ (Fintype.card ι - 1) := by
    intro i
    simp only [A1, Fintype.card_piFinset]
    have each : ∀ j : ι, (if j = i then ({z} : Finset (Fin (2 ^ T))) else univ.erase z).card
        = if j = i then 1 else 2 ^ T - 1 := by
      intro j
      split_ifs <;> simp [card_erase_of_mem]
    simp only [each]
    rw [← mul_prod_erase univ _ (mem_univ i)]
    have rest : ∀ j ∈ (univ : Finset ι).erase i, (if j = i then 1 else 2 ^ T - 1) = 2 ^ T - 1 := by
      intro j hj
      simp [ne_of_mem_erase hj]
    rw [prod_congr rfl rest, prod_const, card_erase_of_mem (mem_univ i), card_univ]
    simp
  have in0 : (fun _ : ι => bf) ∈ A0 := (mem0 _).mpr fun _ => Ne.symm hzb
  have in1 : ∀ i, update (fun _ : ι => bf) i z ∈ A1 i := by
    intro i
    refine (mem1 i _).mpr ⟨by simp, fun j hj => ?_⟩
    rw [update_of_ne hj]
    exact Ne.symm hzb
  have e0 : (A0.erase fun _ => bf).card + 1 = (2 ^ T - 1) ^ Fintype.card ι := by
    rw [card_erase_of_mem in0, card0]
    have : 0 < (2 ^ T - 1) ^ Fintype.card ι := Nat.pow_pos (by omega)
    omega
  have e1 : ∑ i, ((A1 i).erase (update (fun _ => bf) i z)).card + Fintype.card ι
      = Fintype.card ι * (2 ^ T - 1) ^ (Fintype.card ι - 1) := by
    have : ∀ i ∈ (univ : Finset ι), ((A1 i).erase (update (fun _ => bf) i z)).card + 1
        = (2 ^ T - 1) ^ (Fintype.card ι - 1) := by
      intro i _
      rw [card_erase_of_mem (in1 i), card1]
      have : 0 < (2 ^ T - 1) ^ (Fintype.card ι - 1) := Nat.pow_pos (by omega)
      omega
    have s := sum_congr rfl this
    rw [sum_add_distrib] at s
    simpa using s
  have eR : R.card = resetCard ι T := rfl
  rw [← eR]
  omega

end

end Hats
