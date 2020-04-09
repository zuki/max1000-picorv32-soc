### Syntacore SCR* infra
###
### @copyright (C) Syntacore 2015-2017. All rights reserved.
###
### @brief makefile

.PHONY: app

dst_dir := $(CURDIR)
src_root := $(abspath $(COMMON_BASE))/
apps_dir := ${src_root}../../apps

CROSS_PREFIX ?= $(CROSS_PATH)$(if $(CROSS_PATH),/)riscv32-unknown-elf-
CC = $(CROSS_PREFIX)gcc
LD = $(CC)
OBJDUMP = $(CROSS_PREFIX)objdump
OBJCOPY = $(CROSS_PREFIX)objcopy
SIZE = $(CROSS_PREFIX)size

SYS_CLK ?= 50000000
MARCH ?= rv32im
MABI  ?= ilp32

OPT ?= 2

CRT0 ?= $(COMMON_BASE)/ncrt0.S

ld_script ?= $(COMMON_BASE)/common.ld

build_root ?= $(dst_dir)/build/

ifeq ("$(OPT)","3lto")
OPT_CFLAGS=-O3 -funroll-loops
XLFLAGS=-flto
opt_siffix = .o3lto
endif

ifeq ("$(OPT)","3")
OPT_CFLAGS=-O3
XLFLAGS=
opt_siffix = .o3
endif

ifeq ("$(OPT)","2")
OPT_CFLAGS=-O2
XLFLAGS=
opt_siffix = .o2
endif

ifeq ("$(OPT)","2lto")
OPT_CFLAGS=-O2 -funroll-loops
XLFLAGS=-flto
opt_siffix = .o2lto
endif

ifeq ("$(OPT)","0")
OPT_CFLAGS=-O0
XLFLAGS=
opt_siffix = .o0
endif

ifeq ("$(OPT)","s")
OPT_CFLAGS=-Os
XLFLAGS=
opt_siffix = .os
endif

ifeq ("$(OPT)","g")
OPT_CFLAGS=-Og -g3
XLFLAGS=
opt_siffix = .og
endif

ifeq ("$(opt_siffix)","")
opt_siffix = .$(OPT)
endif

bsp_defs += -DSYS_CLK=$(SYS_CLK)

CFLAGS += $(OPT_CFLAGS) $(XLFLAGS) $(includes) $(bsp_defs)

# use "-mdiv" if possible and is not defined
CFLAG_MDIV ?= $(if $(findstring m,$(MARCH)),-mdiv,)

CFLAGS += -static -march=$(MARCH) -mabi=$(MABI) $(CFLAG_MDIV) -std=gnu99 -mstrict-align -msmall-data-limit=8 -ffunction-sections -fdata-sections -fno-common
LFLAGS += -nostartfiles -nostdlib $(XLFLAGS) -march=$(MARCH) -mabi=$(MABI) -Wl,--gc-sections -lm -lc -lgcc

ifneq ("$(INTERNAL_PRINTF)","")
bsp_c_src += $(COMMON_BASE)/printf.c
includes += -I$(COMMON_BASE)
endif

bsp_c_src += $(COMMON_BASE)/uart.c $(COMMON_BASE)/nlib.c $(COMMON_BASE)/syscalls.c
bsp_asm_src += $(CRT0)

bsp_c_src_rel = $(patsubst $(src_root)%,%,$(abspath $(bsp_c_src)))
bsp_asm_src_rel = $(patsubst $(src_root)%,%,$(abspath $(bsp_asm_src)))
app_src_rel = $(patsubst $(dst_dir)%,%,$(abspath $(APP_SRC)))

bsp_c_objs = $(patsubst %.c,%.o,$(bsp_c_src_rel))
bsp_asm_objs = $(patsubst %.s,%.o,$(patsubst %.S,%.o,$(bsp_asm_src_rel)))

app_c_objs = $(patsubst %.c,%.o,$(filter %.c,$(app_src_rel)))
app_asm_objs = $(patsubst %.s,%.o,$(patsubst %.S,%.o,$(filter %.S %s,$(app_src_rel))))

app_objs = $(addprefix $(build_root), $(bsp_c_objs) $(bsp_asm_objs) $(app_c_objs) $(app_asm_objs))

app_elf = $(build_root)$(APP).elf
app_dump = $(build_root)$(APP).dump

build_dirs_tree= $(patsubst %/,%,$(sort $(dir $(app_objs))))

# #######################
# rules

all: app

app: $(app_elf) $(app_dump)

objs: $(app_objs)

$(app_elf): %.elf: $(abspath $(ld_script)) $(app_objs)
	$(LD) -o $@ -Wl,-Map=$(build_root)$(notdir $(@:.elf=.map)) -T $^ $(LFLAGS)
	$(OBJCOPY) -Obinary -S $@ $(@:.elf=.bin)
	cp $(@:.elf=.bin) ${apps_dir}

%.dump: %.elf
	$(OBJDUMP) -w -x -s -S $< > $@
	$(SIZE) --format=berkeley $^

$(build_root)%.o: $(src_root)%.c
	@mkdir -p $(dir $@)
	$(CC) -c $< -o $@ $(CFLAGS)

$(build_root)%.o: $(dst_dir)%.c
	@mkdir -p $(dir $@)
	$(CC) -c $< -o $@ $(CFLAGS)

$(build_root)%.o: $(src_root)%.S
	@mkdir -p $(dir $@)
	$(CC) -c  $< -o $@ -D__ASSEMBLY__=1 $(CFLAGS)

$(build_root)%.o: $(dst_dir)%.S
	@mkdir -p $(dir $@)
	$(CC) -c  $< -o $@ -D__ASSEMBLY__=1 $(CFLAGS)

$(build_root)%.o: $(src_root)%.s
	@mkdir -p $(dir $@)
	$(CC) -c $< -o $@ -D__ASSEMBLY__=1 $(CFLAGS)

$(build_dirs_tree):
	mkdir -p $@

help:
	@echo "Have you tried turning it off and on again?"

build_tree: $(build_dirs_tree)

debug:
	@echo $(app_src_rel)
	@echo $(bsp_c_src_rel)
	@echo $(src_root)
	@echo $(dst_dir)

clean:
	rm -rf $(app_elf)
	rm -rf $(build_root)
