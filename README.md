![](images/logo.jpg)

# Tor website

## Description

This project is a simple example of how to create a Tor hidden service website.
It uses Nginx as a web server and Tor as a proxy to access the website.

## Installation

```
```

## Usage

```bash
# Run tor project
sudo ./startup.sh -p tor
# Stop tor project, remove built images
sudo ./shutdown.sh -p tor -remove
```

```bash

```

## Generating .onion domain

```
# Replace [domain] with string of your choice, rather short like your name or nick, whatever.
docker run --volume ./domain:/root/mkp224o ghcr.io/vansergen/mkp224o -B -S 5 -t 5 -n 1 [domain]
```
