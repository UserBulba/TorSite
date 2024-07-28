#!/bin/bash

# Exit on error
set -e

# Define default project name
SERVICE_NAME="tor"
BACKEND_PROFILE="backend"
FRONTEND_PROFILE="frontend"
VENV_DIR="venv"
domains=()

# Function to check if a container is healthy
check_health() {
    local service="$1"
    local retries=30
    local count
    local service_status

    echo -e "\nService ${service} has ${REPLICAS} replicas."
    echo -e "Checking health of service ${service}, waiting for all replicas to become healthy...\n"

    for instance in $(seq 1 "${REPLICAS}"); do
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

# Check if critical variables are set
if [ -z "$PROJECT_NAME" ] || [ -z "$BACKEND_PROFILE" ] || [ -z "$FRONTEND_PROFILE" ] || [ -z "$REPLICAS" ]; then
    echo "Critical variables are not set."
    exit 1
fi

# Check if the virtual environment directory exists
if [ ! -d "$VENV_DIR" ]; then
    echo "Virtual environment not found. Please run 'make install' to set up the virtual environment."
    exit 1
fi

# Activate the virtual environment
source "$VENV_DIR/bin/activate"

# Check if the script is run as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root. Please use sudo."
    exit 1
fi

# Check if the directory exists
if [ ! -d "$DIRECTORY" ]; then
    echo "Directory does not exist: $DIRECTORY"
    echo "Attempting to create directory..."
    mkdir -p "$DIRECTORY" &&
        echo "Directory created successfully." ||
        echo "Failed to create directory."
else
    echo "Directory already exists: $DIRECTORY"
fi

# Get .onion hostname
if [ -f "${DIRECTORY}/hostname" ]; then
    echo "File exists: ${DIRECTORY}/hostname"

    hostname_value=$(sudo cat "${DIRECTORY}/hostname")
else
    echo "File does not exist: ${DIRECTORY}/hostname"
    echo "Unable to proceed without hostname file."
    exit 1
fi

# Generate the ob_config file
python3 ./scripts/config_generator.py ob_config --master_onion_address "${hostname_value}"

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
    docker-compose -p "$PROJECT_NAME" \
        -f docker-compose-onionbalance.yaml \
        --profile "$BACKEND_PROFILE" up \
        -d --build --force-recreate
    check_health "$SERVICE_NAME"
elif command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    docker compose -p "$PROJECT_NAME" \
        -f docker-compose-onionbalance.yaml \
        --profile "$BACKEND_PROFILE" up \
        -d --build --force-recreate
    check_health "$SERVICE_NAME"
else
    echo "docker-compose is not installed."
    exit 1
fi

for instance in $(seq 1 "$REPLICAS"); do
    container_name="${PROJECT_NAME}-${SERVICE_NAME}-${instance}"
    domain=$(./scripts/domain.sh "$container_name")
    domains+=("$domain")
done

# Generate the frontend configuration file.
python ./scripts/config_generator.py config --log_level "$LOG_LEVEL" --log_location "$LOG_LOCATION" --domains "${domains[@]}" --key_path "$KEY_LOCATION"

# Ensure docker-compose is available and run it
if command -v docker-compose >/dev/null 2>&1; then
    docker-compose -p "$PROJECT_NAME" \
        -f docker-compose-onionbalance.yaml \
        --profile "$FRONTEND_PROFILE" up \
        -d --build --force-recreate
elif command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    docker compose -p "$PROJECT_NAME" \
        -f docker-compose-onionbalance.yaml \
        --profile "$FRONTEND_PROFILE" up \
        -d --build --force-recreate
else
    echo "docker-compose is not installed."
    exit 1
fi

# Deactivate the virtual environment
deactivate

echo -e "\nStartup script completed."
