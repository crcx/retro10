VM = ~/retro
.PHONY: toka tools

default:
	$(VM) --with source/core.retro --with source/meta.retro >build.log
	$(VM) --with source/stage2.retro >>build.log

clean:
	rm -f build.log
