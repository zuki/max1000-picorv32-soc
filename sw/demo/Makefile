RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX = /usr/local/riscv32im
#RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX = /usr/local/riscv32gc

SHELL = bash

FPGA_PROJECT_PATH = ../../
FPGA_PROJECT = picocpu
FPGA_PROJECT_REVISION = picocpu


FIRMWARE_OBJS = start.o main.o irq.o print.o


GCC_WARNS  = -Wall
TOOLCHAIN_PREFIX = $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)/bin/riscv32-unknown-elf-

firmware.hex: firmware.coe
	./coe2hex
	cp firmware.hex ${FPGA_PROJECT_PATH}

firmware.coe: firmware.bin
	./bin2coe.py 32 < firmware.bin > firmware.coe

firmware.bin: firmware.elf
	$(TOOLCHAIN_PREFIX)objcopy -O binary $< $@

firmware.elf: $(FIRMWARE_OBJS) sections.lds
	$(TOOLCHAIN_PREFIX)gcc  -g -ffreestanding -nostdlib -o $@ \
		-Wl,-Bstatic,-T,sections.lds,-Map,firmware.map,--strip-debug \
		$(FIRMWARE_OBJS) -lgcc

start.o: start.S
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32im -o $@ $<

raw_logo.o: raw_logo.S
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32im -o $@ $<

%.o: %.c
	$(TOOLCHAIN_PREFIX)gcc -c -march=rv32im  --std=c99 $(GCC_WARNS) -ffreestanding -nostdlib -o $@ $<

clean:
	rm -vrf $(FIRMWARE_OBJS) firmware.elf firmware.bin firmware.hex firmware.map

asm:
	$(TOOLCHAIN_PREFIX)objdump -d firmware.elf | less
.PHONY:  clean asm

# update the memory files inside the FPGA bitfile
update-mem:	firmware.hex
	cd ${FPGA_PROJECT_PATH} && quartus_cdb ${FPGA_PROJECT} -c ${FPGA_PROJECT_REVISION} --update_mif
	cd ${FPGA_PROJECT_PATH} && quartus_asm --read_settings_files=on --write_settings_files=off ${FPGA_PROJECT} -c ${FPGA_PROJECT_REVISION}

# download the bitfile to your board
download:
	cd ${FPGA_PROJECT_PATH} && quartus_pgm -c "Arrow-USB-Blaster [USB0]" -m jtag -o P\;output_files/${FPGA_PROJECT_REVISION}.sof@1
