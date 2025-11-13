# ================================================================
#  TESTBENCH INDIVIDUAL O COMPLETO - OPCIÓN INTERACTIVA
# ================================================================
test:
	@echo "🔧 Selecciona qué test ejecutar:"
	@echo "  1. Testbench completo (testbench.sv)"
	@echo "  2. Todos los testbenches individuales"
	@read -p "Opción (1 o 2): " opt; \
	if [ $$opt = "1" ]; then \
		make sim-rtl; \
	elif [ $$opt = "2" ]; then \
		make test-all; \
	else \
		echo "❌ Opción inválida"; exit 1; \
	fi

# ================================================================
#  EJECUTAR TODOS LOS TESTBENCHES INDIVIDUALES
# ================================================================
test-all:
	@echo "⚙️ Ejecutando todos los testbenches individuales..."
	@make test-adder
	@make test-alu
	@make test-aludec
	@make test-maindec
	@make test-controller
	@make test-dmem
	@make test-imem
	@make test-extend
	@make test-flopr
	@make test-regfile
	@make test-datapath
	@echo "✅ Todos los testbenches individuales ejecutados correctamente."

# ================================================================
#  TESTBENCHES INDIVIDUALES POR MÓDULO
# ================================================================
test-adder:
	vlog src/adder.sv testbench/adder_tb.sv && vsim -c adder_tb -do "run -all; quit"

test-alu:
	vlog src/alu.sv testbench/alu_tb.sv && vsim -c alu_tb -do "run -all; quit"

test-aludec:
	vlog src/aludec.sv testbench/aludec_tb.sv && vsim -c aludec_tb -do "run -all; quit"

test-maindec:
	vlog src/maindec.sv testbench/maindec_tb.sv && vsim -c maindec_tb -do "run -all; quit"

test-controller:
	vlog src/controller.sv src/maindec.sv src/aludec.sv testbench/controller_tb.sv && vsim -c controller_tb -do "run -all; quit"

test-dmem:
	vlog src/dmem.sv testbench/dmem_tb.sv && vsim -c dmem_tb -do "run -all; quit"

test-imem:
	vlog src/imem.sv testbench/imem_tb.sv && vsim -c imem_tb -do "run -all; quit"

test-extend:
	vlog src/extend.sv testbench/extend_tb.sv && vsim -c extend_tb -do "run -all; quit"

test-flopr:
	vlog src/flopr.sv testbench/flopr_tb.sv && vsim -c flopr_tb -do "run -all; quit"

test-regfile:
	vlog src/regfile.sv testbench/regfile_tb.sv && vsim -c regfile_tb -do "run -all; quit"

test-datapath:
	vlog src/*.sv testbench/datapath_tb.sv && vsim -c datapath_tb -do "run -all; quit"
