.PHONY: all riscv clean mif

FPGA_PROJECT_PATH = ../..
FPGA_PROJECT = picocpu
FPGA_PROJECT_REVISION = picocpu
COMMON_PATH = ../common

all: riscv txt hex

apps = bootloader

ld-script?=bootloader.ld

FLAGS_MARCH ?= rv32im
FLAGS_MABI ?= ilp32

#CROSS_PATH ?=/usr/local/riscv32im/bin
CROSS_PATH ?=/usr/local/riscv32gc/bin
CROSS_COMPILE ?= $(CROSS_PATH)$(if $(CROSS_PATH),/)riscv32-unknown-elf-

CC = $(CROSS_COMPILE)gcc
CFLAGS = -Wa,-march=$(FLAGS_MARCH) -march=$(FLAGS_MARCH) -mabi=${FLAGS_MABI} -mstrict-align -std=gnu99 $(INCLUDE_DIRS) $(C_OPT_FLAGS) -Wall -Werror -Wno-shift-count-overflow

LIBS = -lgcc -lc
LD = $(CC)
LDFLAGS = -march=$(FLAGS_MARCH) -mabi=${FLAGS_MABI} -static -T $(ld-script) -Xlinker -nostdlib -nostartfiles -ffast-math -Wl,--gc-sections -Wl,-Map=$(@:.elf=.map)
OBJDUMP = $(CROSS_COMPILE)objdump -w -x -s -S
OBJCOPY = $(CROSS_COMPILE)objcopy

build_dir ?= build

C_OPT_FLAGS += -O2 -ffast-math -fomit-frame-pointer -fno-exceptions \
               -fno-asynchronous-unwind-tables -fno-unwind-tables \
               -fdata-sections -ffunction-sections -fno-common -fno-builtin-printf

ASM_DEFINES :=
INCLUDE_DIRS += -I.

c_src = uart.c xmodem.c irq.c leds.c bootloader.c
asm_src = start.S

c_objs = $(patsubst %.c, $(build_dir)/%.o, $(c_src))
asm_objs = $(patsubst %.S, $(build_dir)/%.o, $(asm_src))
app_objs = $(c_objs) $(asm_objs)

apps_elf = $(patsubst %, $(build_dir)/%.elf, $(basename $(apps)))
apps_mif = $(patsubst %, $(build_dir)/%.mif, $(basename $(apps)))
apps_txt = $(patsubst %, $(build_dir)/%.txt, $(basename $(apps)))
apps_hex = $(patsubst %, $(build_dir)/%.hex, $(basename $(apps)))

$(apps_elf): $(build_dir)/%.elf: $(build_dir)/%.o $(app_objs)
	@echo "LD\t$@"
	$(LD) $(LDFLAGS) -o $@ $^ $(LIBS)
	$(OBJDUMP) $@ > $(@:.elf=.dump)
	$(OBJCOPY) -Obinary -S $@ $(@:.elf=.bin)

$(build_dir)/%.o: %.c | $(build_dir)
	@echo "CC\t$<"
	@$(CC) $(CFLAGS) $(C_DEFINES) -c $< -o $@

$(build_dir)/%.o: %.S | $(build_dir)
	@echo "AS\t$<"
	@$(CC) $(CFLAGS) $(ASM_DEFINES) -c $< -o $@

$(apps_mif): $(build_dir)/%.mif: $(build_dir)/%.bin
	hexdump -v -e '1/4 "%08x" "\n"' $(@:.mif=.bin) > $(@:.mif=.hex)
	(cd $(build_dir) && ${COMMON_PATH}/bin2mif -4 $(basename $(apps)))

$(apps_txt): $(build_dir)/%.txt: $(build_dir)/%.bin
	hexdump -v -e '"%08x\n"' $< > $@

$(apps_hex): $(build_dir)/%.hex: $(build_dir)/%.txt
	python3 ${COMMON_PATH}/txt2hex.py $< $@ 4
	cp $@ ${FPGA_PROJECT_PATH}/

riscv: $(apps_elf)

mif: $(apps_mif)

txt: $(apps_txt)

hex: $(apps_hex)

$(build_dir):
	mkdir -p $(build_dir)

# update the memory files inside the FPGA bitfile
update-mem:	all
	cd ${FPGA_PROJECT_PATH} && quartus_cdb ${FPGA_PROJECT} -c ${FPGA_PROJECT_REVISION} --update_mif
	cd ${FPGA_PROJECT_PATH} && quartus_asm --read_settings_files=on --write_settings_files=off ${FPGA_PROJECT} -c ${FPGA_PROJECT_REVISION}

# download the bitfile to your board
download:
	cd ${FPGA_PROJECT_PATH} && quartus_pgm -c "Arrow-USB-Blaster [USB0]" -m jtag -o P\;output_files/${FPGA_PROJECT_REVISION}.sof@1

clean:
	rm -rf $(build_dir)
