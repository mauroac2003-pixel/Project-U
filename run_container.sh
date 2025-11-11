#!/usr/bin/env bash
# Start or reattach to the EDA container, mounting the current folder as the workspace.
#
# Soporta X11: permite abrir GTKWave desde el contenedor. Necesita
# ejecutar en el host:  xhost +local:docker

set -euo pipefail

IMAGE=${IMAGE:-eda-env}
CONTAINER_NAME=${CONTAINER_NAME:-eda-dev}
WORKDIR=${WORKDIR:-/workspace}
HOST_DIR=${HOST_DIR:-"$(pwd)"}
HOSTNAME_REQUIRED="el3310"

CLEAN=no
REBUILD=no

while [ $# -gt 0 ]; do
  case "$1" in
    --clean) CLEAN=yes ;;
    --rebuild) REBUILD=yes ;;
    -h|--help) echo "Usage: $0 [--clean] [--rebuild]"; exit 0 ;;
    *) echo "Unknown option: $1"; exit 2 ;;
  esac
  shift
done

if [ "$CLEAN" = "yes" ]; then
  docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
  echo "Removed container $CONTAINER_NAME"
fi

if [ "$REBUILD" = "yes" ]; then
  echo "Rebuilding image $IMAGE ..."
  docker build -t "$IMAGE" .
fi

# Build image if it doesn't exist
if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  echo "Image $IMAGE not found. Building..."
  docker build -t "$IMAGE" .
fi

# If container exists
if docker ps -a --format '{{.Names}}' | grep -Fxq "$CONTAINER_NAME"; then
  HOSTNAME=$(docker inspect -f '{{.Config.Hostname}}' "$CONTAINER_NAME")
  if [ "$HOSTNAME" != "$HOSTNAME_REQUIRED" ]; then
    docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
  else
    # If running, just exec
    if docker ps --format '{{.Names}}' | grep -Fxq "$CONTAINER_NAME"; then
      echo "Container $CONTAINER_NAME is running (hostname $HOSTNAME_REQUIRED). Opening shell..."
      exec docker exec -it \
        -e DISPLAY=$DISPLAY \
        -w "$WORKDIR" \
        "$CONTAINER_NAME" \
        /bin/bash
    else
      echo "Starting existing container $CONTAINER_NAME (hostname $HOSTNAME_REQUIRED)..."
      exec docker start -ai "$CONTAINER_NAME"
    fi
  fi
fi

# Create new container
echo "Creating container $CONTAINER_NAME (hostname $HOSTNAME_REQUIRED) and mounting $HOST_DIR -> $WORKDIR"
exec docker run -it \
  --name "$CONTAINER_NAME" \
  --hostname "$HOSTNAME_REQUIRED" \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$HOST_DIR":"$WORKDIR" \
  -w "$WORKDIR" \
  "$IMAGE"
