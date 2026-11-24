-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.DoubleShift

/-!
# Families of strategies and their hits

The strategies of the article, each built by repeating one operation, with
the number of their hits in closed form.
-/

namespace Hats

open Finset

/-- The strategy on no hat: it has no hat to point at. -/
def none : ℕ → ℤ := fun _ => -1

theorem hits_none : hits 0 none = 0 := by decide

/-! ### A strategy that always points at the same hat -/

/-- A strategy that always points at the same hat of the stack wins one
time in four. -/
theorem hits_const {n : ℕ} {p : ℤ} (hp : 0 ≤ p) (hpn : p < n) :
    hits n (fun _ => p) = 4 ^ (n - 1) := by
  unfold hits pair
  rw [← sum_mul_sum, sum_hat hp hpn, four_pow]

/-! ### Following the lowest black hat, or the lowest white hat -/

/-- The strategy on `n` hats built by `n` left resets of the one-hat
strategy: it points where the stack it sees has its lowest black hat. -/
def lowBlack : ℕ → ℕ → ℤ
  | 0 => none
  | n + 1 => lr 1 one (lowBlack n)

/-- The strategy on `n` hats built by right resets of the one-hat strategy:
it points where the stack it sees has its lowest white hat. -/
def lowWhite : ℕ → ℕ → ℤ
  | 0 => none
  | 1 => one
  | n + 2 => rr 1 one (lowWhite (n + 1))

/-- Following the lowest black hat: `(4 ^ n - 1) / 3` hits. -/
theorem hits_lowBlack (n : ℕ) : 3 * hits n (lowBlack n) + 1 = 4 ^ n := by
  induction n with
  | zero => simp [lowBlack, hits_none]
  | succ n ih =>
    have := hits_lr n (lowBlack n) one_proper
    rw [hits_one, Nat.add_comm 1 n] at this
    rw [lowBlack, this, pow_succ]
    omega

theorem lowWhite_proper (n : ℕ) : Proper (n + 1) (lowWhite (n + 1)) := by
  induction n with
  | zero => exact one_proper
  | succ n ih =>
    have := rr_proper one_proper ih
    rwa [Nat.add_comm 1 (n + 1)] at this

/-- Following the lowest white hat: `(4 ^ n - 1) / 3` hits. -/
theorem hits_lowWhite (n : ℕ) : 3 * hits n (lowWhite n) + 1 = 4 ^ n := by
  rcases n with _ | n
  · simp [lowWhite, hits_none]
  induction n with
  | zero => simp [lowWhite, hits_one]
  | succ n ih =>
    have := hits_rr one_proper (lowWhite_proper n)
    rw [hits_one, Nat.add_comm 1 (n + 1)] at this
    rw [lowWhite, this, pow_succ 4 (n + 1)]
    omega

/-! ### The Carter strategies -/

/-- The Carter strategy on `2 * k + 1` hats: the one-hat strategy,
double-shifted `k` times. -/
def carterOdd : ℕ → ℕ → ℤ
  | 0 => one
  | k + 1 => ds (2 * k + 1) (carterOdd k)

/-- The Carter strategy on `2 * k + 2` hats: the right shift of the one on
`2 * k + 1` hats. -/
def carterEven (k : ℕ) : ℕ → ℤ := rs (2 * k + 1) (carterOdd k)

/-- The Carter strategy on `n` hats, for `n` at least `1`. -/
def carter (n : ℕ) : ℕ → ℤ :=
  if n % 2 = 1 then carterOdd (n / 2) else carterEven (n / 2 - 1)

theorem carterOdd_proper (k : ℕ) : Proper (2 * k + 1) (carterOdd k) := by
  induction k with
  | zero => exact one_proper
  | succ k ih => exact ds_proper ih

theorem hits_carterOdd (k : ℕ) : 5 * hits (2 * k + 1) (carterOdd k) + 2 = 7 * 16 ^ k := by
  induction k with
  | zero => simp [carterOdd, hits_one]
  | succ k ih =>
    have := hits_ds (carterOdd_proper k)
    rw [show 2 * (k + 1) + 1 = 2 * k + 1 + 2 by ring, carterOdd, this, pow_succ]
    omega

theorem hits_carterEven (k : ℕ) :
    5 * hits (2 * k + 2) (carterEven k) + 3 = 28 * 16 ^ k := by
  have h1 := hits_rs (carterOdd_proper k)
  have h2 := hits_carterOdd k
  rw [carterEven, show 2 * k + 2 = 2 * k + 1 + 1 by ring, h1]
  omega

/-- **The hits of the Carter strategies in closed form**: on `n` hats, the
integer part of `7 * 4 ^ n / 20`. -/
theorem hits_carter {n : ℕ} (hn : 1 ≤ n) : hits n (carter n) = 7 * 4 ^ n / 20 := by
  have h16 : ∀ k : ℕ, (4 : ℕ) ^ (2 * k) = 16 ^ k := fun k => by
    rw [pow_mul]; norm_num
  rcases Nat.even_or_odd' n with ⟨k, rfl | rfl⟩
  · obtain ⟨j, rfl⟩ : ∃ j, k = j + 1 := ⟨k - 1, by omega⟩
    have h := hits_carterEven j
    have e : carter (2 * (j + 1)) = carterEven j := by
      have h1 : 2 * (j + 1) % 2 = 0 := by omega
      simp [carter, h1]
    rw [e, show 2 * (j + 1) = 2 * j + 2 by ring, pow_add, h16]
    omega
  · have h := hits_carterOdd k
    have e : carter (2 * k + 1) = carterOdd k := by
      have h2 : (2 * k + 1) / 2 = k := by omega
      simp [carter, h2]
    rw [e, pow_add, h16]
    omega

/-! ### The Reyes strategies -/

/-- The Reyes strategy on `3 * (j + 1)` hats: the Carter strategy on three
hats, double-reset by itself `j` times. -/
def reyes : ℕ → ℕ → ℤ
  | 0 => carterOdd 1
  | j + 1 => dr 3 (carterOdd 1) (reyes j)

theorem reyes_proper (j : ℕ) : Proper (3 * (j + 1)) (reyes j) := by
  induction j with
  | zero => exact carterOdd_proper 1
  | succ j ih =>
    have := dr_proper (carterOdd_proper 1) ih
    rwa [show 2 * 1 + 1 + 3 * (j + 1) = 3 * (j + 1 + 1) by ring] at this

/-- The hits of the Reyes strategies: the win rate on `3 * (j + 1)` hats
is `7 / 20 - 1 / (10 * 16 ^ (j + 1))`, that of the Carter strategy on
`2 * (j + 1) + 1` hats. -/
theorem hits_reyes (j : ℕ) :
    20 * hits (3 * (j + 1)) (reyes j) + 2 * 4 ^ (j + 1) = 7 * 64 ^ (j + 1) := by
  have h3 : hits 3 (carterOdd 1) = 22 := by
    have := hits_carterOdd 1; norm_num at this; omega
  induction j with
  | zero => simp [reyes, h3]
  | succ j ih =>
    have := hits_dr (m := 3) (carterOdd_proper 1) (reyes_proper j)
    have e : (4 : ℕ) ^ (3 * (j + 1)) = 64 ^ (j + 1) := by rw [pow_mul]; norm_num
    rw [h3, e, show 3 + 3 * (j + 1) = 3 * (j + 1 + 1) by ring] at this
    rw [reyes, pow_succ 4 (j + 1), pow_succ 64 (j + 1)]
    omega

/-! ### A strategy played on a taller stack -/

/-- A strategy on `n` hats, played on a taller stack by looking at the `n`
lowest hats only. -/
def emb (n : ℕ) (s : ℕ → ℤ) : ℕ → ℤ := fun t => s (t % 2 ^ n)

/-- A proper strategy keeps its win rate on a taller stack. -/
theorem hits_emb {n : ℕ} (k : ℕ) {s : ℕ → ℤ} (hs : Proper n s) :
    hits (n + k) (emb n s) = 4 ^ k * hits n s := by
  have hpos : 0 < 2 ^ n := Nat.two_pow_pos n
  rw [hits_split]
  unfold hits
  rw [mul_sum]
  refine sum_congr rfl fun t0 ht0 => ?_
  rw [mul_sum]
  refine sum_congr rfl fun u0 hu0 => ?_
  rw [← sum_above_const]
  refine sum_congr rfl fun t1 _ => sum_congr rfl fun u1 _ => ?_
  have ht := mem_range.mp ht0
  have hu := mem_range.mp hu0
  exact pair_low_low hs ht hu (by simp [emb, Nat.mod_eq_of_lt ht])
    (by simp [emb, Nat.mod_eq_of_lt hu])

end Hats
