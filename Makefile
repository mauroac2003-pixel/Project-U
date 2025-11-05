# ============================================================================
# Makefile – Yosys + ModelSim + NanGate 15nm (Timing via OpenSTA)
# ============================================================================

SRC_DIR   = src
TB_DIR    = testbench
OUT_DIR   = sim_output
TOP_MODULE = counter

# Verilog sources
SRC_FILES = counter.v

# Testbenches
TB_RTL    = tb_counter_rtl.v
TB_GLS    = tb_counter_gls.v

# Output files
VCD_RTL   = dump_rtl.vcd
VCD_GLS   = dump_gls.vcd
SDF_FILE  = $(OUT_DIR)/$(TOP_MODULE)_timing.sdf

# Tools
YOSYS   = yosys
VLOG    = vlog
VSIM    = vsim -c -do
GTKWAVE = gtkwave
STA     = sta

# NanGate 15nm library paths
NANGATE_15_PATH ?= /workspace/NanGate_15nm_OCL_v0.1_2014_06.A/front_end
NANGATE_VERILOG_COND ?= $(NANGATE_15_PATH)/verilog/NanGate_15nm_OCL_conditional.v
NANGATE_LIB ?= $(NANGATE_15_PATH)/timing_power_noise/NLDM/NanGate_15nm_OCL_typical_conditional_nldm.lib

# ============================================================================
.PHONY: help sim-rtl waves-rtl synth sim-gls waves-gls clean

help:
	@echo "Available targets:"
	@echo "  make sim-rtl   -> RTL simulation (functional)"
	@echo "  make synth     -> Synthesis + OpenSTA timing (.sdf)"
	@echo "  make sim-gls   -> Gate-level simulation (with SDF)"
	@echo "  make waves-rtl -> Open GTKWave for RTL"
	@echo "  make waves-gls -> Open GTKWave for GLS"
	@echo "  make clean     -> Clean outputs"

# ============================================================================
# RTL Simulation
# ============================================================================
sim-rtl: $(OUT_DIR)
	@echo "=== [SIM-RTL] Running RTL simulation (ModelSim) ==="
	vlib $(OUT_DIR)/work
	vlog -work $(OUT_DIR)/work $(addprefix $(SRC_DIR)/,$(SRC_FILES)) $(TB_DIR)/$(TB_RTL)
	vsim -c -do "vcd file $(OUT_DIR)/$(VCD_RTL); vcd add -r /*; run -all; quit -f" \
		-lib $(OUT_DIR)/work tb_counter_rtl
	@echo ""
	@echo "RTL simulation complete. Run 'make waves-rtl' to view waveforms."

waves-rtl:
	@if [ -f "$(OUT_DIR)/$(VCD_RTL)" ]; then \
		$(GTKWAVE) $(OUT_DIR)/$(VCD_RTL) >/dev/null 2>&1 & \
	else \
		echo "Error: RTL VCD not found."; exit 1; \
	fi

# ============================================================================
# Synthesis
# ============================================================================
synth: $(OUT_DIR)
	@echo "=== [SYNTH] Running Yosys synthesis (NanGate 15nm) ==="
	$(YOSYS) -p "read_verilog $(addprefix $(SRC_DIR)/,$(SRC_FILES)); \
	             synth -top $(TOP_MODULE); \
	             dfflibmap -liberty $(NANGATE_LIB); \
	             abc -liberty $(NANGATE_LIB); \
	             write_verilog $(OUT_DIR)/$(TOP_MODULE)_netlist.v"
	@echo ""
	@echo "Synthesis complete: $(OUT_DIR)/$(TOP_MODULE)_netlist.v"
	@echo "=== [TIMING] Running OpenSTA to generate SDF ==="
	$(STA) /workspace/generate_sdf.tcl
	@echo ""
	@echo "Timing extraction complete:"
	@echo "  - Netlist: $(OUT_DIR)/$(TOP_MODULE)_netlist.v"
	@echo "  - SDF:     $(SDF_FILE)"

# ============================================================================
# Gate-Level Simulation
# ============================================================================
sim-gls:
	@echo "=== [SIM-GLS] Running gate-level simulation (with SDF annotation) ==="
	@NETLIST=$(OUT_DIR)/$(TOP_MODULE)_netlist.v; \
	if [ ! -f $$NETLIST ]; then \
		echo "Error: netlist not found. Run 'make synth'."; exit 1; \
	fi; \
	vlib $(OUT_DIR)/work; \
	vlog -work $(OUT_DIR)/work $$NETLIST $(TB_DIR)/$(TB_GLS) $(NANGATE_VERILOG_COND); \
	vsim -c -do "vcd file $(OUT_DIR)/$(VCD_GLS); vcd add -r /*; \
	             vsim -sdfmax /tb_counter_gls/dut=$(SDF_FILE); \
	             run -all; quit -f" \
		-lib $(OUT_DIR)/work tb_counter_gls; \
	echo ""; \
	echo "GLS simulation complete. Run 'make waves-gls' to view waveforms."

waves-gls:
	@if [ -f "$(OUT_DIR)/$(VCD_GLS)" ]; then \
		$(GTKWAVE) $(OUT_DIR)/$(VCD_GLS) >/dev/null 2>&1 & \
	else \
		echo "Error: GLS VCD not found."; exit 1; \
	fi

# ============================================================================
# Directory management and cleanup
# ============================================================================
$(OUT_DIR):
	@mkdir -p $(OUT_DIR)

clean:
	@echo "Cleaning generated files..."
	rm -rf $(OUT_DIR)
	@echo "Clean complete."
