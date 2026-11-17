// SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
//
// SPDX-License-Identifier: MIT

// Check the formulas of the built pages with MathJax, the way a browser
// would find and read them.
//
// usage: node check_math.cjs NODE_MODULES CONFIG.json SITE_DIR
//
// NODE_MODULES holds the mathjax package (and its font package), CONFIG.json
// is the configuration the pages use (data/mathjax.json), SITE_DIR is the
// built site.  A page is checked when it loads MathJax.  Reported: formulas
// that MathJax cannot read, commands it does not know, references to
// labels that no formula of the page defines, \require (the sources must
// stay plain LaTeX), and TeX left in the text outside any formula (a
// formula that the Markdown processor broke before MathJax could see it).

const fs = require("fs");
const path = require("path");

const [modules, configFile, site] = process.argv.slice(2);
if (!site) {
  console.error("usage: check_math.cjs NODE_MODULES CONFIG.json SITE_DIR");
  process.exit(2);
}

// The text of a page as a reader sees it: no scripts, styles or code
// blocks, no tags, entities decoded.
function visibleText(html) {
  return html
    .replace(/<!--[\s\S]*?-->/g, " ")
    .replace(/<(script|style|pre|code)\b[^>]*>[\s\S]*?<\/\1>/gi, " ")
    .replace(/<[^>]*>/g, " ")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&amp;/g, "&");
}

function htmlFiles(dir) {
  const found = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      // The vendored MathJax files are not pages.
      if (!["mathjax", "mathjax-fonts"].includes(entry.name)) {
        found.push(...htmlFiles(full));
      }
    } else if (entry.name.endsWith(".html")) {
      found.push(full);
    }
  }
  return found.sort();
}

async function main() {
  const config = JSON.parse(fs.readFileSync(configFile, "utf8"));
  const errors = [];
  let current = "";
  const tex = {
    ...config.tex,
    // Unknown commands are errors here; in the browser they show in red.
    packages: { "[-]": ["noundefined"] },
    formatError: (jax, error) => {
      errors.push(`${current}: ${error.message}`);
      return jax.formatError(error);
    },
  };
  const MathJax = await require(path.resolve(modules, "mathjax")).init({
    // The entity tables are loaded up front: the pages contain named
    // entities, which MathJax would otherwise try to fetch one by one.
    loader: { load: ["input/tex", "input/mml/entities", "adaptors/liteDOM"] },
    tex,
    startup: { typeset: false },
  });

  let pages = 0;
  let formulas = 0;
  for (const file of htmlFiles(site)) {
    const html = fs.readFileSync(file, "utf8");
    // The page template marks its MathJax settings with this identifier
    // (the minifier may drop the quotes).
    if (!/id=["']?mathjax-config/.test(html)) continue;
    pages += 1;
    MathJax.texReset();
    const page = path.relative(site, file);
    const document = MathJax.startup.getDocument(
      MathJax.startup.adaptor.parse(html, "text/html"),
    );
    document.findMath();
    const referenced = [];
    for (const item of document.math) {
      formulas += 1;
      current = `${page}: ${item.math.replace(/\s+/g, " ").slice(0, 70)}`;
      if (/\\require\b/.test(item.math)) {
        errors.push(`${current}: \\require is not allowed`);
      }
      for (const match of item.math.matchAll(/\\(?:eq)?ref\{([^}]*)\}/g)) {
        referenced.push([match[1], current]);
      }
    }
    current = page;
    // Compiling formula by formula keeps `current` exact in the messages.
    for (const item of document.math) {
      current = `${page}: ${item.math.replace(/\s+/g, " ").slice(0, 70)}`;
      // A formula that needs an extension MathJax has not loaded yet stops
      // with a "retry" request: wait for the load, then read it again.
      for (;;) {
        try {
          item.compile(document);
          break;
        } catch (error) {
          if (!error.retry) throw error;
          await error.retry;
        }
      }
    }
    // What is left of the text once the formulas are taken out must not
    // look like TeX.
    let rest = visibleText(html);
    for (const item of document.math) {
      rest = rest.replace(item.start.delim + item.math + item.end.delim, " ");
    }
    for (const match of rest.matchAll(/\\(?:begin|end)\{[a-zA-Z*]+\}|\$\$/g)) {
      const around = rest
        .slice(Math.max(0, match.index - 30), match.index + 50)
        .replace(/\s+/g, " ");
      errors.push(`${page}: TeX outside any formula: ...${around}...`);
    }
    const labels = document.inputJax[0].parseOptions.tags.allLabels;
    for (const [label, where] of referenced) {
      if (!(label in labels)) {
        errors.push(`${where}: reference to undefined label "${label}"`);
      }
    }
  }

  for (const error of errors) console.error(`math error: ${error}`);
  console.log(
    `check_math: ${pages} pages, ${formulas} formulas, ${errors.length} errors`,
  );
  process.exit(errors.length ? 1 : 0);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
