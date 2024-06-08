#!/bin/sh
set -e  # Exit on error

# Define default project name
PROJECT_NAME="tor"
REMOVE_IMAGE=false

while [ $# -gt 0 ]; do
  case "$1" in
    -remove|--remove-image)
      REMOVE_IMAGE=true
      ;;
    -p|--project)
      PROJECT_NAME="$2"
      shift
      ;;
    *)
      echo "Usage: $0 [--remove-image] [-p|--project <project_name>]"
      exit 1
      ;;
  esac
  shift
done

# Check if the script is run as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

# Stop docker-compose services
echo "Shutting down Docker services..."
if command -v docker-compose >/dev/null 2>&1; then
    echo "Stopping services using docker-compose..."
    docker-compose -p "$PROJECT_NAME" --profile "$PROJECT_NAME" down
elif command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    echo "Stopping services using Docker Compose v2..."
    docker compose -p "$PROJECT_NAME" --profile "$PROJECT_NAME" down
else
    echo "docker-compose is not installed."
    exit 1
fi

# TODO: Enable to remove images used by the services
# Optionally remove nginx image
if [ "$REMOVE_IMAGE" = true ]; then
  echo "Removing images..."
  IMAGE_ID=$(docker images -q nginx)
  if [ -n "$IMAGE_ID" ]; then
    docker rmi $IMAGE_ID
    echo "Images removed."
  else
    echo "No nginx image found to remove."
  fi
fi

# Clean up socket directory
echo "Cleaning up socket directory..."
SOCKET_DIRECTORY="shared"
if [ -d "$SOCKET_DIRECTORY" ]; then
    # Remove the socket directory or its contents
    rm -rf "$SOCKET_DIRECTORY"/*
    echo "Socket directory cleaned."
else
    echo "Socket directory does not exist. No need to clean."
fi

echo "All services stopped and cleaned up successfully!"
