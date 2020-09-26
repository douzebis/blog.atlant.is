PNGS:= \
  white-full.webp \
  white-short.webp \
  white-auto.webp \
  carter-full.webp \
  carter-short.webp \
  carter-auto.webp \
  reyes-full.webp \
  reyes-short.webp \
  reyes-auto.webp \
  infinite-alpha.webp

%.webp: %.png
	convert $< $@ 

%.webp: %.latex
	pdflatex $< && convert -density 300 $*.pdf $@ 

%.webp: %.tex
	pdflatex $< && convert -density 300 $*.pdf $@ 

all: $(PNGS)

clean:
	rm -f  *.tex *.pdf *.aux *.log *.webp

white-full.tex:
	d8 ../../hats/hats.js -- eval 'tikz([W0,W1,W2,W3,W4,W5,W6,emb(T0,7)])' > $@

white-short.tex:
	d8 ../../hats/hats.js -- eval 'tikz([W0,W1,W2,W3,W4,W5,W6,W7])' > $@

carter-full.tex:
	d8 ../../hats/hats.js -- eval 'tikz([C1,C1,C2,C3,C4,C5,C6,C7,C8,emb(T0,9)])' > $@

carter-short.tex:
	d8 ../../hats/hats.js -- eval 'tikz([C1,C1,C2,C3,C4,C5,C6,C7,C8,C9])' > $@

reyes-full.tex:
	d8 ../../hats/hats.js -- eval 'tikz([R1,R1,R1,R1,R2,R2,R2,R3,R3,emb(T0,9)])' > $@

reyes-short.tex:
	d8 ../../hats/hats.js -- eval 'tikz([R1,R1,R1,R1,R2,R2,R2,R3,R3,R3])' > $@
