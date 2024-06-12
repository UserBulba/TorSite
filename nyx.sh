#!/bin/sh
set -e  # Exit on error

# Find the container ID of the running tor:octo container
TOR_CONTAINER_ID=$(docker ps --filter "ancestor=tor:octo" --format "{{.ID}}")

# Check if the container is found and running
if [ -z "$TOR_CONTAINER_ID" ]; then
  echo "Error: No running container found for image tor:octo"
  exit 1
fi

# Execute nyx inside the running container
docker exec -it "$TOR_CONTAINER_ID" nyx
