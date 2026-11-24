# SPDX-FileCopyrightText: 2026 Frederic Ruget <fred@atlant.is> (GitHub: @douzebis)
#
# SPDX-License-Identifier: MIT

# The pictures of "Infinitely Many Hats (3/3)": see README.md.

PICTURES := \
  white-full.webp \
  white-short.webp \
  white-auto.webp \
  carter-full.webp \
  carter-short.webp \
  carter-auto.webp \
  reyes-full.webp \
  reyes-short.webp \
  reyes-auto.webp

# The calculator, run by node the way `d8 hats.js -- ARGS` runs it.
HATS := node -e 'new Function("arguments", require("fs").readFileSync(process.argv[1], "utf8"))(process.argv.slice(2))' ../../../figures/hats/hats.js

all: $(PICTURES)

%.webp: %.latex
	pdflatex -interaction=batchmode -jobname=$* $< && magick -density 300 $*.pdf $@

%.webp: %.tex
	pdflatex -interaction=batchmode $< && magick -density 300 $*.pdf $@

clean:
	rm -f *.tex *.pdf *.aux *.log *.webp

white-full.tex:
	$(HATS) eval 'tikz([W0,W1,W2,W3,W4,W5,W6,emb(T0,7)])' > $@

white-short.tex:
	$(HATS) eval 'tikz([W0,W1,W2,W3,W4,W5,W6,W7])' > $@

carter-full.tex:
	$(HATS) eval 'tikz([C1,C1,C2,C3,C4,C5,C6,C7,C8,emb(T0,9)])' > $@

carter-short.tex:
	$(HATS) eval 'tikz([C1,C1,C2,C3,C4,C5,C6,C7,C8,C9])' > $@

reyes-full.tex:
	$(HATS) eval 'tikz([R1,R1,R1,R1,R2,R2,R2,R3,R3,emb(T0,9)])' > $@

reyes-short.tex:
	$(HATS) eval 'tikz([R1,R1,R1,R1,R2,R2,R2,R3,R3,R3])' > $@

.PHONY: all clean
