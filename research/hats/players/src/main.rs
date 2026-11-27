// SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
//
// SPDX-License-Identifier: MIT

//! The game of hats with three players: the scorer and the first searches.
//!
//! usage: players score T            wins of the symmetric table on stdin
//!        players winkler T          the table of Winkler's sum, on stdout
//!        players climb T SECONDS [SEED [START]]
//!                                   annealing from the table of the file
//!                                   START, or from a random table
//!
//! Three players, each with a stack of T hats (a number below 2^T, the
//! bottom hat is the units digit, black is 1).  Each sees the two other
//! stacks and points at a position of their own; they win when the three
//! hats pointed at are black.  A symmetric strategy is one table
//! s[u][v] = s[v][u] for the three players.  Its wins are the triples
//! (a, b, c) of stacks with a black at s[b][c], b black at s[a][c] and c
//! black at s[a][b], out of 8^T.
//!
//! A table is 2^T lines of 2^T digits: line u, column v.  The Python file
//! score.py of this directory is the reference that this program is
//! checked against (`cargo test`, and check_players.py).

use std::io::Read;
use std::time::{Duration, Instant};

/// A symmetric strategy for three players on `t` hats.
#[derive(Clone)]
struct Table {
    t: usize,
    size: usize,
    /// s[u * size + v], with s[u][v] = s[v][u]
    s: Vec<u8>,
}

impl Table {
    fn new(t: usize) -> Table {
        let size = 1 << t;
        Table {
            t,
            size,
            s: vec![0; size * size],
        }
    }

    fn get(&self, u: usize, v: usize) -> usize {
        self.s[u * self.size + v] as usize
    }

    fn set(&mut self, u: usize, v: usize, p: usize) {
        self.s[u * self.size + v] = p as u8;
        self.s[v * self.size + u] = p as u8;
    }

    fn parse(t: usize, text: &str) -> Result<Table, String> {
        let mut table = Table::new(t);
        let lines: Vec<&str> = text.split_whitespace().collect();
        if lines.len() != table.size {
            return Err(format!("{} lines, {} expected", lines.len(), table.size));
        }
        for (u, line) in lines.iter().enumerate() {
            if line.len() != table.size {
                return Err(format!("line {u}: {} digits", line.len()));
            }
            for (v, c) in line.chars().enumerate() {
                let p = c.to_digit(10).ok_or(format!("line {u}: not a digit"))? as usize;
                if p >= t {
                    return Err(format!("line {u}: position {p} is not in the stack"));
                }
                table.s[u * table.size + v] = p as u8;
            }
        }
        for u in 0..table.size {
            for v in 0..u {
                if table.get(u, v) != table.get(v, u) {
                    return Err(format!("not symmetric at ({u}, {v})"));
                }
            }
        }
        Ok(table)
    }

    fn print(&self) -> String {
        let mut out = String::new();
        for u in 0..self.size {
            for v in 0..self.size {
                out.push(char::from(b'0' + self.s[u * self.size + v]));
            }
            out.push('\n');
        }
        out
    }

    /// Whether the triple of stacks (a, b, c) wins.
    fn win(&self, a: usize, b: usize, c: usize) -> bool {
        (a >> self.get(b, c)) & (b >> self.get(a, c)) & (c >> self.get(a, b)) & 1 == 1
    }

    /// The wins: all triples, one by one.
    fn wins(&self) -> u64 {
        let mut total = 0;
        for a in 0..self.size {
            for b in 0..self.size {
                for c in 0..self.size {
                    total += self.win(a, b, c) as u64;
                }
            }
        }
        total
    }

    /// The wins among the triples that contain the stacks u and v in two
    /// different places: those that the entry s[u][v] can change.
    fn wins_around(&self, u: usize, v: usize) -> i64 {
        let mut total = 0;
        for x in 0..self.size {
            // the different orders of the three stacks u, v, x
            let orders = [
                (u, v, x),
                (u, x, v),
                (v, u, x),
                (v, x, u),
                (x, u, v),
                (x, v, u),
            ];
            for (i, &(a, b, c)) in orders.iter().enumerate() {
                if orders[..i].contains(&(a, b, c)) {
                    continue;
                }
                total += self.win(a, b, c) as i64;
            }
        }
        total
    }
}

fn lowest_black(t: usize, u: usize) -> Option<usize> {
    (0..t).find(|&p| u >> p & 1 == 1)
}

/// Point at the sum, modulo T, of the lowest black hats of the two stacks.
fn winkler(t: usize) -> Table {
    let mut table = Table::new(t);
    for u in 0..table.size {
        for v in 0..table.size {
            if let (Some(a), Some(b)) = (lowest_black(t, u), lowest_black(t, v)) {
                table.s[u * table.size + v] = ((a + b) % t) as u8;
            }
        }
    }
    table
}

/// A small generator of random numbers (xorshift), so that a run is
/// reproduced by its seed.
struct Rng(u64);

impl Rng {
    fn next(&mut self) -> u64 {
        self.0 ^= self.0 << 13;
        self.0 ^= self.0 >> 7;
        self.0 ^= self.0 << 17;
        self.0
    }

    fn below(&mut self, n: usize) -> usize {
        ((self.next() >> 11) % n as u64) as usize
    }

    fn unit(&mut self) -> f64 {
        (self.next() >> 11) as f64 / (1u64 << 53) as f64
    }
}

/// Simulated annealing on the symmetric tables.  A move changes one entry
/// s[u][v] (and s[v][u]).  Returns the best table met and its wins.
fn climb(start: Table, seconds: f64, seed: u64) -> (Table, u64) {
    let mut rng = Rng(seed.wrapping_mul(0x9E37_79B9_7F4A_7C15) | 1);
    let mut table = start;
    let t = table.t;
    let mut current = table.wins() as i64;
    let mut best = table.clone();
    let mut best_wins = current;
    let begin = Instant::now();
    let limit = Duration::from_secs_f64(seconds);
    // the temperature goes from `hot` down to `cold`, again and again
    let (hot, cold) = (3.0_f64, 0.15_f64);
    let cycle = 2_000_000u64;
    let mut step = 0u64;
    loop {
        if step.is_multiple_of(4096) && begin.elapsed() >= limit {
            break;
        }
        let phase = (step % cycle) as f64 / cycle as f64;
        let temperature = hot * (cold / hot).powf(phase);
        step += 1;
        let u = rng.below(table.size);
        let v = rng.below(table.size);
        let old = table.get(u, v);
        let new = (old + 1 + rng.below(t - 1)) % t;
        let before = table.wins_around(u, v);
        table.set(u, v, new);
        let delta = table.wins_around(u, v) - before;
        if delta >= 0 || rng.unit() < (delta as f64 / temperature).exp() {
            current += delta;
            if current > best_wins {
                best_wins = current;
                best = table.clone();
                eprintln!(
                    "{:8.1}s step {step}: {best_wins} wins",
                    begin.elapsed().as_secs_f64()
                );
            }
        } else {
            table.set(u, v, old);
        }
    }
    assert_eq!(best.wins() as i64, best_wins, "the running count is wrong");
    (best, best_wins as u64)
}

fn read_stdin() -> String {
    let mut text = String::new();
    std::io::stdin()
        .read_to_string(&mut text)
        .expect("reading the standard input");
    text
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let usage = "usage: players score T | winkler T | climb T SECONDS [SEED [START]]";
    if args.len() < 3 {
        eprintln!("{usage}");
        std::process::exit(2);
    }
    let t: usize = args[2].parse().expect("T is a number");
    assert!((1..=7).contains(&t), "T is between 1 and 7");
    match args[1].as_str() {
        "score" => match Table::parse(t, &read_stdin()) {
            Ok(table) => println!("{}", table.wins()),
            Err(message) => {
                eprintln!("bad table: {message}");
                std::process::exit(1);
            }
        },
        "winkler" => print!("{}", winkler(t).print()),
        "climb" => {
            let seconds: f64 = args
                .get(3)
                .expect(usage)
                .parse()
                .expect("SECONDS is a number");
            let seed: u64 = args
                .get(4)
                .map_or(1, |s| s.parse().expect("SEED is a number"));
            let start = match args.get(5) {
                Some(path) => {
                    let text = std::fs::read_to_string(path).expect("reading START");
                    Table::parse(t, &text).expect("START is a table")
                }
                None => {
                    let mut rng = Rng(seed.wrapping_add(0x1234_5678_9ABC_DEF1) | 1);
                    let mut table = Table::new(t);
                    for u in 0..table.size {
                        for v in u..table.size {
                            let p = rng.below(t);
                            table.set(u, v, p);
                        }
                    }
                    table
                }
            };
            let (best, wins) = climb(start, seconds, seed);
            eprintln!("best: {wins} wins out of {}", 1u64 << (3 * t));
            print!("{}", best.print());
        }
        _ => {
            eprintln!("{usage}");
            std::process::exit(2);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn same_hat() {
        for t in 1..=4 {
            assert_eq!(Table::new(t).wins(), 1 << (3 * (t - 1)));
        }
    }

    #[test]
    fn winkler_as_in_score_py() {
        assert_eq!(winkler(2).wins(), 14);
        assert_eq!(winkler(3).wins(), 95);
    }

    #[test]
    fn a_move_changes_the_wins_as_counted_around_it() {
        let mut rng = Rng(7);
        let mut table = winkler(3);
        for _ in 0..500 {
            let (u, v) = (rng.below(8), rng.below(8));
            let before = (table.wins() as i64, table.wins_around(u, v));
            table.set(u, v, rng.below(3));
            let after = (table.wins() as i64, table.wins_around(u, v));
            assert_eq!(after.0 - before.0, after.1 - before.1);
        }
    }
}
