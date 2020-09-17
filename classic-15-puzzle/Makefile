PNGS:= \
  fifteen-dc3.png \
  fifteen-phy-1.png \
  fifteen-s18-1.png \
  fifteen-types.png \
  fifteen-loyd.png \
  fifteen-phy-2.png \
  fifteen-s18-2.png

%.png: %.drawio
	/Applications/draw.io.app/Contents/MacOS/draw.io -x --crop -t -e -o $@ $<

all: $(PNGS)
