-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Rosary.Seed

/-!
# Theorem 1: minimal recitations ending in a black bead

The paper writes the black bead as `𝐧•`, with `2𝐧 - 1 = 3^e q`.  Parts 3,
4 and 5 do not mention `e` and `q`, and are stated here for a black bead
`B ≥ 4` directly.  Parts 1 and 2, at the end of the file, are stated with
`𝐧`, `e` and `q` as in the paper.

The parts are numbered here as the paper numbered them until 21 November
2026.  The paper has since moved the chains into the proof and reordered
the rest.  From the numbers used here to the paper's:

* part 1 (the two chains `a_i`, `b_i`): Step 1 of the proof;
* part 2 (who wins, from `2^(e+1) q` modulo 3): the rule in the head of the
  statement, and "the loser has lambda exponent `e + 1`" in its part 2;
* part 3 (different lambda exponents and seeds): its part 2;
* part 4 (a black bead is at least as high as its neighbors): its part 3;
* part 5 (the winner is on a minimal recitation): its part 1.
-/

namespace Rosary

/-! ## Part 3: the two beads above a black bead have different lambexes
and different seeds, and the larger lambex goes with the smaller seed -/

/-- Two neighbors `x - 1` and `x`, with `x` a multiple of 3: both are
white, and going back with `λ` they stay neighbors until one of them turns
black. -/
theorem neighbors_seed (x : Nat) : 6 ≤ x → x % 3 = 0 →
    lambex (x - 1) ≠ lambex x ∧ seed (x - 1) ≠ seed x ∧
    (lambex x < lambex (x - 1) ↔ seed (x - 1) < seed x) := by
  induction x using Nat.strongRecOn with
  | _ x ih =>
    intro h6 h0
    have hx := seed_white x (by omega) (by rosary)
    have hx1 := seed_white (x - 1) (by omega) (by rosary)
    have hl : lam (x - 1) = lam x - 1 := by rosary
    rw [hl] at hx1
    have hlx : 4 ≤ lam x ∧ lam x < x := by rosary
    by_cases c0 : lam x % 3 = 0
    · have := ih (lam x) hlx.2 (by omega) c0
      omega
    by_cases c1 : lam x % 3 = 1
    · -- `xλ` is black: the seed of `x`
      have hb := seed_black (lam x) c1
      have hw := seed_white (lam x - 1) (by omega) (by rosary)
      have hs := (seed_spec (lam (lam x - 1)) (by rosary)).2.1
      have : lam (lam x - 1) < lam x := by rosary
      omega
    · -- `xλ - 1` is black: the seed of `x - 1`
      have hb := seed_black (lam x - 1) (by rosary)
      have hw := seed_white (lam x) (by omega) (by rosary)
      have hs := (seed_spec (lam (lam x)) (by rosary)).2.1
      have : lam (lam x) < lam x - 1 := by rosary
      omega

/-- **Theorem 1, part 3.**  For a black bead `B > 1`:
`Λ(Bμ) ≠ Λ(Bν)`, `σ(Bμ) ≠ σ(Bν)`, and
`Λ(Bμ) > Λ(Bν) ⟺ σ(Bμ) < σ(Bν)`. -/
theorem theorem1_part3 (B : Nat) (hb : Black B) (h4 : 4 ≤ B) :
    lambex (mu B) ≠ lambex (nu B) ∧ seed (mu B) ≠ seed (nu B) ∧
    (lambex (nu B) < lambex (mu B) ↔ seed (mu B) < seed (nu B)) := by
  have := neighbors_seed (nu B) (by rosary) (by rosary)
  have e : nu B - 1 = mu B := by rosary
  rw [e] at this
  exact this

/-! ## Parts 4 and 5: the heights -/

/-- One rung of the ladders drawn in the paper.  The four beads are
`a = 2k - 1`, `b = 2k` and, below them, `c = k - 1 = aD`, `d = k = bD`.
`H` is the height of the black bead we started from; the hypothesis `IH`
is part 4 for the black beads of smaller height. -/
theorem ladder_step (H : Nat)
    (IH : ∀ B, Black B → 4 ≤ B → height B < H →
      height (B - 1) ≤ height B ∧ height (B + 1) ≤ height B) :
    ∀ k, 2 ≤ k → min (height (2 * k - 1)) (height (2 * k)) + 2 ≤ H →
      max (height (k - 1)) (height k) ≤ min (height (2 * k - 1)) (height (2 * k)) + 1 ∧
      (lambex (2 * k) < lambex (2 * k - 1) → height (2 * k - 1) ≤ height (2 * k)) ∧
      (lambex (2 * k - 1) < lambex (2 * k) → height (2 * k) ≤ height (2 * k - 1)) := by
  intro k
  induction k using Nat.strongRecOn with
  | _ k ih =>
    intro hk hH
    by_cases c0 : k % 3 = 0
    · -- The four beads are white: one step back with `λ`, on each row.
      have ha := lemma2 (2 * k - 1) (by omega) (by rosary)
      have hb := lemma2 (2 * k) (by omega) (by rosary)
      have hc := lemma2 (k - 1) (by omega) (by rosary)
      have hd := lemma2 k (by omega) (by rosary)
      have sa := seed_white (2 * k - 1) (by omega) (by rosary)
      have sb := seed_white (2 * k) (by omega) (by rosary)
      have ea : lam (2 * k - 1) = 2 * lam k - 1 := by rosary
      have eb : lam (2 * k) = 2 * lam k := by rosary
      have ec : lam (k - 1) = lam k - 1 := by rosary
      rw [ea] at ha sa
      rw [eb] at hb sb
      rw [ec] at hc
      have := ih (lam k) (by rosary) (by rosary) (by omega)
      omega
    by_cases c2 : k % 3 = 2
    · -- `b` and `c` are black: "μ wins".
      have hbb : Black (2 * k) := by rosary
      have sb := seed_black (2 * k) hbb
      have sa := seed_white (2 * k - 1) (by omega) (by rosary)
      have h1 : height (2 * k - 1) ≤ height (2 * k) := by
        apply Classical.byContradiction
        intro hlt
        have := (IH (2 * k) hbb (by omega) (by omega)).1
        omega
      have hdown := height_down_le (2 * k - 1) (by omega)
      have ed : down (2 * k - 1) = k - 1 := by rosary
      rw [ed] at hdown
      refine ⟨?_, fun _ => h1, fun h => by omega⟩
      by_cases k2 : k = 2
      · -- `c` is bead 1 and `d` is bead 2
        have e1 : height (k - 1) = 0 := by
          rw [show k - 1 = 1 by omega]; exact height_one
        have e2 : height k ≤ 1 := by
          have := height_up_le 1 (Nat.le_refl 1)
          rw [show up 1 = 2 by decide, height_one] at this
          rw [k2]; exact this
        omega
      · have := (IH (k - 1) (by rosary) (by omega) (by omega)).2
        rw [show k - 1 + 1 = k by omega] at this
        omega
    · -- `a` and `d` are black: "ν wins".
      have hab : Black (2 * k - 1) := by rosary
      have sa := seed_black (2 * k - 1) hab
      have sb := seed_white (2 * k) (by omega) (by rosary)
      have h1 : height (2 * k) ≤ height (2 * k - 1) := by
        apply Classical.byContradiction
        intro hlt
        have := (IH (2 * k - 1) hab (by omega) (by omega)).2
        rw [show 2 * k - 1 + 1 = 2 * k by omega] at this
        omega
      have hdown := height_down_le (2 * k) (by omega)
      have ed : down (2 * k) = k := by rosary
      rw [ed] at hdown
      have := (IH k (by rosary) (by omega) (by omega)).1
      exact ⟨by omega, fun h => by omega, fun _ => h1⟩

theorem theorem1_part4_aux (H : Nat) : ∀ B, Black B → 4 ≤ B → height B < H →
    height (B - 1) ≤ height B ∧ height (B + 1) ≤ height B := by
  induction H with
  | zero => intro B _ _ h; omega
  | succ H ih =>
    intro B hb h4 hH
    have step := ladder_step (height B)
      (fun B' hb' h4' hlt => ih B' hb' h4' (by omega)) (lam (B + 1)) (by rosary)
    have c1 := corollary1 B hb (by omega)
    have wab := white_above_black B hb
    have hmu := lemma2 (mu B) (by rosary) wab.1
    have hnu := lemma2 (nu B) (by rosary) wab.2
    have hm := lemma2 (B - 1) (by omega) (by rosary)
    have hp := lemma2 (B + 1) (by omega) (by rosary)
    have e1 : lam (mu B) = 2 * lam (B + 1) - 1 := by rosary
    have e2 : lam (nu B) = 2 * lam (B + 1) := by rosary
    have e3 : lam (B - 1) = lam (B + 1) - 1 := by rosary
    rw [e1] at hmu
    rw [e2] at hnu
    rw [e3] at hm
    have := step (by omega)
    omega

/-- **Theorem 1, part 4.**  A black bead `B > 1` is at least as high as
its two neighbors: `h(B) ≥ h(B - 1)` and `h(B) ≥ h(B + 1)`. -/
theorem theorem1_part4 (B : Nat) (hb : Black B) (h4 : 4 ≤ B) :
    height (B - 1) ≤ height B ∧ height (B + 1) ≤ height B :=
  theorem1_part4_aux (height B + 1) B hb h4 (Nat.lt_succ_self _)

/-- Of the two beads above a black bead, the one with the larger lambex
is not higher than the other. -/
theorem winner_height (B : Nat) (hb : Black B) (h4 : 4 ≤ B) :
    (lambex (nu B) < lambex (mu B) → height (mu B) ≤ height (nu B)) ∧
    (lambex (mu B) < lambex (nu B) → height (nu B) ≤ height (mu B)) := by
  have step := ladder_step _
    (fun B' hb' h4' _ => theorem1_part4 B' hb' h4') (lam (B + 1)) (by rosary)
    (Nat.le_refl _)
  have wab := white_above_black B hb
  have hmu := lemma2 (mu B) (by rosary) wab.1
  have hnu := lemma2 (nu B) (by rosary) wab.2
  have smu := seed_white (mu B) (by rosary) wab.1
  have snu := seed_white (nu B) (by rosary) wab.2
  have e1 : lam (mu B) = 2 * lam (B + 1) - 1 := by rosary
  have e2 : lam (nu B) = 2 * lam (B + 1) := by rosary
  rw [e1] at hmu smu
  rw [e2] at hnu snu
  omega

/-- **Theorem 1, part 5, when μ wins.**  If `Λ(Bμ) > Λ(Bν)` then
`h(B) = h(σ(Bμ)) + Λ(Bμ) + 1`: a minimal recitation to `B` ends in
`σ(Bμ) U^Λ(Bμ) D`. -/
theorem theorem1_part5_mu (B : Nat) (hb : Black B) (h4 : 4 ≤ B)
    (hwin : lambex (nu B) < lambex (mu B)) :
    height B = height (seed (mu B)) + lambex (mu B) + 1 := by
  have c1 := corollary1 B hb (by omega)
  have w := (winner_height B hb h4).1 hwin
  have hs := height_seed (mu B) (by rosary)
  omega

/-- **Theorem 1, part 5, when ν wins.**  If `Λ(Bν) > Λ(Bμ)` then
`h(B) = h(σ(Bν)) + Λ(Bν) + 1`. -/
theorem theorem1_part5_nu (B : Nat) (hb : Black B) (h4 : 4 ≤ B)
    (hwin : lambex (mu B) < lambex (nu B)) :
    height B = height (seed (nu B)) + lambex (nu B) + 1 := by
  have c1 := corollary1 B hb (by omega)
  have w := (winner_height B hb h4).2 hwin
  have hs := height_seed (nu B) (by rosary)
  omega

/-! ## Parts 1 and 2: the two chains, with `2𝐧 - 1 = 3^e q` -/

/-- `b_i = 2^i 3^(e+1-i) q`, for `0 ≤ i ≤ e + 1`.  The paper's `a_i` is
`b_i - 1`. -/
def bChain (e q i : Nat) : Nat := 2 ^ i * 3 ^ (e + 1 - i) * q

theorem bChain_zero (e q : Nat) : bChain e q 0 = 3 * (3 ^ e * q) := by
  simp only [bChain, Nat.pow_zero, Nat.one_mul, Nat.sub_zero, Nat.pow_succ]
  ac_rfl

theorem bChain_last (e q : Nat) : bChain e q (e + 1) = 2 ^ (e + 1) * q := by
  simp only [bChain, Nat.sub_self, Nat.pow_zero, Nat.mul_one]

theorem bChain_step (e q i : Nat) (hi : i ≤ e) (hq : 1 ≤ q) :
    ∃ t, 1 ≤ t ∧ bChain e q i = 3 * t ∧ bChain e q (i + 1) = 2 * t := by
  refine ⟨2 ^ i * 3 ^ (e - i) * q,
    Nat.mul_pos (Nat.mul_pos (Nat.pow_pos (by decide)) (Nat.pow_pos (by decide))) hq,
    ?_, ?_⟩
  · have : e + 1 - i = (e - i) + 1 := by omega
    simp only [bChain, this, Nat.pow_succ]
    ac_rfl
  · have : e + 1 - (i + 1) = e - i := by omega
    simp only [bChain, this, Nat.pow_succ]
    ac_rfl

theorem lamPow_succ (x i : Nat) : lamPow x (i + 1) = lam (lamPow x i) := by
  induction i generalizing x with
  | zero => rfl
  | succ i ih => exact ih (lam x)

/-- 3 does not divide `2^m q` when it does not divide `q`. -/
theorem two_pow_mul_mod3 (m q : Nat) (hq : q % 3 ≠ 0) : (2 ^ m * q) % 3 ≠ 0 := by
  induction m with
  | zero => rw [Nat.pow_zero, Nat.one_mul]; exact hq
  | succ m ih => rw [Nat.pow_succ, Nat.mul_right_comm]; omega

/-- Every positive integer is `3^e q` with `q` not divisible by 3. -/
theorem exists_pow3 (m : Nat) (hm : 1 ≤ m) : ∃ e q, q % 3 ≠ 0 ∧ m = 3 ^ e * q := by
  induction m using Nat.strongRecOn with
  | _ m ih =>
    by_cases h : m % 3 = 0
    · obtain ⟨e, q, hq, he⟩ := ih (m / 3) (by omega) (by omega)
      exact ⟨e + 1, q, hq, by rw [Nat.pow_succ, Nat.mul_right_comm]; omega⟩
    · exact ⟨0, m, h, by rw [Nat.pow_zero, Nat.one_mul]⟩

/-- **Theorem 1, part 1.**  Let `𝐧 ≥ 2` and `2𝐧 - 1 = 3^e q` with
`3 ∤ q`; the black bead is `𝐧• = 3𝐧 - 2`.  For all `i ≤ e + 1`,
`𝐧•νλⁱ = b_i` and `𝐧•μλⁱ = a_i = b_i - 1`; for `i ≤ e`, both are white. -/
theorem theorem1_part1 (n e q : Nat) (hn : 2 ≤ n) (hq : q % 3 ≠ 0)
    (h : 2 * n - 1 = 3 ^ e * q) :
    ∀ i, i ≤ e + 1 →
      lamPow (nu (3 * n - 2)) i = bChain e q i ∧
      lamPow (mu (3 * n - 2)) i = bChain e q i - 1 ∧
      (i ≤ e → White (bChain e q i) ∧ White (bChain e q i - 1)) := by
  intro i
  induction i with
  | zero =>
    intro _
    have := bChain_zero e q
    refine ⟨?_, ?_, fun _ => ?_⟩ <;> (try simp only [lamPow]) <;> rosary
  | succ i ih =>
    intro hi
    obtain ⟨hb, ha, _⟩ := ih (by omega)
    obtain ⟨t, ht, e3, e2⟩ := bChain_step e q i (by omega) (by omega)
    rw [lamPow_succ, lamPow_succ, hb, ha, e3, e2]
    refine ⟨by rosary, by rosary, fun hle => ?_⟩
    obtain ⟨t', ht', e3', _⟩ := bChain_step e q (i + 1) hle (by omega)
    rw [e2] at e3'
    rosary

/-- **Theorem 1, parts 1 (end) and 2.**  With the same notations,
`b_{e+1} = 2^(e+1) q` is not a multiple of 3, and:

- if `2^(e+1) q ≡ 1 (mod 3)` then `b_{e+1}` is black and
  `Λ(𝐧•μ) > Λ(𝐧•ν) = e + 1` ("μ wins");
- if `2^(e+1) q ≡ 2 (mod 3)` then `a_{e+1} = b_{e+1} - 1` is black and
  `Λ(𝐧•ν) > Λ(𝐧•μ) = e + 1` ("ν wins"). -/
theorem theorem1_part2 (n e q : Nat) (hn : 2 ≤ n) (hq : q % 3 ≠ 0)
    (h : 2 * n - 1 = 3 ^ e * q) :
    ((2 ^ (e + 1) * q) % 3 = 1 ∨ (2 ^ (e + 1) * q) % 3 = 2) ∧
    ((2 ^ (e + 1) * q) % 3 = 1 →
      Black (2 ^ (e + 1) * q) ∧ White (2 ^ (e + 1) * q - 1) ∧
      lambex (nu (3 * n - 2)) = e + 1 ∧ e + 1 < lambex (mu (3 * n - 2))) ∧
    ((2 ^ (e + 1) * q) % 3 = 2 →
      Black (2 ^ (e + 1) * q - 1) ∧ White (2 ^ (e + 1) * q) ∧
      lambex (mu (3 * n - 2)) = e + 1 ∧ e + 1 < lambex (nu (3 * n - 2))) := by
  have p1 := theorem1_part1 n e q hn hq h
  have last := bChain_last e q
  have hnu := seed_lamPow (e + 1) (nu (3 * n - 2)) (by rosary) fun i hi => by
    rw [(p1 i (by omega)).1]; exact ((p1 i (by omega)).2.2 (by omega)).1
  have hmu := seed_lamPow (e + 1) (mu (3 * n - 2)) (by rosary) fun i hi => by
    rw [(p1 i (by omega)).2.1]; exact ((p1 i (by omega)).2.2 (by omega)).2
  rw [(p1 (e + 1) (Nat.le_refl _)).1, last] at hnu
  rw [(p1 (e + 1) (Nat.le_refl _)).2.1, last] at hmu
  have hne := two_pow_mul_mod3 (e + 1) q hq
  refine ⟨by omega, fun h1 => ?_, fun h2 => ?_⟩
  · have sb := seed_black (2 ^ (e + 1) * q) h1
    have hw : White (2 ^ (e + 1) * q - 1) := by rosary
    have sw := seed_white (2 ^ (e + 1) * q - 1) hmu.1 hw
    exact ⟨h1, hw, by omega, by omega⟩
  · have hbk : Black (2 ^ (e + 1) * q - 1) := by rosary
    have sb := seed_black (2 ^ (e + 1) * q - 1) hbk
    have hw : White (2 ^ (e + 1) * q) := by rosary
    have sw := seed_white (2 ^ (e + 1) * q) hnu.1 hw
    exact ⟨hbk, hw, by omega, by omega⟩

end Rosary
