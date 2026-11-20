-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Rosary.Onyx

/-!
# Corollary 2: the address of an onyx

Order the covers of each onyx increasingly and number them from 1.  The
rank `𝛊(𝐧)` of an onyx `𝐧 ≥ 2` is its number among the covers of `𝛑(𝐧)`,
and its address `𝛕(𝐧)` is the list of the ranks met on the way from the
root, onyx 1, to `𝐧`.  Corollary 2: the address is a bijection from the
onyxes onto the finite sequences of positive integers, and `𝐦 ≼ 𝐧` if and
only if the address of `𝐦` is a prefix of the address of `𝐧`.
-/

namespace Rosary

/-- The number of covers of `m` among the onyxes `2, …, N`. -/
def coverCount (m : Nat) : Nat → Nat
  | 0 => 0
  | N + 1 => coverCount m N + (if 2 ≤ N + 1 ∧ pi (N + 1) = m then 1 else 0)

/-- **Rank**: `𝛊(𝐧)`, the number of `𝐧` among the covers of `𝛑(𝐧)`. -/
def rank (n : Nat) : Nat := coverCount (pi n) n

/-- The ranks from `n` back to the root, at most `fuel` of them. -/
def addressRevAux : Nat → Nat → List Nat
  | 0, _ => []
  | fuel + 1, n => if n ≤ 1 then [] else rank n :: addressRevAux fuel (pi n)

/-- The address read from the onyx back to the root. -/
def addressRev (n : Nat) : List Nat := addressRevAux n n

/-- **Address**: `𝛕(𝐧)`, read from the root. -/
def address (n : Nat) : List Nat := (addressRev n).reverse

/-- **Onyx ordering**: `Below m n` is `𝐦 ≼ 𝐧`: `𝐦` is `𝐧` or one of its
predecessors `𝛑(𝐧)`, `𝛑²(𝐧)`, … -/
inductive Below : Nat → Nat → Prop
  | refl (n : Nat) : Below n n
  | step {m n : Nat} : 2 ≤ n → Below m (pi n) → Below m n

/-! ## Counting covers -/

theorem coverCount_succ_le (m N : Nat) : coverCount m (N + 1) ≤ coverCount m N + 1 := by
  simp only [coverCount]; split <;> omega

theorem coverCount_mono (m : Nat) {N N' : Nat} (h : N ≤ N') :
    coverCount m N ≤ coverCount m N' := by
  induction N' with
  | zero => rw [show N = 0 by omega]; exact Nat.le_refl _
  | succ N' ih =>
    by_cases e : N = N' + 1
    · rw [e]; exact Nat.le_refl _
    · have := ih (by omega)
      simp only [coverCount]; omega

theorem coverCount_cover (m n : Nat) (h2 : 2 ≤ n) (hp : pi n = m) :
    coverCount m n = coverCount m (n - 1) + 1 := by
  obtain ⟨N, rfl⟩ : ∃ N, n = N + 1 := ⟨n - 1, by omega⟩
  simp only [coverCount, Nat.add_sub_cancel]
  rw [if_pos ⟨h2, hp⟩]

theorem rank_pos (n : Nat) (h2 : 2 ≤ n) : 1 ≤ rank n := by
  unfold rank
  rw [coverCount_cover (pi n) n h2 rfl]
  omega

/-- Two covers of the same onyx with the same rank are the same. -/
theorem rank_injective (n n' : Nat) (h2 : 2 ≤ n) (h2' : 2 ≤ n') (hp : pi n = pi n')
    (hr : rank n = rank n') : n = n' := by
  unfold rank at hr
  rw [← hp] at hr
  apply Classical.byContradiction
  intro hne
  by_cases hlt : n < n'
  · have h1 := coverCount_cover (pi n) n' h2' hp.symm
    have h2 := coverCount_mono (pi n) (show n ≤ n' - 1 by omega)
    omega
  · have h1 := coverCount_cover (pi n) n h2 rfl
    have h2 := coverCount_mono (pi n) (show n' ≤ n - 1 by omega)
    omega

/-- Every onyx has a cover of each rank `k ≥ 1` (from Theorem 4). -/
theorem exists_cover_rank (m k : Nat) (hm : 1 ≤ m) (hk : 1 ≤ k) :
    ∃ n, 2 ≤ n ∧ pi n = m ∧ rank n = k := by
  have unbounded : ∀ k, ∃ N, k ≤ coverCount m N := by
    intro k
    induction k with
    | zero => exact ⟨0, Nat.zero_le _⟩
    | succ k ih =>
      obtain ⟨N, hN⟩ := ih
      obtain ⟨n, hn, hn2, hp⟩ := theorem4 m hm N
      have h1 := coverCount_cover m n hn2 hp
      have h2 := coverCount_mono m (show N ≤ n - 1 by omega)
      exact ⟨n, by omega⟩
  obtain ⟨N, hN, hmin⟩ := exists_least _ (unbounded k)
  cases N with
  | zero => simp only [coverCount] at hN; omega
  | succ N =>
    have hprev : coverCount m N < k := by
      apply Classical.byContradiction
      intro hc
      have := hmin N (by omega)
      omega
    have hle := coverCount_succ_le m N
    have hcover : 2 ≤ N + 1 ∧ pi (N + 1) = m := by
      apply Classical.byContradiction
      intro hc
      simp only [coverCount, if_neg hc] at hN
      omega
    refine ⟨N + 1, hcover.1, hcover.2, ?_⟩
    unfold rank
    rw [hcover.2]
    omega

/-! ## The address -/

theorem addressRevAux_fuel (f : Nat) :
    ∀ g n, n ≤ f → n ≤ g → addressRevAux f n = addressRevAux g n := by
  induction f with
  | zero =>
    intro g n hf _
    have : n = 0 := by omega
    subst this
    cases g with
    | zero => rfl
    | succ g => simp [addressRevAux]
  | succ f ih =>
    intro g n hf hg
    cases g with
    | zero =>
      have : n = 0 := by omega
      subst this
      simp [addressRevAux]
    | succ g =>
      simp only [addressRevAux]
      by_cases h1 : n ≤ 1
      · rw [if_pos h1, if_pos h1]
      · have hp := (proposition2 n (by omega)).2.2.1
        rw [if_neg h1, if_neg h1, ih g (pi n) (by omega) (by omega)]

theorem addressRev_root (n : Nat) (h : n ≤ 1) : addressRev n = [] := by
  cases n with
  | zero => rfl
  | succ n => simp [addressRev, addressRevAux, h]

theorem addressRev_cons (n : Nat) (h2 : 2 ≤ n) :
    addressRev n = rank n :: addressRev (pi n) := by
  obtain ⟨f, rfl⟩ : ∃ f, n = f + 1 := ⟨n - 1, by omega⟩
  have hp := (proposition2 (f + 1) h2).2.2.1
  have hfuel := addressRevAux_fuel f (pi (f + 1)) (pi (f + 1)) (by omega) (Nat.le_refl _)
  simp only [addressRev, addressRevAux]
  rw [if_neg (by omega), hfuel]

theorem addressRev_injective (n : Nat) :
    ∀ n', 1 ≤ n → 1 ≤ n' → addressRev n = addressRev n' → n = n' := by
  induction n using Nat.strongRecOn with
  | _ n ih =>
    intro n' hn hn' h
    by_cases h1 : n ≤ 1
    · rw [addressRev_root n h1] at h
      by_cases h1' : n' ≤ 1
      · omega
      · rw [addressRev_cons n' (by omega)] at h
        exact absurd h (by simp)
    · by_cases h1' : n' ≤ 1
      · rw [addressRev_root n' h1', addressRev_cons n (by omega)] at h
        exact absurd h (by simp)
      · rw [addressRev_cons n (by omega), addressRev_cons n' (by omega)] at h
        have hr : rank n = rank n' := (List.cons.inj h).1
        have ht : addressRev (pi n) = addressRev (pi n') := (List.cons.inj h).2
        have p := proposition2 n (by omega)
        have p' := proposition2 n' (by omega)
        have hp := ih (pi n) p.2.2.1 (pi n') p.1 p'.1 ht
        exact rank_injective n n' (by omega) (by omega) hp hr

theorem addressRev_surjective (l : List Nat) (hl : ∀ x, x ∈ l → 1 ≤ x) :
    ∃ n, 1 ≤ n ∧ addressRev n = l := by
  induction l with
  | nil => exact ⟨1, Nat.le_refl 1, addressRev_root 1 (Nat.le_refl 1)⟩
  | cons k l ih =>
    obtain ⟨m, hm, hml⟩ := ih fun x hx => hl x (List.mem_cons_of_mem k hx)
    obtain ⟨n, hn2, hp, hr⟩ := exists_cover_rank m k hm (hl k List.mem_cons_self)
    exact ⟨n, by omega, by rw [addressRev_cons n hn2, hr, hp, hml]⟩

theorem below_iff_suffix (n : Nat) : ∀ m, 1 ≤ m → 1 ≤ n →
    (Below m n ↔ addressRev m <:+ addressRev n) := by
  induction n using Nat.strongRecOn with
  | _ n ih =>
    intro m hm hn
    constructor
    · intro h
      cases h with
      | refl => exact List.suffix_refl _
      | step h2 hb =>
        have p := proposition2 n h2
        have := (ih (pi n) p.2.2.1 m hm p.1).mp hb
        rw [addressRev_cons n h2]
        exact List.IsSuffix.trans this (List.suffix_cons _ _)
    · intro h
      by_cases h1 : n ≤ 1
      · rw [addressRev_root n h1] at h
        have hnil : addressRev m = [] := List.suffix_nil.mp h
        have : m = n := addressRev_injective m n hm hn (by rw [hnil, addressRev_root n h1])
        rw [this]; exact Below.refl n
      · have p := proposition2 n (by omega)
        rw [addressRev_cons n (by omega), List.suffix_cons_iff] at h
        rcases h with h | h
        · have : m = n := addressRev_injective m n hm hn (by rw [h, addressRev_cons n (by omega)])
          rw [this]; exact Below.refl n
        · exact Below.step (by omega) ((ih (pi n) p.2.2.1 m hm p.1).mpr h)

/-! ## Corollary 2 -/

/-- **Corollary 2, injectivity.**  Different onyxes have different
addresses. -/
theorem corollary2_injective (n n' : Nat) (hn : 1 ≤ n) (hn' : 1 ≤ n')
    (h : address n = address n') : n = n' :=
  addressRev_injective n n' hn hn' (List.reverse_inj.mp h)

/-- **Corollary 2, surjectivity.**  Every finite sequence of positive
integers is the address of an onyx. -/
theorem corollary2_surjective (l : List Nat) (hl : ∀ x, x ∈ l → 1 ≤ x) :
    ∃ n, 1 ≤ n ∧ address n = l := by
  obtain ⟨n, hn, h⟩ := addressRev_surjective l.reverse fun x hx =>
    hl x (List.mem_reverse.mp hx)
  exact ⟨n, hn, by unfold address; rw [h, List.reverse_reverse]⟩

/-- **Corollary 2, the order.**  `𝐦 ≼ 𝐧` if and only if the address of `𝐦`
is a prefix of the address of `𝐧`. -/
theorem corollary2_prefix (m n : Nat) (hm : 1 ≤ m) (hn : 1 ≤ n) :
    Below m n ↔ address m <+: address n := by
  unfold address
  rw [List.reverse_prefix]
  exact below_iff_suffix n m hm hn

end Rosary
