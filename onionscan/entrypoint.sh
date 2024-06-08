#!/bin/sh

# Start Tor in the background
tor &

# Wait for the log file to be created
while [ ! -f /var/log/tor/notices.log ]; do
  sleep 1
done

# Check for Tor readiness
echo "Waiting for Tor to establish a connection..."
while ! grep -q "Bootstrapped 100% (done): Done" /var/log/tor/notices.log; do
  sleep 1
done
sleep 5 # Sleep for a few more seconds to ensure Tor is fully operational
echo "Tor is fully operational."

# Run OnionScan with the domain provided as an argument
onionscan -verbose --torProxyAddress 127.0.0.1:9050 "$1"

# Optionally, keep the container running if needed
# tail -f /dev/null
