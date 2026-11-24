-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

import Hats.SearchFast
import HatsSearch.Program

/-!
# The fast search program is correct

`HatsSearch.search n depth` (file `HatsSearch/Program.lean`) is the
program that is compiled to the executable `hats-search`.  It keeps its
counts in machine words.  This file proves that, for `n` from 2 to 4, it
returns `best n`: the most hits of any strategy on `n` hats.

The proof follows the program.  The words are read as four counts each
(`pack`); the counts are those of the choices made so far (`cntQ`); with
them, what the program adds at each choice is what the plain search
`Hats.go` adds (`Hats.incr`).
-/

namespace Hats

open HatsSearch

/-! ### Counts, and words that hold four of them -/

/-- Among the stacks seen so far, those that chose `q` and are black at
`p`.  The list holds the choices, the latest first; `m` is their number. -/
def cntQ (q p : ℕ) : ℕ → List ℕ → ℕ
  | m + 1, x :: rest => (if x = q ∧ m.testBit p = true then 1 else 0) + cntQ q p m rest
  | _, _ => 0

theorem cntQ_le (q p : ℕ) : ∀ (m : ℕ) (prev : List ℕ), cntQ q p m prev ≤ m
  | 0, _ => by simp [cntQ]
  | m + 1, [] => by simp [cntQ]
  | m + 1, x :: rest => by
    have := cntQ_le q p m rest
    simp only [cntQ]
    split_ifs <;> omega

/-- The plain search counts, for a stack `t'` and a choice `p`, the earlier
stacks that pointed at a black hat of `t'` and are black at `p`: the sum,
over the black positions `q` of `t'`, of the counts above. -/
theorem cnt_eq_sum_cntQ (t' p : ℕ) : ∀ (m : ℕ) (prev : List ℕ), (∀ x ∈ prev, x < 4) →
    cnt t' p m prev
      = (if t'.testBit 0 = true then cntQ 0 p m prev else 0)
        + (if t'.testBit 1 = true then cntQ 1 p m prev else 0)
        + (if t'.testBit 2 = true then cntQ 2 p m prev else 0)
        + (if t'.testBit 3 = true then cntQ 3 p m prev else 0)
  | 0, _, _ => by simp [cnt, cntQ]
  | m + 1, [], _ => by simp [cnt, cntQ]
  | m + 1, x :: rest, h => by
    have hx : x < 4 := h x List.mem_cons_self
    have ih := cnt_eq_sum_cntQ t' p m rest fun y hy => h y (List.mem_cons_of_mem _ hy)
    simp only [cnt, cntQ, ih]
    interval_cases x <;> by_cases hm : m.testBit p = true <;>
      by_cases h0 : t'.testBit 0 = true <;> by_cases h1 : t'.testBit 1 = true <;>
      by_cases h2 : t'.testBit 2 = true <;> by_cases h3 : t'.testBit 3 = true <;>
      simp [hm, h0, h1, h2, h3] <;> omega

/-- A word that holds four counts, in fields of 8 bits. -/
def pack (f : ℕ → ℕ) : ℕ := f 0 + 256 * f 1 + 65536 * f 2 + 16777216 * f 3

/-! ### The operations of the program, on numbers -/

theorem toNat_eq_ofNat {t : UInt64} {k : ℕ} (h : t.toNat = k) : t = UInt64.ofNat k := by
  rw [← h, UInt64.ofNat_toNat]

/-- `bit t q` is the color of the hat at position `q` of stack `t`. -/
theorem bit_ofNat : ∀ k < 16, ∀ q < 4,
    (bit (UInt64.ofNat k) (UInt64.ofNat q)).toNat = if k.testBit q = true then 1 else 0 := by
  decide

/-- `spread t` has a one in the field of each black position of `t`. -/
theorem spread_ofNat : ∀ k < 16,
    (spread (UInt64.ofNat k)).toNat = pack fun p => if k.testBit p = true then 1 else 0 := by
  decide

theorem bit_toNat {t : UInt64} {k : ℕ} (ht : t.toNat = k) (hk : k < 16) {q : ℕ} (hq : q < 4) :
    (bit t (UInt64.ofNat q)).toNat = if k.testBit q = true then 1 else 0 := by
  rw [toNat_eq_ofNat ht]; exact bit_ofNat k hk q hq

theorem spread_toNat {t : UInt64} {k : ℕ} (ht : t.toNat = k) (hk : k < 16) :
    (spread t).toNat = pack fun p => if k.testBit p = true then 1 else 0 := by
  rw [toNat_eq_ofNat ht]; exact spread_ofNat k hk

/-- A field of a word that holds four counts below 256. -/
theorem field_pack {f : ℕ → ℕ} (hf : ∀ p < 4, f p < 256) {v : UInt64} (hv : v.toNat = pack f) :
    ((v >>> (8 * 0 : UInt64)) &&& 0xFF).toNat = f 0
    ∧ ((v >>> (8 * 1 : UInt64)) &&& 0xFF).toNat = f 1
    ∧ ((v >>> (8 * 2 : UInt64)) &&& 0xFF).toNat = f 2
    ∧ ((v >>> (8 * 3 : UInt64)) &&& 0xFF).toNat = f 3 := by
  have h0 := hf 0 (by norm_num)
  have h1 := hf 1 (by norm_num)
  have h2 := hf 2 (by norm_num)
  have h3 := hf 3 (by norm_num)
  have e : (0xFF : UInt64).toNat = 2 ^ 8 - 1 := by decide
  have s0 : ((8 * 0 : UInt64)).toNat % 64 = 0 := by decide
  have s1 : ((8 * 1 : UInt64)).toNat % 64 = 8 := by decide
  have s2 : ((8 * 2 : UInt64)).toNat % 64 = 16 := by decide
  have s3 : ((8 * 3 : UInt64)).toNat % 64 = 24 := by decide
  simp only [UInt64.toNat_and, UInt64.toNat_shiftRight, e, Nat.and_two_pow_sub_one_eq_mod,
    Nat.shiftRight_eq_div_pow, s0, s1, s2, s3, hv, pack]
  refine ⟨?_, ?_, ?_, ?_⟩ <;> omega

/-! ### The words of the program hold the counts -/

theorem cnt_le (t' p : ℕ) : ∀ (m : ℕ) (prev : List ℕ), cnt t' p m prev ≤ m
  | 0, _ => by simp [cnt]
  | m + 1, [] => by simp [cnt]
  | m + 1, x :: rest => by
    have := cnt_le t' p m rest
    simp only [cnt]
    split_ifs <;> omega

theorem pack_add (f g : ℕ → ℕ) : pack f + pack g = pack fun p => f p + g p := by
  simp only [pack]; ring

theorem pack_congr {f g : ℕ → ℕ} (h : ∀ p < 4, f p = g p) : pack f = pack g := by
  simp only [pack, h 0 (by norm_num), h 1 (by norm_num), h 2 (by norm_num), h 3 (by norm_num)]

theorem pack_lt {f : ℕ → ℕ} (h : ∀ p < 4, f p ≤ 255) : pack f < 2 ^ 32 := by
  have h0 := h 0 (by norm_num); have h1 := h 1 (by norm_num)
  have h2 := h 2 (by norm_num); have h3 := h 3 (by norm_num)
  simp only [pack]; omega

theorem ite_pack (c : Prop) [Decidable c] (f : ℕ → ℕ) :
    (if c then pack f else 0) = pack fun p => if c then f p else 0 := by
  split_ifs <;> simp [pack]

/-- A word times the color of a hat. -/
theorem mul_bit_toNat {w b : UInt64} {c : Prop} [Decidable c]
    (hb : b.toNat = if c then 1 else 0) : (w * b).toNat = if c then w.toNat else 0 := by
  rw [UInt64.toNat_mul, hb]
  split_ifs
  · rw [mul_one]; exact Nat.mod_eq_of_lt w.toNat_lt
  · simp

theorem add_toNat {a b : UInt64} (h : a.toNat + b.toNat < 2 ^ 64) :
    (a + b).toNat = a.toNat + b.toNat := by
  rw [UInt64.toNat_add, Nat.mod_eq_of_lt h]

/-- The state of the program after the stacks below `tN`: their choices are
in `prev`, and the four words hold the counts. -/
structure Inv (n tN : ℕ) (prev : List ℕ) (w0 w1 w2 w3 : UInt64) : Prop where
  len : prev.length = tN
  lt : ∀ x ∈ prev, x < n
  h0 : w0.toNat = pack fun p => cntQ 0 p tN prev
  h1 : w1.toNat = pack fun p => cntQ 1 p tN prev
  h2 : w2.toNat = pack fun p => cntQ 2 p tN prev
  h3 : w3.toNat = pack fun p => cntQ 3 p tN prev

section step

variable {n tN : ℕ} {prev : List ℕ} {t w0 w1 w2 w3 : UInt64}

theorem Inv.word_lt (htN : tN < 16) (I : Inv n tN prev w0 w1 w2 w3) :
    w0.toNat < 2 ^ 32 ∧ w1.toNat < 2 ^ 32 ∧ w2.toNat < 2 ^ 32 ∧ w3.toNat < 2 ^ 32 := by
  have c : ∀ q, ∀ p < 4, cntQ q p tN prev ≤ 255 := fun q p _ =>
    (cntQ_le q p tN prev).trans (by omega)
  exact ⟨I.h0 ▸ pack_lt (c 0), I.h1 ▸ pack_lt (c 1), I.h2 ▸ pack_lt (c 2), I.h3 ▸ pack_lt (c 3)⟩

/-- `seen` holds, for each position `p`, the count that the plain search
computes. -/
theorem seen_toNat (hn : n ≤ 4) (ht : t.toNat = tN) (htN : tN < 16)
    (I : Inv n tN prev w0 w1 w2 w3) :
    (seen t w0 w1 w2 w3).toNat = pack fun p => cnt tN p tN prev := by
  have hlt : ∀ x ∈ prev, x < 4 := fun x hx => lt_of_lt_of_le (I.lt x hx) hn
  obtain ⟨l0, l1, l2, l3⟩ := I.word_lt htN
  have m0 := mul_bit_toNat (w := w0) (bit_toNat ht htN (q := 0) (by norm_num))
  have m1 := mul_bit_toNat (w := w1) (bit_toNat ht htN (q := 1) (by norm_num))
  have m2 := mul_bit_toNat (w := w2) (bit_toNat ht htN (q := 2) (by norm_num))
  have m3 := mul_bit_toNat (w := w3) (bit_toNat ht htN (q := 3) (by norm_num))
  have b0 : (w0 * bit t 0).toNat < 2 ^ 32 := by
    rw [show (w0 * bit t 0).toNat = _ from m0]; split_ifs <;> omega
  have b1 : (w1 * bit t 1).toNat < 2 ^ 32 := by
    rw [show (w1 * bit t 1).toNat = _ from m1]; split_ifs <;> omega
  have b2 : (w2 * bit t 2).toNat < 2 ^ 32 := by
    rw [show (w2 * bit t 2).toNat = _ from m2]; split_ifs <;> omega
  have b3 : (w3 * bit t 3).toNat < 2 ^ 32 := by
    rw [show (w3 * bit t 3).toNat = _ from m3]; split_ifs <;> omega
  have a1 : (w0 * bit t 0 + w1 * bit t 1).toNat
      = (w0 * bit t 0).toNat + (w1 * bit t 1).toNat := add_toNat (by omega)
  have a2 : (w0 * bit t 0 + w1 * bit t 1 + w2 * bit t 2).toNat
      = (w0 * bit t 0).toNat + (w1 * bit t 1).toNat + (w2 * bit t 2).toNat := by
    rw [add_toNat (by omega), a1]
  have a3 : (seen t w0 w1 w2 w3).toNat
      = (w0 * bit t 0).toNat + (w1 * bit t 1).toNat + (w2 * bit t 2).toNat
        + (w3 * bit t 3).toNat := by
    unfold seen; rw [add_toNat (by omega), a2]
  rw [a3, show (w0 * bit t 0).toNat = _ from m0, show (w1 * bit t 1).toNat = _ from m1,
    show (w2 * bit t 2).toNat = _ from m2, show (w3 * bit t 3).toNat = _ from m3,
    I.h0, I.h1, I.h2, I.h3, ite_pack, ite_pack, ite_pack, ite_pack, pack_add, pack_add, pack_add]
  exact pack_congr fun p _ => (cnt_eq_sum_cntQ tN p tN prev hlt).symm

/-- What the program adds for a choice is what the plain search adds. -/
theorem gain_toNat (hn : n ≤ 4) (ht : t.toNat = tN) (htN : tN < 16)
    (I : Inv n tN prev w0 w1 w2 w3) :
    (gain t (seen t w0 w1 w2 w3) 0).toNat = incr tN 0 prev
    ∧ (gain t (seen t w0 w1 w2 w3) 1).toNat = incr tN 1 prev
    ∧ (gain t (seen t w0 w1 w2 w3) 2).toNat = incr tN 2 prev
    ∧ (gain t (seen t w0 w1 w2 w3) 3).toNat = incr tN 3 prev := by
  have hv := seen_toNat hn ht htN I
  have hf : ∀ p < 4, cnt tN p tN prev < 256 := fun p _ =>
    lt_of_le_of_lt (cnt_le tN p tN prev) (by omega)
  obtain ⟨f0, f1, f2, f3⟩ := field_pack hf hv
  have e2 : (2 : UInt64).toNat = 2 := by decide
  have key : ∀ (x b : UInt64) (p : ℕ), x.toNat = cnt tN p tN prev →
      (b.toNat = if tN.testBit p = true then 1 else 0) →
      (2 * x + b).toNat = incr tN p prev := by
    intro x b p hx hb
    have c := cnt_le tN p tN prev
    have hm : (2 * x).toNat = 2 * cnt tN p tN prev := by
      rw [UInt64.toNat_mul, e2, hx]; exact Nat.mod_eq_of_lt (by omega)
    have hb1 : b.toNat ≤ 1 := by rw [hb]; split_ifs <;> omega
    rw [add_toNat (by omega), hm, hb]
    rfl
  exact ⟨key _ _ 0 f0 (bit_toNat ht htN (q := 0) (by norm_num)),
    key _ _ 1 f1 (bit_toNat ht htN (q := 1) (by norm_num)),
    key _ _ 2 f2 (bit_toNat ht htN (q := 2) (by norm_num)),
    key _ _ 3 f3 (bit_toNat ht htN (q := 3) (by norm_num))⟩

theorem incr_le (t p : ℕ) (prev : List ℕ) : incr t p prev ≤ 2 * t + 1 := by
  have := cnt_le t p t prev
  unfold incr
  split_ifs <;> omega

/-- After one more choice, the words still hold the counts. -/
theorem Inv.step (ht : t.toNat = tN) (htN : tN < 16) (I : Inv n tN prev w0 w1 w2 w3) :
    (0 < n → Inv n (tN + 1) (0 :: prev) (w0 + spread t) w1 w2 w3)
    ∧ (1 < n → Inv n (tN + 1) (1 :: prev) w0 (w1 + spread t) w2 w3)
    ∧ (2 < n → Inv n (tN + 1) (2 :: prev) w0 w1 (w2 + spread t) w3)
    ∧ (3 < n → Inv n (tN + 1) (3 :: prev) w0 w1 w2 (w3 + spread t)) := by
  have hs := spread_toNat ht htN
  obtain ⟨l0, l1, l2, l3⟩ := I.word_lt htN
  have ls : (spread t).toNat < 2 ^ 32 := by
    rw [hs]; exact pack_lt fun p _ => by split_ifs <;> omega
  have keep : ∀ q x : ℕ, x ≠ q → ∀ p, cntQ q p (tN + 1) (x :: prev) = cntQ q p tN prev := by
    intro q x hx p; simp [cntQ, hx]
  have add : ∀ q p : ℕ, cntQ q p tN prev + (if tN.testBit p = true then 1 else 0)
      = cntQ q p (tN + 1) (q :: prev) := by
    intro q p; simp [cntQ, add_comm]
  have mem : ∀ x : ℕ, x < n → ∀ y ∈ x :: prev, y < n := by
    intro x hx y hy
    rcases List.mem_cons.mp hy with rfl | hy
    · exact hx
    · exact I.lt y hy
  have upd : ∀ (q : ℕ) (w : UInt64), w.toNat < 2 ^ 32 →
      (w.toNat = pack fun p => cntQ q p tN prev) →
      (w + spread t).toNat = pack fun p => cntQ q p (tN + 1) (q :: prev) := by
    intro q w hw h
    rw [add_toNat (by omega), h, hs, pack_add]
    exact pack_congr fun p _ => add q p
  have same : ∀ (q x : ℕ) (w : UInt64), x ≠ q → (w.toNat = pack fun p => cntQ q p tN prev) →
      w.toNat = pack fun p => cntQ q p (tN + 1) (x :: prev) := by
    intro q x w hx h
    rw [h]; exact pack_congr fun p _ => (keep q x hx p).symm
  have len : ∀ x : ℕ, (x :: prev).length = tN + 1 := fun x => by simp [I.len]
  exact ⟨fun h => ⟨len 0, mem 0 h, upd 0 w0 l0 I.h0, same 1 0 w1 (by norm_num) I.h1,
      same 2 0 w2 (by norm_num) I.h2, same 3 0 w3 (by norm_num) I.h3⟩,
    fun h => ⟨len 1, mem 1 h, same 0 1 w0 (by norm_num) I.h0, upd 1 w1 l1 I.h1,
      same 2 1 w2 (by norm_num) I.h2, same 3 1 w3 (by norm_num) I.h3⟩,
    fun h => ⟨len 2, mem 2 h, same 0 2 w0 (by norm_num) I.h0, same 1 2 w1 (by norm_num) I.h1,
      upd 2 w2 l2 I.h2, same 3 2 w3 (by norm_num) I.h3⟩,
    fun h => ⟨len 3, mem 3 h, same 0 3 w0 (by norm_num) I.h0, same 1 3 w1 (by norm_num) I.h1,
      same 2 3 w2 (by norm_num) I.h2, upd 3 w3 l3 I.h3⟩⟩

end step

/-! ### The program follows the plain search -/

/-- The most of at most four numbers, written out. -/
theorem foldr_max_range {m : ℕ} (hm : m ≤ 3) (f : ℕ → ℕ) :
    ((List.range (m + 1)).map f).foldr max 0
      = max (f 0) (max (if 1 ≤ m then f 1 else 0)
          (max (if 2 ≤ m then f 2 else 0) (if 3 ≤ m then f 3 else 0))) := by
  interval_cases m <;> simp [List.range_succ]

/-- When every earlier stack pointed at a black hat of `t'`, those that are
black at the bottom are half of them. -/
theorem cnt_all (t' : ℕ) : ∀ (m : ℕ) (prev : List ℕ), prev.length = m →
    (∀ x ∈ prev, t'.testBit x = true) → cnt t' 0 m prev = m / 2
  | 0, _, _, _ => by simp [cnt]
  | m + 1, [], h, _ => by simp at h
  | m + 1, x :: rest, h, hb => by
    have ih := cnt_all t' m rest (by simpa using h) fun y hy => hb y (List.mem_cons_of_mem _ hy)
    have hx := hb x List.mem_cons_self
    simp only [cnt, ih, hx, Nat.testBit_zero, true_and, decide_eq_true_eq]
    split_ifs <;> omega

/-- What the all-black stack adds, whatever the choices before it. -/
theorem incr_final {n : ℕ} (hn : 1 ≤ n) {prev : List ℕ} (hlen : prev.length = 2 ^ n - 1)
    (hlt : ∀ x ∈ prev, x < n) : incr (2 ^ n - 1) 0 prev = 2 ^ n - 1 := by
  have hc := cnt_all (2 ^ n - 1) (2 ^ n - 1) prev hlen fun x hx => by
    simp [Nat.testBit_two_pow_sub_one, hlt x hx]
  have hodd : (2 ^ n - 1) % 2 = 1 := by
    obtain ⟨j, rfl⟩ : ∃ j, n = j + 1 := ⟨n - 1, by omega⟩
    have := Nat.two_pow_pos j
    rw [pow_succ]; omega
  unfold incr
  rw [hc]
  simp only [Nat.testBit_zero, hodd, decide_true, ↓reduceIte]
  omega

section main

variable {n : ℕ} {top fin : UInt64}

theorem guard_eq (htop : top.toNat = n - 1) {t : UInt64} {tN : ℕ} (ht : t.toNat = tN) :
    (decide (top ≥ 1) && decide (t ≥ 1)) = decide (1 ≤ min tN (n - 1))
    ∧ (decide (top ≥ 2) && decide (t ≥ 2)) = decide (2 ≤ min tN (n - 1))
    ∧ (decide (top ≥ 3) && decide (t ≥ 3)) = decide (3 ≤ min tN (n - 1)) := by
  have e1 : (1 : UInt64).toNat = 1 := by decide
  have e2 : (2 : UInt64).toNat = 2 := by decide
  have e3 : (3 : UInt64).toNat = 3 := by decide
  refine ⟨?_, ?_, ?_⟩ <;>
    simp only [ge_iff_le, UInt64.le_iff_toNat_le, htop, ht, e1, e2, e3, ← Bool.decide_and,
      decide_eq_decide] <;> omega

/-- **The program computes what the plain search computes**, from any
state that the two share. -/
theorem go_toNat (hn2 : 2 ≤ n) (hn4 : n ≤ 4) (htop : top.toNat = n - 1)
    (hfin : fin.toNat = 2 ^ n - 1) :
    ∀ (k tN : ℕ) (prev : List ℕ) (accN : ℕ) (t acc w0 w1 w2 w3 res : UInt64),
      tN + k + 2 = 2 ^ n → t.toNat = tN → acc.toNat = accN → accN ≤ 31 * tN →
      Inv n tN prev w0 w1 w2 w3 →
      (HatsSearch.go top fin k t acc w0 w1 w2 w3 res).toNat
        = max res.toNat (Hats.go n (k + 1) tN prev accN) := by
  have hpow : 2 ^ n ≤ 16 := by
    have : 2 ^ n ≤ 2 ^ 4 := Nat.pow_le_pow_right (by norm_num) hn4
    simpa using this
  intro k
  induction k with
  | zero =>
    intro tN prev accN t acc w0 w1 w2 w3 res hk ht hacc hbound I
    have htN : tN < 16 := by omega
    obtain ⟨g0, g1, g2, g3⟩ := gain_toNat hn4 ht htN I
    obtain ⟨G1, G2, G3⟩ := guard_eq htop ht
    have sc : ∀ (g : UInt64) (p : ℕ), g.toNat = incr tN p prev →
        (acc + g + fin).toNat = accN + incr tN p prev + (2 ^ n - 1) := by
      intro g p hg
      have := incr_le tN p prev
      have h1 : (acc + g).toNat = accN + incr tN p prev := by
        rw [add_toNat (by omega), hacc, hg]
      rw [add_toNat (by omega), h1, hfin]
    have spec : Hats.go n (0 + 1) tN prev accN
        = ((List.range (min tN (n - 1) + 1)).map fun p =>
            accN + incr tN p prev + (2 ^ n - 1)).foldr max 0 := by
      simp only [Hats.go, choices]
      congr 1
      refine List.map_congr_left fun p hp => ?_
      have hp' : p ≤ min tN (n - 1) := Nat.lt_succ_iff.mp (List.mem_range.mp hp)
      have hfinal := incr_final (n := n) (by omega) (prev := p :: prev)
        (by simp [I.len]; omega) (fun x hx => by
          rcases List.mem_cons.mp hx with rfl | hx
          · omega
          · exact I.lt x hx)
      rw [show tN + 1 = 2 ^ n - 1 by omega, hfinal]
    rw [spec, foldr_max_range (by omega)]
    simp only [HatsSearch.go, G1, G2, G3, decide_eq_true_eq]
    obtain ⟨m, hm⟩ : ∃ m, m = min tN (n - 1) := ⟨_, rfl⟩
    rw [← hm]
    have hm3 : m ≤ 3 := by omega
    interval_cases m <;>
      simp [UInt64.toNat_max, sc _ 0 g0, sc _ 1 g1, sc _ 2 g2, sc _ 3 g3]
  | succ k ih =>
    intro tN prev accN t acc w0 w1 w2 w3 res hk ht hacc hbound I
    have htN : tN < 16 := by omega
    obtain ⟨g0, g1, g2, g3⟩ := gain_toNat hn4 ht htN I
    obtain ⟨G1, G2, G3⟩ := guard_eq htop ht
    obtain ⟨S0, S1, S2, S3⟩ := I.step ht htN
    have e1 : (1 : UInt64).toNat = 1 := by decide
    have ht1 : (t + 1).toNat = tN + 1 := by rw [add_toNat (by omega), ht, e1]
    have ac : ∀ (g : UInt64) (p : ℕ), g.toNat = incr tN p prev →
        (acc + g).toNat = accN + incr tN p prev ∧ accN + incr tN p prev ≤ 31 * (tN + 1) := by
      intro g p hg
      have := incr_le tN p prev
      exact ⟨by rw [add_toNat (by omega), hacc, hg], by omega⟩
    have E0 : ∀ r : UInt64, (HatsSearch.go top fin k (t + 1)
        (acc + gain t (seen t w0 w1 w2 w3) 0) (w0 + spread t) w1 w2 w3 r).toNat
          = max r.toNat (Hats.go n (k + 1) (tN + 1) (0 :: prev) (accN + incr tN 0 prev)) :=
      fun r => ih _ _ _ _ _ _ _ _ _ r (by omega) ht1 (ac _ 0 g0).1 (ac _ 0 g0).2 (S0 (by omega))
    have E1 : 1 ≤ min tN (n - 1) → ∀ r : UInt64, (HatsSearch.go top fin k (t + 1)
        (acc + gain t (seen t w0 w1 w2 w3) 1) w0 (w1 + spread t) w2 w3 r).toNat
          = max r.toNat (Hats.go n (k + 1) (tN + 1) (1 :: prev) (accN + incr tN 1 prev)) :=
      fun h r => ih _ _ _ _ _ _ _ _ _ r (by omega) ht1 (ac _ 1 g1).1 (ac _ 1 g1).2 (S1 (by omega))
    have E2 : 2 ≤ min tN (n - 1) → ∀ r : UInt64, (HatsSearch.go top fin k (t + 1)
        (acc + gain t (seen t w0 w1 w2 w3) 2) w0 w1 (w2 + spread t) w3 r).toNat
          = max r.toNat (Hats.go n (k + 1) (tN + 1) (2 :: prev) (accN + incr tN 2 prev)) :=
      fun h r => ih _ _ _ _ _ _ _ _ _ r (by omega) ht1 (ac _ 2 g2).1 (ac _ 2 g2).2 (S2 (by omega))
    have E3 : 3 ≤ min tN (n - 1) → ∀ r : UInt64, (HatsSearch.go top fin k (t + 1)
        (acc + gain t (seen t w0 w1 w2 w3) 3) w0 w1 w2 (w3 + spread t) r).toNat
          = max r.toNat (Hats.go n (k + 1) (tN + 1) (3 :: prev) (accN + incr tN 3 prev)) :=
      fun h r => ih _ _ _ _ _ _ _ _ _ r (by omega) ht1 (ac _ 3 g3).1 (ac _ 3 g3).2 (S3 (by omega))
    have spec : Hats.go n (k + 1 + 1) tN prev accN
        = ((List.range (min tN (n - 1) + 1)).map fun p =>
            Hats.go n (k + 1) (tN + 1) (p :: prev) (accN + incr tN p prev)).foldr max 0 := by
      rw [Hats.go, choices]
    rw [spec, foldr_max_range (by omega)]
    simp only [HatsSearch.go, G1, G2, G3, decide_eq_true_eq]
    obtain ⟨m, hm⟩ : ∃ m, m = min tN (n - 1) := ⟨_, rfl⟩
    rw [← hm] at E1 E2 E3 ⊢
    have hm3 : m ≤ 3 := by omega
    interval_cases m
    · simp [E0]
    · simp [E0, E1 (by norm_num)]
    · simp [E0, E1 (by norm_num), E2 (by norm_num)]
    · simp [E0, E1 (by norm_num), E2 (by norm_num), E3 (by norm_num)]

/-- The search cut into tasks computes the same number. -/
theorem split_toNat (hn2 : 2 ≤ n) (hn4 : n ≤ 4) (htop : top.toNat = n - 1)
    (hfin : fin.toNat = 2 ^ n - 1) :
    ∀ (d k tN : ℕ) (prev : List ℕ) (accN : ℕ) (t acc w0 w1 w2 w3 r0 : UInt64),
      tN + k + 2 = 2 ^ n → t.toNat = tN → acc.toNat = accN → accN ≤ 31 * tN →
      Inv n tN prev w0 w1 w2 w3 →
      ((HatsSearch.split top fin d k t acc w0 w1 w2 w3).foldl
          (fun r task => max r task.get) r0).toNat
        = max r0.toNat (Hats.go n (k + 1) tN prev accN) := by
  have hpow : 2 ^ n ≤ 16 := by
    have : 2 ^ n ≤ 2 ^ 4 := Nat.pow_le_pow_right (by norm_num) hn4
    simpa using this
  have one : ∀ (k tN : ℕ) (prev : List ℕ) (accN : ℕ) (t acc w0 w1 w2 w3 r0 : UInt64),
      tN + k + 2 = 2 ^ n → t.toNat = tN → acc.toNat = accN → accN ≤ 31 * tN →
      Inv n tN prev w0 w1 w2 w3 →
      (([Task.spawn fun _ => HatsSearch.go top fin k t acc w0 w1 w2 w3 0] : List (Task UInt64)).foldl
          (fun r task => max r task.get) r0).toNat
        = max r0.toNat (Hats.go n (k + 1) tN prev accN) := by
    intro k tN prev accN t acc w0 w1 w2 w3 r0 hk ht hacc hb I
    have h := go_toNat hn2 hn4 htop hfin k tN prev accN t acc w0 w1 w2 w3 0 hk ht hacc hb I
    have e0 : (0 : UInt64).toNat = 0 := by decide
    have hget : (Task.spawn fun _ => HatsSearch.go top fin k t acc w0 w1 w2 w3 0).get
        = HatsSearch.go top fin k t acc w0 w1 w2 w3 0 := rfl
    simp only [List.foldl_cons, List.foldl_nil, UInt64.toNat_max, hget, h, e0]
    omega
  intro d
  induction d with
  | zero =>
    intro k tN prev accN t acc w0 w1 w2 w3 r0 hk ht hacc hb I
    cases k <;> exact one _ tN prev accN t acc w0 w1 w2 w3 r0 hk ht hacc hb I
  | succ d ih =>
    intro k tN prev accN t acc w0 w1 w2 w3 r0 hk ht hacc hbound I
    rcases k with _ | k
    · exact one 0 tN prev accN t acc w0 w1 w2 w3 r0 hk ht hacc hbound I
    have htN : tN < 16 := by omega
    obtain ⟨g0, g1, g2, g3⟩ := gain_toNat hn4 ht htN I
    obtain ⟨G1, G2, G3⟩ := guard_eq htop ht
    obtain ⟨S0, S1, S2, S3⟩ := I.step ht htN
    have e1 : (1 : UInt64).toNat = 1 := by decide
    have ht1 : (t + 1).toNat = tN + 1 := by rw [add_toNat (by omega), ht, e1]
    have ac : ∀ (g : UInt64) (p : ℕ), g.toNat = incr tN p prev →
        (acc + g).toNat = accN + incr tN p prev ∧ accN + incr tN p prev ≤ 31 * (tN + 1) := by
      intro g p hg
      have := incr_le tN p prev
      exact ⟨by rw [add_toNat (by omega), hacc, hg], by omega⟩
    have E0 : ∀ r : UInt64, ((HatsSearch.split top fin d k (t + 1)
        (acc + gain t (seen t w0 w1 w2 w3) 0) (w0 + spread t) w1 w2 w3).foldl
          (fun r task => max r task.get) r).toNat
          = max r.toNat (Hats.go n (k + 1) (tN + 1) (0 :: prev) (accN + incr tN 0 prev)) :=
      fun r => ih _ _ _ _ _ _ _ _ _ _ r (by omega) ht1 (ac _ 0 g0).1 (ac _ 0 g0).2 (S0 (by omega))
    have E1 : 1 ≤ min tN (n - 1) → ∀ r : UInt64, ((HatsSearch.split top fin d k (t + 1)
        (acc + gain t (seen t w0 w1 w2 w3) 1) w0 (w1 + spread t) w2 w3).foldl
          (fun r task => max r task.get) r).toNat
          = max r.toNat (Hats.go n (k + 1) (tN + 1) (1 :: prev) (accN + incr tN 1 prev)) :=
      fun h r => ih _ _ _ _ _ _ _ _ _ _ r (by omega) ht1 (ac _ 1 g1).1 (ac _ 1 g1).2
        (S1 (by omega))
    have E2 : 2 ≤ min tN (n - 1) → ∀ r : UInt64, ((HatsSearch.split top fin d k (t + 1)
        (acc + gain t (seen t w0 w1 w2 w3) 2) w0 w1 (w2 + spread t) w3).foldl
          (fun r task => max r task.get) r).toNat
          = max r.toNat (Hats.go n (k + 1) (tN + 1) (2 :: prev) (accN + incr tN 2 prev)) :=
      fun h r => ih _ _ _ _ _ _ _ _ _ _ r (by omega) ht1 (ac _ 2 g2).1 (ac _ 2 g2).2
        (S2 (by omega))
    have E3 : 3 ≤ min tN (n - 1) → ∀ r : UInt64, ((HatsSearch.split top fin d k (t + 1)
        (acc + gain t (seen t w0 w1 w2 w3) 3) w0 w1 w2 (w3 + spread t)).foldl
          (fun r task => max r task.get) r).toNat
          = max r.toNat (Hats.go n (k + 1) (tN + 1) (3 :: prev) (accN + incr tN 3 prev)) :=
      fun h r => ih _ _ _ _ _ _ _ _ _ _ r (by omega) ht1 (ac _ 3 g3).1 (ac _ 3 g3).2
        (S3 (by omega))
    have spec : Hats.go n (k + 1 + 1) tN prev accN
        = ((List.range (min tN (n - 1) + 1)).map fun p =>
            Hats.go n (k + 1) (tN + 1) (p :: prev) (accN + incr tN p prev)).foldr max 0 := by
      rw [Hats.go, choices]
    rw [spec, foldr_max_range (by omega)]
    simp only [HatsSearch.split, G1, G2, G3, decide_eq_true_eq, List.foldl_append]
    obtain ⟨m, hm⟩ : ∃ m, m = min tN (n - 1) := ⟨_, rfl⟩
    rw [← hm] at E1 E2 E3 ⊢
    have hm3 : m ≤ 3 := by omega
    interval_cases m
    · simp [E0]
    · simp [E0, E1 (by norm_num)]
    · simp [E0, E1 (by norm_num), E2 (by norm_num)]
    · simp [E0, E1 (by norm_num), E2 (by norm_num), E3 (by norm_num)]

end main

/-- **The fast search program is correct**: for `n` from 2 to 4 it returns
`best n`, whatever the number of tasks. -/
theorem search_toNat {n : ℕ} (hn2 : 2 ≤ n) (hn4 : n ≤ 4) (depth : ℕ) :
    (HatsSearch.search n depth).toNat = best n := by
  have htop : (n.toUInt64 - 1).toNat = n - 1 := by interval_cases n <;> decide
  have hfin : ((1 <<< n.toUInt64) - 1 : UInt64).toNat = 2 ^ n - 1 := by
    interval_cases n <;> decide
  have hP : 4 ≤ 2 ^ n := by
    have : 2 ^ 2 ≤ 2 ^ n := Nat.pow_le_pow_right (by norm_num) hn2
    simpa using this
  have I : Inv n 1 [0] 0 0 0 0 := by
    have e0 : (0 : UInt64).toNat = 0 := by decide
    refine ⟨rfl, fun x hx => ?_, ?_, ?_, ?_, ?_⟩
    · have : x = 0 := by simpa using hx
      omega
    all_goals simp [e0, pack, cntQ]
  have h := split_toNat hn2 hn4 htop hfin depth (2 ^ n - 3) 1 [0] 0 1 0 0 0 0 0 0 (by omega)
    (by decide) (by decide) (by omega) I
  unfold HatsSearch.search
  rw [h, ← bestFast_eq_best (by omega), bestFast, show 2 ^ n - 3 + 1 = 2 ^ n - 2 by omega]
  simp

/-- What the program returns is the most hits of a strategy on `n` hats:
no strategy has more, and one has as many. -/
theorem search_spec {n : ℕ} (hn2 : 2 ≤ n) (hn4 : n ≤ 4) (depth : ℕ) :
    (∀ s : ℕ → ℤ, hits n s ≤ (HatsSearch.search n depth).toNat)
    ∧ ∃ s : ℕ → ℤ, hits n s = (HatsSearch.search n depth).toNat := by
  rw [search_toNat hn2 hn4]
  exact ⟨hits_le_best (by omega), exists_hits_eq_best n⟩

end Hats
