# Tor All in One - Dockerized Hidden Service

This project provides a Dockerized solution for hosting a Tor hidden service, integrating Nginx and Hugo for a robust, secure, and easily maintainable web presence on the dark web. It is designed for users seeking a highly automated setup with advanced tools for domain generation, security scanning, and traffic monitoring.

![Logo](images/logo.jpg "Logo")

## Getting Started

### Prerequisites

- Docker
- Docker Compose

It is good to have a basic understanding of Docker and Docker Compose before using this project.

### Configuration

- `OnionBalance` requires a configuration file named `ob_config`. Create this file in the `conf` folder with the following content:

    ```ini
    MasterOnionAddress domain.onion
    ```

    Make sure to replace `domain.onion` with your actual master onion address.

### Installation

To spin up a Tor hidden service, you need to have Docker installed on your machine. The project is built using Docker Compose, and it contains a set of scripts for starting and stopping the project.

> **Note**: This project contains two versions of images, Alpine and Debian. To switch between them, change the base image in `.env` file. The Alpine image is primarily used.

Use makefile to 'build' the project:

```bash
make install
```

## Usage

To start or stop the project, use provided scripts:

```bash
# Run tor project
sudo ./startup.sh -p tor
# Stop tor project, remove built images
sudo ./shutdown.sh -p tor -remove
```

## Tools

Project contains additional tools for generating .onion domain, scanning it, and monitoring Tor traffic.

### Generating .onion domain

```bash
# Replace [domain] with string of your choice, rather short like your name or nick, whatever.
docker run --volume ./domain:/root/mkp224o ghcr.io/vansergen/mkp224o -B -S 5 -t 5 -n 1 [domain]
```

### OnionScan

To scan your .onion domain, use OnionScan:

```bash
./onionscan/startup.sh [domain]
```

### Nyx

To monitor Tor traffic, use Nyx:

```bash
./nyx.sh
```

## External links

- [Best Practices for Hosting Onion Services](https://riseup.net/en/security/network-security/tor/onionservices-best-practices)
