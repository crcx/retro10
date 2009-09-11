.PHONY: image toka tools
VM = ~/retro

default:
	cd tools && gcc build.c -o build
	cd tools && ./build fix-image
	cd toka && ../tools/build toka
	cd image && ../toka/toka build-retro.toka
	cd image && ../tools/fix-image retroImage
	cd image && $(VM) --with stage2.retro
	mv image/retroImage* .

clean:
	rm -f retroImage retroImage.map
	rm -f toka/*.o tools/*.o
	rm -f tools/build tools/fix-image toka/toka
