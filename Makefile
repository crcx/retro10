VM     = ~/retro
CORE   = --with source/core.retro
STAGE2 = --with source/stage2.retro
STAGE3 = --with source/stage3.retro
FINAL  = --with source/final.retro
META   = --with source/meta.retro
STATS  = --opstats build.stats --callstats

default: image errors

image:
	$(VM) $(FINAL) $(STAGE3) $(STAGE2) $(CORE) $(META) >build.log

shrink:
	$(VM) --shrink $(FINAL)

errors:
	cat build.log | grep -v ok

js: image
	$(VM) --with source/extras/canvas.retro --shrink >>build.log
	$(VM) --with tools/image2js.retro >js0
	sed '1,10d' js0 | grep -v ok >retroImage.js
	rm -f js0

midp: image
	$(VM) --with tools/image2midp.retro >js0
	sed '1,10d' js0 | sed s'/ \]/\]/g' | sed 's/ \;/\;/g' | grep -v ok >Img.java
	rm -f js0

stats:
	$(VM) $(FINAL) $(STAGE3) $(STAGE2) $(CORE) $(META) $(STATS) >build.log

clean:
	rm -f build.log retroImage.js Img.java build.stats
