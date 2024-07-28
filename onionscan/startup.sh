#!/bin/bash

# Get the directory where the script is located and change to it
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
cd "$SCRIPT_DIR" || exit 1

# Check if a domain was passed as an argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

# Assign the domain to a variable
DOMAIN=$1

# Echo the domain to be used for confirmation
echo "Preparing to scan: $DOMAIN"

# Build the Docker image
echo "Building Docker image..."
if ! docker build -f Dockerfile.onionscan -t onionscan:octo .; then
    echo "Docker build failed, exiting..."
    exit 1
fi

# Run the Docker container, passing the domain as an argument
echo "Running OnionScan on $DOMAIN..."
docker run --rm onionscan:octo "$DOMAIN"
