#!/bin/bash
# Launch script for Raspberry Pi Waveshare TFT Clock
# Starts the clock in full screen mode

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Starting TFT Clock..."
echo "Press Ctrl+C to stop"

# Change to script directory
cd "$SCRIPT_DIR"

# Run the clock
python3 clock.py
