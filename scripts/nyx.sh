#!/bin/sh
set -e  # Exit on error

# Default value for the Docker container name
CONTAINER_NAME="${1:-tor-frontend}"

# Check if the container is found and running
if [ -z "$CONTAINER_NAME" ]; then
    echo "Error: No running container found for image '$CONTAINER_NAME'."
    exit 1
fi

# Execute nyx in the running container
echo "=============================="
echo "In the darkness of the Underworld, Nyx, the Night Incarnate, watches over..."
echo "=============================="

docker exec -it "$CONTAINER_NAME" sh -c 'PYTHONWARNINGS="ignore:invalid escape sequence" nyx'

echo "======================================"
echo "The night recedes. Until next time, traveler."
echo "======================================"
