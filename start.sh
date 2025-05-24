#!/bin/bash

# Start SSH service
service ssh start

# Keep the container running indefinitely
# This allows SSH access while keeping the container alive in detached mode
exec tail -f /dev/null
