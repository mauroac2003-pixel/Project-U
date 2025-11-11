# ================================================================
#  Proyecto 2 - Diseño de Sistemas Digitales
#  Makefile corregido para simulación y síntesis (NanGate 15nm)
# ================================================================

# Directorios principales
SRC_DIR     := src
TB_DIR      := testbench
OUT_DIR     := sim_output

# Archivos principales
TB_TOP      := testbench
TOP_MODULE  := top

# Librería NanGate 15nm
LIB_PATH    := /workspace/NanGate_15nm_OCL_v0.1_2014_06.A/front_end/timing_power_noise/NLDM
LIB_FILE    := $(LIB_PATH)/NanGate_15nm_OCL_typical_conditional_nldm.lib

help:
	@echo "Available targets:"
	@echo "  make sim-rtl   -> RTL simulation (functional)"
	@echo "  make synth     -> Synthesis + OpenSTA timing (.sdf)"
	@echo "  make sim-gls   -> Gate-level simulation (with SDF)"
	@echo "  make waves-rtl -> Open GTKWave for RTL"
	@echo "  make waves-gls -> Open GTKWave for GLS"
	@echo "  make clean     -> Clean outputs"

# ================================================================
#  SIMULACIÓN RTL (ModelSim)
# ================================================================
sim-rtl: $(OUT_DIR)
	@echo "=== [SIM-RTL] Running RTL simulation (ModelSim) ==="
	vlib $(OUT_DIR)/work || true
	vlog -sv -work $(OUT_DIR)/work $(SRC_DIR)/*.sv $(TB_DIR)/$(TB_TOP).sv
	vsim -c -do "vcd file $(OUT_DIR)/dump_rtl.vcd; vcd add -r /*; run -all; quit -f" \
		-lib $(OUT_DIR)/work $(TB_TOP)
	@echo ""
	@echo "RTL simulation complete. Run 'make waves-rtl' to view waveforms."

# ================================================================
#  SÍNTESIS (Yosys + NanGate 15nm)
# ================================================================
synth: $(OUT_DIR)
	@echo "=== [SYNTH] Running Yosys synthesis (NanGate 15nm) ==="
	yosys -p "read_verilog -sv $(SRC_DIR)/design.sv; \
	          synth -top $(TOP_MODULE); \
	          dfflibmap -liberty $(LIB_FILE); \
	          abc -liberty $(LIB_FILE); \
	          write_verilog $(OUT_DIR)/$(TOP_MODULE)_netlist.v"

# ================================================================
#  SIMULACIÓN GATE‑LEVEL (ModelSim)
# ================================================================
sim-gls: $(OUT_DIR)
	@echo "=== [SIM-GLS] Running Gate-Level Simulation (ModelSim) ==="
	vlib $(OUT_DIR)/work || true
	vlog -sv -work $(OUT_DIR)/work $(OUT_DIR)/$(TOP_MODULE)_netlist.v $(TB_DIR)/$(TB_TOP).sv
	vsim -c -do "vcd file $(OUT_DIR)/dump_gls.vcd; vcd add -r /*; run -all; quit -f" \
		-lib $(OUT_DIR)/work $(TB_TOP)
	@echo ""
	@echo "GLS simulation complete. Run 'make waves-gls' to view waveforms."

# ================================================================
#  VISUALIZACIÓN DE WAVES (GTKWave)
# ================================================================
waves-rtl:
	@echo "=== [WAVES-RTL] Opening GTKWave ==="
	gtkwave $(OUT_DIR)/dump_rtl.vcd &

waves-gls:
	@echo "=== [WAVES-GLS] Opening GTKWave ==="
	gtkwave $(OUT_DIR)/dump_gls.vcd &

# ================================================================
#  CREACIÓN Y LIMPIEZA DE DIRECTORIOS
# ================================================================
$(OUT_DIR):
	@mkdir -p $(OUT_DIR)

clean:
	@echo "Cleaning generated files..."
	rm -rf $(OUT_DIR)
	@echo "Clean complete."
