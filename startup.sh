#!/bin/bash

# Exit on error
set -e

SERVICE_NAME="backend"
domains=()

# Load environment variables from .env file
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

# Function to check if a container is healthy
check_health() {
    local service="$1"
    local retries=30
    local count
    local service_status

    echo -e "\nService ${service} has ${REPLICAS} replicas."
    echo -e "Checking health of service ${service}, waiting for all replicas to become healthy...\n"

    for instance in $(seq 1 ${REPLICAS}); do
        count=0
        service_status="starting"
        while [ "$service_status" != "healthy" ] && [ $count -lt $retries ]; do
            service_status=$(docker inspect --format='{{.State.Health.Status}}' "${PROJECT_NAME}-${service}-${instance}")
            if [ "$service_status" = "healthy" ]; then
                echo "Service ${service}-${instance} is healthy."
            else
                echo "Waiting for ${service}-${instance} to become healthy..."
                sleep 10
                count=$((count + 1))
            fi
        done

        if [ "$service_status" != "healthy" ]; then
            echo "Service ${service}-${instance} failed to become healthy after $((retries * 10)) seconds."
            exit 1
        fi
    done
}

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

# Get .onion hostname
if [ -f "${DIRECTORY}/hostname" ]; then
    echo "File exists: ${DIRECTORY}/hostname"

    # Read the content of the file and assign it to a variable
    hostname_value=$(sudo cat "${DIRECTORY}/hostname")
    echo "Hostname is: $hostname_value"
else
    echo "File does not exist: ${DIRECTORY}/hostname"
    echo "Unable to proceed without hostname file."
    # Exit if the hostname file does not exist
    exit 1
fi

echo "Setting up directories..."

# Set permissions and ownership for the directory
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
    docker-compose -p "$PROJECT_NAME" -f docker-compose-onionbalance.yaml --profile "$PROJECT_NAME" up -d --build --force-recreate "$SERVICE_NAME"
    check_health "$SERVICE_NAME"
elif command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    docker compose -p "$PROJECT_NAME" -f docker-compose-onionbalance.yaml --profile "$PROJECT_NAME" up -d --build --force-recreate "$SERVICE_NAME"
    check_health "$SERVICE_NAME"
else
    echo "docker-compose is not installed."
    exit 1
fi

# Get the domain name for each container
for instance in $(seq 1 $REPLICAS); do
    container_name="${PROJECT_NAME}-${SERVICE_NAME}-${instance}"
    domain=$(./scripts/domain.sh "$container_name")
    domains+=("$domain")
done

# TODO: run script if all containers are healthy
python3 ./scripts/config_generator.py "${domains[@]}" "$hostname_value"

echo -e "\nStartup script completed."
