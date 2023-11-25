# Directory
PRJ_DIR := $(shell pwd)
RTL_DIR := $(PRJ_DIR)/rtl
TB_DIR  := $(PRJ_DIR)/rtl/tb
SIM_DIR := $(PRJ_DIR)/sim

# RTL
RTL_V		+= $(wildcard $(RTL_DIR)/config/*.*v*)
RTL_V		+= $(wildcard $(RTL_DIR)/utils/*.*v)
RTL_V		+= $(wildcard $(RTL_DIR)/core/*.*v)

# Testbench
TB			?= isa
TB_V  	:= $(wildcard $(TB_DIR)/tb_$(TB).*v)

# Tools
SIM_TOOL  ?= iverilog
ifeq ($(SIM_TOOL), vcs)
SIM_FLAGS := -full64 +v2k -sverilog -kdb -fsdb -ldflags -debug_access+all -LDFLAGS \
						 -Wl,--no-as-needed -Mdir=$(SIM_DIR)/csrc +incdir+rtl/config
else ifeq ($(SIM_TOOL), iverilog)
SIM_FLAGS := -g2005-sv -I rtl/config
endif
WAVE_TOOL ?= gtkwave

all: sim

sim:
	@mkdir -p sim
	$(SIM_TOOL) $(SIM_FLAGS) \
		$(TB_V) $(RTL_V) -o $(SIM_DIR)/simv && $(SIM_DIR)/simv

wave:
	nohup $(WAVE_TOOL) $(SIM_DIR)/wave.vcd > $(SIM_DIR)/wave_nohup &
	
clean:
	rm -rf sim ucli.key
	
.PHONY: all sim wave clean
