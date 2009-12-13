VM = ~/retro

default: image errors

image: core stage2 stage3

core:
	$(VM) --with source/core.retro --with source/meta.retro >build.log

stage2:
	$(VM) --with source/stage2.retro >>build.log

stage3:
	$(VM) --with source/stage3.retro >>build.log

errors:
	cat build.log | grep -v ok

js: image
	$(VM) --with source/extras/canvas.retro --shrink >>build.log
	$(VM) --with tools/image2js.retro >js0
	sed '1,10d' js0 | grep -v ok >retroImage.js
	rm -f js0

midp:
	$(VM) --with tools/image2midp.retro >js0
	sed '1,10d' js0 | sed s'/ \]/\]/g' | sed 's/ \;/\;/g' | grep -v ok >Img.java
	rm -f js0

clean:
	rm -f build.log retroImage.js Img.java
