-- SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
--
-- SPDX-License-Identifier: MIT

/-!
# Jane's infinite rosary: the names (Section 1 of the paper)

A bead is a positive integer.  Lean's type `Nat` also contains `0`, which is
not a bead, so a statement about beads says `1 ≤ n` where it needs it.
-/

namespace Rosary

/-- The label of bead `n`, the length of Jane's step: `L(n) = ⌈n/2⌉`.
On `Nat`, `/` is the division that rounds down. -/
def label (n : Nat) : Nat := (n + 1) / 2

/-- Up: `nU = n + L(n)`. -/
def up (n : Nat) : Nat := n + label n

/-- Down: `nD = n - L(n)`. -/
def down (n : Nat) : Nat := n - label n

/-- Lambda: `nλ = ⌊2n/3⌋`, meant for a white bead `n`. -/
def lam (n : Nat) : Nat := 2 * n / 3

/-- Mu: `nμ = 2n`. -/
def mu (n : Nat) : Nat := 2 * n

/-- Nu: `nν = 2n + 1`. -/
def nu (n : Nat) : Nat := 2 * n + 1

/-- A black bead: `n ≡ 1 (mod 3)`. -/
def Black (n : Nat) : Prop := n % 3 = 1

/-- A white bead: any other bead. -/
def White (n : Nat) : Prop := n % 3 ≠ 1

/-- `upPow n i` is `nUⁱ`: bead `n`, then `i` moves up. -/
def upPow (n : Nat) : Nat → Nat
  | 0 => n
  | i + 1 => up (upPow n i)

/-- The tactic `rosary` replaces the names above by their definitions and
hands the goal to `omega`, Lean's decision procedure for linear arithmetic
on integers with division and remainder by constants. -/
macro "rosary" : tactic =>
  `(tactic| (simp only [label, up, down, lam, mu, nu, Black, White] at *; omega))

/-- An up move is `n ↦ ⌈3n/2⌉`. -/
theorem up_eq (n : Nat) : up n = (3 * n + 1) / 2 := by rosary

/-- A down move is `n ↦ ⌊n/2⌋`. -/
theorem down_eq (n : Nat) : down n = n / 2 := by rosary

end Rosary
