VM = ~/retro

default: image errors

image:
	$(VM) --with source/core.retro --with source/meta.retro >build.log
	$(VM) --with source/stage2.retro >>build.log

errors:
	cat build.log | grep -v ok

js:
	$(VM) --with tools/image2js.retro >js0
	sed '1,10d' js0 | grep -v ok >retroImage.js
	rm -f js0

midp:
	$(VM) --with tools/image2midp.retro >js0
	sed '1,10d' js0 | grep -v ok >Img.java
	rm -f js0

clean:
	rm -f build.log retroImage.js Img.java
