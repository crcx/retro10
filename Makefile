VM = ~/retro
.PHONY: toka tools

default:
	@cd tools && gcc build.c -o build
	@cd tools && ./build fix-image
	@cd toka && ../tools/build toka
	@cd source && ../toka/toka build-retro.toka
	@cd source && ../tools/fix-image retroImage
	@cd source && $(VM) --with stage2.retro >/dev/null
	@mv source/retroImage* .

clean:
	@rm -f retroImage retroImage.map
	@rm -f toka/*.o tools/*.o
	@rm -f tools/build tools/fix-image toka/toka
