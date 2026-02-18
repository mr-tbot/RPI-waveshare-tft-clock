#!/bin/bash
# Installation script for Raspberry Pi Waveshare TFT Clock
# This script installs dependencies and configures the system

set -e

echo "================================"
echo "RPI Waveshare TFT Clock Installer"
echo "================================"
echo ""

# Check if running on Raspberry Pi
if [ ! -f /proc/device-tree/model ]; then
    echo "Warning: This doesn't appear to be a Raspberry Pi"
    echo "Installation will continue but hardware features may not work"
fi

# Update package lists
echo "Updating package lists..."
sudo apt-get update

# Install Python 3 and pip if not already installed
echo "Installing Python 3 and dependencies..."
sudo apt-get install -y python3 python3-pip python3-dev

# Install SDL and graphics libraries for pygame
echo "Installing SDL libraries for display..."
sudo apt-get install -y libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev \
    libfreetype6-dev libportmidi-dev libjpeg-dev python3-setuptools python3-numpy

# Install Python requirements
echo "Installing Python packages..."
pip3 install --user -r requirements.txt

# Make scripts executable
echo "Setting script permissions..."
chmod +x clock.py
chmod +x launch.sh

# Install systemd service (optional)
read -p "Would you like to install the clock as a systemd service (auto-start on boot)? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing systemd service..."
    sudo cp clock.service /etc/systemd/system/
    
    # Update the service file with the current directory
    CURRENT_DIR=$(pwd)
    sudo sed -i "s|/path/to/clock|$CURRENT_DIR|g" /etc/systemd/system/clock.service
    
    sudo systemctl daemon-reload
    sudo systemctl enable clock.service
    
    echo "Service installed. You can start it with: sudo systemctl start clock.service"
fi

echo ""
echo "================================"
echo "Installation complete!"
echo "================================"
echo ""
echo "To start the clock manually, run: ./launch.sh"
echo "To enable the framebuffer for Waveshare display, you may need to configure /boot/config.txt"
echo ""
echo "For Waveshare 3.5\" LCD (B), add these lines to /boot/config.txt:"
echo "  dtparam=spi=on"
echo "  dtoverlay=waveshare35b"
echo ""
echo "Then reboot your Raspberry Pi."
