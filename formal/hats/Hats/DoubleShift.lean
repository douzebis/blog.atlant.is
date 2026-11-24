-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.Shift

/-!
# The double shift

`ds n s` adds two hats to a strategy on `n` hats: it is the left shift of
the right shift, with one more change, for the stack whose two new hats
are black and all others white, which now points at the top hat.
-/

namespace Hats

open Finset

/-- `s` (a strategy on `n` hats) double-shifted. -/
def ds (n : ℕ) (s : ℕ → ℤ) : ℕ → ℤ := fun t =>
  if t = 2 ^ (n + 1) + 2 ^ n then n + 1 else ls (n + 1) (rs n s) t

theorem rs_proper {n : ℕ} {s : ℕ → ℤ} (hs : Proper n s) : Proper (n + 1) (rs n s) := by
  intro t _
  have := hs _ (Nat.mod_lt t (Nat.two_pow_pos n))
  unfold rs
  split_ifs
  · constructor <;> push_cast <;> omega
  · constructor <;> push_cast <;> omega

/-- Changing what a strategy does for one stack `k`: how the hits move.
Only the pairs that involve `k` count. -/
theorem hits_update {N k : ℕ} (hk : k < 2 ^ N) {s1 s2 : ℕ → ℤ}
    (h : ∀ t, t ≠ k → s1 t = s2 t) :
    hits N s2 + 2 * ∑ t ∈ range (2 ^ N), pair s1 t k + pair s2 k k
      = hits N s1 + 2 * ∑ t ∈ range (2 ^ N), pair s2 t k + pair s1 k k := by
  have hmem : k ∈ range (2 ^ N) := mem_range.mpr hk
  have split : ∀ s : ℕ → ℤ, hits N s
      = ∑ t ∈ (range (2 ^ N)).erase k, ∑ u ∈ (range (2 ^ N)).erase k, pair s t u
        + 2 * ∑ t ∈ (range (2 ^ N)).erase k, pair s t k + pair s k k := by
    intro s
    unfold hits
    rw [← add_sum_erase _ _ hmem, ← add_sum_erase _ (fun u => pair s k u) hmem]
    rw [sum_congr rfl fun t _ => (add_sum_erase _ (fun u => pair s t u) hmem).symm]
    rw [sum_add_distrib, sum_congr rfl fun u _ => pair_comm s k u]
    ring
  have row : ∀ s : ℕ → ℤ, ∑ t ∈ range (2 ^ N), pair s t k
      = pair s k k + ∑ t ∈ (range (2 ^ N)).erase k, pair s t k := by
    intro s; exact (add_sum_erase _ (fun t => pair s t k) hmem).symm
  have same : ∑ t ∈ (range (2 ^ N)).erase k, ∑ u ∈ (range (2 ^ N)).erase k, pair s1 t u
      = ∑ t ∈ (range (2 ^ N)).erase k, ∑ u ∈ (range (2 ^ N)).erase k, pair s2 t u := by
    refine sum_congr rfl fun t ht => sum_congr rfl fun u hu => ?_
    unfold pair
    rw [h t (ne_of_mem_erase ht), h u (ne_of_mem_erase hu)]
  rw [split s1, split s2, row s1, row s2, same]
  ring

section

variable {n : ℕ} {s : ℕ → ℤ}

/-- The stack whose two top hats are black, the others white: its colors. -/
theorem hat_k_low {p : ℤ} (hp : 0 ≤ p) (hpn : p < n) :
    hat (2 ^ (n + 1) + 2 ^ n) p = 0 := by
  have h0 : 2 ^ n < 2 ^ (n + 1) := by rw [pow_succ]; have := Nat.two_pow_pos n; omega
  rw [show 2 ^ (n + 1) + 2 ^ n = 2 ^ (n + 1) * 1 + 2 ^ n by ring,
    hat_low 1 h0 hp (by push_cast; omega)]
  have h := hat_low_zero n 1 hp hpn
  rwa [mul_one] at h

theorem hat_k_n : hat (2 ^ (n + 1) + 2 ^ n) n = 1 := by
  have h0 : 2 ^ n < 2 ^ (n + 1) := by rw [pow_succ]; have := Nat.two_pow_pos n; omega
  rw [show 2 ^ (n + 1) + 2 ^ n = 2 ^ (n + 1) * 1 + 2 ^ n by ring,
    hat_low 1 h0 (by positivity) (by push_cast; omega)]
  simp [hat]

theorem hat_k_top : hat (2 ^ (n + 1) + 2 ^ n) ((n : ℤ) + 1) = 1 := by
  have h0 : 2 ^ n < 2 ^ (n + 1) := by rw [pow_succ]; have := Nat.two_pow_pos n; omega
  have := hat_above (m := n + 1) 1 h0 (p := 0) le_rfl
  simpa [hat] using this

end

/-- **Win rate after a double shift**, as a count of hits: the double
shift of a proper strategy on `n` hats has `16 * hits s + 6` hits. -/
theorem hits_ds {n : ℕ} {s : ℕ → ℤ} (hs : Proper n s) :
    hits (n + 2) (ds n s) = 16 * hits n s + 6 := by
  have hn := hs.pos
  have hP : 2 ≤ 2 ^ n := by
    have : 2 ^ 1 ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hn
    simpa using this
  have hQ : 2 ^ (n + 1) = 2 * 2 ^ n := by rw [pow_succ]; ring
  have hs0 := hs 0 (Nat.two_pow_pos n)
  have hk : 2 ^ (n + 1) + 2 ^ n < 2 ^ (n + 2) := by
    rw [pow_succ 2 (n + 1)]; omega
  have hkeq : 2 ^ (n + 1) + 2 ^ n = 2 ^ (n + 1) * 1 + 2 ^ n := by ring
  -- the two strategies
  have hagree : ∀ t, t ≠ 2 ^ (n + 1) + 2 ^ n → ls (n + 1) (rs n s) t = ds n s t := by
    intro t ht; simp [ds, ht]
  -- their values on the stack `Q * q + r`
  have v1 : ∀ q r, r < 2 ^ (n + 1) → ls (n + 1) (rs n s) (2 ^ (n + 1) * q + r)
      = if q = 1 ∧ r = 0 then (n : ℤ) + 1 else if r = 2 ^ n - 1 then (n : ℤ)
        else s (r % 2 ^ n) := by
    intro q r hr
    have hmod : (2 ^ (n + 1) * q + r) % 2 ^ (n + 1) = r := by
      rw [Nat.mul_add_mod, Nat.mod_eq_of_lt hr]
    have hiff : 2 ^ (n + 1) * q + r = 2 ^ (n + 1) ↔ q = 1 ∧ r = 0 := by
      constructor
      · intro h
        have hq : q = 1 := by
          rcases Nat.lt_or_ge q 1 with h1 | h1
          · interval_cases q; omega
          · rcases Nat.lt_or_ge q 2 with h2 | h2
            · omega
            · have : 2 ^ (n + 1) * 2 ≤ 2 ^ (n + 1) * q := Nat.mul_le_mul_left _ h2
              omega
        subst hq; exact ⟨rfl, by omega⟩
      · rintro ⟨rfl, rfl⟩; ring
    simp only [ls, rs, hmod, hiff]
    push_cast
    rfl
  have vk1 : ls (n + 1) (rs n s) (2 ^ (n + 1) + 2 ^ n) = s 0 := by
    rw [hkeq, v1 1 (2 ^ n) (by omega)]
    have h1 : ¬ ((1 : ℕ) = 1 ∧ 2 ^ n = 0) := by omega
    have h2 : 2 ^ n ≠ 2 ^ n - 1 := by omega
    simp [h2]
  have vk2 : ds n s (2 ^ (n + 1) + 2 ^ n) = (n : ℤ) + 1 := by simp [ds]
  -- the row of that stack, for the first strategy
  have row1 : ∑ t ∈ range (2 ^ (n + 2)), pair (ls (n + 1) (rs n s)) t (2 ^ (n + 1) + 2 ^ n)
      = 2 := by
    rw [show 2 ^ (n + 2) = 2 ^ (n + 1) * 2 by ring, sum_range_mul]
    have term : ∀ q ∈ range 2, ∀ r ∈ range (2 ^ (n + 1)),
        pair (ls (n + 1) (rs n s)) (2 ^ (n + 1) * q + r) (2 ^ (n + 1) + 2 ^ n)
          = if r = 2 ^ n - 1 then 1 else 0 := by
      intro q _ r hr
      have hr' := mem_range.mp hr
      unfold pair
      rw [vk1, v1 q r hr', hat_low q hr' hs0.1 (by push_cast; omega)]
      by_cases h1 : q = 1 ∧ r = 0
      · obtain ⟨_, rfl⟩ := h1
        have : (0 : ℕ) ≠ 2 ^ n - 1 := by omega
        simp [hat_zero, this]
      · by_cases h2 : r = 2 ^ n - 1
        · subst h2
          simp [h1, hat_ones hs0.1 hs0.2, hat_k_n]
        · have := hs _ (Nat.mod_lt r (Nat.two_pow_pos n))
          simp [h1, h2, hat_k_low this.1 this.2]
    rw [sum_congr rfl fun q hq => sum_congr rfl fun r hr => term q hq r hr]
    have hW : 2 ^ n - 1 ∈ range (2 ^ (n + 1)) := mem_range.mpr (by omega)
    simp [sum_ite_eq', hW]
  -- the row of that stack, for the second strategy
  have row2 : ∑ t ∈ range (2 ^ (n + 2)), pair (ds n s) t (2 ^ (n + 1) + 2 ^ n) = 3 := by
    rw [show 2 ^ (n + 2) = 2 ^ (n + 1) * 2 by ring, sum_range_mul]
    have term : ∀ q ∈ range 2, ∀ r ∈ range (2 ^ (n + 1)),
        pair (ds n s) (2 ^ (n + 1) * q + r) (2 ^ (n + 1) + 2 ^ n)
          = if q = 1 then (if r = 2 ^ n then 1 else 0) + (if r = 0 then 1 else 0)
              + (if r = 2 ^ n - 1 then 1 else 0) else 0 := by
      intro q hq r hr
      have hr' := mem_range.mp hr
      have hq' : q < 2 := mem_range.mp hq
      unfold pair
      rw [vk2]
      have hA := hat_above q hr' (p := 0) le_rfl
      simp only [add_zero] at hA
      have hA' : hat (2 ^ (n + 1) * q + r) ((n : ℤ) + 1) = hat q 0 := by
        have := hA; push_cast at this; exact this
      rw [hA']
      interval_cases q
      · simp [hat]
      · have hq1 : hat 1 0 = 1 := by simp [hat]
        rw [hq1, one_mul]
        by_cases hk' : r = 2 ^ n
        · subst hk'
          have e : 2 ^ (n + 1) * 1 + 2 ^ n = 2 ^ (n + 1) + 2 ^ n := by ring
          have h2 : (2 : ℕ) ^ n ≠ 0 := by omega
          have h3 : 2 ^ n ≠ 2 ^ n - 1 := by omega
          rw [e, vk2, hat_k_top]
          simp [h3]
        · have hne : 2 ^ (n + 1) * 1 + r ≠ 2 ^ (n + 1) + 2 ^ n := by omega
          rw [← hagree _ hne, v1 1 r hr']
          by_cases h1 : r = 0
          · subst h1
            have h3 : (0 : ℕ) ≠ 2 ^ n - 1 := by omega
            have h4 : (0 : ℕ) ≠ 2 ^ n := by omega
            simp [hat_k_top, h3, h4]
          · by_cases h2 : r = 2 ^ n - 1
            · subst h2
              have h3 : 2 ^ n - 1 ≠ 2 ^ n := by omega
              simp [h1, hat_k_n, h3]
            · have := hs _ (Nat.mod_lt r (Nat.two_pow_pos n))
              simp [h1, h2, hk', hat_k_low this.1 this.2]
    rw [sum_congr rfl fun q hq => sum_congr rfl fun r hr => term q hq r hr]
    have hW : 2 ^ n - 1 ∈ range (2 ^ (n + 1)) := mem_range.mpr (by omega)
    have hP' : 2 ^ n ∈ range (2 ^ (n + 1)) := mem_range.mpr (by omega)
    have h0 : 0 ∈ range (2 ^ (n + 1)) := mem_range.mpr (by omega)
    simp [sum_add_distrib, sum_ite_eq', hW, hP', h0]
  -- the pair of that stack with itself
  have d1 : pair (ls (n + 1) (rs n s)) (2 ^ (n + 1) + 2 ^ n) (2 ^ (n + 1) + 2 ^ n) = 0 := by
    unfold pair; rw [vk1, hat_k_low hs0.1 hs0.2]
  have d2 : pair (ds n s) (2 ^ (n + 1) + 2 ^ n) (2 ^ (n + 1) + 2 ^ n) = 1 := by
    unfold pair; rw [vk2, hat_k_top]
  have upd := hits_update hk hagree
  rw [row1, row2, d1, d2] at upd
  have e1 : hits (n + 1 + 1) (ls (n + 1) (rs n s)) = 4 * hits (n + 1) (rs n s) + 1 :=
    hits_ls (rs_proper hs)
  have e2 := hits_rs hs
  have e3 : hits (n + 2) (ls (n + 1) (rs n s)) = hits (n + 1 + 1) (ls (n + 1) (rs n s)) := rfl
  omega

theorem ds_proper {n : ℕ} {s : ℕ → ℤ} (hs : Proper n s) : Proper (n + 2) (ds n s) := by
  intro t _
  have := hs _ (Nat.mod_lt (t % 2 ^ (n + 1)) (Nat.two_pow_pos n))
  unfold ds ls rs
  split_ifs <;> constructor <;> push_cast <;> omega

end Hats
