# Laboratorio 2 — Semáforo Vehicular en FPGA
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

## Preguntas de Seguimiento de Aprendizaje

### 1. FSM de Moore vs. Mealy — ¿Cuál se implementó?

Una FSM de **Moore** genera sus salidas únicamente en función del **estado actual**, sin importar las entradas. Una FSM de **Mealy** genera sus salidas en función del **estado actual y las entradas** simultáneamente.

En este diseño se implementó una FSM **híbrida con predominio Moore**: las salidas de los LEDs (`led_r`, `led_v`, `led_a`) dependen únicamente del estado actual, lo que es comportamiento Moore. Sin embargo, las señales `load` y `load_value` se activan combinacionalmente cuando `zero` es verdadero dentro del bloque de salidas, lo cual introduce una dependencia de entrada característica de Mealy.

Se optó por este enfoque porque el semáforo es un sistema orientado a estados (cada luz corresponde a un estado), lo que se modela naturalmente con Moore, y las señales de carga se derivan de la condición de transición para mayor simplicidad.

---

### 2. ¿Por qué usar un tick de 1 Hz en lugar del reloj principal?

El reloj principal de la FPGA corre a **100 MHz**. Usar ese reloj directamente para temporizar segundos requeriría contadores de 100 millones de ciclos en cada módulo, lo que complica el diseño, consume más recursos y hace el código difícil de mantener.

En este diseño, el módulo `divclock` genera un reloj de **1 Hz** (configurado con `TICKS = 50_000_000`, lo que produce un toggle cada 0.5 s, resultando en un período de 1 s). Así, la FSM y el contador `dcount` operan directamente con `clk_1s`, simplificando la lógica de temporización a un simple decremento por ciclo de reloj.

---

### 3. ¿Cómo se garantiza la sincronía entre el contador y la FSM?

Ambos módulos, `FSM` y `dcount`, están conectados al **mismo reloj** (`clk_1s`) y comparten las señales `zero`, `load` y `load_value`. En cada flanco positivo de `clk_1s`:

- `dcount` decrementa su valor o carga uno nuevo.
- `FSM` evalúa `zero` y transita de estado si corresponde.

Dado que ambos registros se actualizan en el **mismo flanco de reloj**, el cambio de estado y la recarga del contador ocurren de forma simultánea y síncrona, sin riesgo de condiciones de carrera entre módulos.

---

### 4. Multiplexado de 7 segmentos

**¿Por qué se comparten segmentos y se activan ánodos por turno?**  
Los displays comparten las líneas de segmentos (`a–g, dp`) para reducir el número de pines necesarios en la FPGA. Como cada display tiene su propio ánodo, se activan de uno en uno en secuencia rápida. El ojo humano percibe el conjunto como una imagen continua gracias a la persistencia visual.

**¿Qué problemas aparecen con frecuencia de multiplexación incorrecta?**  
- Si es **muy baja** (< ~50 Hz): parpadeo visible, el ojo distingue el encendido y apagado de cada display.  
- Si es **muy alta**: el tiempo de encendido por display es tan corto que el brillo percibido disminuye notablemente, los dígitos se ven tenues o ilegibles.

En este diseño, `seg7mux` usa un contador de 16 bits (`refresh_cnt`) corriendo a 100 MHz. El selector cambia cada 2¹⁶ = 65,536 ciclos, lo que da una frecuencia de multiplexación de aproximadamente **763 Hz**, bien por encima del umbral de parpadeo.

---

### 5. Implementación del decodificador BCD a 7 segmentos

El decodificador se implementó dentro del módulo `seg7mux` mediante un bloque `always @(*)` con una sentencia `case` que mapea cada dígito decimal (0–9) a su patrón de 8 bits correspondiente para los segmentos.

Se usó la convención **activo bajo**: un bit en `0` enciende el segmento correspondiente, y un bit en `1` lo apaga. Por ejemplo:

- `4'd0 → 8'b11000000` (segmentos a,b,c,d,e,f encendidos; g apagado)
- `4'd1 → 8'b11111001` (solo segmentos b,c encendidos)

La verificación se realizó comprobando en la Nexys A7 que los dígitos mostrados coincidieran con el tiempo restante esperado para cada estado del semáforo.

---

### 6. ¿Para qué sirven los constraints y qué fallas ocurren si están incorrectos?

Los constraints (archivo `.xdc`) le indican al sintetizador/implementador cómo mapear las señales del diseño a **pines físicos** de la FPGA y definen la **frecuencia del reloj** para análisis de timing.

Si están incorrectos:
- **Pines equivocados**: los LEDs o displays no responden, o se activan señales no deseadas.
- **Reloj mal declarado**: el análisis de timing falla o pasa con márgenes incorrectos, provocando fallos intermitentes en hardware real aunque la simulación sea correcta.
- **Ausencia de constraint de reloj**: la herramienta no puede verificar si se cumplen los tiempos de setup/hold, lo que puede resultar en metaestabilidad o comportamiento impredecible.

---

### 7. Recursos principales consumidos

| Recurso | Módulo dominante |
|---------|-----------------|
| **LUTs** | `seg7mux` (decodificador + lógica combinacional del mux) |
| **Flip-Flops (FFs)** | `divclock` (contador de 32 bits) y `dcount` (contador de 5 bits + registro de estado) |
| **BRAM** | No se utiliza |
| **DSP** | No se utiliza |

El bloque que domina el uso de recursos es **`divclock`**, principalmente por su contador de 32 bits que requiere 32 flip-flops y la lógica de comparación asociada (LUTs). El decodificador de 7 segmentos también contribuye con LUTs por su tabla de verdad de 10 entradas, pero en menor medida. En general, el diseño es de bajo consumo de recursos dado su naturaleza de control simple.
