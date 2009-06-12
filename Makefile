# .----,   .-----  -------  .----,    ,---,
# |     \  |          |     |     \  |     |
# |-----/  |---       |     |-----/  |     |
# |  \     |          |     |  \     |     |
# |   \    |          |     |   \    |     |
# |    \   `-----     |     |    \    `---'
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Written by Charles Childers
# This code is gifted to the public domain.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
.PHONY: vm image toka tools


default:
	@clear
	@echo Try one of the following:
	@echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	@echo make vm
	@echo - Compile the VM \(console version\)
	@echo
	@echo make fastvm
	@echo - Compile the VM \(console version, Mat\'s implementation\)
	@echo
	@echo make fbvm
	@echo - Build the VM \(with framebuffer\)
	@echo
	@echo make dotnet
	@echo - Build the VM \(For .NET, requires Mono\)
	@echo
	@echo make java
	@echo - Build the VM \(for Java, requires JDK\)
	@echo
	@echo make image
	@echo - Rebuild the initial retroImage. Only needed if you customize
	@echo \ \ the original image.
	@echo
	@echo make clean
	@echo - Remove temporary files, binaries
	@echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
tools:
	@cd tools && make
toka: tools
	@cd toka && make
image: tools toka
	@cd image && make
	@mv image/retroImage* bin
clean:
	@rm -f bin/retro
	@rm -f bin/retro-fast
	@rm -f bin/retro-nocurses
	@rm -f bin/retro-fb
	@rm -f bin/retroImage.map
	@rm -f bin/retroImage
	@rm -f bin/retro.class
	@rm -f bin/retro.exe
	@rm -f toka/toka
	@rm -f latest.tar.gz
	@rm -f tools/fix-image
	@rm -rf tools/build
	@cd vm/console && make clean
	@cd vm/console_fast && make clean
	@cd vm/framebuffer && make clean
	@cd vm/java && make clean
	@cd vm/dotnet && make clean
	@cd toka && make clean
	@cd doc && make clean
vm: tools
	@cd vm/console && make
	@mv vm/console/retro bin
	@mv vm/console/retro-nocurses bin
fastvm: tools
	@cd vm/console_fast && make
	@mv vm/console_fast/retro-fast bin
fbvm:
	@cd vm/framebuffer && make
	@mv vm/framebuffer/retro-fb bin
dotnet:
	@cd vm/dotnet && make
	@mv vm/dotnet/retro.exe bin
java:
	@cd vm/java && make
	@mv vm/java/retro.class bin
dist:
	@git archive master | gzip -9 >latest.tar.gz
	@mkdir retro-10.latest
	@cd retro-10.latest && tar xvf ../latest.tar.gz
	@rm -r latest.tar.gz
	@tar cf latest.tar retro-10.latest
	@gzip -9 latest.tar
	@rm -rf retro-10.latest
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
