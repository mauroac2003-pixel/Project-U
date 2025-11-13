# ================================================================
#  Proyecto U - Makefile extendido con menú interactivo
# ================================================================

# Rutas
SRC_DIR     := src
TB_DIR      := testbench
OUT_DIR     := sim_output

# Módulos
TOP_MODULE  := top
TB_TOP      := testbench
LIB_PATH    := /workspace/NanGate_15nm_OCL_v0.1_2014_06.A/front_end/timing_power_noise/NLDM
LIB_FILE    := $(LIB_PATH)/NanGate_15nm_OCL_typical_conditional_nldm.lib

help:
	@echo "🔧 Comandos disponibles:"
	@echo "  make help       -> Mostrar esta ayuda"
	@echo "  make sim-rtl    -> Simulación RTL (menu interactivo)"
	@echo "  make synth      -> Síntesis (Yosys + NanGate 15nm)"
	@echo "  make sim-gls    -> Simulación a nivel de compuerta"
	@echo "  make waves-rtl  -> Ver ondas de RTL en GTKWave"
	@echo "  make waves-gls  -> Ver ondas de GLS en GTKWave"
	@echo "  make clean      -> Borrar archivos generados"

# ================================================================
#  SIMULACIÓN RTL (menu interactivo)
# ================================================================
sim-rtl:
	@echo "🔧 Selecciona una opción:"
	@echo "  1. Ejecutar testbench completo (testbench.sv)"
	@echo "  2. Ejecutar testbenches de módulos individuales"
	@read -p " Opción (1 o 2): " opt; \
	if [ $$opt = "1" ]; then \
		echo "📦 Selecciona el programa de ensamblador a simular:"; \
		echo "  1. riscvtest1.txt (Cifrado)"; \
		echo "  2. riscvtest2.txt (Ordenamiento)"; \
		read -p " Opción (1 o 2): " asm_opt; \
		if [ $$asm_opt = "1" ]; then \
			echo "🚀 Ejecutando simulación con testbench/riscvtest1.txt"; \
			cp testbench/riscvtest1.txt testbench/riscvtest.txt; \
		else \
			echo "🚀 Ejecutando simulación con testbench/riscvtest2.txt"; \
			cp testbench/riscvtest2.txt testbench/riscvtest.txt; \
		fi; \
		vlib $(OUT_DIR)/work || true; \
		vlog -sv -work $(OUT_DIR)/work $(SRC_DIR)/*.sv $(TB_DIR)/$(TB_TOP).sv; \
		vsim -c -do "vcd file $(OUT_DIR)/dump_rtl.vcd; vcd add -r /*; run -all; quit -f" \
			-lib $(OUT_DIR)/work $(TB_TOP); \
	elif [ $$opt = "2" ]; then \
		echo "▶️ Ejecutando testbenches de módulos individuales..."; \
		for tb in $(TB_DIR)/*_tb.sv; do \
			tb_mod=$$(basename $$tb .sv); \
			echo "▶️ Simulando $$tb_mod..."; \
			vlib $(OUT_DIR)/work || true; \
			vlog -sv -work $(OUT_DIR)/work $(SRC_DIR)/*.sv $$tb; \
			vsim -c -do "run -all; quit -f" -lib $(OUT_DIR)/work $$tb_mod || exit $$?; \
		done; \
	else \
		echo "❌ Opción no válida."; \
		exit 1; \
	fi
	@echo "✅ Simulación RTL finalizada."

# ================================================================
#  SÍNTESIS
# ================================================================
synth: $(OUT_DIR)
	@echo "🔧 Ejecutando síntesis con Yosys..."
	yosys -p "read_verilog -sv $(SRC_DIR)/design.sv; \
	          synth -top $(TOP_MODULE); \
	          dfflibmap -liberty $(LIB_FILE); \
	          abc -liberty $(LIB_FILE); \
	          write_verilog $(OUT_DIR)/$(TOP_MODULE)_netlist.v"
	@echo "✅ Síntesis completada."

# ================================================================
#  SIMULACIÓN A NIVEL DE COMPUERTA (GLS)
# ================================================================
sim-gls: $(OUT_DIR)
	@echo "🔧 Simulación a nivel de compuerta (GLS)..."
	vlib $(OUT_DIR)/work || true
	vlog -sv -work $(OUT_DIR)/work $(OUT_DIR)/$(TOP_MODULE)_netlist.v $(TB_DIR)/$(TB_TOP).sv
	vsim -c -do "vcd file $(OUT_DIR)/dump_gls.vcd; vcd add -r /*; run -all; quit -f" \
		-lib $(OUT_DIR)/work $(TB_TOP)
	@echo "✅ Simulación GLS completada."

# ================================================================
#  GTKWave
# ================================================================
waves-rtl:
	gtkwave $(OUT_DIR)/dump_rtl.vcd &

waves-gls:
	gtkwave $(OUT_DIR)/dump_gls.vcd &

# ================================================================
#  OUTPUTS
# ================================================================
$(OUT_DIR):
	@mkdir -p $(OUT_DIR)

clean:
	@echo "🧹 Limpiando archivos generados..."
	rm -rf $(OUT_DIR)
	@echo "✅ Limpieza completada."
