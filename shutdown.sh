#!/bin/bash

set -e # Exit on error

# Define default project name
REMOVE_IMAGE=false

# Load environment variables from .env file
if [ -f .env ]; then
    while IFS='=' read -r key value; do
        if [[ $key != \#* && $key != "" ]]; then
            export "$key"="$value"
            echo "Loaded $key=$value"
        fi
    done <.env
else
    echo ".env file not found"
fi

while [ $# -gt 0 ]; do
    case "$1" in
    -remove | --remove-images)
        REMOVE_IMAGE=true
        ;;
    *)
        echo "Usage: $0 [--remove-images]"
        exit 1
        ;;
    esac
    shift
done

# Check if critical variables are set
if [ -z "$PROJECT_NAME" ] || [ -z "$TAG" ]; then
    echo "Critical variables are not set. PROJECT_NAME='$PROJECT_NAME', TAG='$TAG'"
    exit 1
fi

# Check if the script is run as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

# Stop docker-compose services
echo "Shutting down Docker services..."
if command -v docker-compose >/dev/null 2>&1; then
    echo "Stopping services using docker-compose..."
    docker-compose -p "$PROJECT_NAME" down
elif command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    echo "Stopping services using Docker Compose v2..."
    docker compose -p "$PROJECT_NAME" down
else
    echo "docker-compose is not installed."
    exit 1
fi

# Optionally remove project images
if [ "$REMOVE_IMAGE" = true ]; then
    echo "Searching for images with tag: $TAG..."
    IMAGE_IDS=$(docker images | grep "$TAG" | awk '{print $3}')

    if [ -z "$IMAGE_IDS" ]; then
        echo "No images found with tag: $TAG."
    else
        echo "Removing images..."
        echo "$IMAGE_IDS" | xargs -r docker rmi -f
        echo "Images with tag: $TAG removed."
    fi
fi

# Clean up socket directory
echo "Cleaning up socket directory..."
SOCKET_DIRECTORY="shared"
if [ -d "$SOCKET_DIRECTORY" ]; then
    # Remove the socket directory or its contents
    rm -rf "${SOCKET_DIRECTORY:?}"/*
    echo "Socket directory cleaned."
else
    echo "Socket directory does not exist. No need to clean."
fi

echo "All services stopped and cleaned up successfully!"
