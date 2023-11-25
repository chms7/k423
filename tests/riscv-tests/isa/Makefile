#=======================================================================
# Makefile for riscv-tests/isa
#-----------------------------------------------------------------------

XLEN := 32

src_dir := .

ifeq ($(XLEN),64)
# include $(src_dir)/rv64ui/Makefrag
# include $(src_dir)/rv64uc/Makefrag
# include $(src_dir)/rv64um/Makefrag
# include $(src_dir)/rv64ua/Makefrag
# include $(src_dir)/rv64uf/Makefrag
# include $(src_dir)/rv64ud/Makefrag
# include $(src_dir)/rv64si/Makefrag
# include $(src_dir)/rv64mi/Makefrag
endif
include $(src_dir)/rv32ui/Makefrag
# include $(src_dir)/rv32uc/Makefrag
# include $(src_dir)/rv32um/Makefrag
# include $(src_dir)/rv32ua/Makefrag
# include $(src_dir)/rv32uf/Makefrag
# include $(src_dir)/rv32ud/Makefrag
# include $(src_dir)/rv32si/Makefrag
# include $(src_dir)/rv32mi/Makefrag

default: all

#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------

RISCV_PREFIX ?= riscv32-unknown-elf-
RISCV_GCC ?= $(RISCV_PREFIX)gcc
RISCV_GCC_OPTS ?= -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles
RISCV_OBJDUMP ?= $(RISCV_PREFIX)objdump --disassemble-all
RISCV_OBJCOPY ?= $(RISCV_PREFIX)objcopy

vpath %.S $(src_dir)

#------------------------------------------------------------
# Build assembly tests

%.dump: % 
	$(RISCV_OBJDUMP) generated/$< > generated/$@
	$(RISCV_OBJCOPY) -O verilog generated/$<   generated/$<.verilog
	$(RISCV_OBJCOPY) -O binary generated/$<   generated/$<.bin

define compile_template

$$($(1)_p_tests): $(1)-p-%: $(1)/%.S
	$$(RISCV_GCC) $(2) $$(RISCV_GCC_OPTS) -I$(src_dir) -T$(src_dir)/link.ld $$< -o generated/$$@
$(1)_tests += $$($(1)_p_tests)

$(1)_tests_dump = $$(addsuffix .dump, $$($(1)_tests))

$(1): $$($(1)_tests_dump)

.PHONY: $(1)

tests += $$($(1)_tests)

endef

#ifeq ($(XLEN),64)
#$(eval $(call compile_template,rv64ui,-march=rv64g -mabi=lp64))
#$(eval $(call compile_template,rv64uc,-march=rv64g -mabi=lp64))
#$(eval $(call compile_template,rv64um,-march=rv64g -mabi=lp64))
#$(eval $(call compile_template,rv64ua,-march=rv64g -mabi=lp64))
#$(eval $(call compile_template,rv64uf,-march=rv64g -mabi=lp64))
#$(eval $(call compile_template,rv64ud,-march=rv64g -mabi=lp64))
#$(eval $(call compile_template,rv64si,-march=rv64g -mabi=lp64))
#$(eval $(call compile_template,rv64mi,-march=rv64g -mabi=lp64))
#endif
$(eval $(call compile_template,rv32ui,-march=rv32i -mabi=ilp32))
#$(eval $(call compile_template,rv32uc,-march=rv32g -mabi=ilp32))
$(eval $(call compile_template,rv32um,-march=rv32im -mabi=ilp32))
#$(eval $(call compile_template,rv32ua,-march=rv32g -mabi=ilp32))
# $(eval $(call compile_template,rv32uf,-march=rv32g -mabi=ilp32f))
#$(eval $(call compile_template,rv32ud,-march=rv32g -mabi=ilp32))
#$(eval $(call compile_template,rv32si,-march=rv32g -mabi=ilp32))
# $(eval $(call compile_template,rv32mi,-march=rv32g -mabi=ilp32f))


tests_verilog = $(addsuffix .verilog, $(tests))
tests_dump = $(addsuffix .dump, $(tests))


#------------------------------------------------------------
# Default

all: $(tests_dump)

clean:
	rm -rf generated/*

