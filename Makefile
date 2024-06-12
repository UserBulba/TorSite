# Define the scripts that need permission changes
SCRIPTS = shutdown.sh startup.sh nyx.sh

# Default target executed when no arguments are given to make
all: set_permissions check_docker check_docker_compose

# Set executable permissions for the scripts
set_permissions:
	@echo "Setting executable permissions on scripts..."
	chmod +x $(SCRIPTS)

# Check for Docker installation
check_docker:
	@echo "Checking for Docker installation..."
	@which docker > /dev/null 2>&1 || (echo "Docker is not installed. Please install Docker." && exit 1)
	@echo "Docker is installed."

# Check for Docker Compose installation
check_docker_compose:
	@echo "Checking for Docker Compose installation..."
	@which docker-compose > /dev/null 2>&1 || (echo "Docker Compose is not installed. Please install Docker Compose." && exit 1)
	@echo "Docker Compose is installed."

# Clean up by removing executable permissions
clean:
	@echo "Removing executable permissions from scripts..."
	chmod -x $(SCRIPTS)
