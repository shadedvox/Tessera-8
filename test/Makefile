# Tiny Tapeout GF180 Verilog SRAM testbench
SIM ?= icarus
FST ?= -fst
TOPLEVEL_LANG ?= verilog

SRC_DIR = $(abspath ../src)
SRAM_DIR = $(SRC_DIR)/gf180mcu_fd_ip_sram
SRAM_CELLS = \
	gf180mcu_fd_ip_sram__sram64x8m8wm1 \
	gf180mcu_fd_ip_sram__sram128x8m8wm1 \
	gf180mcu_fd_ip_sram__sram256x8m8wm1 \
	gf180mcu_fd_ip_sram__sram512x8m8wm1
SRAM_MODELS = $(foreach cell,$(SRAM_CELLS),$(SRAM_DIR)/cells/$(cell)/$(cell).v)

PROJECT_SOURCES = project.v

ifneq ($(GATES),yes)

# RTL simulation: use the official GF180 functional/timing SRAM models.
SIM_BUILD = sim_build/rtl
VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))

else

# Gate-level simulation: the netlist contains the hardened SRAM macro cell.
SIM_BUILD = sim_build/gl
COMPILE_ARGS += -DGL_TEST
COMPILE_ARGS += -DFUNCTIONAL
COMPILE_ARGS += -DUSE_POWER_PINS
COMPILE_ARGS += -DSIM
COMPILE_ARGS += -DUNIT_DELAY=\#1
VERILOG_SOURCES += $(PDK_ROOT)/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/gf180mcuD/libs.ref/gf180mcu_fd_sc_mcu7t5v0/verilog/gf180mcu_fd_sc_mcu7t5v0.v
VERILOG_SOURCES += $(PWD)/gate_level_netlist.v

endif

# Icarus cannot elaborate the vendor model's bit-specific specify output
# paths (source/destination width mismatch). Leave specify disabled for this
# functional model test; physical timing is checked against the Liberty views
# in the ASIC flow. The 100 ns test clock remains above the model's 55.6 ns
# data-sheet minimum cycle and 25 ns minimum high/low pulse widths.
COMPILE_ARGS += -g2012
COMPILE_ARGS += -I$(SRC_DIR)

# The official model sources are simulation-only; physical views are used by
# LibreLane through src/config.json.
VERILOG_SOURCES += $(SRAM_MODELS)
VERILOG_SOURCES += $(PWD)/tb.v

TOPLEVEL = tb
COCOTB_TEST_MODULES = test

include $(shell cocotb-config --makefiles)/Makefile.sim
