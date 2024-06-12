# Tor website

![Logo](images/logo.jpg "Logo")

## Table of Contents

- [Description](#description)
- [Installation](#installation)
- [Usage](#usage)
- [Tools](#tools)
  - [Generating .onion domain](#generating-onion-domain)
  - [OnionScan](#onionscan)
  - [Nyx](#nyx)

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
