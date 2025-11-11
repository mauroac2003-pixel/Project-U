# ============================================================================
# Makefile – Yosys + ModelSim + NanGate 15nm (Timing via OpenSTA)
# ============================================================================

# Carpetas
SRC_DIR    = src
TB_DIR     = testbench
OUT_DIR    = sim_output

# Nombres de módulos
TOP_MODULE = top           # <- tu módulo superior está en design.sv y se llama 'top'
TB_TOP     = testbench     # <- tu testbench principal

# Archivos (no hace falta listarlos manualmente)
SRC_GLOB   = $(SRC_DIR)/*.sv

# Salidas
NETLIST    = $(OUT_DIR)/$(TOP_MODULE)_netlist.v
SDF_FILE   = $(OUT_DIR)/$(TOP_MODULE)_timing.sdf
VCD_RTL    = dump_rtl.vcd
VCD_GLS    = dump_gls.vcd

# Herramientas
YOSYS   = yosys
VLOG    = vlog
VSIM    = vsim -c -do
GTKWAVE = gtkwave
STA     = sta

# NanGate 15nm
NANGATE_15_PATH        ?= /workspace/NanGate_15nm_OCL_v0.1_2014_06.A/front_end
NANGATE_VERILOG_COND   ?= $(NANGATE_15_PATH)/verilog/NanGate_15nm_OCL_conditional.v
NANGATE_LIB            ?= $(NANGATE_15_PATH)/timing_power_noise/NLDM/NanGate_15nm_OCL_typical_conditional_nldm.lib

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
	vlib $(OUT_DIR)/work || true
	$(VLOG) -work $(OUT_DIR)/work $(SRC_GLOB) $(TB_DIR)/$(TB_TOP).sv
	$(VSIM) "vcd file $(OUT_DIR)/$(VCD_RTL); vcd add -r /*; run -all; quit -f" \
		-lib $(OUT_DIR)/work $(TB_TOP)
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
	$(YOSYS) -p "read_verilog -sv $(SRC_GLOB); \
	             synth -top $(TOP_MODULE); \
	             dfflibmap -liberty $(NANGATE_LIB); \
	             abc -liberty $(NANGATE_LIB); \
	             write_verilog $(NETLIST)"
	@echo ""
	@echo "Synthesis complete: $(NETLIST)"
	@echo "=== [TIMING] Running OpenSTA to generate SDF ==="
	$(STA) /workspace/generate_sdf.tcl
	@echo ""
	@echo "Timing extraction complete:"
	@echo "  - Netlist: $(NETLIST)"
	@echo "  - SDF:     $(SDF_FILE)"

# ============================================================================
# Gate-Level Simulation
# ============================================================================
sim-gls:
	@echo "=== [SIM-GLS] Running gate-level simulation (with SDF annotation) ==="
	@if [ ! -f $(NETLIST) ]; then \
		echo "Error: netlist not found. Run 'make synth'."; exit 1; \
	fi
	vlib $(OUT_DIR)/work || true
	$(VLOG) -work $(OUT_DIR)/work $(NETLIST) $(TB_DIR)/$(TB_TOP).sv $(NANGATE_VERILOG_COND)
	$(VSIM) "vcd file $(OUT_DIR)/$(VCD_GLS); vcd add -r /*; \
	         vsim -sdfmax /$(TB_TOP)/dut=$(SDF_FILE); \
	         run -all; quit -f" \
		-lib $(OUT_DIR)/work $(TB_TOP)
	@echo ""; \
	echo "GLS simulation complete. Run 'make waves-gls' to view waveforms."

waves-gls:
	@if [ -f "$(OUT_DIR)/$(VCD_GLS)" ]; then \
		$(GTKWAVE) $(OUT_DIR)/$(VCD_GLS) >/dev/null 2>&1 & \
	else \
		echo "Error: GLS VCD not found."; exit 1; \
	fi

# ============================================================================
# Directorios y limpieza
# ============================================================================
$(OUT_DIR):
	@mkdir -p $(OUT_DIR)

clean:
	@echo "Cleaning generated files..."
	rm -rf $(OUT_DIR)
	@echo "Clean complete."
