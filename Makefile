# Makefile - Simulación RTL con menú interactivo

# Directorios
SRC_DIR = src
TB_DIR = testbench
BUILD_DIR = sim_output
LIB_DIR = $(BUILD_DIR)/work

# Archivos de origen
SRC_FILES = $(wildcard $(SRC_DIR)/*.sv)
RTL_TB = $(TB_DIR)/testbench.sv

# Lista de testbenches individuales
MODULE_TB_LIST := adder_tb alu_tb aludec_tb controller_tb datapath_tb \
                  dmem_tb extend_tb flopr_tb imem_tb maindec_tb mux2_tb \
                  mux3_tb regfile_tb

# Comando para simular
VSIM = vsim -c -do "run -all; quit -f"

# Crear biblioteca si no existe
$(LIB_DIR):
	@vlib $(LIB_DIR)

.PHONY: help sim-rtl sim-modules clean

help:
	@echo "Opciones disponibles:"
	@echo "  make sim-rtl       -> Simula con testbench completo (selección interactiva)"
	@echo "  make sim-modules   -> Simula todos los módulos individuales secuencialmente"
	@echo "  make clean         -> Elimina archivos de simulación"

sim-rtl: $(LIB_DIR)
	@echo "🔧 Selecciona una opción:"
	@echo "  1. Ejecutar testbench completo (testbench.sv)"
	@echo "  2. Ejecutar testbenches de módulos individuales"
	@read -p " Opción (1 o 2): " opt; \
	if [ $$opt = "1" ]; then \
		echo "📂 Programas disponibles:"; \
		select file in $(wildcard testbench/*.txt); do \
			echo "▶️ Ejecutando testbench completo con $$file"; \
			vlog -sv -work $(LIB_DIR) $(SRC_FILES) $(RTL_TB); \
			$(VSIM) -lib $(LIB_DIR) testbench +program=$$file; \
			break; \
		done; \
	elif [ $$opt = "2" ]; then \
		$(MAKE) sim-modules; \
	else \
		echo "❌ Opción inválida."; \
	fi

sim-modules: $(LIB_DIR)
	@echo "▶️ Ejecutando testbenches de módulos individuales..."
	@for tb in $(MODULE_TB_LIST); do \
		echo "▶️ Simulando $$tb..."; \
		vlog -sv -work $(LIB_DIR) $(SRC_FILES) $(TB_DIR)/$$tb.sv; \
		if [ "$$tb" = "imem_tb" ]; then \
			$(VSIM) -lib $(LIB_DIR) $$tb +program=testbench/dummy.txt; \
		else \
			$(VSIM) -lib $(LIB_DIR) $$tb; \
		fi \
	done
	@echo "✅ Simulación RTL finalizada."

clean:
	@rm -rf $(BUILD_DIR)
	@echo "🧹 Limpieza completada."
