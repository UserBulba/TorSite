# Define the scripts that need permission changes
SCRIPTS = shutdown.sh startup.sh scripts/nyx.sh scripts/domain.sh


# Default target executed when no arguments are given to make
all: install
install: set_permissions check_docker check_docker_compose check_python setup_venv

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

# Check for Python installation
check_python:
	@echo "Checking for Python installation..."
	@which python3 > /dev/null 2>&1 || { echo "Python is not installed. Please install Python." ; exit 1; }
	@echo "Python is installed."
	@python3 -c "import venv" 2>/dev/null || { sudo apt-get update && sudo apt-get install python3-venv; }

# Set up virtual environment and install dependencies
setup_venv:
	@echo "Setting up virtual environment..."
	@[ -d venv ] || python3 -m venv venv
	@echo "Virtual environment created."
	@echo "Upgrading pip and installing dependencies..."
	@. venv/bin/activate; \
	python -m pip install --upgrade pip; \
	pip install -r requirements.txt
	@echo "Dependencies installed."

# Clean up by removing executable permissions
clean:
	@echo "Removing executable permissions from scripts..."
	chmod -x $(SCRIPTS)
