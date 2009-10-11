VM = ~/retro
.PHONY: toka tools

default:
	$(VM) --with source/core.retro --with source/meta.retro >build.log
	$(VM) --with source/stage2.retro >>build.log
	$(VM) --with tools/image2js.retro >js0
	sed '1,10d' js0 | sed '$d' >retroImage.js
	rm -f js0

clean:
	rm -f build.log
