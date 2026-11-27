// SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
//
// SPDX-License-Identifier: MIT

//! A small language for strategies, with no input or output.
//!
//! A candidate strategy is a text in this language.  It is read by the
//! parser below and computed by the evaluator below; it is never run as
//! code by anything else.  The language has no loop without a bound, no
//! string, no file, no call outside the list of this file, and a function
//! can only call the functions defined before it: a candidate cannot do
//! anything but compute a number from the stacks it is given.
//!
//! A program is a list of definitions followed by one expression:
//!
//! ```text
//! (def (lowsum a b) (mod (+ (lb a) (lb b)) t))
//! (if (* (cnt u) (cnt v)) (lowsum u v) 0)
//! ```
//!
//! The expression gives the position to point at for the player who sees
//! the stacks `u` and `v`; `t` is the number of hats of a stack.  A stack
//! is a whole number (bit `p` is `1` for a black hat at position `p`).
//!
//! Expressions:
//!
//! - a whole number, a variable (`t`, `u`, `v`, a parameter, a bound
//!   variable);
//! - `(+ a b ...)`, `(* a b ...)`, `(- a b)`, `(div a b)`, `(mod a b)`,
//!   `(min a b ...)`, `(max a b ...)`;
//! - `(< a b)`, `(<= a b)`, `(= a b)`: `1` or `0`; `(not a)`: `1` when
//!   `a` is `0`;
//! - `(if c a b)`: `a` when `c` is not `0`, else `b` (only one is computed);
//! - on stacks: `(lb x)` and `(lw x)`, the lowest black and the lowest
//!   white position (`t` if there is none); `(hb x)` and `(hw x)`, the
//!   highest (`-1` if there is none); `(cnt x)`, the number of black
//!   hats; `(hat x p)`, `1` for a black hat at position `p`, `0` otherwise
//!   and outside the stack; `(band x y)`, `(bor x y)`, `(bxor x y)`,
//!   `(flip x)`, hat by hat; `(low x k)`, the `k` lowest hats; `(above x
//!   k)`, the stack without its `k` lowest hats;
//! - `(first p e)`: the lowest position `p` below `t` for which `e` is not
//!   `0` (`t` if there is none); `(count p e)`: how many; `(sum p e)`: the
//!   sum of `e`;
//! - `(f a b ...)` for a function `f` defined earlier.

use std::collections::HashMap;

/// An expression, after parsing.
#[derive(Debug, Clone)]
pub enum Expr {
    Number(i64),
    /// A variable, by its place in the environment.
    Var(usize),
    /// A primitive with its arguments.
    Prim(Prim, Vec<Expr>),
    If(Box<Expr>, Box<Expr>, Box<Expr>),
    /// `first`, `count` or `sum` over the positions: the place of the bound
    /// variable in the environment, and the body.
    Scan(Scan, usize, Box<Expr>),
    /// A call of a function defined earlier, by its number.
    Call(usize, Vec<Expr>),
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum Prim {
    Add,
    Mul,
    Sub,
    Div,
    Mod,
    Min,
    Max,
    Lt,
    Le,
    Eq,
    Not,
    Lb,
    Lw,
    Hb,
    Hw,
    Cnt,
    Hat,
    Band,
    Bor,
    Bxor,
    Flip,
    Low,
    Above,
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum Scan {
    First,
    Count,
    Sum,
}

/// A function: its number of parameters and its body, in which the
/// parameters are the first variables of the environment.
#[derive(Debug, Clone)]
struct Function {
    arity: usize,
    body: Expr,
}

/// A program: its functions and its last expression, in which the
/// variables are `t`, `u`, `v` in this order.
#[derive(Debug, Clone)]
pub struct Program {
    functions: Vec<Function>,
    main: Expr,
}

const MAX_TEXT: usize = 4000;
const MAX_DEPTH: usize = 40;
/// The steps allowed for one call of a program.
const MAX_STEPS: u64 = 200_000;

// ---- reading ----

#[derive(Debug, Clone, PartialEq)]
enum Token {
    Open,
    Close,
    Word(String),
}

fn tokens(text: &str) -> Result<Vec<Token>, String> {
    if text.len() > MAX_TEXT {
        return Err(format!("the program has more than {MAX_TEXT} characters"));
    }
    let mut out = Vec::new();
    let mut word = String::new();
    for c in text.chars() {
        let flush = c == '(' || c == ')' || c.is_whitespace();
        if flush && !word.is_empty() {
            out.push(Token::Word(std::mem::take(&mut word)));
        }
        match c {
            '(' => out.push(Token::Open),
            ')' => out.push(Token::Close),
            c if c.is_whitespace() => {}
            c if c.is_ascii_alphanumeric() || "+-*<=_".contains(c) => word.push(c),
            c => return Err(format!("character {c:?} is not in the language")),
        }
    }
    if !word.is_empty() {
        out.push(Token::Word(word));
    }
    Ok(out)
}

/// A piece of text with its parentheses: a word or a list.
#[derive(Debug, Clone)]
enum Tree {
    Word(String),
    List(Vec<Tree>),
}

fn tree(tokens: &[Token], at: &mut usize, depth: usize) -> Result<Tree, String> {
    if depth > MAX_DEPTH {
        return Err("too many parentheses inside one another".to_string());
    }
    match tokens.get(*at) {
        None => Err("the program ends too early".to_string()),
        Some(Token::Close) => Err("a closing parenthesis has no opening one".to_string()),
        Some(Token::Word(w)) => {
            *at += 1;
            Ok(Tree::Word(w.clone()))
        }
        Some(Token::Open) => {
            *at += 1;
            let mut items = Vec::new();
            loop {
                match tokens.get(*at) {
                    None => return Err("a parenthesis is not closed".to_string()),
                    Some(Token::Close) => {
                        *at += 1;
                        return Ok(Tree::List(items));
                    }
                    Some(_) => items.push(tree(tokens, at, depth + 1)?),
                }
            }
        }
    }
}

fn primitive(name: &str) -> Option<(Prim, usize, usize)> {
    // the primitive, and the least and the greatest number of arguments
    let many = usize::MAX;
    Some(match name {
        "+" => (Prim::Add, 2, many),
        "*" => (Prim::Mul, 2, many),
        "-" => (Prim::Sub, 2, 2),
        "div" => (Prim::Div, 2, 2),
        "mod" => (Prim::Mod, 2, 2),
        "min" => (Prim::Min, 2, many),
        "max" => (Prim::Max, 2, many),
        "<" => (Prim::Lt, 2, 2),
        "<=" => (Prim::Le, 2, 2),
        "=" => (Prim::Eq, 2, 2),
        "not" => (Prim::Not, 1, 1),
        "lb" => (Prim::Lb, 1, 1),
        "lw" => (Prim::Lw, 1, 1),
        "hb" => (Prim::Hb, 1, 1),
        "hw" => (Prim::Hw, 1, 1),
        "cnt" => (Prim::Cnt, 1, 1),
        "hat" => (Prim::Hat, 2, 2),
        "band" => (Prim::Band, 2, 2),
        "bor" => (Prim::Bor, 2, 2),
        "bxor" => (Prim::Bxor, 2, 2),
        "flip" => (Prim::Flip, 1, 1),
        "low" => (Prim::Low, 2, 2),
        "above" => (Prim::Above, 2, 2),
        _ => return None,
    })
}

struct Reader {
    /// The functions defined so far: name and number of parameters.
    names: HashMap<String, (usize, usize)>,
}

impl Reader {
    fn expr(&self, tree: &Tree, scope: &mut Vec<String>) -> Result<Expr, String> {
        match tree {
            Tree::Word(w) => {
                if let Ok(n) = w.parse::<i64>() {
                    if n.abs() > 1_000_000 {
                        return Err(format!("the number {n} is too large"));
                    }
                    return Ok(Expr::Number(n));
                }
                match scope.iter().rposition(|name| name == w) {
                    Some(place) => Ok(Expr::Var(place)),
                    None => Err(format!("{w} is not a variable here")),
                }
            }
            Tree::List(items) => {
                let Some(Tree::Word(head)) = items.first() else {
                    return Err("a list must begin with a name".to_string());
                };
                let rest = &items[1..];
                if head == "if" {
                    let [c, a, b] = rest else {
                        return Err("if takes three arguments".to_string());
                    };
                    return Ok(Expr::If(
                        Box::new(self.expr(c, scope)?),
                        Box::new(self.expr(a, scope)?),
                        Box::new(self.expr(b, scope)?),
                    ));
                }
                let scan = match head.as_str() {
                    "first" => Some(Scan::First),
                    "count" => Some(Scan::Count),
                    "sum" => Some(Scan::Sum),
                    _ => None,
                };
                if let Some(scan) = scan {
                    let [Tree::Word(name), body] = rest else {
                        return Err(format!("{head} takes a name and an expression"));
                    };
                    if name.parse::<i64>().is_ok() {
                        return Err(format!("{name} is not a name"));
                    }
                    scope.push(name.clone());
                    let body = self.expr(body, scope);
                    scope.pop();
                    return Ok(Expr::Scan(scan, scope.len(), Box::new(body?)));
                }
                let mut arguments = Vec::new();
                for item in rest {
                    arguments.push(self.expr(item, scope)?);
                }
                if let Some((prim, least, most)) = primitive(head) {
                    if arguments.len() < least || arguments.len() > most {
                        return Err(format!(
                            "{head} does not take {} arguments",
                            arguments.len()
                        ));
                    }
                    return Ok(Expr::Prim(prim, arguments));
                }
                match self.names.get(head) {
                    Some(&(number, arity)) if arity == arguments.len() => {
                        Ok(Expr::Call(number, arguments))
                    }
                    Some(_) => Err(format!(
                        "{head} does not take {} arguments",
                        arguments.len()
                    )),
                    None => Err(format!("{head} is not defined (yet)")),
                }
            }
        }
    }
}

/// Reads a program.  Everything that is not in the language is an error.
pub fn parse(text: &str) -> Result<Program, String> {
    let tokens = tokens(text)?;
    let mut at = 0;
    let mut trees = Vec::new();
    while at < tokens.len() {
        trees.push(tree(&tokens, &mut at, 0)?);
    }
    let Some((last, definitions)) = trees.split_last() else {
        return Err("the program is empty".to_string());
    };
    let mut reader = Reader {
        names: HashMap::new(),
    };
    let mut functions = Vec::new();
    for definition in definitions {
        let Tree::List(items) = definition else {
            return Err("only the last expression is not a definition".to_string());
        };
        let [Tree::Word(def), Tree::List(head), body] = items.as_slice() else {
            return Err("a definition is (def (name parameters...) body)".to_string());
        };
        if def != "def" {
            return Err("only the last expression is not a definition".to_string());
        }
        let mut words = Vec::new();
        for item in head {
            let Tree::Word(w) = item else {
                return Err("a parameter is a name".to_string());
            };
            if w.parse::<i64>().is_ok() || primitive(w).is_some() {
                return Err(format!("{w} cannot be a name"));
            }
            words.push(w.clone());
        }
        let Some((name, parameters)) = words.split_first() else {
            return Err("a definition needs a name".to_string());
        };
        let reserved = ["if", "first", "count", "sum", "def", "t", "u", "v"];
        if reader.names.contains_key(name) || reserved.contains(&name.as_str()) {
            return Err(format!("{name} is already taken"));
        }
        // inside a function: its parameters, and t
        let mut scope: Vec<String> = parameters.to_vec();
        scope.push("t".to_string());
        let body = reader.expr(body, &mut scope)?;
        reader
            .names
            .insert(name.clone(), (functions.len(), parameters.len()));
        functions.push(Function {
            arity: parameters.len(),
            body,
        });
    }
    let mut scope = vec!["t".to_string(), "u".to_string(), "v".to_string()];
    let main = reader.expr(last, &mut scope)?;
    Ok(Program { functions, main })
}

// ---- computing ----

struct Machine<'a> {
    program: &'a Program,
    t: i64,
    steps: u64,
}

fn stack(x: i64, t: i64) -> Result<u64, String> {
    if x < 0 || x >= 1 << t {
        return Err(format!("{x} is not a stack of {t} hats"));
    }
    Ok(x as u64)
}

impl Machine<'_> {
    fn eval(&mut self, e: &Expr, env: &mut Vec<i64>) -> Result<i64, String> {
        self.steps += 1;
        if self.steps > MAX_STEPS {
            return Err("too many steps".to_string());
        }
        let t = self.t;
        match e {
            Expr::Number(n) => Ok(*n),
            Expr::Var(place) => Ok(env[*place]),
            Expr::If(c, a, b) => {
                if self.eval(c, env)? != 0 {
                    self.eval(a, env)
                } else {
                    self.eval(b, env)
                }
            }
            Expr::Scan(scan, place, body) => {
                debug_assert_eq!(*place, env.len());
                let mut result = if *scan == Scan::First { t } else { 0 };
                for p in 0..t {
                    env.push(p);
                    let value = self.eval(body, env);
                    env.pop();
                    let value = value?;
                    match scan {
                        Scan::First if value != 0 => {
                            result = p;
                            break;
                        }
                        Scan::First => {}
                        Scan::Count => result += (value != 0) as i64,
                        Scan::Sum => {
                            result = result.checked_add(value).ok_or("a sum is too large")?;
                        }
                    }
                }
                Ok(result)
            }
            Expr::Call(number, arguments) => {
                let function = &self.program.functions[*number];
                debug_assert_eq!(function.arity, arguments.len());
                let mut inner = Vec::with_capacity(arguments.len() + 1);
                for argument in arguments {
                    inner.push(self.eval(argument, env)?);
                }
                inner.push(t);
                self.eval(&function.body, &mut inner)
            }
            Expr::Prim(prim, arguments) => {
                let mut a = Vec::with_capacity(arguments.len());
                for argument in arguments {
                    a.push(self.eval(argument, env)?);
                }
                self.prim(*prim, &a)
            }
        }
    }

    fn prim(&self, prim: Prim, a: &[i64]) -> Result<i64, String> {
        let t = self.t;
        let full = (1u64 << t) - 1;
        let large = || "a number is too large".to_string();
        Ok(match prim {
            Prim::Add => a
                .iter()
                .try_fold(0i64, |x, &y| x.checked_add(y))
                .ok_or_else(large)?,
            Prim::Mul => a
                .iter()
                .try_fold(1i64, |x, &y| x.checked_mul(y))
                .ok_or_else(large)?,
            Prim::Sub => a[0].checked_sub(a[1]).ok_or_else(large)?,
            Prim::Div | Prim::Mod => {
                if a[1] <= 0 {
                    return Err("division by a number that is not positive".to_string());
                }
                if prim == Prim::Div {
                    a[0].div_euclid(a[1])
                } else {
                    a[0].rem_euclid(a[1])
                }
            }
            Prim::Min => *a.iter().min().expect("at least two arguments"),
            Prim::Max => *a.iter().max().expect("at least two arguments"),
            Prim::Lt => (a[0] < a[1]) as i64,
            Prim::Le => (a[0] <= a[1]) as i64,
            Prim::Eq => (a[0] == a[1]) as i64,
            Prim::Not => (a[0] == 0) as i64,
            Prim::Lb => match stack(a[0], t)? {
                0 => t,
                x => x.trailing_zeros() as i64,
            },
            Prim::Lw => {
                let x = !stack(a[0], t)? & full;
                if x == 0 {
                    t
                } else {
                    x.trailing_zeros() as i64
                }
            }
            Prim::Hb => match stack(a[0], t)? {
                0 => -1,
                x => 63 - x.leading_zeros() as i64,
            },
            Prim::Hw => {
                let x = !stack(a[0], t)? & full;
                if x == 0 {
                    -1
                } else {
                    63 - x.leading_zeros() as i64
                }
            }
            Prim::Cnt => stack(a[0], t)?.count_ones() as i64,
            Prim::Hat => {
                let x = stack(a[0], t)?;
                if (0..t).contains(&a[1]) {
                    (x >> a[1] & 1) as i64
                } else {
                    0
                }
            }
            Prim::Band => (stack(a[0], t)? & stack(a[1], t)?) as i64,
            Prim::Bor => (stack(a[0], t)? | stack(a[1], t)?) as i64,
            Prim::Bxor => (stack(a[0], t)? ^ stack(a[1], t)?) as i64,
            Prim::Flip => (!stack(a[0], t)? & full) as i64,
            Prim::Low => {
                let x = stack(a[0], t)?;
                let k = a[1].clamp(0, t);
                (x & ((1u64 << k) - 1)) as i64
            }
            Prim::Above => {
                let x = stack(a[0], t)?;
                let k = a[1].clamp(0, t);
                (x >> k) as i64
            }
        })
    }
}

impl Program {
    /// The position to point at, on `t` hats, for the stacks `u` and `v`.
    /// An error if the program fails or points outside the stack.
    pub fn point(&self, t: usize, u: usize, v: usize) -> Result<usize, String> {
        let mut machine = Machine {
            program: self,
            t: t as i64,
            steps: 0,
        };
        let mut env = vec![t as i64, u as i64, v as i64];
        let p = machine.eval(&self.main, &mut env)?;
        if p < 0 || p >= t as i64 {
            return Err(format!(
                "for the stacks {u} and {v} it points at {p}, outside the stack"
            ));
        }
        Ok(p as usize)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn value(text: &str, t: usize, u: usize, v: usize) -> Result<usize, String> {
        parse(text)?.point(t, u, v)
    }

    #[test]
    fn arithmetic_and_stacks() {
        assert_eq!(value("(+ 1 1)", 5, 0, 0), Ok(2));
        assert_eq!(value("(mod (- 0 1) t)", 5, 0, 0), Ok(4));
        assert_eq!(value("(lb u)", 5, 0b01100, 0), Ok(2));
        assert_eq!(value("(lw u)", 5, 0b01011, 0), Ok(2));
        assert_eq!(value("(hb u)", 5, 0b01011, 0), Ok(3));
        assert_eq!(value("(cnt (bxor u v))", 5, 0b01011, 0b00001), Ok(2));
        assert_eq!(value("(hat (flip u) 0)", 5, 0b01010, 0), Ok(1));
        assert_eq!(value("(low (above u 1) 2)", 5, 0b01110, 0), Ok(3));
        assert_eq!(value("(first p (hat u p))", 5, 0b01000, 0), Ok(3));
        assert_eq!(value("(count p (hat u p))", 5, 0b01011, 0), Ok(3));
        assert_eq!(value("(if (< 1 2) 3 (div 1 0))", 5, 0, 0), Ok(3));
    }

    #[test]
    fn functions() {
        let text = "(def (twice x) (* 2 x)) (def (f a b) (+ (twice a) b)) (f 1 2)";
        assert_eq!(value(text, 5, 0, 0), Ok(4));
    }

    #[test]
    fn what_is_not_in_the_language_is_refused() {
        for text in [
            "",
            "(",
            ")",
            "(open \"file\")",
            "(import os)",
            "x",
            "(def (f x) (f x)) (f 1)",
            "(def (g x) (h x)) (def (h x) 1) (g 1)",
            "(+ 1)",
            "(lb 1 2)",
            "(def (t x) 1) 0",
            "1 2",
        ] {
            assert!(parse(text).is_err(), "{text:?} was accepted");
        }
        // accepted by the parser, refused when computed
        assert!(value("(div 1 0)", 5, 0, 0).is_err());
        assert!(value("(lb 99)", 5, 0, 0).is_err());
        assert!(value("7", 5, 0, 0).is_err());
        assert!(value("(- 0 1)", 5, 0, 0).is_err());
    }
}
