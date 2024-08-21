#!/bin/sh
set -e  # Exit on error

# Default value for the Docker container name.
CONTAINER_NAME="${1:-kuma}"

# Check if the container is found and running.
if [ -z "$CONTAINER_NAME" ]; then
    echo "Error: No running container found for image '$CONTAINER_NAME'."
    exit 1
fi

# Check if the SQL script file exists inside the container.
if ! docker exec -it "$CONTAINER_NAME" sh -c 'test -f /tmp/insert_config.sql'; then
    echo "Error: SQL script '/tmp/insert_config.sql' not found in the container '$CONTAINER_NAME'."
    exit 1
fi

echo "Importing configuration data into Kuma..."

# Execute the SQL script using sqlite3 and catch any errors.
if ! docker exec -it "$CONTAINER_NAME" sh -c 'sqlite3 /app/data/kuma.db < /tmp/insert_config.sql'; then
    echo "Error: Failed to execute SQL script in the container '$CONTAINER_NAME'."
    exit 1
fi

echo "SQL script executed successfully."

# Stop the Node.js application.
docker exec -i "$CONTAINER_NAME" sh -c 'pkill -f "node server/server.js"'

# Start the Node.js application.
docker exec -d "$CONTAINER_NAME" sh -c 'node server/server.js'
