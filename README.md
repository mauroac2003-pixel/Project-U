# Investigación Teórica  
## Taller de Diseño Digital – EL3313  

**Estudiantes:**  
- Navarro Acuña Mauro  
- Arce Cruz Josué  
- Arguedas Guzmán Gabriel  

**Profesor:**  
Luis G. León-Vega Ph.D  

Instituto Tecnológico de Costa Rica  
I Semestre 2026  

---

# Preguntas de Seguimiento de Aprendizaje

Al finalizar el laboratorio, responda las siguientes preguntas:

---

## 1. ¿Para qué funcionan los bloques procedurales y asignaciones bloqueantes? ¿Cómo se diferencian de los assign.

Los bloques procedurales (`always`) permiten describir hardware de forma estructurada utilizando control de flujo como `if` y `case`. Dentro de estos bloques pueden utilizarse asignaciones bloqueantes (`=`) para modelar lógica combinacional, o asignaciones no bloqueantes (`<=`) para modelar lógica secuencial.

En nuestra implementación:

- Se utilizó `always @(*)` en el módulo `seg7_digit` para implementar la decodificación BCD a 7 segmentos mediante un `case`.
- Se utilizó `always @(posedge sclk)` para el registro `refresh`, que permite dividir la frecuencia del reloj y realizar el multiplexado del display.

Las asignaciones bloqueantes (`=`) se ejecutan respetando el orden en que aparecen dentro del bloque, lo que es adecuado para modelar lógica combinacional.

Por otro lado, `assign` es una asignación continua que describe directamente una ecuación lógica combinacional y no requiere un bloque `always`.

En nuestro diseño, `assign` se utilizó para:

- Suma con signo
- Resta
- Multiplicación
- Función booleana
- Selección de operación mediante operador ternario

Diferencia principal:

- `assign` describe una ecuación directa.
- `always` permite estructurar lógica más compleja.
- `assign` se usa con `wire`.
- `always` utiliza señales tipo `reg`.

---

## 2. ¿Hizo uso de control de flujo? ¿Cuál usó y por qué?

Sí, se utilizó control de flujo en varias partes del diseño.

Se utilizó el operador ternario (`?:`) para seleccionar la operación aritmética en el módulo `calculadora`. Esto implementa un multiplexor 4:1 combinacional que selecciona entre suma, resta, multiplicación o función booleana según los switches.

También se utilizó la estructura `case` en:

- El módulo `seg7_digit` para decodificar los números.
- El módulo `top` para controlar el multiplexado de los displays.

Finalmente, se utilizó una estructura secuencial con `posedge sclk` para generar el contador de refresco del display.

El control de flujo fue necesario para:

- Seleccionar la operación correcta.
- Decodificar correctamente los dígitos.
- Implementar el multiplexado del display.

---

## 3. ¿Para qué sirven los constraints?

Los constraints (.xdc) sirven para conectar el diseño lógico con los pines físicos de la FPGA.

En nuestro proyecto se utilizaron para:

- Asignar el reloj de 100 MHz al puerto `sclk`.
- Mapear los switches a las entradas `a`, `b` y `selec`.
- Asignar los LEDs al resultado `c`.
- Conectar los segmentos y ánodos del display de 7 segmentos.

Además, permiten:

- Definir el estándar eléctrico (LVCMOS33).
- Crear restricciones de temporización mediante `create_clock`.
- Permitir análisis de timing durante la implementación.

Sin constraints, el diseño no podría interactuar correctamente con el hardware físico de la tarjeta Nexys A7.

---

## 4. ¿Cómo se mide el consumo de recursos en una FPGA?

El consumo de recursos se mide utilizando el reporte de utilización en Vivado después de la síntesis o implementación.

En Vivado se accede mediante:

Implementation → Report Utilization

El reporte muestra el uso de:

- LUTs
- Flip-Flops
- DSP slices
- Block RAM
- Entradas y salidas (I/O)

En nuestro diseño:

- La suma, resta y función booleana utilizan LUTs.
- La multiplicación 4x4 puede utilizar LUTs o un DSP slice dependiendo de la optimización.
- El registro `refresh` utiliza Flip-Flops.
- El multiplexado y decodificación utilizan LUTs.

Este reporte permite analizar qué tan eficiente es el diseño en términos de recursos físicos.

---

## 5. ¿Cómo se mide la potencia aproximada de un diseño en FPGA?

La potencia aproximada se estima utilizando la herramienta de análisis de potencia en Vivado.

Se accede mediante:

Tools → Report Power

La herramienta calcula:

- Potencia estática (corriente de fuga).
- Potencia dinámica (conmutación).
- Consumo por reloj.
- Consumo por I/O.

Para obtener una estimación más precisa se puede usar información de actividad proveniente de simulación.

En nuestro diseño, el consumo es bajo debido a:

- Tamaño reducido del circuito.
- Poca lógica secuencial.
- Baja complejidad de operaciones.

---

## 6. ¿Qué es un IP Core? ¿Su implementación es un IP Core y por qué?

Un IP Core (Intellectual Property Core) es un bloque funcional pre-diseñado, verificado y documentado que puede integrarse en diferentes proyectos de diseño digital.

Puede ser:

- Soft IP: descrito en HDL.
- Hard IP: bloque físico dedicado dentro del chip (como PLL o controladores de memoria).

Nuestra implementación no es un IP Core formal porque:

- No está empaquetada como bloque reutilizable.
- No posee documentación formal de integración.
- No fue diseñada como componente independiente.
- No fue validada como producto comercial.

Es un diseño RTL modular compuesto por varios módulos interconectados, pero no cumple con los requisitos formales para considerarse un IP Core.

---

# Conclusión

La calculadora implementada cumple con los objetivos del laboratorio, integrando correctamente:

- Lógica combinacional.
- Lógica secuencial para multiplexado.
- Uso adecuado de control de flujo.
- Implementación correcta de constraints.
- Flujo completo de diseño: HDL → Síntesis → Implementación → Bitstream.

El proyecto demuestra comprensión del proceso completo de diseño digital en FPGA.
