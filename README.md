# Laboratorio 3 
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

## Actividad 1: Testbench

**1. ¿Cómo se genera la señal del reloj?**

La señal de reloj se genera a partir del bloque de código que se muestra a continuación:

always #5 clk = ~clk;

**2. ¿Cómo se generan los retrasos entre cambios?**

Los retrasos se generar utilizando el operador "#" junto al tiempo de retraso y la variable a retrasar, junto con el estado al estado al cual se quiere cambiar la variable luego del retraso.

Ejemplo: #12 pulse = 1;

**3. ¿Cómo se introducen entradas y se extraen las salidas?**

Las entradas en el DUT (Device Under Test) son controladas mediante variables "reg" en el testbench, estas variables de entrada corresponden a "clk", "rst" y "pulse".
Las salidas son controladas mediante señales "wire" tales como la señal "count".

**4. ¿Cómo se puede imprimir información tan pronto como las señales cambian?**

Para imprimir información en tiempo real se utiliza la función "$monitor", esta imprime las señales cada vez que cambian.
En el código se implementó de la siguiente manera: 
"$monitor("time=%0t rst=%b pulse=%b count=%d", $time, rst, pulse, count);"

---

## Actividad 2: Circuito Anti-rebote

**1. Presione el botón múltiples veces. ¿La cuenta coincide con el número de veces que presionó?**

La cuenta no coincide con el numero de veces, un pulso mecánico en el botón está siendo interpretado de manera diferente por el contador de pulsos, a veces da un numero exagerado y la cuenta no coincide. 

**2. ¿Cuál es el fenómeno que causa lo anterior?**

El fenómeno presentado se conoce como rebote (bounce). 

**3. Explique con sus propias palabras qué es rebote.**

Es un fenómeno mecánico debido a la construcción de los botones, sucede cuando se presiona el botón y el contacto interno que indica si el botón esta abierto o cerrado se abre y cierra varias veces muy rápido, dando como resultados pulsaciones falsas.  

**4. ¿Por qué es necesario contar con todos los módulos del anti-rebote?**

Los tres módulos extra funcionan debido a que en conjunto combaten los problemas presentados por la mecánica del botón.

El modulo  button_sync pasa a ser el primer modulo por el cual pasa la señal de pulse cuando se presiona el botón, lee esa señal por ejemplo como 101010111 y ayuda a sincronizar la señal del botón con el reloj de la FPGA y que cambie solo con el clk.

El modulo debounce toma la señal del modulo button_sync y la escanea por decir un termino sencillo y si la señal cambia mucho entonces no se toma en cuenta, si la señal permanece estable por un tiempo considerable entonces lo toma como una señal correcta. 

El edge_detector toma la señal limpia y hace que solo se tome en cuenta cuando se detecte el flanco de subida, ademas de que calcula la señal de salida mediante la operación AND, haciendo pulse_out =  valor de entrada AND ~ valor de entrada, una vez que esa operación da 1, entonces pulse toma el valor de pulse_out.

---

## Actividad 3: Circuitos de Reset

**1. ¿Qué sucede cuando uno aplica un rst?**

En el ripple counter con reset síncrono, al aplicar rst se observa que los dos contadores no se resetean al mismo tiempo. El counter0 se resetea en el siguiente flanco negativo del reloj principal, pero el counter1 no se resetea hasta el siguiente flanco negativo de count0[3], que es una señal derivada y más lenta. Esto se vio claramente en la simulación donde al aplicar rst en t=530000, counter0 pasó a 0000 inmediatamente pero counter1 se quedó en 0011 y siguió incrementando durante varios ciclos más antes de resetearse. En hardware esto se traduce en LEDs mostrando valores inconsistentes por un instante al momento del reset.

**2. ¿Cómo puede solucionarse el problema?**

La solución es usar reset asíncrono combinado con un sincronizador de doble flip-flop. El reset asíncrono garantiza que ambos contadores se reseteen instantáneamente sin depender de ningún flanco de reloj, resolviendo el problema de los distintos dominios de reloj del ripple counter. El sincronizador de doble FF se encarga de que la liberación del reset ocurra de forma sincronizada con el reloj principal, evitando metaestabilidad. Esto se verificó tanto en simulación como en la FPGA, donde al subir SW0 todos los LEDs se apagaron al mismo tiempo.

**¿Por qué no es conveniente tener una señal de reset asíncrona en FPGAs?**

Un reset asíncrono puro presenta varios problemas en FPGAs. Primero, cuando el reset se libera puede hacerlo cerca de un flanco activo del reloj, dejando algún flip-flop en estado indeterminado por metaestabilidad. Segundo, en un diseño grande la señal de reset no llega a todos los flip-flops al mismo tiempo debido a retardos de ruteo, dejando el sistema en un estado parcialmente reseteado por un instante. Tercero, las herramientas como Vivado tienen dificultades para analizar el timing de señales asíncronas, lo que puede producir errores que no se detectan en simulación pero sí aparecen en hardware.

**Recomendaciones principales para señales de reset en FPGA:**

- Preferir reset síncrono siempre que sea posible ya que las herramientas lo optimizan mejor.
- Si se necesita reset asíncrono, usar siempre el patrón async assert, sync deassert con sincronizador de doble FF.
- Usar una sola fuente de reset distribuida globalmente para que llegue a todos los flip-flops con el menor retardo posible.
- No resetear flip-flops que no lo necesiten, ya que el reset consume recursos de ruteo adicionales.
- Evitar generar resets internamente desde lógica combinacional porque pueden producir pulsos espurios por glitches.

---

## Preguntas de Seguimiento de Aprendizaje

**1. ¿Cuál es el propósito de un testbench en el proceso de diseño digital? Explique brevemente su función dentro del flujo de verificación.**

Un testbench es un módulo de simulación, el cual se utiliza para verificar el funcionamiento de un diseño digital antes de su implementación en hardware. Su propósito es observar las salidas del circuito y su comportamiento ante diferentes entradas o señales generadas, como por ejemplo un "clock". Mediante este análisis se logra detectar posibles errores durante la simulación y validar el diseño del circuito antes de implementarlo de manera física.

**2. En el experimento inicial, ¿qué comportamiento se observa cuando un botón se conecta directamente al contador sin un circuito anti-rebote?**

Al presionar el botón varias veces, el contador muestra un valor mayor al número real de pulsaciones. Por ejemplo, si se presiona el botón 5 veces, el contador puede mostrar 8, 12 o cualquier valor superior. Esto ocurre porque cada vez que se presiona el botón físicamente, los contactos metálicos no establecen una conexión limpia de inmediato sino que rebotan varias veces en milisegundos, generando múltiples flancos que el contador interpreta como pulsaciones independientes. El comportamiento es impredecible ya que la cantidad de rebotes varía en cada pulsación dependiendo de la velocidad y fuerza con que se presione el botón.

**3. ¿Qué fenómeno físico causa el rebote en los pulsadores mecánicos y cómo afecta el comportamiento del sistema digital?**

El fenómeno causado es debido a las vibraciones mecánicas del botón cuando es pulsado, por lo cual el sistema digital va detectar esas pequeñas vibraciones y las va interpretar como pulsaciones. 

**4. ¿Cuál es la función del sincronizador de entrada antes del circuito anti-rebote?**

La función es la de estabilizar la señal de entrada y sincronizarla con el reloj de la FPGA.

**5. Explique el principio de funcionamiento del circuito anti-rebote implementado en este laboratorio.**

El principio de funcionamiento es tomar la señal de entrada, estabilizarla y sincronizarla con la señal de la FPGA, escanear esa señal para determinar si se mantiene estable por un cierto y si se cumple entonces es valida, si la señal cambia mucho de valor se reinicia el contador, luego esa señal es la entrada al modulo en el cual se genera una señal por ciclo de reloj el cual es usado para enviarla al modulo del contador de pulsos y se usa para contar cuantas veces se presiona el botón. 

**6. ¿Cómo influye el valor del parámetro que define el tiempo de filtrado en el funcionamiento del anti-rebote?**

Ese parámetro influye en el tiempo que se usa para determinar que la señal se considera estable, se conoce como tiempo de filtrado = parámetro/frecuencia de FPGA, por lo cual si el parámetro es muy largo hay pulsaciones que no se tomaran en cuenta y si es muy pequeño se tomaran en cuenta muchas pulsaciones.

**7. Compare el comportamiento del contador utilizando reset síncrono y reset asíncrono. ¿Cuál es la diferencia principal observada en simulación?**

En la simulación se observó claramente la diferencia al aplicar rst en t=530000. Con reset síncrono, counter0 se resetea a 0000 de inmediato pero counter1 se quedó en 0011 y continuó incrementando hasta 0100, 0101 y siguientes durante varios ciclos antes de resetearse, dejando el sistema en un estado inconsistente. Con reset asíncrono, ambos contadores pasaron a 0000 exactamente en el mismo instante sin importar en qué punto del ciclo de reloj se encontraban. La diferencia principal es que el reset síncrono depende del flanco del reloj de cada contador para actuar, y como en un ripple counter cada contador tiene su propio dominio de reloj, el reset no ocurre simultáneamente en todos. El reset asíncrono no tiene esa limitación.

**8. Mencione al menos dos ventajas y dos desventajas del reset síncrono.**

Ventajas:
- Es predecible y fácil de analizar por las herramientas EDA como Vivado, lo que facilita el timing  del diseño.
- Elimina el riesgo de metaestabilidad porque el reset y su liberación siempre ocurren en el flanco del reloj.

Desventajas:
- Requiere que el reloj esté activo para que el reset tenga efecto, lo que puede ser un problema si el reloj falla.
- En diseños con múltiples dominios de reloj como el ripple counter, el reset no ocurre simultáneamente en todos los módulos, generando estados inconsistentes.

**9. Mencione al menos dos ventajas y dos desventajas del reset asíncrono.**

Ventajas:
- Actúa de forma inmediata sin depender del reloj, lo que es útil cuando se necesita detener el sistema instantáneamente.
- Puede resetear el sistema aunque el reloj esté detenido o funcionando mal.

Desventajas:
- La liberación del reset puede ocurrir cerca de un flanco activo del reloj y causar metaestabilidad en los flip-flops.
- En diseños grandes con muchos flip-flops, la señal de reset no llega a todos al mismo tiempo por los retardos de ruteo, dejando el sistema parcialmente reseteado por un instante.

**10. Con base en los resultados obtenidos, ¿qué tipo de reset considera más apropiado para sistemas digitales síncronos y por qué?**

Con base en los resultados obtenidos, el reset más apropiado para sistemas digitales síncronos es el patrón combinado de reset asíncrono con sincronizador de doble FF, que es exactamente lo que se implementó en este laboratorio. Este enfoque toma lo mejor de ambos tipos: la activación del reset es asíncrona, lo que garantiza que todos los módulos respondan de forma inmediata sin importar su dominio de reloj, resolviendo el problema observado con el reset síncrono en el ripple counter. La liberación del reset pasa por el sincronizador de doble FF, lo que elimina el riesgo de metaestabilidad al salir del estado de reset. 
