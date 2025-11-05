[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/UNvIHnys)
# El3310-Proy2-2s2025

Ambiente **Docker** para el curso de Digitales con herramientas.

> [!IMPORTANT]
> **Para usuarios de macOS:**
>
> ModelSim no es compatible con macOS debido a limitaciones de arquitectura. Si estás en macOS:
>
> - Cambia al branch `macOS`:
>
> ```bash
> git checkout macOS
> ```
>
> - Ese branch contiene una configuración alternativa compatible con macOS con _Icarus Verilog_.

## 📑 Índice

- [⚙️ Instalación](#️-instalación)
- [🔧 Configuración de la librería NanGate](#-configuración-de-la-librería-nangate)
- [📂 Estructura del proyecto](#-estructura-del-proyecto)
- [🎯 Uso del Makefile](#-uso-del-makefile)
- [📝 Configurar tu diseño](#-configurar-tu-diseño)
- [🐛 Solución de problemas](#-solución-de-problemas)
- [📖 Scripts](#-scripts)

## ⚙️ Instalación

> [!NOTE]
> Este entorno está diseñado para **Windows WSL**. Para macOS o Linux, los pasos pueden variar.

> [!WARNING]
>
> **Para Linux:**
> - Si `docker` solo funciona con `sudo`, agregá tu usuario al grupo docker:
>
>   ```bash
>   sudo groupadd docker
>   sudo usermod -aG docker $USER
>   newgrp docker
>   xhost +local:docker #esto habilita la gui
>   ```
>
>   Luego probá de nuevo.
>
> - Si sigue sin funcionar, reiniciá tu computadora.

1. **Verificar Docker**

   ```bash
   docker run --rm hello-world
   ```

2. **Dar permisos de ejecución**

   ```bash
   chmod +x ./build_image.sh ./run_container.sh
   ```

3. **Construir la imagen**

   ```bash
   ./build_image.sh
   ```

4. **Iniciar el contenedor**

   ```bash
   ./run_container.sh
   ```

## 🔧 Configuración de la librería NanGate

**Descargar:** [NanGate 15nm OCL desde aquí](https://1drv.ms/f/c/eede2584e5404a82/Eg-52MIsNntNjOACvSZaHj0BEPEqPbD_cVVx2A-i0y2ChQ?e=ZrwwGG)

**Instalación:**

1. **Instalar unzip**:

   ```bash
   sudo apt install unzip
   ```

2. **Extraer la librería** en el directorio raíz del proyecto:

   ```bash
   unzip NanGate_15nm_OCL_v0.1_2014_06.A.zip
   ```

3. **Verificar:**

   ```bash
   ls NanGate_15nm_OCL_v0.1_2014_06.A/front_end/
   ```

> [!IMPORTANT]
> Sin esta librería, la síntesis y simulación GLS NO funcionarán.

## 📂 Estructura del proyecto

```bash
eda-env-docker/
├── Dockerfile
├── Makefile
├── generate_sdf.tcl
├── build_image.sh
├── run_container.sh
├── NanGate_15nm_OCL_v0.1_2014_06.A/    # Librería extraída aquí
├── src/                                 # Tu diseño Verilog
│   └── counter.v
├── testbench/                           # Tus testbenches
│   ├── tb_counter_rtl.v
│   └── tb_counter_gls.v
├── sim_output/                          # Generado automáticamente
│   ├── counter_netlist.v
│   ├── counter_timing.sdf
│   ├── dump_rtl.vcd
│   ├── dump_gls.vcd
│   └── work/
└── README.md
```

## 🎯 Uso del Makefile

### Comandos disponibles

```bash
make help       # Ayuda
make sim-rtl    # Simulación RTL
make waves-rtl  # Ver waveforms RTL
make synth      # Síntesis + timing
make sim-gls    # Gate-Level Simulation
make waves-gls  # Ver waveforms GLS
make clean      # Limpiar
```

### Flujo típico

```bash
# 1. Simular RTL
make sim-rtl
make waves-rtl

# 2. Sintetizar
make synth

# 3. Simular con timing real
make sim-gls
make waves-gls
```

### Interpretar timing

Después de `make synth` verás dos reportes importantes:

**Hold Time (Tiempo de contaminación):**

```bash
Path Type: min
...
data arrival time:      13.7902 ns
data required time:       1.7657 ns
slack (MET):            12.0245 ns
```

**Setup Time (Tiempo de propagación):**

```bash
Path Type: max
...
data arrival time:      45.8368 ns
data required time:       1.9199 ns
slack (VIOLATED):      -43.9169 ns
```

**¿Qué significa?**

- **Tiempo de propagación (tpd)**: Tiempo máximo que tarda una señal en propagarse desde una entrada hasta una salida. En el ejemplo: 45.84 ns
- **Tiempo de contaminación (tcd)**: Tiempo mínimo que tarda una señal en cambiar. En el ejemplo: 13.79 ns

## 📝 Configurar tu diseño

### Editar Makefile

```makefile
SRC_FILES = counter.v alu.v          # Tus módulos
TOP_MODULE = counter                 # Módulo principal
TB_RTL = tb_counter_rtl.v           # TB para RTL
TB_GLS = tb_counter_gls.v           # TB para GLS
```

### Estructura de archivos

- **Diseño:** `src/*.v`
- **Testbenches:** `testbench/tb_*.v`

### Testbench GLS importante

La instancia en el testbench GLS debe llamarse `dut`:

```verilog
module tb_counter_gls;
    reg clk, rst, enable;
    wire [7:0] count;
    
    counter dut (  // Nombre 'dut' es necesario para SDF
        .clk(clk),
        .rst(rst),
        .enable(enable),
        .count(count)
    );
    
    initial begin
        $dumpfile("dump_gls.vcd");
        $dumpvars(0, tb_counter_gls);
    end
    
    // Resto del testbench...
endmodule
```

### Ajustar frecuencia del reloj de la Síntesis

Editar `generate_sdf.tcl`:

```tcl
create_clock -period 10 clk   # 100 MHz
# -period 20  → 50 MHz
# -period 50  → 20 MHz
```

## 🐛 Solución de problemas

### Librería no encontrada

```bash
Error: can't read "NANGATE_15_PATH"
```

Verificar:

```bash
ls NanGate_15nm_OCL_v0.1_2014_06.A/
```

### GTKWave no abre

```bash
xhost +local:docker
./run_container.sh
```

### Diferencias RTL vs GLS

1. Comparar waveforms en GTKWave
2. Buscar señales `x` (indeterminadas)
3. Verificar que el reset esté activo suficiente tiempo
4. Revisar reporte de timing de OpenSTA

## 📖 Scripts

### build_image.sh

```bash
./build_image.sh                      # Auto-detecta plataforma
./build_image.sh --platform linux/amd64
./build_image.sh --tag mi-imagen
```

### run_container.sh

```bash
./run_container.sh           # Iniciar/conectar
./run_container.sh --clean   # Eliminar y recrear
./run_container.sh --rebuild # Reconstruir imagen
```

**Comportamiento:**

- Primera vez: crea contenedor nuevo
- Siguientes: se conecta al existente
- Hostname fijo: `el3310`
