#!/bin/bash
set -e  # Exit on error.

# Default value for the Docker container name.
CONTAINER_NAME="${1:-kuma}"
SQL_SCRIPTS=("/tmp/monitor_config.sql" "/tmp/basic_config.sql")

# Check if the SQL scripts are present in the container.
MISSING_FILES=false

for SQL_SCRIPT in "${SQL_SCRIPTS[@]}"; do
    if ! docker exec -it "$CONTAINER_NAME" sh -c "test -f $SQL_SCRIPT"; then
        echo "Error: SQL script '$SQL_SCRIPT' not found in the container '$CONTAINER_NAME'."
        MISSING_FILES=true
    fi
done

# Exit if any of the SQL scripts are missing.
if [ "$MISSING_FILES" = true ]; then
    exit 1
fi

# Execute the SQL scripts using sqlite3 and catch any errors.
for SQL_SCRIPT in "${SQL_SCRIPTS[@]}"; do
    if ! docker exec -it "$CONTAINER_NAME" sh -c "sqlite3 /app/data/kuma.db < $SQL_SCRIPT"; then
        echo "Error: Failed to execute SQL script '$SQL_SCRIPT' in the container '$CONTAINER_NAME'."
        exit 1
    fi
done

echo "SQL scripts executed successfully in the container '$CONTAINER_NAME'."

# Stop the Node.js application.
docker exec -i "$CONTAINER_NAME" sh -c 'pkill -f "node server/server.js"'

# Start the Node.js application.
docker exec -d "$CONTAINER_NAME" sh -c 'node server/server.js'
