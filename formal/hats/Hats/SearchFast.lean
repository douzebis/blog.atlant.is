-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Search

/-!
# The search, counting hits as it goes

`best n` scores every strategy it tries from scratch.  The search of the
second article is faster: it fixes the choices stack by stack, and adds to
the score, at each choice, the hits of the pairs that this choice
completes.  Here is that search, `bestFast n`, with the proof that it
computes the same number as `best n`.
-/

namespace Hats

open Finset

/-! ### The hits, stack by stack -/

/-- What the choice for stack `t` adds to the hits, the choices for the
stacks before it being known: the pair `(t, t)`, and twice the pairs of
`t` with an earlier stack. -/
def contrib (s : ℕ → ℕ) (t : ℕ) : ℕ :=
  2 * (∑ u ∈ range t, if t.testBit (s u) = true ∧ u.testBit (s t) = true then 1 else 0)
    + if t.testBit (s t) = true then 1 else 0

/-- A sum over all pairs, for a symmetric function: the diagonal, and
twice the pairs below it. -/
theorem sum_sum_symm (N : ℕ) (f : ℕ → ℕ → ℕ) (hf : ∀ a b, f a b = f b a) :
    ∑ t ∈ range N, ∑ u ∈ range N, f t u
      = ∑ t ∈ range N, (2 * (∑ u ∈ range t, f t u) + f t t) := by
  induction N with
  | zero => simp
  | succ N ih =>
    have e1 : ∑ t ∈ range N, ∑ u ∈ range (N + 1), f t u
        = ∑ t ∈ range N, ∑ u ∈ range N, f t u + ∑ t ∈ range N, f t N := by
      rw [← sum_add_distrib]
      exact sum_congr rfl fun t _ => sum_range_succ _ _
    have e2 : ∑ t ∈ range N, f t N = ∑ u ∈ range N, f N u :=
      sum_congr rfl fun t _ => hf t N
    have e3 : ∑ u ∈ range (N + 1), f N u = ∑ u ∈ range N, f N u + f N N := sum_range_succ _ _
    rw [sum_range_succ (fun t => ∑ u ∈ range (N + 1), f t u) N,
      sum_range_succ (fun t => 2 * (∑ u ∈ range t, f t u) + f t t) N, e1, e3, e2, ih]
    ring

/-- The hits of a strategy are the sum of what its choices add. -/
theorem hits_eq_sum_contrib (n : ℕ) (s : ℕ → ℕ) :
    hits n (fun t => (s t : ℤ)) = ∑ t ∈ range (2 ^ n), contrib s t := by
  have hhat : ∀ t p : ℕ, hat t (p : ℤ) = if t.testBit p = true then 1 else 0 := by
    intro t p; simp [hat]
  unfold hits pair
  simp only [hhat]
  rw [sum_sum_symm _ (fun t u => (if t.testBit (s u) = true then 1 else 0)
    * (if u.testBit (s t) = true then 1 else 0)) (fun a b => mul_comm _ _)]
  refine sum_congr rfl fun t _ => ?_
  unfold contrib
  congr 1
  · congr 1
    refine sum_congr rfl fun u _ => ?_
    by_cases h1 : t.testBit (s u) = true <;> by_cases h2 : u.testBit (s t) = true <;>
      simp [h1, h2]
  · by_cases h : t.testBit (s t) = true <;> simp [h]

/-! ### The search -/

/-- Among the stacks before `t'`, the number of those that pair up with
`t'` when it chooses `p`.  The list holds their choices, the latest first;
`m` is their number. -/
def cnt (t' p : ℕ) : ℕ → List ℕ → ℕ
  | m + 1, q :: rest =>
    (if t'.testBit q = true ∧ m.testBit p = true then 1 else 0) + cnt t' p m rest
  | _, _ => 0

/-- What the choice `p` for stack `t` adds to the hits. -/
def incr (t p : ℕ) (prev : List ℕ) : ℕ :=
  2 * cnt t p t prev + if t.testBit p = true then 1 else 0

/-- The search: `k` stacks remain to be given a choice, from stack `t` on;
`prev` holds the choices made (the latest first) and `acc` their hits.
After them comes the all-black stack, which points at the bottom hat. -/
def go (n : ℕ) : ℕ → ℕ → List ℕ → ℕ → ℕ
  | 0, t, prev, acc => acc + incr t 0 prev
  | k + 1, t, prev, acc =>
    ((choices n t).map fun p => go n k (t + 1) (p :: prev) (acc + incr t p prev)).foldr max 0

/-- **The search that counts as it goes.** -/
def bestFast (n : ℕ) : ℕ := go n (2 ^ n - 2) 1 [0] 0

/-! ### It computes the same number -/

/-- The score of one way of choosing, counted as the search counts it. -/
def pathScore : ℕ → List ℕ → List ℕ → ℕ
  | t, prev, [] => incr t 0 prev
  | t, prev, p :: c => incr t p prev + pathScore (t + 1) (p :: prev) c

theorem foldr_max_append (l1 l2 : List ℕ) :
    (l1 ++ l2).foldr max 0 = max (l1.foldr max 0) (l2.foldr max 0) := by
  induction l1 with
  | nil => simp
  | cons x xs ih => rw [List.cons_append, List.foldr_cons, List.foldr_cons, ih, max_assoc]

theorem foldr_max_flatMap {α β : Type} (l : List α) (f : α → List β) (g : β → ℕ) :
    ((l.flatMap f).map g).foldr max 0 = (l.map fun a => ((f a).map g).foldr max 0).foldr max 0 := by
  induction l with
  | nil => rfl
  | cons a l ih =>
    rw [List.flatMap_cons, List.map_append, foldr_max_append, ih, List.map_cons, List.foldr_cons]

theorem go_eq (n k t : ℕ) (prev : List ℕ) (acc : ℕ) :
    go n k t prev acc = ((enum n k t).map fun c => acc + pathScore t prev c).foldr max 0 := by
  induction k generalizing t prev acc with
  | zero => simp [go, enum, pathScore]
  | succ k ih =>
    rw [go, enum, foldr_max_flatMap]
    congr 1
    refine List.map_congr_left fun p _ => ?_
    rw [ih, List.map_map]
    congr 1
    refine List.map_congr_left fun c _ => ?_
    simp [pathScore, add_assoc]

theorem cnt_eq (t' p : ℕ) (s : ℕ → ℕ) (t : ℕ) :
    cnt t' p t ((List.range t).map s).reverse
      = ∑ u ∈ range t, if t'.testBit (s u) = true ∧ u.testBit p = true then 1 else 0 := by
  induction t with
  | zero => simp [cnt]
  | succ t ih =>
    rw [List.range_succ, List.map_append, List.reverse_append, sum_range_succ]
    simp only [List.map_cons, List.map_nil, List.reverse_cons, List.reverse_nil, List.nil_append,
      List.singleton_append, cnt, ih]
    ring

theorem incr_eq (s : ℕ → ℕ) (t : ℕ) :
    incr t (s t) ((List.range t).map s).reverse = contrib s t := by
  unfold incr contrib
  rw [cnt_eq]

theorem pathScore_eq (s : ℕ → ℕ) (k t : ℕ) (hlast : s (t + k) = 0) :
    pathScore t ((List.range t).map s).reverse ((List.range k).map fun i => s (t + i))
      = ∑ i ∈ range (k + 1), contrib s (t + i) := by
  induction k generalizing t with
  | zero =>
    have : s t = 0 := by simpa using hlast
    simp only [List.range_zero, List.map_nil, pathScore, zero_add, range_one, sum_singleton,
      add_zero]
    rw [← this, incr_eq]
  | succ k ih =>
    have hl : s (t + 1 + k) = 0 := by rwa [show t + 1 + k = t + (k + 1) by ring]
    have e : (List.range (k + 1)).map (fun i => s (t + i))
        = s t :: (List.range k).map fun i => s (t + 1 + i) := by
      rw [List.range_succ_eq_map, List.map_cons, List.map_map]
      simp only [add_zero, List.cons.injEq, true_and]
      refine List.map_congr_left fun i _ => ?_
      simp [show t + 1 + i = t + (i + 1) by ring]
    have e2 : s t :: ((List.range t).map s).reverse = ((List.range (t + 1)).map s).reverse := by
      rw [List.range_succ, List.map_append, List.reverse_append]
      rfl
    rw [e, pathScore, incr_eq, e2, ih (t + 1) hl, sum_range_succ' _ (k + 1)]
    simp only [add_zero]
    rw [add_comm]
    congr 1
    refine sum_congr rfl fun i _ => ?_
    rw [show t + 1 + i = t + (i + 1) by ring]

/-- **The two searches agree.** -/
theorem bestFast_eq_best {n : ℕ} (hn : 1 ≤ n) : bestFast n = best n := by
  have hP : 2 ≤ 2 ^ n := by
    have : 2 ^ 1 ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hn
    simpa using this
  unfold bestFast best
  rw [go_eq]
  congr 1
  refine List.map_congr_left fun c hc => ?_
  obtain ⟨hlen, -⟩ := (mem_enum _ _ _).mp hc
  set s : ℕ → ℕ := fun t => (0 :: c).getD t 0 with hs
  have hof : ofChoices c = fun t => (s t : ℤ) := rfl
  have hc' : c = (List.range (2 ^ n - 2)).map fun i => s (1 + i) := by
    apply List.ext_getElem
    · simp [hlen]
    · intro i h1 h2
      simp [hs, add_comm 1 i, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem h1]
  have hlast : s (1 + (2 ^ n - 2)) = 0 := by
    simp [hs, add_comm 1, List.getD_eq_getElem?_getD, hlen]
  have hprev : ([0] : List ℕ) = ((List.range 1).map s).reverse := by simp [hs]
  have h0 : contrib s 0 = 0 := by simp [contrib]
  rw [hof, hits_eq_sum_contrib, zero_add]
  conv_lhs => rw [hc', hprev]
  rw [pathScore_eq s (2 ^ n - 2) 1 hlast]
  have hN : 2 ^ n = (2 ^ n - 2 + 1) + 1 := by omega
  conv_rhs => rw [hN, sum_range_succ' _ (2 ^ n - 2 + 1), h0, add_zero]
  refine sum_congr rfl fun i _ => ?_
  rw [add_comm]

end Hats
