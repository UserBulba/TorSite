#!/bin/bash
set -e

# Start Tor in the background
tor -f "/etc/tor/torrc" &

# Wait for the log file to indicate that Tor is fully bootstrapped
echo "Waiting for Tor to be fully operational..."
while ! grep -q "Bootstrapped 100% (done): Done" /var/log/tor/notices.log; do
    sleep 1
done

# Start Vanguard after Tor is ready
echo "Starting Vanguard..."
exec vanguards