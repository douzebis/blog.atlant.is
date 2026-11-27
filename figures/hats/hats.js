// Copyright 2020 Frederic Ruget

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.


// == HATS CALCULATOR =========================================================

// == Environment Abstraction Layer ===========================================

// -- Catalog of supported environments ---------------------------------------

const Env = { // Supported environments
  d8: 'd8',
  chrome: 'chrome',
}

// Determine our execution environment
let env = Env.d8; // Default execution environment
if (typeof document == "object") { // Assume we are executing inside chrome
  env = Env.chrome;
}

// -- Arguments -------------------------------------------------------

let args = [];

// -- Display a message -------------------------------------------------------

let disp;
switch (env) {
  case Env.d8:
    disp = console.log;
    break;
  case Env.chrome:
    disp = function(text) {
      document.getElementById('result').innerText += text + '\n';
    }
  break;
}


// == Code Builder "Library" ==================================================

let tab = 0;
let _script = '';
let _lineInited = false;
let _tab = 0;
let _line = '';
function _init_codeBuilder() {
  tab = 0;
  _script = '';
  _lineInited = false;
  _tab = 0;
  _line = '';
}

class _Line {
  constructor(text, flush) {
    // Flush the _line buffer
    this.flush = function () {
      if (_tab)
        _script += '                                '.slice(-_tab);
      _script += _line + '\n';
    };
    // Append text
    this.a = function (text) {
      return new _Line(_line + text, false);
    };
    // Tabulate (with spaces)
    this.t = function (column) {
      return new _Line((_line + '                ').slice(0, column), false);
    };
    // Replace % with replacement text
    this.r = function (r) {
      return new _Line(_line.replace(/%/, r), false);
    };
    // Format as H2 title
    this.h2 = function () {
      return new _Line(('//== ' + _line +
      ' =======================================================================')
      .slice(0, 80), false);
    };
    // Format as H3 title
    this.h3 = function () {
      return new _Line(('//-- ' + _line +
      ' -----------------------------------------------------------------------')
      .slice(0, 80), false);
    };
    // Constructor for the _Line object
    if (flush) {
      if (_lineInited)
        this.flush();
      _tab = tab;
      _lineInited = true;
    }
    _line = text;
  }
}

function _(text) {
  return new _Line(text, true);
}

let __ = _;
let ___ = _;
let ____ = _;
let _____ = _;
let ______ = _;
let _______ = _;
let ________ = _;
let _________ = _;
let __________ = _;
let ___________ = _;
let ____________ = _;
let _____________ = _;
let ______________ = _;
let _______________ = _;
let ________________ = _;
let _________________ = _;
let __________________ = _;
let ___________________ = _;
let ____________________ = _;
let _____________________ = _;
let ______________________ = _;
let _______________________ = _;
let ________________________ = _;
let _________________________ = _;
let __________________________ = _;
let ___________________________ = _;
let ____________________________ = _;
let _____________________________ = _;
let ______________________________ = _;
let _______________________________ = _;
let ________________________________ = _;
let _________________________________ = _;
let __________________________________ = _;
let ___________________________________ = _;


// == Auxiliary "Library" =====================================================

// -- log_2 (non-optimized) ---------------------------------------------------

function log_2(n) {
  var l = 0;
  while (n != 1) {
      ++l;
      n = n >> 1;
  }
  return l;
}

// -- Convert numeric digit to string -----------------------------------------

function d2s(d) {
  switch (d) {
      case 0x0: return "0";
      case 0x1: return "1";
      case 0x2: return "2";
      case 0x3: return "3";
      case 0x4: return "4";
      case 0x5: return "5";
      case 0x6: return "6";
      case 0x7: return "7";
      case 0x8: return "8";
      case 0x9: return "9";
      case 0xa: return "a";
      case 0xb: return "b";
      case 0xc: return "c";
      case 0xd: return "d";
      case 0xe: return "e";
      case 0xf: return "f";
  }
}

// -- Parse a strategy --------------------------------------------------------

// ingests string or array, returns array
function parse(s) {
  if (typeof s === 'string') {
      // special case: stack of height 0 with negative choice, like: "-1"
      if (s.slice(0,1) == "-") {
          s = [parseInt(s)];
      // general case
      } else {
          let str = s;
          let len = str.length;
          s = [];
          for (let t = -1, i = 0; i < len; ++i) {
              switch (str.slice(i, i+1)) {
                  case "0": s[++t] = 0x0; break;
                  case "1": s[++t] = 0x1; break;
                  case "2": s[++t] = 0x2; break;
                  case "3": s[++t] = 0x3; break;
                  case "4": s[++t] = 0x4; break;
                  case "5": s[++t] = 0x5; break;
                  case "6": s[++t] = 0x6; break;
                  case "7": s[++t] = 0x7; break;
                  case "8": s[++t] = 0x8; break;
                  case "9": s[++t] = 0x9; break;
                  case "a": s[++t] = 0xa; break;
                  case "b": s[++t] = 0xb; break;
                  case "c": s[++t] = 0xc; break;
                  case "d": s[++t] = 0xd; break;
                  case "e": s[++t] = 0xe; break;
                  case "f": s[++t] = 0xf; break;
                  case "-": break;
                  default: throw Err.cliParsing;
              }
          }
      }
  }
  if (!Array.isArray(s)) throw Err.cliParsing;
  // Lastly, check that the size of the array is a power of 2
  if (s.length != (1 << log_2(s.length))) throw Err.cliParsing;
  return s;
}

// -- Compute a strategy hit score --------------------------------------------

// Requires s to be an array
function _score(s) {
    let c = s.length; // count of possible towers
    let hits = 0;

    // Test all play configs
    for (let t = 0; t < c; ++t) { // my tower
        var p = 1 << s[t]; // based on t you choose position log_2(p)
        for (let u = 0; u < c; ++u) { // your tower
            if (u & p) { // if your guess is successful
                if (t & (1 << s[u])) { // and mine too
                    ++hits; // then we have an additional hit
                }
            }
        }
    }
    return hits;
}

// -- Format a strategy (pretty print) ----------------------------------------

// Requires s to be an array
function _fmt(s) {
    let len = s.length;
    // decide option: full or shortened
    let full = 0;
    for (let i = 0; i < len; ++i) {
        if (s[i] < 0 || s[i] > 15) {
            ++full;
            break;
        }
    }
    if (full) return '[' + s.toString() + ']';
    let n = log_2(len); // height of the strategy
    let buf = '"';
    let once = 0;
    for (let i = 0; i < len; ++i) {
        if (!(i % 8)) {
            if (!once) {
                ++once;
            } else {
                if (!(i % 32)) buf += "\n ";
                else if (!(i % 16)) buf += "--";
                else buf += "-";
            }
        }
        buf += d2s(s[i]);
    }
    return buf + '"';
}

// -- Output a strategy to the console (pretty print) -------------------------

function show(s) {
  s = parse(s);
  let H = _score(s);
  let cardinalSquared = s.length * s.length;
  let msg = _fmt(s) + ' w = ' + H + '/' + cardinalSquared + ' ';
  const exactRatio = 100 * H / cardinalSquared;
  const shortRatio = Math.trunc(100 * exactRatio +0.5) / 100;
  if (shortRatio == exactRatio) {
    msg += '=';
  } else {
    msg += '~';
  }
  msg += ' ' + shortRatio + '%';
  disp(msg);
  return s;
}


// == Operations on strategies ================================================

// -- Transform a strategy by swapping two hats positions ---------------------

// Requires s to be an array
function _swap(s, i, j) {
  let c = s.length;
  let n = log_2(c);
  let tower = []; // tower keeps track of the initial tower identity
  // 1- swap bits i and j, keep towers in place
  for (let k = 0; k < c; ++k) {
      // swap the strategy's choice for k
      switch (s[k]) {
          case i: s[k] = j; break;
          case j: s[k] = i; break;
      }
      // swap bits i and j in k's name
      let bi = (k & (1 << i)) >> i; // i-th bit in t
      let bj = (k & (1 << j)) >> j; // j-th bit in t
      tower[k] = (k & ~((1 << i) | (1 << j)))
          | (bi << j) | (bj << i);
  }
  // 2- sort renamed towers
  for (let k = 0; k < c; ++k) {
      if (tower[k] == k) continue;
      for (let l = k + 1; l < c; ++l) {
          if (tower[l] == k) {
              tower[l] = tower[k];
              tower[k] = k;
              let tmp = s[l];
              s[l] = s[k];
              s[k] = tmp;
              break;
          }
      }
  }
  return s;
}

// -- Crush a strategy so that s[i] <= i --------------------------------------

function crush(s) {
  s = parse(s);
  let c = s.length;
  let n = log_2(c);
  s[0] = 0;
  s[c-1] = 0;
  for (let t = 0; t < c && t <= n; ++t) {
      if (s[t] < 0 || s[t] >= n) throw Err.notInTower;
      if (s[t] > t) s = _swap(s, t, s[t]);
  }
  return s;
}

// -- Embedding: a +--> emb_n(a) ----------------------------------------------

function emb(a,n) {
  a = parse(a);
  let ca = a.length; // count of possible towers for a
  let m = log_2(ca); // height of a
  if (n < m) throw Err.towerTooShort;
  let s = []; // to construct emb_n(a)
  let i = -1;
  for (let v = 2 ** (n - m); v > 0; --v) {
    for (let u = 0; u < ca; ++u) {
      s[++i] = a[u];
    }
  }
  return s;
}

// The colors: black is the digit 1 and the color to point at (until 2026 it
// was white).  The operations are named after the color that triggers them:
// the white reset and the white shift (lr and ls until 2026, "left") act on
// the stack of all-white hats, number 0; the black reset and the black shift
// (rr and rs, "right") on the stack of all-black hats.  The old names are
// kept.

// -- White reset: a, and b above it when the hats of a are all white ---------

function lr(a, b) {
  a = parse(a);
  b = parse(b);
  let ca = a.length; // count of possible towers for a
  let m = log_2(ca); // height of a
  let cb = b.length; // count of possible towers for b
  let s = []; // to construct (b -> a)
  let i = -1;
  for (let u = 0; u < cb; ++u) {
    for (let t = 0; t < ca; ++t) {
      if (t == 0) {
        s[++i] = b[u] + m;
      } else {
        s[++i] = a[t];
      }
    }
  }
  return s;
}

// -- Black reset: a, and b above it when the hats of a are all black ---------

function rr(a, b) {
  a = parse(a);
  b = parse(b);
  let ca = a.length; // count of possible towers for a
  let m = log_2(ca); // height of a
  let cb = b.length; // count of possible towers for b
  let s = []; // to construct (b -> a)
  let i = -1;
  for (let u = 0; u < cb; ++u) {
    for (let t = 0; t < ca; ++t) {
      if (t == ca - 1) {
        s[++i] = b[u] + m;
      } else {
        s[++i] = a[t];
      }
    }
  }
  return s;
}

// -- Double reset: a, and b above it when the hats of a have one color -------

function dr(a, b) {
  a = parse(a);
  b = parse(b);
  let ca = a.length; // count of possible towers for a
  let m = log_2(ca); // height of a
  let cb = b.length; // count of possible towers for b
  let s = []; // to construct (b -> a)
  let i = -1;
  for (let u = 0; u < cb; ++u) {
    for (let t = 0; t < ca ; ++t) {
      if (t == 0 || t == ca - 1) {
        s[++i] = b[u] + m;
      } else {
        s[++i] = a[t];
      }
    }
  }
  return s;
}

// -- White shift --------------------------------------------------------------

function ls(a) {
  a = parse(a);
  let ca = a.length; // count of possible towers for a
  let m = log_2(ca); // height of a
  let s = []; // to construct (b -> a)
  let i = -1;
  for (let u = 0; u < 2; ++u) {
    for (let t = 0; t < ca; ++t) {
      if (u != 0 && t == 0) {
        s[++i] = m;
      } else {
        s[++i] = a[t];
      }
    }
  }
  return s;
}

// -- Black shift --------------------------------------------------------------

function rs(a) {
  a = parse(a);
  let ca = a.length; // count of possible towers for a
  let m = log_2(ca); // height of a
  let s = []; // to construct (b -> a)
  let i = -1;
  for (let u = 0; u < 2; ++u) {
    for (let t = 0; t < ca; ++t) {
      if (u == 0 && t == ca - 1) {
        s[++i] = m;
      } else {
        s[++i] = a[t];
      }
    }
  }
  return s;
}

// -- Double shift: the white shift of the black shift, one choice changed ----

function ds(a) {
  a = parse(a);
  let ca = a.length; // count of possible towers for a
  let m = log_2(ca); // height of a
  let s = []; // to construct (b -> a)
  let i = -1;
  for (let u = 0; u < 4; ++u) {
    for (let t = 0; t < ca; ++t) {
      if ((u == 0 || u == 2) && t == ca - 1) {
        s[++i] = m;
      } else if ((u == 2 || u == 3) && t == 0) {
        s[++i] = m + 1;
      } else {
        s[++i] = a[t];
      }
    }
  }
  return s;
}

// -- Sibling double shift: the black shift of the white shift, one choice ----
// -- changed.  It is the double shift with its two new positions exchanged ---

function sd(a) {
  a = parse(a);
  let ca = a.length; // count of possible stacks for a
  let m = log_2(ca); // height of a
  let s = [];
  let i = -1;
  for (let u = 0; u < 4; ++u) {
    for (let t = 0; t < ca; ++t) {
      if ((u == 1 || u == 3) && t == 0) {
        s[++i] = m;
      } else if ((u == 0 || u == 1) && t == ca - 1) {
        s[++i] = m + 1;
      } else {
        s[++i] = a[t];
      }
    }
  }
  return s;
}

// -- Dual: the strategy with the two colors exchanged ------------------------

function dual(a) {
  a = parse(a);
  return a.slice().reverse();
}

// -- The operations under the names of their colors --------------------------

const wr = lr;
const br = rr;
const ws = ls;
const bs = rs;

// -- Basic strategies --------------------------------------------------------

const T0 = [-1];

// B<n> points at the lowest black hat, W<n> at the lowest white hat (the
// two names were exchanged in 2026, with the colors).
const B0 = T0;
const B1 = lr([0, 0], B0);
const B2 = lr([0, 0], B1);
const B3 = lr([0, 0], B2);
const B4 = lr([0, 0], B3);
const B5 = lr([0, 0], B4);
const B6 = lr([0, 0], B5);
const B7 = lr([0, 0], B6);
const B8 = lr([0, 0], B7);
const B9 = lr([0, 0], B8);

const W0 = T0;
const W1 = rr([0, 0], W0);
const W2 = rr([0, 0], W1);
const W3 = rr([0, 0], W2);
const W4 = rr([0, 0], W3);
const W5 = rr([0, 0], W4);
const W6 = rr([0, 0], W5);
const W7 = rr([0, 0], W6);
const W8 = rr([0, 0], W7);
const W9 = rr([0, 0], W8);

const C1 = [0, 0];
const C2 = rs(C1);
const C3 = ds(C1);
const C4 = rs(C3);
const C5 = ds(C3);
const C6 = rs(C5);
const C7 = ds(C5);
const C8 = rs(C7);
const C9 = ds(C7);

const R0 = T0;
// R(n+1) is C3 double-reset by R(n), as in the article.  Until 2026 this
// read dr(R2, C3) for R3, which is another strategy (double reset is not
// associative) with a lower win rate.
const R1 = C3;
const R2 = dr(C3, R1);
const R3 = dr(C3, R2);


// == Drawing =================================================================

// -- Tree of the choices of a sequence of strategies, as a LaTeX picture -----

// The 2020 version of this function was lost; this one was written in 2026
// from the pictures it had made.
//
// strats is a list of strategies.  The tree has one node per tower: the
// node of a tower of d hats, d edges below the root, shows the position
// that strats[d] chooses for it (a strategy for fewer hats only looks at
// the lowest ones).  The edge to a node tells the color of its top hat, 0
// or 1.
//
// A node is gray, and has nothing below it, when all the later strategies
// of the list make the same choice whatever hats are added on top: the
// limit of the sequence is reached there.  A list that ends with a
// strategy which never chooses a hat, such as emb(T0, 9), gives the whole
// tree with no gray node.
//
// The last three strategies of the list are only looked at for this, not
// drawn, unless rows tells how many rows to draw.  Dashed lines under the
// last row stand for the rest of the tree.

function tikz(strats, rows) {
  strats = strats.map(parse);
  const n = strats.length;
  if (rows === undefined) rows = n - 3;
  if (rows < 1 || rows > n) throw Err.tikzRows;
  const choice = (d, t) => strats[d][t % strats[d].length];
  const settled = (d, t) => {
    for (let e = d + 1; e < n; ++e) {
      for (let u = t; u < 2 ** e; u += 2 ** d) {
        if (choice(e, u) != choice(d, t)) return false;
      }
    }
    return d < n - 1;
  };
  const name = (d, t) => 'l' + d + '_' + t;
  let edges = '';
  const node = (d, t) => {
    const indent = ' '.repeat(d);
    const gray = settled(d, t);
    let text = (d ? indent + 'child {node' : '\\node')
      + ' [' + (gray ? 'settled' : 'open') + '](' + name(d, t) + ')'
      + ' {$' + choice(d, t) + '$}\n';
    if (!gray && d < rows - 1) {
      for (let bit = 0; bit < 2; ++bit) {
        const u = t + bit * 2 ** d;
        text += node(d + 1, u);
        edges += '\\path (' + name(d, t) + ') edge[draw] node['
          + (bit ? 'one' : 'zero') + ']{$' + bit + '$} (' + name(d + 1, u)
          + ');\n';
      }
    } else if (!gray) {
      edges += '\\draw[dashed] (' + name(d, t) + '.south) +(-0.3mm,0)'
        + ' -- +(-1mm,-11mm) (' + name(d, t) + '.south) +(0.3mm,0)'
        + ' -- +(1mm,-11mm);\n';
    }
    return text + (d ? indent + '}\n' : '');
  };
  const tree = node(0, 0);
  return { tikz: ''
    + '\\documentclass[preview]{standalone}\n'
    + '\\usepackage{tikz}\n'
    + '\\begin{document}\n'
    + '\\begin{tikzpicture}[\n'
    + ' level/.style={sibling distance=240mm/2^(1*(#1))},\n'
    + ' edge from parent/.style={},\n'
    + ' open/.style={draw,circle,fill=white,inner sep=0,minimum size=6.2mm},\n'
    + ' settled/.style={open,very thick,fill=gray!20},\n'
    + ' zero/.style={pos=0.45,above left,inner sep=1.5pt},\n'
    + ' one/.style={pos=0.45,above right,inner sep=1.5pt}]\n'
    + tree + ';\n' + edges
    + '\\end{tikzpicture}\n'
    + '\\end{document}' };
}

// == Command Line Parsing ====================================================

// -- Available commands ------------------------------------------------------

const Cmd = { // Implemented commands
  none: 'none',
  eval: 'eval',
  search: 'search',
  help: 'help',
};

// -- Help messages -----------------------------------------------------------

function help() {
  disp('usage: hats [help] <command> [<args>]');
  disp('');
  disp('Available commands include:');
  disp('   eval     Evaluate strategy expression');
  disp('   search   Search for optimal strategies');
}

function helpEval() {
  disp('usage: hats eval <expr>');
  disp('');
  disp('Evaluates strategy <expr> and displays the result: the position');
  disp('it points at for each stack, its hits and its win rate w.');
  disp('A stack is a number, its bottom hat is the units digit, black is 1,');
  disp('and the players point at black hats.');
  disp('');
  disp('Recognized syntax for <expr> include:');
  disp('   "00" | "0100" | ...      Literal strategy (short form)');
  disp('   [0,0] | [0,1,0,0] | ...  Literal strategy (long form)');
  disp('   B0, B1, ..., B9          Predefined lowest-black strategies');
  disp('   W0, W1, ..., W9          Predefined lowest-white strategies');
  disp('   C1, C2, ..., C9          Predefined Carter strategies');
  disp('   R0, R1, R2, R3           Predefined Reyes strategies');
  disp('   emb(<expr>, <num>)       <expr> played on stacks of <num> hats');
  disp('   wr(<expr>, <expr2>)      White reset of <expr> by <expr2>');
  disp('   br(<expr>, <expr2>)      Black reset of <expr> by <expr2>');
  disp('   dr(<expr>, <expr2>)      Double reset of <expr> by <expr2>');
  disp('   ws(<expr>)               White shift of <expr>');
  disp('   bs(<expr>)               Black shift of <expr>');
  disp('   ds(<expr>)               Double shift of <expr>');
  disp('   sd(<expr>)               Double shift of <expr>, the two new');
  disp('                            positions exchanged');
  disp('   dual(<expr>)             <expr> with the colors exchanged');
  disp('   crush(<expr>)            Crush transform of <expr>');
  disp('   tikz([<expr>, ...])      Tree of the choices of the strategies,');
  disp('                            as a LaTeX picture');
  disp('   lr, rr, ls, rs           Names of 2020 for wr, br, ws, bs');
  disp('');
  disp('Examples');
  disp('   eval \'"0100"\'');
  disp('   eval \'[0,1,0,0]\'');
  disp('   eval \'B3\'');
  disp('   eval \'ds(ds(C1))\'');
  disp('   eval \'wr(B1,B1)\'');
}

function helpSearch() {
  disp('usage: hats search [-n <num>] [-s <seed>] [-d <distance>] [-a]');
  disp('    [-q] [-c]');
  disp('');
  disp('Searches for optimal strategies');
  disp('');
  disp('   -n <num>');
  disp('        Search for a strategy of height <num>. <num> must be within');
  disp('        [1,..,5]. The default is 1.');
  disp('   -s <expr>');
  disp('        Limit the search to strategies close to strategy <expr>');
  disp('        (the seed). The default is the constant strategy 0. -s has');
  disp('        precedence over -n');
  disp('   -d <num>');
  disp('        Limit the search to strategies within a Hamming distance of');
  disp('        <num> of the seed. <num> must be positive of 0 (no limit).');
  disp('        The default is 0.');
  disp('   -a');
  disp('        Display all optimal strategies found');
  disp('   -q');
  disp('        Don\'t display search progress messages');
  disp('   -c');
  disp('        Do not actually search. Instead output the optimized');
  disp('        JavaScript code which implements the search.');
  disp('');
  disp('Examples');
  disp('   search -n 4 -q');
  disp('   search -n 5 -d 6');
}

// -- Catalog of errors -------------------------------------------------------

const Err = { // Throwable errors
  cliParsing: 'Command line parsing error',
  cliParameters: 'Command line parameters error',
  eval: 'The expression is not a strategy',
  heightSearch: 'Height search must be within [1,..,5]',
  searchSeed: 'Search seed must be in crushed form',
  notInTower: 'Crushed argument must point within the stack',
  towerTooShort: 'Cannot embed in a shorter stack',
  badEnv: 'Did not expect this execution environment',
  tikzRows: 'The number of rows must be between 1 and the number of strategies',
}

// -- Command parameters ------------------------------------------------------

const ALARM_TRIGGER = 100000000; // 100 Millions
let command = Cmd.none;
let expression = [];
let cardinal = 0;
let cardinalSquared = 0;
let height = -1;
let seed = expression;
let distance = 0;
let all = false;
let quiet = false;
let code = false;
let ratings = 0;
let worker = null;

function _init_commandParameters() {
  command = Cmd.none;
  expression = [];
  cardinal = 0;
  cardinalSquared = 0;
  height = -1;
  seed = expression;
  distance = 0;
  all = false;
  quiet = false;
  code = false;
  ratings = 0;
  let worker = null;
}

// -- Parser ------------------------------------------------------------------

function parseCommandLine(args) {
  while (args.length) {
    switch (command) {
      case Cmd.none:
        switch (args[0]) {
          case Cmd.help: // help
            command = Cmd.help;
            switch (args[1]) {
              case Cmd.eval:
                helpEval();
                break;
              case Cmd.search:
                helpSearch();
                break;
              default:
                help();
              break;
            }
            args = [];
            break;
          case Cmd.eval: // eval
            command = Cmd.eval;
            if (args.length != 2) { helpEval(); throw Err.cliParsing; }
            if (args[1] == Cmd.help) { // "eval help"
              command = Cmd.help;
              helpEval();
              args = [];
              break;
            }
            expression = args[1];
            args = [];
            break;
          case Cmd.search: // search
            command = Cmd.search;
            args = args.slice(1);
            break;
          default: { help(); throw Err.cliParsing; }
        }
        break;

      case Cmd.search:
        switch (args[0]) {
          case '-n': // height
            if (args.length < 2) { helpSearch(); throw Err.cliParsing; }
            height = parseInt(args[1]);
            if (height < 0) { helpSearch(); throw Err.cliParameters; }
            args = args.slice(2);
            break;
          case '-s': // seed
            if (args.length < 2) { helpSearch(); throw Err.cliParsing; }
            expression = args[1];
            args = args.slice(2);
            break;
          case '-d': // Hamming distance
            if (args.length < 2) { helpSearch(); throw Err.cliParsing; }
            distance = parseInt(args[1]);
            if (distance < 0) { helpSearch(); throw Err.cliParameters; }
            args = args.slice(2);
            break;
          case '-a': // all optimal strategies
            all = true;
            args = args.slice(1);
            break;
          case '-q': // quiet
            quiet = true;
            args = args.slice(1);
            break;
          case '-c': // dump code
            code = true;
            args = args.slice(1);
            break;
          default: { helpSearch(); throw Err.cliParsing; }
        }
        break;

      default: { help(); throw Err.cliParsing; }
    }
  }

  switch (command) {
    case Cmd.help:
      break;

    case Cmd.eval:
      let start = performance.now();
      seed = eval(expression);
      if (typeof seed == 'number') seed = parse(expression);
      else if (typeof seed == 'string') seed = parse(seed);
      if (seed && seed.tikz) { disp(seed.tikz); break; }
      if (!Array.isArray(seed)) { helpEval(); throw Err.eval; }
      show(seed);
      disp("Done in " + Math.trunc(performance.now() - start) + " ms.");
      break;

    case Cmd.search:
      if (height == -1 && expression == "") height = 1;
      if (expression == '') { // if seed not specified, use constant 0
        expression = '"';
        for (let i = 2 ** height; i > 0; --i) expression += '0';
        expression += '"';
      }
      seed = eval(expression);
      if (typeof seed == 'number') seed = parse(expression);
      else if (typeof seed == 'string') seed = parse(seed);
      if (!Array.isArray(seed)) { helpSearch(); throw Err.eval; }
      // Set other command parameters
      cardinal = seed.length;
      cardinalSquared = cardinal * cardinal;
      height = log_2(cardinal);
      if (height < 1 || height > 5) throw Err.heightSearch;
      // Check acceptability of seed (must be in crushed form)
      for (let i = cardinal - 2; i >= 0 ; --i) {
        if (seed[i] < 0 || seed[i] >= height || seed[i] > i
          || seed[cardinal - 1] != 0) throw Err.searchSeed;
      }
      break;

    default: { help(); throw Err.cliParsing; }
  }
}


// == Commodity Functions =====================================================

// -- Converter: digit to expanded digit  -------------------------------------

function d2e(d, height) {
  return 1 << ((height + 1) * d);
}

// -- Converter: expanded digit to digit as string ----------------------------

function e2s(e, height) {
  for (let i = height - 1; i > 0; --i) {
    if (e == (1 << (i * (height + 1)))) return i;
  }
  return 0;
}

// -- Code builder: synthetise e2s() function ---------------------------------

function _code_e2s(height) {
  _____________________________('function e2s(e) {');
  _____________________________('  switch (e) {');
  for (let i = 0; i < height; ++i) {
    ___________________________('    case %: return "%";')
    .r(1 << (i * (height + 1))).r(i);
  }
  _____________________________('  }');
  _____________________________('}');
}

// -- Code builder: synthetise fmt() function ---------------------------------

function _code_fmt(height) {
  const cardinal = 2 ** height;
  let expression = '';
  let already = false;
  _____________________________('function fmt() {');
  for (let i = 0; i < cardinal; ++i) {
    if (!(i % 8)) {
      if (already) {
        if (!(i % 32)) expression += ' + "\\n"';
        else if (!(i % 16)) expression += ' + "--"';
        else expression += ' + "-"';
      }
    }
    if (already) {
      expression += ' + e2s(s' + i + ')';
    } else {
      already = true;
      expression += 'e2s(s' + i + ')';
    }
  }
  _____________________________('  return "\\\"" + % + "\\\"";')
  .r(expression);
  _____________________________('}');
}

// -- Code builder: synthetise hit contribution snippets ----------------------

function _code_hitContribExpanded(tower, choice, height) {
  const cardinal = 2 ** height;
  let single = 0;
  let already = 0;
  let expression = '((';
  for (let t = 0; t < cardinal; ++t) { // for all possible configurations for _my_ tower
      if (!(t & (1 << choice))) continue; // if _your_ choice points to a white hat: no hit
      if (t == tower) {
          single = 1; // count this hit ony once (and add it last)
      } else { // these hits must be counted twice
          if (already) expression += ' + '; else already = 1;
          expression += 's' + t;
      }
  }
  if (!already) expression += '0';
  expression += ') << 1)' // (count these hits twice)
  if (single) expression += ' + s' + tower; // (add "single" hit last, if any)
  return expression;
}

function _code_hitContribInteger(e, tower, choice, height) {
  const cardinal = 2 ** height;
  let single = 0;
  let already = 0;
  // Convert expanded digits to integer
  already = 0;
  expression = '((';
  for (let position = 0; position < height; ++position) {   // for each position...
      if (!(tower & (1 << position))) continue;             // ...where I have a black hat
      if (already) expression += ' + '; else already = 1;
      let shift = position * (height + 1);                  // gather the associated hits
      if (shift) {
        expression += '(' + e + ' >> ' + shift + ')'; 
      } else {
        expression += e; 
      }
  }
  if (!already) expression += '0';
  expression += ') & ' + ((1 << (height + 1)) - 1) + ')';   // discard garbage bits on the left
  return expression;
}

// -- Code builder: synthetise gotcha() function ------------------------------

function _code_gotcha(height, ratings) {
  const cardinal = 2 ** height;
  ___________________________('function gotcha(H) { // H is the current hit score');
  ___________________________('  if (H >= B) { // Check for high score');
  ___________________________('    ++C;');
  ___________________________('    if (H > B) { // New high score, reset counter');
  ___________________________('        B = H;');
  ___________________________('        C = 1;');
  if (all) __________________('    }');
  ___________________________('      S = fmt(); // Remember strategy');
  if (!quiet) {
    _________________________('      msg = S + " w = " + H + "/% ";').r(cardinalSquared);
    _________________________('      const exactRatio = 100 * H / %;').r(cardinalSquared);
    _________________________('      const shortRatio = Math.trunc(100 * exactRatio +0.5) / 100;');
    _________________________('      if (shortRatio == exactRatio) {');
    _________________________('        msg += "=";');
    _________________________('      } else {');
    _________________________('        msg += "~";');
    _________________________('      }');
    _________________________('      msg += " " + shortRatio + "%";');
    _________________________('      disp(msg);');
  }
  if (!all) _________________('    }');
  ___________________________('  }');

  if (distance || !quiet) {
    _________________________('  if(!A) { // Check for alarm');
    _________________________('    A = %;').r(ALARM_TRIGGER);
    if (distance) ___________('    E += A;');
    if (!quiet) {
      _______________________('    ///disp(msg +');
      _______________________('    disp("Progress = -" + (Math.trunc(100*Math.log10(%/p())+0.5)/10) +').r(ratings);
      _______________________('    "dB after " + Math.trunc((performance.now() - start)/1000+0.5) + "s");');
    }
    _________________________('  }');
  }
  ___________________________('}');
}

// -- Code builder: synthetise exploreLevel() function ------------------------

function _code_exploreLevel(tower, height) {
  const cardinal = 2 ** height;
  _____________________________('function x%(H) { // H is the current hit score')
  .r(tower);

  if (tower == cardinal - 1) { // This is the last tower: check for high score

    if (distance || !quiet) {
      // Count down on two possible grounds:
      //
      // - count all ratings performed
      // - send regular alert message
      _________________________('  if (!--A || H >= B) gotcha(H);');
    } else {
      _________________________('  if (H >= B) gotcha(H);');
    }
    ___________________________('}');

  } else { // Explore this level

    let choice = seed[tower];

    // Hamming distance reached?
    if (distance) {
      _________________________('  // Max Hamming distance reached?');
      if (tower == cardinal - 1) {
        _______________________('  if (!D) { gotcha(H); return; }');
      } else {
        _______________________('  if (!D) { x%(H); return; }').r(cardinal - 1);
      }
    }

    // Call the next level
    ___________________________('  x%(H);')
    .r(tower + 1);
    // Compute hit increment due to initial seed choice
    // and remove it from current hit score
    ___________________________('  let e = %;')
    .r(_code_hitContribExpanded(tower, choice, height));
    ___________________________('  H -= %')
    .r(_code_hitContribInteger('e', tower, choice, height));
    if (distance) _____________('  --D; // Increment Hamming distance');

    for (let i = 1; i < height && i <= tower; ++i) {
      ++choice;
      if (choice >= height || choice > tower) choice = 0;
      // Increment hit score due to new choice and call the next level
      _________________________('  s% = %;')
      .r(tower).r(d2e(choice, height));
      _________________________('  e = %;')
      .r(_code_hitContribExpanded(tower, choice, height));
      _________________________('  x%(H + %);')
      .r(tower + 1).r(_code_hitContribInteger('e', tower, choice, height));
    }

    // Restore initial seed digit
    if (distance) _____________('  ++D; // Decrement Hamming distance');
    ___________________________('  s% = %;')
    .r(tower).r(d2e(seed[tower], height));
    ___________________________('}');

  }
}

// -- Code builder: synthetise getProgress() function ------------------------

function _code_progress(height) {
  const cardinal = 2 ** height;
  _____________________________('function p() {');
  _____________________________('  let c = 1;');
  let total = 1;
  let unit = 0; // Unit is the weight of each given digit
  for (tower = cardinal - 2; tower > 0; --tower) {
    if (unit == 0) {
      unit = 1;
    } else {
      if ((tower + 1) < height) {
        unit = unit * (tower + 2);
      } else {
        unit = unit * height;
      }
    }
    ___________________________('  // Contribution of s%;')
    .r(tower);
    ___________________________('  switch (s%) {')
    .r(tower);
    if (tower < height) {
      total += unit * tower;
    } else {
      total += unit * (height - 1);
    }
    for (let choice = seed[tower] + 1, i = 1;
    i < height && i <= tower; ++i, ++choice) {
      if (choice >= height || choice > tower) choice = 0;
      _________________________('    case %: { c += %; break; }')
      .r(d2e(choice, height)).r(unit * i);
    }
    ___________________________('  }')
  }
  _____________________________('  return c;');
  _____________________________('}');
  return total;
}


// == Main entry point ========================================================

function main(abort) {
  try {
  parseCommandLine(args);
  } catch (e) {
    disp('Error: ' + e);
    return;
  }
  if (command != Cmd.search) return;

// Fast track for search: generate optimized code...

// -- Strategy digits --------------------------------------------------------
_______________________________('Environment Abstraction Layer').h2();
_______________________________('');
if (env == Env.d8) {
  _____________________________('let disp = console.log;');
} else {
  _____________________________('function disp(s) { postMessage(s + "\\n"); }');
}

// -- Strategy digits --------------------------------------------------------
_______________________________('Define seed (expanded) digits').h3();
_______________________________('');
for (let i = 0; i < cardinal; ++i) {
  _____________________________('let s% = %;')
  .r(i).r(d2e(seed[i], height)).t(20)
  .a('// 1 << (% * %)')
  .r(height + 1).r(seed[i]);
}
_______________________________('');

// -- Other global variables --------------------------------------------------
_______________________________('Define other global variables').h3();
_______________________________('');
_______________________________('let B = 0; // Best score');
_______________________________('let S = ""; // Best strategy');
_______________________________('let C = 0; // Count of optimal strategies');
if (distance) _________________('let D = %; // Hamming distance allowance').r(distance);
if (distance || !quiet) _______('let A = %; // Periodic alarm trigger').r(ALARM_TRIGGER);
if (distance) _________________('let E = A; // Count of evaluated strategies');
_______________________________('let msg = "";');
_______________________________('');

// -- Rez formatting functions ------------------------------------------------
_______________________________('Define formatting functions').h3();
_______________________________('');
/*_____________________________*/_code_e2s(height);
_______________________________('');
/*_____________________________*/_code_fmt(height);
_______________________________('');

// -- Rez progress reporting functions ----------------------------------------
_______________________________('Define progress reporting functions').h3();
_______________________________('');
ratings = /*___________________*/_code_progress(height);
_______________________________('');

// -- Rez exploration functions -----------------------------------------------
_______________________________('Define strategies exploration functions').h3();
_______________________________('');
/*_____________________________*/_code_gotcha(height, ratings);
_______________________________('');
for (let i = cardinal - 1; i > 0; --i) {
  /*___________________________*/_code_exploreLevel(i, height);
  _____________________________('');
}

// -- Gogogo!... --------------------------------------------------------------
_______________________________('let start = performance.now();')
_______________________________('x1(%);')
.r(_score(seed));
if (distance) {
  _____________________________('let farewell = "Done comparing " + (E - A).toLocaleString();');
} else {
  _____________________________('let farewell = "Done comparing %";').r(ratings.toLocaleString());
}
_______________________________('farewell += " strategie(s) in ";');
_______________________________('let duration = performance.now() - start;');
_______________________________('if (duration < 10000) {');
_______________________________('  farewell += Math.trunc(duration + 0.5)/1000;');
_______________________________('} else {');
_______________________________('  farewell += Math.trunc(duration/1000 + 0.5);');
_______________________________('}');
_______________________________('farewell += "s.";');
_______________________________('disp(farewell);');
_______________________________('farewell = "Best win rate is " + B + "/% ";').r(cardinalSquared);
_______________________________('const exactRatio = 100 * B / %;').r(cardinalSquared);
_______________________________('const shortRatio = Math.trunc(100 * exactRatio +0.5) / 100;');
_______________________________('if (shortRatio == exactRatio) {');
_______________________________('  farewell += "=";');
_______________________________('} else {');
_______________________________('  farewell += "~";');
_______________________________('}');
_______________________________('farewell += " " + shortRatio + "%";');
_______________________________('if (C < 2) farewell += " (" + C + " occurrence).";');
_______________________________('if (C >= 2) farewell += " (" + C + " occurrences).";');
_______________________________('disp(farewell);');
_______________________________('disp("E.g.: " + S);');
if (env != Env.d8) ____________('disp("abort");'); /// FIXME
_______________________________(''); // Flush the _Line buffer


// == Run synthetised code ====================================================

if (code) {
  disp(_script);
} else if (env == Env.d8) {
  // From https://denolib.github.io/v8-docs/d8_8cc_source.html:1361
  worker = new Worker(_script, {type: 'string'});
} else {
  if (worker == null) {
    document.getElementById('submit').style. background = 'LightGray';
    document.getElementById('abort').style. background = 'PaleGreen';
    worker = new Worker(URL.createObjectURL(new Blob( [_script],
    {type:'text/javascript'} )));
    worker.onmessage = function(e) {
      console.log(e);
      if (e.data == "abort\n") {
        hats(true);
      } else {
        document.getElementById("result").innerText += e.data;
      }
    }
  }
}
}


// == _main ===================================================================

// From https://stackoverflow.com/questions/39303787/parse-string-into-command-and-args-in-javascript
function parse_cmdline(cmdline) {
  var re_next_arg = /^\s*((?:(?:"(?:\\.|[^"])*")|(?:'[^']*')|\\.|\S)+)\s*(.*)$/;
  var next_arg = ['', '', cmdline];
  var args = [];
  while (next_arg = re_next_arg.exec(next_arg[2])) {
      var quoted_arg = next_arg[1];
      var unquoted_arg = "";
      while (quoted_arg.length > 0) {
          if (/^"/.test(quoted_arg)) {
              var quoted_part = /^"((?:\\.|[^"])*)"(.*)$/.exec(quoted_arg);
              unquoted_arg += quoted_part[1].replace(/\\(.)/g, "$1");
              quoted_arg = quoted_part[2];
          } else if (/^'/.test(quoted_arg)) {
              var quoted_part = /^'([^']*)'(.*)$/.exec(quoted_arg);
              unquoted_arg += quoted_part[1];
              quoted_arg = quoted_part[2];
          } else if (/^\\/.test(quoted_arg)) {
              unquoted_arg += quoted_arg[1];
              quoted_arg = quoted_arg.substring(2);
          } else {
              unquoted_arg += quoted_arg[0];
              quoted_arg = quoted_arg.substring(1);
          }
      }
      args[args.length] = unquoted_arg;
  }
  return args;
}

function hats(abort) {
  _init_codeBuilder();
  _init_commandParameters()
  switch (env) {
    case Env.chrome:
      if (abort) {
        if (worker != null) {
          worker.terminate();
          worker = null;
          document.getElementById('submit').style. background = 'PaleGreen';
          document.getElementById('abort').style. background = 'LightGray';
        }
        return;
      } else {
        if (worker == null) {
          document.getElementById('result').innerText = '';
          args = parse_cmdline(document.getElementById("query").value);
          main();
        }
      }
      break;
    case Env.d8:
      main();
      break;
    default: throw Err.badEnv;
  }
}

if (env == Env.d8) {
  args = [];
  for (let i = 0; i < arguments.length; ++i) args[i] = arguments[i];
  hats(false);
}

// == The end =================================================================
