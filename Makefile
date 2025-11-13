# ================================================================
#  Proyecto 2 - Diseño de Sistemas Digitales
#  Makefile con selección de programa en sim-rtl
# ================================================================

SRC_DIR     := src
TB_DIR      := testbench
OUT_DIR     := sim_output

TB_TOP      := testbench
TOP_MODULE  := top

LIB_PATH    := /workspace/NanGate_15nm_OCL_v0.1_2014_06.A/front_end/timing_power_noise/NLDM
LIB_FILE    := $(LIB_PATH)/NanGate_15nm_OCL_typical_conditional_nldm.lib

help:
	@echo "Available targets:"
	@echo "  make sim-rtl   -> RTL simulation con selección de programa"
	@echo "  make synth     -> Yosys synthesis (NanGate 15nm)"
	@echo "  make sim-gls   -> Gate-level simulation (ModelSim)"
	@echo "  make waves-rtl -> GTKWave RTL"
	@echo "  make waves-gls -> GTKWave GLS"
	@echo "  make clean     -> Clean outputs"

sim-rtl: $(OUT_DIR)
	@echo "🔧 Selecciona el programa:"
	@echo "  1. riscvtest1.txt (Cifrado)"
	@echo "  2. riscvtest2.txt (Ordenamiento)"
	@read -p ' Opción (1 o 2): ' opt; \
	case $$opt in \
	  1) program=$(TB_DIR)/riscvtest1.txt ;; \
	  2) program=$(TB_DIR)/riscvtest2.txt ;; \
	  *) echo ' Opción inválida'; exit 1 ;; \
	esac; \
	echo "🚀 Ejecutando simulación con $$program"; \
	vlib $(OUT_DIR)/work || true; \
	vlog -sv -work $(OUT_DIR)/work $(SRC_DIR)/*.sv $(TB_DIR)/$(TB_TOP).sv; \
	vsim -c -do "vcd file $(OUT_DIR)/dump_rtl.vcd; vcd add -r /*; run -all; quit -f" \
	  -lib $(OUT_DIR)/work $(TB_TOP) +program=$$program

synth: $(OUT_DIR)
	yosys -p "read_verilog -sv $(SRC_DIR)/design.sv; \
	          synth -top $(TOP_MODULE); \
	          dfflibmap -liberty $(LIB_FILE); \
	          abc -liberty $(LIB_FILE); \
	          write_verilog $(OUT_DIR)/$(TOP_MODULE)_netlist.v"

sim-gls: $(OUT_DIR)
	vlib $(OUT_DIR)/work || true
	vlog -sv -work $(OUT_DIR)/work $(OUT_DIR)/$(TOP_MODULE)_netlist.v $(TB_DIR)/$(TB_TOP).sv
	vsim -c -do "vcd file $(OUT_DIR)/dump_gls.vcd; vcd add -r /*; run -all; quit -f" \
		-lib $(OUT_DIR)/work $(TB_TOP)

waves-rtl:
	gtkwave $(OUT_DIR)/dump_rtl.vcd &

waves-gls:
	gtkwave $(OUT_DIR)/dump_gls.vcd &

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

clean:
	rm -rf $(OUT_DIR)
