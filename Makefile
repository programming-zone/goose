### Build params

CC_CROSS = i686-elf-gcc
LD_CROSS = i686-elf-ld
GO_CROSS =i686-elf-gccgo
OBJCOPY = i686-elf-objcopy
PREPROC = $(CC_CROSS) -E -x c -P
CC = gcc
LD = ld
ASM = nasm -f elf
CFLAGS_CROSS = -Werror -nostdlib -fno-builtin -nostartfiles -nodefaultlibs
GOFLAGS_CROSS = -static  -Werror -nostdlib -nostartfiles -nodefaultlibs 
INCLUDE_DIRS = -Ipkg/.

### Sources
CORE_SOURCES = 64bit/kernel64.o pkg/loader.o pkg/ptr.go.o pkg/ptr.gox pkg/elf.go.o pkg/elf.gox pkg/page.go.o pkg/page.gox pkg/types.go.o pkg/types.gox pkg/goose.go.o
# Disabled Sources # pkg/color.go.o pkg/color.gox pkg/video.go.o pkg/video.gox pkg/interupts.o pkg/asm.o pkg/asm.go.o pkg/asm.gox pkg/regs.go.o pkg/regs.gox pkg/gdt.go.o pkg/gdt.gox pkg/idt.go.o pkg/idt.gox pkg/pit.go.o pkg/pit.gox pkg/kbd.go.o pkg/kbd.gox 

SOURCE_OBJECTS = $(CORE_SOURCES)
 
### Targets

all: kernel.iso

clean:
	rm -f $(SOURCE_OBJECTS) $(TEST_EXECS) pkg/kernel.bin isodir/boot/kernel.bin kernel.iso
	make -C 64bit clean

boot-nogrub: kernel.bin
	qemu-system-i386 -kernel pkg/kernel.bin -m 1024

boot: kernel.iso
	qemu-system-x86_64 -cdrom kernel.iso

### Rules

pkg/%.o: %.s
	$(ASM) $(INCLUDE_DIRS) -o $@ $<

pkg/%.gox: pkg/%.go.o
	$(OBJCOPY) -j .go_export $< $@

pkg/%.go.o: %.go
	$(GO_CROSS) $(GOFLAGS_CROSS) $(INCLUDE_DIRS) -o $@ -c $<

kernel.bin: $(SOURCE_OBJECTS)
	$(LD_CROSS) -T link.ld -o pkg/kernel.bin $(SOURCE_OBJECTS)
 
kernel.iso: kernel.bin
	cp pkg/kernel.bin isodir/boot/kernel.bin
	grub-mkrescue -o kernel.iso isodir
	
64bit/kernel64.o:
	make -C 64bit kernel64
