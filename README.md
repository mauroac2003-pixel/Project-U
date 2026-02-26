# Investigación Teórica  
## Taller de Diseño Digital – EL3313  

**Estudiantes:**  
- Navarro Acuña Mauro  
- Arce Cruz Josué  
- Arguedas Guzmán Gabriel  

**Profesor:** Luis G. León-Vega Ph.D  

---

# 1. Descripción de hardware usando lenguajes de descripción de hardware (HDL), particularmente Verilog

Un Hardware Description Language (HDL) es un lenguaje formal utilizado para modelar, describir y sintetizar hardware digital. A diferencia de los lenguajes de programación tradicionales, un HDL no describe instrucciones que se ejecutan secuencialmente, sino la estructura y el comportamiento de un circuito electrónico.

Verilog, estandarizado por el IEEE (IEEE Std 1364-2005), permite describir:

- Conexiones físicas (`wire`)
- Lógica combinacional
- Lógica secuencial (flip-flops y registros)
- Arquitecturas jerárquicas mediante módulos

En una FPGA, el código Verilog se sintetiza en recursos físicos como:

- LUTs (Look-Up Tables)
- Flip-flops
- Bloques DSP
- Memorias internas (Block RAM)

Ejemplo:

```verilog
module and2(
    input wire a,
    input wire b,
    output wire y
);
assign y = a & b;
endmodule
```

Este módulo describe una compuerta AND que será implementada físicamente dentro de una LUT durante el proceso de síntesis.

Es importante comprender que el HDL no se ejecuta como un programa tradicional; el sintetizador traduce la descripción a hardware real.

**Fuentes:**  
IEEE Std 1364-2005 – Verilog Hardware Description Language  
AMD/Xilinx Vivado Design Suite User Guide: Synthesis (UG901)

---

# 2. Descripción de circuitos combinacionales usando bloques procedurales y asignación bloqueante

Un circuito combinacional es aquel cuya salida depende únicamente de las entradas actuales, sin memoria ni reloj.

Puede describirse en Verilog mediante:

## a) Asignación continua

```verilog
assign y = (a & b) | c;
```

Características:

- Se usa con señales tipo `wire`
- Es concurrente
- Modela directamente una ecuación booleana

## b) Bloque procedural combinacional

```verilog
always @(*) begin
    y = (a & b) | c;
end
```

Aquí se utiliza asignación bloqueante (`=`). En lógica combinacional:

- Se recomienda usar `always @(*)`
- Se deben cubrir todos los caminos lógicos
- Es buena práctica definir valores por defecto

Si no se asigna un valor en todos los caminos posibles, el sintetizador puede inferir un latch, lo cual introduce memoria no deseada.

La diferencia principal entre `assign` y `always` es que `assign` describe directamente una función lógica, mientras que `always` permite describir estructuras más complejas usando `if`, `case` u otras construcciones de control.

**Fuentes:**  
IEEE Std 1364-2005  
AMD/Xilinx Vivado Design Suite User Guide: Synthesis (UG901)

---

# 3. Flujo de síntesis en FPGA

El flujo de diseño típico en Vivado consta de las siguientes etapas:

## 1. Elaboración
Se analiza el código HDL y se construye una representación RTL (Register Transfer Level).

## 2. Síntesis
Convierte la descripción RTL en una red optimizada de recursos físicos:

- LUTs
- Flip-flops
- Bloques DSP
- Block RAM

## 3. Implementación
Incluye:

- Mapping: asignación a recursos físicos específicos.
- Placement: ubicación física dentro del chip.
- Routing: interconexión de los recursos.

## 4. Generación de Bitstream
Se genera el archivo `.bit`, que contiene la configuración necesaria para programar la FPGA.

Este flujo transforma la descripción en HDL en una configuración física funcional.

**Fuentes:**  
AMD/Xilinx Vivado Design Suite User Guide: Synthesis (UG901)  
AMD/Xilinx Vivado Design Suite User Guide: Implementation (UG904)

---

# 4. Uso de archivos de restricciones (constraints)

Los archivos de restricciones (.xdc en Vivado) permiten especificar cómo el diseño lógico se conecta físicamente al dispositivo FPGA.

Se utilizan para:

- Asignar pines físicos
- Definir estándares eléctricos (por ejemplo LVCMOS33)
- Establecer frecuencia del reloj
- Definir restricciones de temporización (timing)

Ejemplo:

```tcl
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.0 [get_ports clk]
```

Sin constraints, el diseño no puede interactuar correctamente con el hardware físico ni realizar análisis de temporización adecuados.

**Fuente:**  
AMD/Xilinx Vivado Design Suite User Guide: Using Constraints (UG903)

---

# 5. Proceso y tipos de configuración de FPGA: programación de la FPGA y de la memoria no volátil

La Nexys A7 utiliza una FPGA Artix-7 basada en tecnología SRAM. Esto implica que:

- Pierde su configuración cuando se apaga.
- Debe cargarse con un bitstream en cada encendido.

Existen dos métodos principales de configuración:

## a) Programación por JTAG

- Se realiza directamente desde Vivado.
- Es temporal.
- Se pierde al apagar la tarjeta.

## b) Programación de memoria no volátil (Flash SPI)

- Se programa una memoria externa.
- La FPGA se configura automáticamente al encender.
- Permite funcionamiento autónomo sin conexión al PC.

El archivo utilizado para la configuración es el bitstream (.bit).

**Fuente:**  
AMD/Xilinx 7 Series FPGAs Configuration User Guide (UG470)

---

# 6. Concepto de módulo e IP Core

## Módulo

Un módulo es la unidad básica de diseño en Verilog. Permite:

- Encapsular funcionalidad
- Crear jerarquía
- Facilitar reutilización
- Mejorar organización del diseño

Por ejemplo, en una calculadora digital se puede tener un módulo principal que instancie submódulos como:

- Sumador
- Restador
- Multiplicador
- Decodificador de 7 segmentos

Esto permite dividir el sistema en bloques más pequeños y manejables.

## IP Core

Un IP Core (Intellectual Property Core) es un bloque funcional pre-diseñado, verificado y optimizado que puede integrarse dentro de un diseño digital.

Puede clasificarse como:

- Soft IP: descrito en HDL.
- Hard IP: bloque físico dedicado dentro del chip (por ejemplo PLL, controlador DDR o bloques DSP especializados).

Un diseño propio en Verilog no se considera un IP Core comercial a menos que esté formalmente empaquetado, documentado y preparado para reutilización estandarizada.

**Fuente:**  
AMD/Xilinx Vivado Design Suite User Guide: Designing with IP (UG896)

---

# Referencias

[1] IEEE Std 1364-2005 – IEEE Standard for Verilog Hardware Description Language.  
[2] AMD/Xilinx Vivado Design Suite User Guide: Synthesis (UG901).  
[3] AMD/Xilinx Vivado Design Suite User Guide: Implementation (UG904).  
[4] AMD/Xilinx Vivado Design Suite User Guide: Using Constraints (UG903).  
[5] AMD/Xilinx 7 Series FPGAs Configuration User Guide (UG470).  
[6] Roth, C. H., & Kinney, L. L., *Fundamentals of Logic Design*.
