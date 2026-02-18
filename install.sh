#!/bin/bash

set -e

USER_NAME=$(whoami)
HOME_DIR="$HOME"
INSTALL_DIR="$HOME_DIR/RPI-waveshare-tft-clock"

echo "=========================================="
echo " Installing RPI Waveshare TFT Clock"
echo " User: $USER_NAME"
echo " Install dir: $INSTALL_DIR"
echo "=========================================="

# Verify repo exists
if [ ! -d "$INSTALL_DIR" ]; then
    echo "ERROR: $INSTALL_DIR not found."
    echo "Clone the repo into your home directory first."
    exit 1
fi

if [ ! -d "$INSTALL_DIR/bin" ] || [ ! -d "$INSTALL_DIR/service-launchers" ]; then
    echo "ERROR: Required directories missing (bin/ or service-launchers/)."
    exit 1
fi

echo "=== Updating package lists ==="
sudo apt update

echo "=== Installing Python 3.11 and dependencies ==="
sudo apt install -y \
    python3.11 \
    python3.11-venv \
    python3-gi \
    python3-gi-cairo \
    gir1.2-gtk-3.0 \
    xdotool \
    xprintidle

# Verify python3.11 exists
if [ ! -x /usr/bin/python3.11 ]; then
    echo "ERROR: python3.11 not found after install."
    exit 1
fi

echo "=== Verifying GTK bindings for python3.11 ==="
if ! /usr/bin/python3.11 -c "import gi" 2>/dev/null; then
    echo "ERROR: python3.11 cannot import gi."
    echo "Make sure python3-gi is installed for system Python."
    exit 1
fi

echo "=== Setting executable permissions ==="
chmod +x "$INSTALL_DIR/bin/"*.py 2>/dev/null || true
chmod +x "$INSTALL_DIR/service-launchers/"*.sh 2>/dev/null || true

echo "=== Installing autostart entry ==="

AUTOSTART_DIR="$HOME_DIR/.config/autostart"
mkdir -p "$AUTOSTART_DIR"

cat > "$AUTOSTART_DIR/idle-clock-launcher.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Idle Clock Launcher
Exec=$INSTALL_DIR/service-launchers/idle_clock_launcher.sh
X-GNOME-Autostart-enabled=true
EOF

echo "=== Removing legacy autostarts (if present) ==="
rm -f "$AUTOSTART_DIR/clock-fullscreen.desktop" || true

echo ""
echo "=========================================="
echo " Installation complete."
echo " Python 3.11 verified."
echo " Reboot recommended."
echo "=========================================="
