// SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
//
// SPDX-License-Identifier: MIT

//! The game of hats with three players: the scorer and the first searches.
//!
//! usage: players score T            wins of the symmetric table on stdin
//!        players winkler T          the table of Winkler's sum, on stdout
//!        players climb T SECONDS [SEED [START [HOT COLD]]]
//!                                   annealing from the table of the file
//!                                   START ("-" for a random table), the
//!                                   temperature going from HOT down to
//!                                   COLD again and again (3 and 0.15 by
//!                                   default)
//!        players factor T K SECONDS [SEED [HOT COLD]]
//!                                   annealing on the tables of the form
//!                                   s[u][v] = F(state(u), state(v)), where
//!                                   each stack has one of K states
//!        players eval [T ...]       the wins, on T hats (2 to 6 by default),
//!                                   of the strategy written on stdin in the
//!                                   small language of lang.rs
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

mod lang;

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
fn climb(start: Table, seconds: f64, seed: u64, hot: f64, cold: f64) -> (Table, u64) {
    let mut rng = Rng(seed.wrapping_mul(0x9E37_79B9_7F4A_7C15) | 1);
    let mut table = start;
    let t = table.t;
    let mut current = table.wins() as i64;
    let mut best = table.clone();
    let mut best_wins = current;
    let begin = Instant::now();
    let limit = Duration::from_secs_f64(seconds);
    // the temperature goes from `hot` down to `cold`, again and again
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

/// A table of the form s[u][v] = f[state[u]][state[v]]: each stack seen is
/// summed up by one of `k` states, and `f` is symmetric.
#[derive(Clone)]
struct Factored {
    t: usize,
    k: usize,
    state: Vec<usize>,
    f: Vec<usize>,
}

impl Factored {
    fn table(&self) -> Table {
        let mut table = Table::new(self.t);
        for u in 0..table.size {
            for v in 0..table.size {
                let p = self.f[self.state[u] * self.k + self.state[v]];
                table.s[u * table.size + v] = p as u8;
            }
        }
        table
    }

    /// The wins, counted by states: with count[i][p] the number of stacks
    /// in state i that are black at p, they are the sum over the triples
    /// of states (i, j, l) of
    /// count[i][f(j, l)] * count[j][f(i, l)] * count[l][f(i, j)].
    fn wins(&self) -> i64 {
        let (k, t) = (self.k, self.t);
        let mut count = vec![0i64; k * t];
        for (u, &i) in self.state.iter().enumerate() {
            for p in 0..t {
                count[i * t + p] += (u >> p & 1) as i64;
            }
        }
        let mut total = 0;
        for i in 0..k {
            for j in 0..k {
                for l in 0..k {
                    total += count[i * t + self.f[j * k + l]]
                        * count[j * t + self.f[i * k + l]]
                        * count[l * t + self.f[i * k + j]];
                }
            }
        }
        total
    }
}

/// Simulated annealing on the factored tables with `k` states.  A move
/// changes the state of one stack or one value of `f`.
fn factor(t: usize, k: usize, seconds: f64, seed: u64, hot: f64, cold: f64) -> (Factored, i64) {
    let mut rng = Rng(seed.wrapping_mul(0x9E37_79B9_7F4A_7C15) | 1);
    let size = 1usize << t;
    let mut x = Factored {
        t,
        k,
        state: (0..size).map(|_| rng.below(k)).collect(),
        f: vec![0; k * k],
    };
    for i in 0..k {
        for j in i..k {
            let p = rng.below(t);
            x.f[i * k + j] = p;
            x.f[j * k + i] = p;
        }
    }
    let mut current = x.wins();
    let mut best = x.clone();
    let mut best_wins = current;
    let begin = Instant::now();
    let limit = Duration::from_secs_f64(seconds);
    let cycle = 400_000u64;
    let mut step = 0u64;
    loop {
        if step.is_multiple_of(4096) && begin.elapsed() >= limit {
            break;
        }
        let phase = (step % cycle) as f64 / cycle as f64;
        let temperature = hot * (cold / hot).powf(phase);
        step += 1;
        // either the state of a stack, or a value of f
        let move_state = k > 1 && rng.below(3) > 0;
        let (place, other, old) = if move_state {
            let u = rng.below(size);
            (u, u, x.state[u])
        } else {
            let (i, j) = (rng.below(k), rng.below(k));
            (i * k + j, j * k + i, x.f[i * k + j])
        };
        if move_state {
            x.state[place] = (old + 1 + rng.below(k - 1)) % k;
        } else {
            let new = (old + 1 + rng.below(t - 1)) % t;
            x.f[place] = new;
            x.f[other] = new;
        }
        let wins = x.wins();
        let delta = wins - current;
        if delta >= 0 || rng.unit() < (delta as f64 / temperature).exp() {
            current = wins;
            if current > best_wins {
                best_wins = current;
                best = x.clone();
                eprintln!(
                    "{:8.1}s step {step}: {best_wins} wins",
                    begin.elapsed().as_secs_f64()
                );
            }
        } else if move_state {
            x.state[place] = old;
        } else {
            x.f[place] = old;
            x.f[other] = old;
        }
    }
    assert_eq!(
        best.table().wins() as i64,
        best_wins,
        "the count by states is wrong"
    );
    (best, best_wins)
}

/// The table on `t` hats of a program of the small language.  An error if
/// the program fails for some stacks, points outside the stack, or is not
/// symmetric in the two stacks seen.
fn table_of(program: &lang::Program, t: usize) -> Result<Table, String> {
    let mut table = Table::new(t);
    for u in 0..table.size {
        for v in 0..table.size {
            let p = program.point(t, u, v)?;
            table.s[u * table.size + v] = p as u8;
        }
    }
    for u in 0..table.size {
        for v in 0..u {
            if table.get(u, v) != table.get(v, u) {
                return Err(format!(
                    "on {t} hats it is not symmetric for the stacks {u} and {v}"
                ));
            }
        }
    }
    Ok(table)
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
    if args.get(1).map(String::as_str) == Some("eval") {
        // the text on stdin is only ever parsed and computed by lang.rs
        let heights: Vec<usize> = if args.len() > 2 {
            args[2..]
                .iter()
                .map(|s| s.parse().expect("T is a number"))
                .collect()
        } else {
            (2..=6).collect()
        };
        let program = match lang::parse(&read_stdin()) {
            Ok(program) => program,
            Err(message) => {
                println!("refused: {message}");
                std::process::exit(1);
            }
        };
        for t in heights {
            assert!((1..=8).contains(&t), "T is between 1 and 8");
            match table_of(&program, t) {
                Ok(table) => println!("{t} hats: {} wins out of {}", table.wins(), 1u64 << (3 * t)),
                Err(message) => {
                    println!("refused: {message}");
                    std::process::exit(1);
                }
            }
        }
        return;
    }
    let usage = "usage: players score T | winkler T | climb T SECONDS [SEED [START [HOT COLD]]] \
                 | factor T K SECONDS [SEED [HOT COLD]] | eval [T ...]";
    if args.len() < 3 {
        eprintln!("{usage}");
        std::process::exit(2);
    }
    let t: usize = args[2].parse().expect("T is a number");
    assert!((1..=8).contains(&t), "T is between 1 and 8");
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
            let number = |i: usize, default: f64| {
                args.get(i)
                    .map_or(default, |s| s.parse().expect("a number"))
            };
            let (hot, cold) = (number(6, 3.0), number(7, 0.15));
            let start = match args.get(5).filter(|path| path.as_str() != "-") {
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
            let (best, wins) = climb(start, seconds, seed, hot, cold);
            eprintln!("best: {wins} wins out of {}", 1u64 << (3 * t));
            print!("{}", best.print());
        }
        "factor" => {
            let k: usize = args.get(3).expect(usage).parse().expect("K is a number");
            let seconds: f64 = args
                .get(4)
                .expect(usage)
                .parse()
                .expect("SECONDS is a number");
            let seed: u64 = args
                .get(5)
                .map_or(1, |s| s.parse().expect("SEED is a number"));
            let number = |i: usize, default: f64| {
                args.get(i)
                    .map_or(default, |s| s.parse().expect("a number"))
            };
            let scale = (1u64 << (3 * t)) as f64;
            let (hot, cold) = (number(6, 0.004) * scale, number(7, 0.0001) * scale);
            let (best, wins) = factor(t, k, seconds, seed, hot, cold);
            eprintln!("best: {wins} wins out of {}", 1u64 << (3 * t));
            println!("states of the stacks 0, 1, ...: {:?}", best.state);
            for i in 0..k {
                println!("f[{i}]: {:?}", &best.f[i * k..(i + 1) * k]);
            }
            print!("{}", best.table().print());
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
    fn factored_tables_are_counted_by_states() {
        let mut rng = Rng(11);
        for _ in 0..50 {
            let (t, k) = (4, 3);
            let mut x = Factored {
                t,
                k,
                state: (0..16).map(|_| rng.below(k)).collect(),
                f: vec![0; k * k],
            };
            for i in 0..k {
                for j in i..k {
                    let p = rng.below(t);
                    x.f[i * k + j] = p;
                    x.f[j * k + i] = p;
                }
            }
            assert_eq!(x.wins(), x.table().wins() as i64);
        }
    }

    #[test]
    fn winkler_written_in_the_small_language() {
        let text = "(if (* (cnt u) (cnt v)) (mod (+ (lb u) (lb v)) t) 0)";
        let program = lang::parse(text).expect("a program");
        for t in 2..=4 {
            assert_eq!(table_of(&program, t).expect("a table").s, winkler(t).s);
        }
        let lopsided = lang::parse("(lb u)").expect("a program");
        assert!(table_of(&lopsided, 3).is_err());
    }

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
