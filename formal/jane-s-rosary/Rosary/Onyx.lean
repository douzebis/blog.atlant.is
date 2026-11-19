-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Rosary.Theorem1

/-!
# The onyx rosary (Part III of the paper): Proposition 2, Lemma 8, Theorem 4

In the paper a bold number counts black beads.  Here an onyx is a plain
`Nat`, at least 1, and `bullet n` is the bead `𝐧• = 3𝐧 - 2`.
-/

namespace Rosary

/-- `𝐧• = 3𝐧 - 2`: the bead of onyx `𝐧`. -/
def bullet (n : Nat) : Nat := 3 * n - 2

/-- The rank of a black bead among the black beads: `onyxOf (bullet n) = n`. -/
def onyxOf (b : Nat) : Nat := (b + 2) / 3

/-- The winner above a black bead `B`: of `Bμ` and `Bν`, the one with the
larger lambex. -/
def winner (B : Nat) : Nat := if lambex (nu B) < lambex (mu B) then mu B else nu B

/-- **Onyx predecessor**: `𝛑(𝐧)`, for `𝐧 ≥ 2`, is the onyx whose bead is
the seed of the winner above `𝐧•`. -/
def pi (n : Nat) : Nat := onyxOf (seed (winner (bullet n)))

theorem onyxOf_bullet (n : Nat) (hn : 1 ≤ n) : onyxOf (bullet n) = n := by
  simp only [onyxOf, bullet]; omega

theorem bullet_onyxOf (b : Nat) (hb : Black b) : bullet (onyxOf b) = b := by
  simp only [onyxOf, bullet, Black] at *; omega

/-! ## Proposition 2 -/

/-- Two white neighbors `x - 1`, `x` (`x` a multiple of 3): the smaller of
their seeds is at most `(2 xλ - 1)/3`. -/
theorem neighbors_seed_le (x : Nat) : 6 ≤ x → x % 3 = 0 →
    3 * min (seed (x - 1)) (seed x) + 1 ≤ 2 * lam x := by
  induction x using Nat.strongRecOn with
  | _ x ih =>
    intro h6 h0
    have hx := (seed_white x (by omega) (by rosary)).1
    have hx1 := (seed_white (x - 1) (by omega) (by rosary)).1
    have hl : lam (x - 1) = lam x - 1 := by rosary
    rw [hl] at hx1
    have hlx : 4 ≤ lam x ∧ lam x < x := by rosary
    by_cases c0 : lam x % 3 = 0
    · have := ih (lam x) hlx.2 (by omega) c0
      have : lam (lam x) ≤ lam x := by rosary
      omega
    by_cases c1 : lam x % 3 = 1
    · have hw := (seed_white (lam x - 1) (by omega) (by rosary)).1
      have hs := (seed_spec (lam (lam x - 1)) (by rosary)).2.1
      have : 3 * lam (lam x - 1) + 1 ≤ 2 * lam x := by rosary
      omega
    · have hw := (seed_white (lam x) (by omega) (by rosary)).1
      have hs := (seed_spec (lam (lam x)) (by rosary)).2.1
      have : 3 * lam (lam x) + 1 ≤ 2 * lam x := by rosary
      omega

/-- The seed of the winner is the smaller of the two seeds. -/
theorem seed_winner (B : Nat) (hb : Black B) (h4 : 4 ≤ B) :
    seed (winner B) = min (seed (mu B)) (seed (nu B)) := by
  have := theorem1_part3 B hb h4
  unfold winner
  by_cases h : lambex (nu B) < lambex (mu B)
  · rw [if_pos h]; omega
  · rw [if_neg h]; omega

/-- **Proposition 2.**  For every onyx `𝐧 ≥ 2`,
`𝛑(𝐧) ≤ (8𝐧 + 1)/9 < 𝐧`; and `𝛑(𝐧)` is an onyx, whose bead is the seed
of the winner above `𝐧•`. -/
theorem proposition2 (n : Nat) (hn : 2 ≤ n) :
    1 ≤ pi n ∧ 9 * pi n ≤ 8 * n + 1 ∧ pi n < n ∧
    bullet (pi n) = seed (winner (bullet n)) := by
  have hb : Black (bullet n) := by simp only [bullet, Black]; omega
  have h4 : 4 ≤ bullet n := by simp only [bullet]; omega
  have hsw := seed_winner (bullet n) hb h4
  have hle := neighbors_seed_le (nu (bullet n)) (by rosary) (by rosary)
  have e1 : nu (bullet n) - 1 = mu (bullet n) := by rosary
  have e2 : lam (nu (bullet n)) = 4 * n - 2 := by simp only [bullet]; rosary
  rw [e1, e2, ← hsw] at hle
  have hwpos : 1 ≤ winner (bullet n) := by
    unfold winner; split <;> rosary
  have hblack := (seed_spec (winner (bullet n)) hwpos).1
  have hbo := bullet_onyxOf _ hblack
  simp only [pi, onyxOf, bullet, Black] at *
  omega

/-! ## Up-chains: order -/

theorem upPow_lt (x y i : Nat) (h : x < y) : upPow x i < upPow y i := by
  induction i with
  | zero => exact h
  | succ i ih => simp only [upPow]; rosary

theorem upPow_lt_succ (x i : Nat) (hx : 1 ≤ x) : upPow x i < upPow x (i + 1) := by
  have := upPow_pos x i hx
  simp only [upPow]; rosary

theorem upPow_lt_index (x i j : Nat) (hx : 1 ≤ x) (h : i < j) :
    upPow x i < upPow x j := by
  induction j with
  | zero => omega
  | succ j ih =>
    have := upPow_lt_succ x j hx
    by_cases hij : i = j
    · rw [hij]; exact this
    · have := ih (by omega); omega

theorem upPow_ge (x i : Nat) (hx : 1 ≤ x) : x + i ≤ upPow x i := by
  induction i with
  | zero => exact Nat.le_refl x
  | succ i ih => have := upPow_lt_succ x i hx; omega

/-! ## Lemma 8 (neighboring up-chains) -/

/-- If the chains of `x` and `x + 1` are one apart after `r` steps, the
chain of `x` was odd all the way. -/
theorem gap_one (x r : Nat) (h : upPow (x + 1) r = upPow x r + 1) :
    ∀ i, i < r → upPow x i % 2 = 1 := by
  induction r with
  | zero => intro i hi; omega
  | succ r ih =>
    have hlt := upPow_lt x (x + 1) r (Nat.lt_succ_self x)
    simp only [upPow] at h
    have key : upPow (x + 1) r = upPow x r + 1 ∧ upPow x r % 2 = 1 := by rosary
    intro i hi
    by_cases hir : i = r
    · rw [hir]; exact key.2
    · exact ih key.1 i (by omega)

/-- **Lemma 8, the count.**  The chains of `a` and `a + 1` are one apart
after `r` steps exactly when `2^r` divides `a + 1`: this happens for
`r = 0, …, v₂(a + 1)`, that is `1 + v₂(a + 1)` times. -/
theorem gap_one_iff (a r : Nat) :
    upPow (a + 1) r = upPow a r + 1 ↔ 2 ^ r ∣ a + 1 := by
  constructor
  · intro h; exact (lemma7_odd a r).mp (gap_one a r h)
  · intro h
    induction r with
    | zero => rfl
    | succ r ih =>
      have hr := ih (Nat.dvd_trans (Nat.pow_dvd_pow 2 (Nat.le_succ r)) h)
      have hodd := (lemma7_odd a (r + 1)).mpr h r (Nat.lt_succ_self r)
      simp only [upPow]
      rw [hr]
      rosary

/-- For `a ≥ 3`, the chains of `a` and `a + 1` interlace, so the chain of
`a + 1` meets the chain of `a` shifted by one only at equal numbers of
steps, and at most `a` steps away. -/
theorem coincidence (a r r' : Nat) (ha : 3 ≤ a)
    (h : upPow a r + 1 = upPow (a + 1) r') : r = r' ∧ r ≤ a := by
  have i1 := upPow_lt a (a + 1) r' (Nat.lt_succ_self a)
  have i2 : upPow (a + 1) r' < upPow a (r' + 1) := by
    rw [upPow_succ_left]; exact upPow_lt _ _ r' (by rosary)
  have hrr : r = r' := by
    apply Classical.byContradiction
    intro hne
    by_cases hlt : r < r'
    · have := upPow_lt_index a r r' (by omega) hlt; omega
    · have : upPow a (r' + 1) ≤ upPow a r := by
        by_cases e : r' + 1 = r
        · rw [e]; exact Nat.le_refl _
        · exact Nat.le_of_lt (upPow_lt_index a (r' + 1) r (by omega) (by omega))
      omega
  refine ⟨hrr, ?_⟩
  rw [← hrr] at h
  have hdvd := (gap_one_iff a r).mp h.symm
  have := Nat.le_of_dvd (by omega) hdvd
  have : r < 2 ^ r := Nat.lt_two_pow_self
  omega

/-- **Lemma 8 (neighboring up-chains).**  Let `↑(m)` and `↑(n)` be two
disjoint up-chains.  Then `↑(n) ∩ (↑(m) + 1)` is finite: the steps `i`
with `mUⁱ + 1 ∈ ↑(n)` are bounded. -/
theorem lemma8 (m n : Nat) (hm : 1 ≤ m) (hn : 1 ≤ n)
    (disj : ∀ i j, upPow m i ≠ upPow n j) :
    ∃ N, ∀ i j, upPow m i + 1 = upPow n j → i ≤ N := by
  by_cases hex : ∃ i, ∃ j, upPow m i + 1 = upPow n j
  · -- `a = mU^i₀` is the least element of `↑(m)` with `a + 1 ∈ ↑(n)`
    obtain ⟨i0, ⟨j0, h0⟩, hmin⟩ := exists_least _ hex
    have hapos := upPow_pos m i0 hm
    have ha : 3 ≤ upPow m i0 := by
      apply Classical.byContradiction
      intro hsmall
      have e : upPow m (i0 + 1) = upPow m i0 + 1 := by simp only [upPow]; rosary
      exact disj (i0 + 1) j0 (by rw [e, h0])
    refine ⟨i0 + upPow m i0, fun i j h => ?_⟩
    have hi : i0 ≤ i := hmin i ⟨j, h⟩
    have hj : j0 ≤ j := by
      apply Classical.byContradiction
      intro hlt
      have := upPow_lt_index n j j0 hn (by omega)
      have : upPow m i0 ≤ upPow m i := by
        by_cases e : i0 = i
        · rw [e]; exact Nat.le_refl _
        · exact Nat.le_of_lt (upPow_lt_index m i0 i hm (by omega))
      omega
    have e1 : upPow m i = upPow (upPow m i0) (i - i0) := by
      rw [← upPow_add]; congr 1; omega
    have e2 : upPow n j = upPow (upPow m i0 + 1) (j - j0) := by
      rw [h0, ← upPow_add]; congr 1; omega
    rw [e1, e2] at h
    have := (coincidence _ _ _ ha h).2
    omega
  · exact ⟨0, fun i j h => absurd ⟨i, j, h⟩ hex⟩

/-! ## Theorem 4: every onyx has infinitely many covers -/

/-- The up-chains of two different black beads are disjoint. -/
theorem chains_disjoint (B B' : Nat) (hb : Black B) (hb' : Black B') (hne : B ≠ B') :
    ∀ i j, upPow B i ≠ upPow B' j := by
  intro i j h
  have h1 := (seed_upPow B i hb).1
  have h2 := (seed_upPow B' j hb').1
  rw [h, h2] at h1
  exact hne h1.symm

/-- Only finitely many beads of the chain of `B` are neighbors of a bead
of a chain that starts at a lower black bead. -/
theorem bad_steps (B : Nat) (hb : Black B) (M : Nat) : M ≤ B →
    ∃ N, ∀ i B' i', Black B' → B' < M →
      (upPow B i + 1 = upPow B' i' ∨ upPow B' i' + 1 = upPow B i) → i ≤ N := by
  induction M with
  | zero => intro _; exact ⟨0, fun i B' i' _ h => by omega⟩
  | succ M ih =>
    intro hM
    obtain ⟨N0, hN0⟩ := ih (by omega)
    by_cases hbM : Black M
    · have hBpos : 1 ≤ B := by rosary
      have hMpos : 1 ≤ M := by rosary
      obtain ⟨N1, hN1⟩ := lemma8 B M hBpos hMpos
        (chains_disjoint B M hb hbM (by omega))
      obtain ⟨N2, hN2⟩ := lemma8 M B hMpos hBpos
        (chains_disjoint M B hbM hb (by omega))
      refine ⟨N0 + N1 + upPow M N2 + 1, fun i B' i' hb' hlt h => ?_⟩
      by_cases e : B' = M
      · subst e
        rcases h with h | h
        · have := hN1 i i' h; omega
        · have hi' := hN2 i' i h
          have hge := upPow_ge B i hBpos
          have : upPow B' i' ≤ upPow B' N2 := by
            by_cases e : i' = N2
            · rw [e]; exact Nat.le_refl _
            · exact Nat.le_of_lt (upPow_lt_index B' i' N2 hMpos (by omega))
          omega
      · have := hN0 i B' i' hb' (by omega) h; omega
    · refine ⟨N0, fun i B' i' hb' hlt h => ?_⟩
      have : B' ≠ M := fun e => hbM (e ▸ hb')
      exact hN0 i B' i' hb' (by omega) h

/-- **Theorem 4.**  Every onyx has infinitely many covers: for every onyx
`𝐦` and every bound `N` there is an onyx `𝐧 > N` with `𝛑(𝐧) = 𝐦`. -/
theorem theorem4 (m : Nat) (hm : 1 ≤ m) (N : Nat) : ∃ n, N < n ∧ 2 ≤ n ∧ pi n = m := by
  have hb : Black (bullet m) := by simp only [bullet, Black]; omega
  have hBpos : 1 ≤ bullet m := by simp only [bullet]; omega
  obtain ⟨N0, hN0⟩ := bad_steps (bullet m) hb (bullet m) (Nat.le_refl _)
  -- far enough along the chain of `𝐦•`, a step where the parity changes
  obtain ⟨j, hj, hpar⟩ := lemma7 (bullet m) hBpos (N0 + 6 * N + 8)
  have hk : upPow (bullet m) (j + 1) = up (upPow (bullet m) j) := rfl
  have hblack : Black (down (upPow (bullet m) (j + 1))) := by
    rw [hk]; exact (lemma6 _).mpr (by rw [← hk]; exact hpar)
  have hge := upPow_ge (bullet m) (j + 1) hBpos
  have hseed := (seed_upPow (bullet m) (j + 1) hb).1
  generalize hkdef : upPow (bullet m) (j + 1) = k at *
  -- `k` sits just above the black bead `kD = 𝐧•`
  have hn4 : 4 ≤ down k := by rosary
  have hbn := bullet_onyxOf (down k) hblack
  have p3 := theorem1_part3 (down k) hblack hn4
  have hkk : k = mu (down k) ∨ k = nu (down k) := (down_eq_iff k (down k)).mp rfl
  refine ⟨onyxOf (down k), by simp only [onyxOf]; rosary, by simp only [onyxOf]; rosary, ?_⟩
  have hwin : winner (down k) = k := by
    unfold winner
    rcases hkk with e | e
    · -- `k = 𝐧•μ`, its sibling is `k + 1`
      have hsib : nu (down k) = k + 1 := by rosary
      rw [← e] at p3 ⊢
      rw [hsib] at p3 ⊢
      by_cases hlt : lambex (k + 1) < lambex k
      · rw [if_pos hlt]
      · -- the sibling has the smaller seed: a lower chain runs next to ours
        have hs := seed_spec (k + 1) (by omega)
        have := hN0 (j + 1) (seed (k + 1)) (lambex (k + 1)) hs.1 (by omega)
          (Or.inl (by rw [hs.2.2, hkdef]))
        omega
    · -- `k = 𝐧•ν`, its sibling is `k - 1`
      have hsib : mu (down k) = k - 1 := by rosary
      rw [← e] at p3 ⊢
      rw [hsib] at p3 ⊢
      by_cases hlt : lambex k < lambex (k - 1)
      · have hs := seed_spec (k - 1) (by omega)
        have := hN0 (j + 1) (seed (k - 1)) (lambex (k - 1)) hs.1 (by omega)
          (Or.inr (by rw [hs.2.2, hkdef]; omega))
        omega
      · rw [if_neg hlt]
  unfold pi
  rw [hbn, hwin, hseed]
  exact onyxOf_bullet m hm

end Rosary
