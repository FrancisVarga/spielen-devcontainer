#!/bin/bash

# Start SSH service
service ssh start

# Switch to developer user and start bash
exec su - developer
