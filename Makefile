VM     = ~/retro
CORE   = --with source/core.retro
STAGE2 = --with source/stage2.retro
EDITOR = --with source/editor.retro
DEBUG  = --with source/debug.retro
CANVAS = --with source/canvas.retro
FINAL  = --with source/final.retro
META   = --with source/meta.retro
STATS  = --opstats build.stats --callstats

default: image errors

image:
	$(VM) $(FINAL) $(CANVAS) $(EDITOR) $(DEBUG) $(STAGE2) $(CORE) $(META) >build.log

shrink:
	$(VM) --shrink $(FINAL)

errors:
	cat build.log | grep -v ok

js: image
	$(VM) --with tools/image2js.retro >js0
	sed '1,10d' js0 | grep -v ok >retroImage.js
	rm -f js0

midp: image
	$(VM) --with tools/image2midp.retro >js0
	sed '1,10d' js0 | sed s'/ \]/\]/g' | sed 's/ \;/\;/g' | grep -v ok >Img.java
	rm -f js0

stats:
	$(VM) $(FINAL) $(CANVAS) $(EDITOR) $(DEBUG) $(STAGE2) $(CORE) $(META) >build.log

clean:
	rm -f build.log retroImage.js Img.java build.stats
