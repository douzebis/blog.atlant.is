# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

"""Check the hats calculator (figures/hats/hats.js) against check_article.py.

usage: check_calculator.py [HATS_JS]

Runs the calculator under Node.js and compares what it computes with the
definitions of check_article.py: the operations on all proper strategies
on one and two hats and some on three, the predefined strategies, and a
few commands as a user types them.
"""

import itertools
import json
import pathlib
import subprocess
import sys
import tempfile

import check_article as ca

# Loads the calculator as the d8 shell would, with the given arguments,
# and prints what it displays; then evaluates expressions in its scope.
HARNESS = """
const fs = require('fs');
const [file, job] = process.argv.slice(1);
const {commands, expressions} = JSON.parse(fs.readFileSync(job, 'utf8'));
const code = fs.readFileSync(file, 'utf8');
const run = (args) => {
  const lines = [];
  const scope = new Function('arguments', 'console',
    code + '; return (e) => eval(e);');
  const evaluate = scope(args, {log: (text) => lines.push(String(text))});
  return {lines, evaluate};
};
const shown = commands.map((args) => run(args).lines);
const {evaluate} = run(['help']);
const values = expressions.map((e) => evaluate(e));
console.log(JSON.stringify({shown, values}));
"""


def literal(s: ca.Strategy) -> str:
    return json.dumps(s)


def main() -> int:
    here = pathlib.Path(__file__).resolve().parent
    default = here.parent.parent / "figures" / "hats" / "hats.js"
    calculator = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else default

    expected: list[tuple[str, ca.Strategy]] = []
    proper = {
        n: [list(s) for s in itertools.product(range(n), repeat=2**n)] for n in (1, 2)
    }
    proper[3] = [
        ca.carter(3),
        ca.low_black(3),
        ca.low_white(3),
        [2, 1, 0, 2, 1, 0, 1, 2],
    ]
    for n, strategies in proper.items():
        for s in strategies:
            x = literal(s)
            expected += [
                (f"ws({x})", ca.white_shift(n, s)),
                (f"bs({x})", ca.black_shift(n, s)),
                (f"ls({x})", ca.white_shift(n, s)),
                (f"rs({x})", ca.black_shift(n, s)),
                (f"ds({x})", ca.double_shift(n, s)),
                (f"sd({x})", ca.sibling_double_shift(n, s)),
                (f"dual({x})", ca.dual(n, s)),
            ]
    for m, n in itertools.product((1, 2, 3), (1, 2)):
        for a, b in itertools.product(proper[m][:4], proper[n][:4]):
            x, y = literal(a), literal(b)
            expected += [
                (f"wr({x},{y})", ca.white_reset(m, n, a, b)),
                (f"br({x},{y})", ca.black_reset(m, n, a, b)),
                (f"lr({x},{y})", ca.white_reset(m, n, a, b)),
                (f"rr({x},{y})", ca.black_reset(m, n, a, b)),
                (f"dr({x},{y})", ca.double_reset(m, n, a, b)),
            ]
    for n in range(1, 10):
        expected.append((f"C{n}", ca.carter(n)))
        # the choice for the stack with no hat to follow does not matter
        expected.append((f"B{n}.slice(1)", ca.low_black(n)[1:]))
        expected.append((f"W{n}.slice(0, -1)", ca.low_white(n)[:-1]))
    for j in (1, 2, 3):
        expected.append((f"R{j}", ca.reyes(j)))
    expected.append(('emb("0100", 3)', ca.strategy("01000100")))

    commands = [
        ["eval", "C3"],
        ["eval", "help"],
        ["help", "eval"],
        ["eval", "Math"],
        ["eval", "sd(C1)"],
    ]
    with tempfile.TemporaryDirectory() as work:
        job = pathlib.Path(work) / "job.json"
        job.write_text(
            json.dumps({"commands": commands, "expressions": [e for e, _ in expected]})
        )
        output = subprocess.run(
            ["node", "-e", HARNESS, str(calculator), str(job)],
            check=True,
            capture_output=True,
            text=True,
        ).stdout
    result = json.loads(output)

    failures = [
        f"{expression}: {word} expected, {got} computed"
        for (expression, word), got in zip(expected, result["values"], strict=True)
        if word != got
    ]
    shown = result["shown"]
    c3 = ca.carter(3)
    first = f'"{ca.word(c3)}" w = {ca.hits(3, c3)}/64 ~ 34.38%'
    if shown[0][0] != first:
        failures.append(f"eval C3 shows {shown[0][0]!r}, not {first!r}")
    if not shown[1][0].startswith("usage: hats eval") or any(
        "Error" in line for line in shown[1]
    ):
        failures.append("eval help does not show the help of eval")
    if shown[1] != shown[2]:
        failures.append("eval help and help eval differ")
    if shown[3][-1] != "Error: The expression is not a strategy":
        failures.append(f"eval Math ends with {shown[3][-1]!r}")
    sibling = ca.sibling_double_shift(1, ca.ONE)
    if not shown[4][0].startswith(f'"{ca.word(sibling)}" w = 22/64'):
        failures.append(f"eval sd(C1) shows {shown[4][0]!r}")

    for failure in failures:
        print(f"FAILED: {failure}")
    print(
        f"check_calculator: {len(expected)} expressions, {len(commands)} commands, "
        f"{len(failures)} failures"
    )
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
