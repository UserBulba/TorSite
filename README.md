# Tor website

![Logo](images/logo.jpg "Logo")

## Description

This repository contains a Dockerized solution for hosting a hidden website using Nginx, Hugo, and Tor.

## Installation

Use makefile to 'build' the project:

```bash
make
```

## Usage

To start or stop the project, use provided scripts:

```bash
# Run tor project
sudo ./startup.sh -p tor
# Stop tor project, remove built images
sudo ./shutdown.sh -p tor -remove
```

## Generating .onion domain

```bash
# Replace [domain] with string of your choice, rather short like your name or nick, whatever.
docker run --volume ./domain:/root/mkp224o ghcr.io/vansergen/mkp224o -B -S 5 -t 5 -n 1 [domain]
```
