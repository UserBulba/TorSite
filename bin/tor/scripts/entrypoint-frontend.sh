#!/bin/sh

set -e

# Start Tor in the background
tor -f "/etc/tor/torrc" &

# Wait for the log file to be created
while [ ! -f /var/log/tor/notices.log ]; do
    sleep 1
done

# Wait for the log file to indicate that Tor is fully bootstrapped
echo "Waiting for Tor to establish a connection..."
while ! grep -q "Bootstrapped 100% (done): Done" /var/log/tor/notices.log; do
    sleep 1
done

exec supervisord -c /supervisor/supervisord.conf
