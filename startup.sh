#!/bin/sh

set -e  # Exit on error

# Define path
DIRECTORY="domain"
# Define project name
PROJECT_NAME=${1:-tor}
DISTRIBUTION=${DISTRIBUTION:-alpine}
# Check if the script is run as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

# Check if the directory exists
if [ ! -d "$DIRECTORY" ]; then
    echo "Directory does not exist: $DIRECTORY"
    echo "Attempting to create directory..."
    mkdir -p "$DIRECTORY" && echo "Directory created successfully." || echo "Failed to create directory."
else
    echo "Directory already exists: $DIRECTORY"
fi

echo "Setting up directories..."

if [ -d "$DIRECTORY" ]; then
    chmod -R 700 "$DIRECTORY"
    chown -R 100:100 "$DIRECTORY"
else
    echo "Directory $DIRECTORY does not exist."
    exit 1
fi

echo "Running docker-compose..."

# Ensure docker-compose is available and run it
if command -v docker-compose >/dev/null 2>&1; then
    docker-compose -p "$PROJECT_NAME" --profile "$PROJECT_NAME" up -d --build --force-recreate
elif command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    docker compose -p "$PROJECT_NAME" --profile "$PROJECT_NAME" up -d --build --force-recreate
else
    echo "docker-compose is not installed."
    exit 1
fi

echo "Done!"
