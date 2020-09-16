PNGS:=loyd.png initial-phy.png initial-s18.png gamma3down-phy.png gamma3down-s18.png gamma3down.png

%.png: %.drawio
	/Applications/draw.io.app/Contents/MacOS/draw.io -x --crop -t -e -o $@ $<

all: $(PNGS)
