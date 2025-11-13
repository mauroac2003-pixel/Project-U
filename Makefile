# Usa Bash como intérprete
SHELL := /bin/bash

# ============
# RUTAS
# ============
SRC_DIR     := src
TB_DIR      := testbench
OUT_DIR     := sim_output
LIB_PATH    := /workspace/NanGate_15nm_OCL_v0.1_2014_06.A/front_end/timing_power_noise/NLDM
LIB_FILE    := $(LIB_PATH)/NanGate_15nm_OCL_typical_conditional_nldm.lib

# ============
# ARCHIVOS Y MÓDULOS
# ============
TOP_MODULE  := top
TB_TOP      := testbench
MODULE_TB   := adder alu aludec controller datapath dmem extend flopr imem maindec mux2 mux3 regfile

# ============
# AYUDA
# ============
help:
	@echo "Opciones disponibles:"
	@echo "  make sim-rtl       -> Simula con testbench completo (selección interactiva)"
	@echo "  make sim-modules   -> Simula todos los módulos individuales secuencialmente"
	@echo "  make synth         -> Síntesis con Yosys (NanGate 15nm)"
	@echo "  make waves-rtl     -> Abre GTKWave con simulación RTL"
	@echo "  make waves-gls     -> Abre GTKWave con simulación Gate-Level"
	@echo "  make clean         -> Elimina archivos de simulación"

# ============
# OPCIÓN INTERACTIVA: SIM-RUN
# ============
sim-rtl:
	@echo "🔧 Selecciona una opción:"
	@echo "  1. Ejecutar testbench completo (testbench.sv)"
	@echo "  2. Ejecutar testbenches de módulos individuales"
	@read -p " Opción (1 o 2): " opt; \
	if [[ $$opt == 1 ]]; then \
		echo "📦 Selecciona el programa a cargar:"; \
		echo "  1. riscvtest1.txt (Cifrado)"; \
		echo "  2. riscvtest2.txt (Ordenamiento)"; \
		read -p " Opción (1 o 2): " progopt; \
		if [[ $$progopt == 1 ]]; then \
			export PROG=$(TB_DIR)/riscvtest1.txt; \
		elif [[ $$progopt == 2 ]]; then \
			export PROG=$(TB_DIR)/riscvtest2.txt; \
		else \
			echo "❌ Opción inválida"; exit 1; \
		fi; \
		echo "🚀 Ejecutando simulación con $$PROG..."; \
		make sim-full PROGRAM=$$PROG; \
	elif [[ $$opt == 2 ]]; then \
		make sim-modules; \
	else \
		echo "❌ Opción inválida"; \
	fi

# ============
# SIMULACIÓN TESTBENCH COMPLETO
# ============
sim-full: $(OUT_DIR)
	@echo "=== [SIM-FULL] Simulación de sistema completo ==="
	vlib $(OUT_DIR)/work || true
	vlog -sv -work $(OUT_DIR)/work $(SRC_DIR)/*.sv $(TB_DIR)/$(TB_TOP).sv
	vsim -c -do "vcd file $(OUT_DIR)/dump_rtl.vcd; vcd add -r /*; run -all; quit -f" \
	     -lib $(OUT_DIR)/work $(TB_TOP) +program=$(PROGRAM)

# ============
# SIMULACIÓN DE MÓDULOS INDIVIDUALES
# ============
sim-modules: $(OUT_DIR)
	@echo "🔬 Ejecutando testbenches de módulos individuales..."
	vlib $(OUT_DIR)/work || true
	@for tb in $(MODULE_TB); do \
		echo "🧪 Simulando $$tb_tb.sv"; \
		vlog -sv -work $(OUT_DIR)/work $(SRC_DIR)/*.sv $(TB_DIR)/$${tb}_tb.sv; \
		vsim -c -do "run -all; quit -f" -lib $(OUT_DIR)/work $${tb}_tb; \
	done

# ============
# SÍNTESIS CON YOSYS
# ============
synth: $(OUT_DIR)
	@echo "=== [SYNTH] Ejecutando síntesis (Yosys + NanGate 15nm) ==="
	yosys -p "read_verilog -sv $(SRC_DIR)/design.sv; \
	          synth -top $(TOP_MODULE); \
	          dfflibmap -liberty $(LIB_FILE); \
	          abc -liberty $(LIB_FILE); \
	          write_verilog $(OUT_DIR)/$(TOP_MODULE)_netlist.v"

# ============
# GATE-LEVEL SIMULATION
# ============
sim-gls: $(OUT_DIR)
	vlib $(OUT_DIR)/work || true
	vlog -sv -work $(OUT_DIR)/work $(OUT_DIR)/$(TOP_MODULE)_netlist.v $(TB_DIR)/$(TB_TOP).sv
	vsim -c -do "vcd file $(OUT_DIR)/dump_gls.vcd; vcd add -r /*; run -all; quit -f" \
	     -lib $(OUT_DIR)/work $(TB_TOP)

# ============
# GTKWave
# ============
waves-rtl:
	gtkwave $(OUT_DIR)/dump_rtl.vcd &

waves-gls:
	gtkwave $(OUT_DIR)/dump_gls.vcd &

# ============
# DIRECTORIOS
# ============
$(OUT_DIR):
	@mkdir -p $(OUT_DIR)

# ============
# LIMPIEZA
# ============
clean:
	@echo "🧹 Limpiando archivos de simulación..."
	rm -rf $(OUT_DIR)
	@echo "✔️  Limpieza completa."
