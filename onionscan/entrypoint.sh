#!/bin/sh

# Start Tor in the background
tor &
# Use tail to keep the container running
tail -f /dev/null
