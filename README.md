# Laboratorio 4
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

## Actividad 1: Arquitectura Uniciclo

**2. Latencia de la arquitectura uniciclo**

La arquitectura uniciclo es completamente combinacional, por lo tanto no requiere ciclos de reloj para producir el resultado. La latencia es de 0 ciclos de reloj: el resultado en `dot` aparece inmediatamente tras aplicar las entradas, con un retraso correspondiente únicamente a la propagación de señales a través de los multiplicadores y sumadores.

## Diagrama de tiempos
<img width="1069" height="430" alt="wave_uniciclo" src="https://github.com/user-attachments/assets/a8dfcfb9-f408-496f-81d7-e4787cd8ff4d" />


## Diagrama RTL 
<img width="968" height="427" alt="uniciclo_RTL" src="https://github.com/user-attachments/assets/baca909b-602b-4f49-b813-c058efe9a14c" />


## Report Power
<img width="667" height="425" alt="uniciclo_power" src="https://github.com/user-attachments/assets/1bc47bd9-bc5b-4c80-9cbc-88e519ab8e50" />


## Timing
<img width="862" height="247" alt="uniciclo_Timing" src="https://github.com/user-attachments/assets/7fba06df-f766-4be1-892d-079bc2633f6b" />

** Frecuencia maxima **

  Para el uniciclo hay un detalle importante y es un circuito puramente combinacional, por tanto no tiene reloj. 
  
---

## Actividad 2: Arquitectura Segmentada

**2. Latencia de la arquitectura segmentada**

La arquitectura segmentada introduce 3 etapas de pipeline mediante registros síncronos. Por lo tanto, la latencia es de 3 ciclos de reloj desde que se aplican las entradas hasta que el resultado correcto aparece en `dot`. Esto se verificó en la simulación observando que el valor correcto aparece en el tercer flanco de subida del reloj después de establecer las entradas.


## Diagrama de tiempos
<img width="1055" height="456" alt="wave_segmentada" src="https://github.com/user-attachments/assets/55ef0fea-0a68-4baa-bba1-6d4c906d7eba" />



## Diagrama RTL 
<img width="984" height="422" alt="segmentada_RTL" src="https://github.com/user-attachments/assets/13827e21-0a54-40b3-9afc-4cc2d4293cc0" />


## Report Power
<img width="677" height="377" alt="segmentada_power" src="https://github.com/user-attachments/assets/8388ff2d-e936-45da-97ec-697ae0d14a8a" />


## Timing
<img width="869" height="204" alt="segmentada_timing" src="https://github.com/user-attachments/assets/7ac93cd0-5ace-48b2-9213-174daa8442b6" />

** Frecuencia maxima **

La arquitectura segmentada opera a una frecuencia máxima de ≈ 123.5 MHz


---

## Actividad 3: Arquitectura Multiciclo

**2. Latencia de la arquitectura multiciclo**

La arquitectura multiciclo procesa un elemento del vector por ciclo de reloj. Para n=8 elementos, la latencia es de 8 ciclos de reloj desde que se activa `start=1` hasta que `done=1` y el resultado está disponible en `dot`. Esto se verificó en la simulación contando los flancos de reloj entre la activación de `start` y la señal `done`.


## Diagrama de tiempos
<img width="1054" height="471" alt="wave_multiciclo" src="https://github.com/user-attachments/assets/e9c3abc4-a757-46fc-af8f-5bbfaece4339" />


## Diagrama RTL 
<img width="1059" height="490" alt="multiciclo_RTL" src="https://github.com/user-attachments/assets/15fa05d8-237f-4696-b26a-e6c3537b9787" />


## Report Power
<img width="729" height="445" alt="multiciclo_power" src="https://github.com/user-attachments/assets/faa1d1a2-dcf3-4104-a36e-50cf6560aa2f" />


## Timing
<img width="854" height="207" alt="multiciclo_timing" src="https://github.com/user-attachments/assets/a103d59f-cb1f-4c29-a31b-c837d1214d91" />

** Frecuencia maxima **

La arquitectura multiciclo opera a una frecuencia máxima de ≈ 108.4 MHz

---

## Actividad 4: Preguntas de Seguimiento del Aprendizaje

**1. Tabla resumen de microarquitecturas**

| Reporte | Uniciclo | Multiciclo | Segmentado |
|---|---|---|---|
| Consumo CLBs (%) |1|1|1|
| Consumo DSPs (%) |0|0|0|
| Retraso crítico |2.682 ns|9.226 ns|8.096 ns|
| Frecuencia máxima |372.9 MHz|108.4 MHz|123.5 MHz|

> Nota: completar con los valores obtenidos en Vivado tras síntesis e implementación.

---

**2. ¿Por qué las distintas microarquitecturas consumen menos o más recursos?**

En los diagramas RTL se observa claramente la diferencia en hardware instanciado. La arquitectura uniciclo instancia los 8 multiplicadores y 7 sumadores de forma paralela y simultánea, por lo que consume la mayor cantidad de recursos tanto en CLBs como en DSPs. La arquitectura segmentada instancia la misma cantidad de operadores pero agrega registros de pipeline entre etapas, lo que incrementa ligeramente el uso de flip-flops pero permite operar a mayor frecuencia al reducir el camino crítico.

La arquitectura multiciclo es la que menor cantidad de recursos consume porque reutiliza un único multiplicador y un único sumador en cada ciclo de reloj, cambiando únicamente los operandos mediante un multiplexor. Esto se relaciona directamente con las microarquitecturas de RISC-V: la arquitectura uniciclo de RISC-V instancia una ALU, una memoria de instrucciones y una memoria de datos que solo se usan una vez por instrucción, mientras que la multiciclo reutiliza esos mismos componentes en distintas fases de ejecución (fetch, decode, execute, memory, writeback), reduciendo el área de hardware a costa de mayor latencia.

---

**3. ¿Cuándo se debe usar una microarquitectura u otra?**

La elección de microarquitectura depende directamente del contexto de aplicación:

- **Bajo consumo de potencia y alta duración de batería** (por ejemplo, sensores IoT o dispositivos médicos portátiles como marcapasos o monitores de glucosa): se debe preferir la arquitectura **multiciclo**, ya que al reutilizar las unidades aritméticas solo activa una pequeña parte del hardware en cada ciclo, reduciendo la actividad de conmutación y por ende el consumo dinámico de potencia. El mayor tiempo de cómputo es aceptable si la frecuencia de operación es baja.

- **Computación de alto rendimiento** (por ejemplo, aceleradores de IA, procesamiento de señales en tiempo real o simulaciones científicas): se debe preferir la arquitectura **segmentada**, ya que permite procesar múltiples operaciones en paralelo aprovechando el pipeline y opera a la mayor frecuencia posible. El throughput es significativamente mayor al uniciclo y multiciclo una vez que el pipeline está lleno.

- **Medicina con restricciones de latencia determinista** (por ejemplo, sistemas de respuesta en tiempo real como desfibriladores o robots quirúrgicos): puede preferirse la arquitectura **uniciclo** porque su latencia es predecible y mínima en términos de ciclos, siendo adecuada cuando se necesita una respuesta inmediata y el diseño no es crítico en frecuencia.

---

**4. ¿Qué tanto difiere el banco de registros implementado del banco de registros de un procesador?**

El banco de registros implementado en este laboratorio es funcional pero simplificado en comparación con el de un procesador real. Las diferencias principales son las siguientes:

En este laboratorio el banco tiene dos vectores separados (X e Y) de 8 elementos de 8 bits cada uno, con escritura secuencial controlada por switches. En un procesador como RISC-V, el banco de registros tiene 32 registros de propósito general de 32 o 64 bits, con dos puertos de lectura simultánea y un puerto de escritura, todos accesibles en el mismo ciclo de reloj mediante las direcciones rs1, rs2 y rd decodificadas de la instrucción.

Además, el banco de registros de un procesador está integrado con la etapa de decodificación y el forwarding para resolver hazards de datos, lo cual no aplica en esta implementación. En esencia, este banco cumple la misma función conceptual de almacenar operandos para la unidad aritmética, pero carece de los mecanismos de acceso simultáneo y control que requiere un procesador completo.

---

**5. ¿Cuál microarquitectura ofrece el mejor balance entre rendimiento y consumo de recursos?**

La arquitectura **segmentada** ofrece el mejor balance entre rendimiento y consumo de recursos. Si bien consume más recursos que la multiciclo por los registros de pipeline adicionales, su frecuencia máxima de operación es considerablemente mayor que la uniciclo, ya que el camino crítico se reduce al dividir la operación en etapas. Esto se traduce en un throughput alto: aunque la latencia de la primera operación es de 3 ciclos, a partir de ese punto produce un resultado nuevo cada ciclo de reloj cuando se alimentan operaciones continuas.

La arquitectura uniciclo tiene la menor latencia por operación individual pero su camino crítico limita fuertemente la frecuencia máxima. La multiciclo economiza recursos pero sacrifica significativamente el rendimiento al requerir 8 ciclos por operación. La segmentada es el punto medio que aprovecha el paralelismo temporal del pipeline sin duplicar el hardware, que es exactamente el mismo argumento por el que la mayoría de procesadores modernos, incluyendo implementaciones de RISC-V, utilizan esta microarquitectura como base.
