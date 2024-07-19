import os
import sys

domains = sys.argv[1:-1]
hostname = sys.argv[-1]

print("Received domains:")
for domain in domains:
    print(domain)

print(f"Received hostname: {hostname}")
