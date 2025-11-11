#!/usr/bin/env bash
# Start or reattach to the EDA container, mounting the current folder as the workspace.
#
# Agregado soporte para X11 (GTKWave / interfaz gráfica)
# - Requiere ejecutar previamente:  xhost +local:docker
#
# Behavior:
# - Si la imagen no existe, la construye.
# - Si el contenedor ya existe, abre shell dentro.
# - Si está detenido, lo inicia y adjunta.
# - Caso contrario, crea un contenedor nuevo montando $(pwd) a /workspace.
#
# Env vars (opcionales):
#   IMAGE          Nombre de la imagen (default: eda-env)
#   CONTAINER_NAME Nombre del contenedor (default: eda-dev)
#   WORKDIR        Directorio de trabajo dentro del contenedor (default: /workspace)
#   HOST_DIR       Directorio del host a montar (default: current directory)
#
# Hostname fijo: el3310
# Flags:
#   --clean        Elimina el contenedor existente
#   --rebuild      Fuerza la reconstrucción de la imagen

set -euo pipefail

IMAGE=${IMAGE:-eda-env}
CONTAINER_NAME=${CONTAINER_NAME:-eda-dev}
WORKDIR=${WORKDIR:-/workspace}
HOST_DIR=${HOST_DIR:-"$(pwd)"}
HOSTNAME_REQUIRED="el3310"

usage() {
  echo "Uso: $0 [--clean] [--rebuild]" >&2
}

CLEAN=no
REBUILD=no

while [ $# -gt 0 ]; do
  case "$1" in
    --clean) CLEAN=yes ;;
    --rebuild) REBUILD=yes ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Opción desconocida: $1" >&2; usage; exit 2 ;;
  esac
  shift
done

if [ "$CLEAN" = "yes" ]; then
  docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
  echo "🧹 Contenedor $CONTAINER_NAME eliminado."
fi

if [ "$REBUILD" = "yes" ]; then
  echo "🔧 Reconstruyendo imagen $IMAGE ..."
  docker build -t "$IMAGE" .
fi

# Si la imagen no existe
if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  echo "⚙️ Imagen $IMAGE no encontrada. Construyendo..."
  docker build -t "$IMAGE" .
fi

# Si ya existe el contenedor
if docker ps -a --format '{{.Names}}' | grep -Fxq "$CONTAINER_NAME"; then
  EXISTING_HOSTNAME=$(docker inspect -f '{{.Config.Hostname}}' "$CONTAINER_NAME" 2>/dev/null || echo "")
  if [ "$EXISTING_HOSTNAME" != "$HOSTNAME_REQUIRED" ]; then
    echo "⚠️  El contenedor $CONTAINER_NAME tiene hostname '$EXISTING_HOSTNAME' (esperado '$HOSTNAME_REQUIRED'). Recreando..."
    docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
  else
    # Si ya está corriendo, entra directo
    if docker ps --format '{{.Names}}' | grep -Fxq "$CONTAINER_NAME"; then
      echo "🟢 Contenedor $CONTAINER_NAME en ejecución (hostname $HOSTNAME_REQUIRED). Abriendo shell..."
      exec docker exec -it \
        -e DISPLAY=$DISPLAY \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -w "$WORKDIR" \
        "$CONTAINER_NAME" /bin/bash
    else
      echo "🔵 Iniciando contenedor existente $CONTAINER_NAME (hostname $HOSTNAME_REQUIRED)..."
      exec docker start -ai "$CONTAINER_NAME"
    fi
  fi
fi

# Crear nuevo contenedor con X11 habilitado
echo "🚀 Creando contenedor $CONTAINER_NAME (hostname $HOSTNAME_REQUIRED) con soporte X11..."
exec docker run -it \
  --name "$CONTAINER_NAME" \
  --hostname "$HOSTNAME_REQUIRED" \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$HOST_DIR":"$WORKDIR" \
  -w "$WORKDIR" \
  "$IMAGE"
