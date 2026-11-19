<!--
SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)

SPDX-License-Identifier: MIT
-->

# Jane's infinite rosary, checked by a proof assistant

This directory holds statements of the paper
[*Jane's infinite rosary*](../../content/posts/2022-12-02-jane-s-infinite-rosary/index.md)
written in the language of [Lean 4](https://lean-lang.org), with proofs
that Lean checks. The plan is in
[`docs/specs/0004-rosary-formal-verification.md`](../../docs/specs/0004-rosary-formal-verification.md).

This page is written for a reader who has never used a proof assistant.

## What is done

| In the paper | In Lean | File |
|---|---|---|
| The names of Section 1 | `label`, `up`, `down`, `lam`, `mu`, `nu`, `Black`, `White`, `upPow` | [`Rosary/Basic.lean`](Rosary/Basic.lean) |
| The examples of Section 1 (bead 8) | `example` lines | [`Rosary/Examples.lean`](Rosary/Examples.lean) |
| Fact 1, part 1 | `up_odd`, `up_even`, `up_injective`, `up_white`, `lam_up`, `up_lam`, `black_not_up` | [`Rosary/Fact1.lean`](Rosary/Fact1.lean) |
| Fact 1, part 2 | `down_eq_iff`, `mu_even`, `nu_odd`, `mu_down`, `nu_down` | [`Rosary/Fact1.lean`](Rosary/Fact1.lean) |
| Lemma 1 (commutation) | `lemma1` | [`Rosary/Lemma1.lean`](Rosary/Lemma1.lean) |
| Lemma 6 (parity) | `lemma6` | [`Rosary/Parity.lean`](Rosary/Parity.lean) |
| Lemma 7 (parity changes) | `lemma7_even`, `lemma7_odd`, `lemma7` | [`Rosary/Parity.lean`](Rosary/Parity.lean) |

## How to run the check

```sh
nix-build formal/jane-s-rosary 2>&1 | tee /tmp/rosary-formal-build.log
```

It takes about a minute. If it ends with a path in `/nix/store`, every
proof was accepted. It fails if a proof is wrong, if a proof is unfinished,
or if a theorem rests on an assumption that is not one of Lean's three
standard axioms.

To work on the files, with Lean answering as you type:

```sh
nix-shell -E '(import ./nix/nixpkgs.nix).mkShell { packages = [ (import ./nix/nixpkgs.nix).lean4 ]; }'
cd formal/jane-s-rosary
lake build
```

`lake` is Lean's build tool. An editor with the Lean extension (VS Code has
one) shows, at each line of a proof, what is known and what remains to be
proved; this is by far the best way to learn to read proofs. Small pieces
can also be tried without installing anything at
<https://live.lean-lang.org>.

## What a proof assistant does

A proof on paper is checked by readers, who fill the gaps ("direct
computation", "the same computation as above") from their own
understanding. A proof assistant accepts no gap. The statement and the
proof are written in a formal language; a small program, the *kernel*,
checks that every step follows from the rules of logic and from what was
proved before. If the kernel accepts, the statement is a theorem.

What this buys: no slip in a computation, no forgotten case, no induction
that quietly uses more than its hypothesis.

What it does not buy: Lean checks that the proof proves *the statement as
written in Lean*. Whether that statement says what the paper says is for a
human to judge. So the part to read with care is short:

1. **the definitions** (all in `Basic.lean`, about 40 lines), and
2. **the statements** of the theorems (the text between `theorem` and
   `:= by`).

The proofs (the text after `:= by`) need not be read at all. That is the
point of the exercise.

What must be trusted besides: the kernel of Lean, and its three standard
axioms (`propext`, `Classical.choice`, `Quot.sound`), on which practically
all formalized mathematics rests. `Rosary/Audit.lean` asks Lean to list the
axioms behind each theorem, and the build checks the list.

## How to read a statement

Here is Lemma 6 of the paper:

> For every bead $n$: $nUD$ is black if and only if $n$ and $nU$ have
> different parities.

and here it is in Lean:

```lean
theorem lemma6 (n : Nat) : Black (down (up n)) ↔ n % 2 ≠ up n % 2 := by rosary
```

Piece by piece:

- `theorem lemma6`: a theorem, named `lemma6`.
- `(n : Nat)`: for every natural number `n`. What comes before the colon
  `:` are the things the theorem is about and its hypotheses.
- `Black (down (up n))`: the paper writes moves after the bead, $nUD$; Lean
  writes functions before their argument, so $nUD$ is `down (up n)`. Read
  it from the inside out.
- `↔`: if and only if.
- `n % 2 ≠ up n % 2`: `%` is the remainder of the division, so `n % 2` is
  the parity of `n`.
- `:= by rosary`: the proof. `rosary` is a tactic defined in `Basic.lean`.

A statement with hypotheses, from Fact 1:

```lean
theorem lam_up (n : Nat) (hn : 1 ≤ n) (hw : White n) :
    1 ≤ lam n ∧ up (lam n) = n := by rosary
```

"For every `n`, if `1 ≤ n` (call this hypothesis `hn`) and if `n` is white
(call it `hw`), then `lam n` is a bead and going up from it leads to `n`."

The signs:

| Sign | Meaning | Sign | Meaning |
|---|---|---|---|
| `∀ x,` | for every `x` | `∃ x,` | there is an `x` such that |
| `∧` | and | `∨` | or |
| `→` | implies | `↔` | if and only if |
| `¬` | not | `≠` | is different from |
| `a / b` | the quotient, rounded down | `a % b` | the remainder |
| `a ∣ b` | `a` divides `b` | `2 ^ r` | $2^r$ |

## How the Lean text differs from the paper

- **Bead 0.** A bead is a positive integer, but Lean's `Nat` starts at 0.
  A statement that needs `n` to be a bead says `1 ≤ n`. Several statements
  happen to be true for 0 as well and do not say it; they are then slightly
  stronger than the paper's.
- **Ceilings.** The paper writes $L(n) = \lceil n/2 \rceil$. On `Nat` the
  division rounds down, so the definition reads `(n + 1) / 2`. The theorems
  `up_eq` and `down_eq` confirm $nU = \lceil 3n/2 \rceil$ and
  $nD = \lfloor n/2 \rfloor$, and `Examples.lean` computes the paper's
  examples.
- **"Call it $\hat{w}$".** Lemma 1 names a bead in the middle of its
  statement. In Lean this becomes "there are `ŵ` and `b` such that ...".
- **"Infinitely often".** Lemma 7 says that the parity changes infinitely
  often along an up-chain. In Lean: after any step `i` there is a later
  step `j` where it changes.
- **Up-chains.** $nU^i$ is `upPow n i`.

## What the proofs look like

Fact 1, Lemma 1 and Lemma 6 are proved by one tactic, `rosary`, which
replaces the names by their definitions and calls `omega`. `omega` is a
decision procedure: an algorithm that settles any statement made of
integers, `+`, `≤`, `=`, and division or remainder by fixed numbers. It
does not try values of `n`. It produces a proof for all `n` at once, and
the kernel checks that proof. This is what the paper calls "direct
computation": the six diagrams of Lemma 1 are left to the machine.

Lemma 7 needs induction, which `omega` cannot do, so its proofs are written
step by step. The words that come back:

| Tactic | What it does |
|---|---|
| `induction r with` | proof by induction on `r`: one case for 0, one for `r + 1` with the hypothesis `ih` |
| `intro h` | to prove "if A then B": assume A, call it `h` |
| `constructor` | to prove "A if and only if B": prove each direction |
| `obtain ⟨k, hk⟩ := h` | from "there is a `k` such that ...", get such a `k` |
| `rw [e]` | rewrite the goal using the equation `e` |
| `exact e` | here is the proof: `e` |
| `by_cases h : P` | two cases: `P` holds, or it does not |
| `have h : P := ...` | an intermediate step |
| `omega` | finish by arithmetic |

## An experiment worth doing

Break something and watch the check fail. For instance, in
`Rosary/Parity.lean`, change `≠` to `=` in the statement of `lemma6` (it
then says "the same parity") and run the check: Lean refuses, and prints
the constraints of a counterexample. Or delete a hypothesis, such as
`(hw : White n)` in `lam_up`.

The same goes for unfinished work. The word `sorry` is accepted by Lean in
place of any proof, with a warning; it is how one writes a statement first
and its proof later. The check of this directory rejects it.
