#!/bin/sh
set -e  # Exit on error

# Default values for the Docker container name and the path to the Python script
CONTAINER_NAME="${1:-tor}"
SCRIPT_PATH="${2:-/etc/tor/scripts/get_tor_hidden_domain.py}"

# Executing the Python script inside the specified Docker container to get the .onion domain.
domain=$(docker exec "$CONTAINER_NAME" python "$SCRIPT_PATH")

# Checking if the domain was successfully fetched.
if [ -z "$domain" ]; then
    echo "Failed to retrieve the domain or no domain found."
else
    echo "The hidden service domain is: $domain"
fi
