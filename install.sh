#!/bin/bash

# =============================================================================
#  CLOCK CONFIGURATION
#  Edit these values, then re-run ./install.sh to apply changes.
# =============================================================================

# -- Top label (displayed above the clock) ------------------------------------
SHOW_LABEL="true"          # true | false
LABEL_TEXT="BOTSERVER-HK"  # Any text string

# -- Time format ---------------------------------------------------------------
CLOCK_24HR="false"         # true = 24-hour  |  false = 12-hour with AM/PM

# -- Date style ----------------------------------------------------------------
# weekday-mdy  →  Wednesday / 02-19-2026   (US)
# weekday-dmy  →  Wednesday / 19-02-2026   (EU)
# weekday-iso  →  Wednesday / 2026-02-19   (ISO)
# mdy          →  02-19-2026
# dmy          →  19-02-2026
# iso          →  2026-02-19
# none         →  (no date shown)
DATE_STYLE="weekday-mdy"

# -- Colors (CSS hex values) --------------------------------------------------
COLOR_BG="#000000"         # Window background
COLOR_TIME="#ff8c00"       # Time digits
COLOR_DATE="#9aa0a6"       # Date text
COLOR_LABEL="#9aa0a6"      # Top label text

# -- Idle timeout --------------------------------------------------------------
IDLE_TIMEOUT_MS=60000      # Milliseconds of inactivity before clock appears

# =============================================================================
#  END CONFIG — do not edit below this line unless you know what you're doing
# =============================================================================

set -e

USER_NAME=$(whoami)
HOME_DIR="$HOME"
INSTALL_DIR="$HOME_DIR/RPI-waveshare-tft-clock"
BIN_DIR="$HOME_DIR/bin"
DEST_SCRIPT="$BIN_DIR/clock_gtk.py"

echo "=========================================="
echo " Installing RPI Waveshare TFT Clock"
echo " User:        $USER_NAME"
echo " Install dir: $INSTALL_DIR"
echo " Clock script: $DEST_SCRIPT"
echo "=========================================="
echo ""
echo " Config:"
echo "   SHOW_LABEL    = $SHOW_LABEL"
echo "   LABEL_TEXT    = $LABEL_TEXT"
echo "   CLOCK_24HR    = $CLOCK_24HR"
echo "   DATE_STYLE    = $DATE_STYLE"
echo "   COLOR_BG      = $COLOR_BG"
echo "   COLOR_TIME    = $COLOR_TIME"
echo "   COLOR_DATE    = $COLOR_DATE"
echo "   COLOR_LABEL   = $COLOR_LABEL"
echo "   IDLE_TIMEOUT  = ${IDLE_TIMEOUT_MS}ms"
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

echo ""
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

# ---------------------------------------------------------------------------
# Deploy clock script with baked-in config
# ---------------------------------------------------------------------------
echo "=== Deploying clock script to $DEST_SCRIPT ==="
mkdir -p "$BIN_DIR"
cp "$INSTALL_DIR/bin/clock_gtk.py" "$DEST_SCRIPT"

# Convert shell booleans → Python booleans
if [ "$SHOW_LABEL" = "true" ]; then PY_SHOW_LABEL="True"; else PY_SHOW_LABEL="False"; fi
if [ "$CLOCK_24HR" = "true" ]; then PY_CLOCK_24HR="True"; else PY_CLOCK_24HR="False"; fi

# Bake config values into the deployed script using sed
# (format matches the named constants at the top of clock_gtk.py)
sed -i "s|^COLOR_BG    = .*|COLOR_BG    = \"${COLOR_BG}\"|"       "$DEST_SCRIPT"
sed -i "s|^COLOR_TIME  = .*|COLOR_TIME  = \"${COLOR_TIME}\"|"     "$DEST_SCRIPT"
sed -i "s|^COLOR_DATE  = .*|COLOR_DATE  = \"${COLOR_DATE}\"|"     "$DEST_SCRIPT"
sed -i "s|^COLOR_LABEL = .*|COLOR_LABEL = \"${COLOR_LABEL}\"|"   "$DEST_SCRIPT"
sed -i "s|^LABEL_TEXT  = .*|LABEL_TEXT  = \"${LABEL_TEXT}\"|"     "$DEST_SCRIPT"
sed -i "s|^SHOW_LABEL  = .*|SHOW_LABEL  = ${PY_SHOW_LABEL}|"     "$DEST_SCRIPT"
sed -i "s|^CLOCK_24HR  = .*|CLOCK_24HR  = ${PY_CLOCK_24HR}|"     "$DEST_SCRIPT"
sed -i "s|^DATE_STYLE  = .*|DATE_STYLE  = \"${DATE_STYLE}\"|"     "$DEST_SCRIPT"

chmod +x "$DEST_SCRIPT"

# ---------------------------------------------------------------------------
# Deploy idle launcher with baked-in config
# ---------------------------------------------------------------------------
LAUNCHER="$INSTALL_DIR/service-launchers/idle_clock_launcher.sh"
echo "=== Writing launcher: $LAUNCHER ==="

cat > "$LAUNCHER" << LAUNCHER_EOF
#!/bin/bash
export DISPLAY=:0
export XAUTHORITY=/run/user/$(id -u)/gdm/Xauthority

# Dismiss the GNOME Activities overview at login
sleep 5
xdotool key Super

# Idle threshold before clock appears
IDLE_MS=${IDLE_TIMEOUT_MS}

while true; do
  idle=\$(xprintidle 2>/dev/null || echo 0)

  if [ "\$idle" -ge "\$IDLE_MS" ]; then
    if ! pgrep -f "${DEST_SCRIPT}" >/dev/null 2>&1; then
      /usr/bin/python3.11 "${DEST_SCRIPT}" >/dev/null 2>&1 &
      sleep 1
    fi
  fi

  sleep 2
done
LAUNCHER_EOF

chmod +x "$LAUNCHER"

# ---------------------------------------------------------------------------
# Autostart entry
# ---------------------------------------------------------------------------
echo "=== Installing autostart entry ==="
AUTOSTART_DIR="$HOME_DIR/.config/autostart"
mkdir -p "$AUTOSTART_DIR"

cat > "$AUTOSTART_DIR/idle-clock-launcher.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Idle Clock Launcher
Exec=$LAUNCHER
X-GNOME-Autostart-enabled=true
EOF

echo "=== Removing legacy autostarts (if present) ==="
rm -f "$AUTOSTART_DIR/clock-fullscreen.desktop" || true

echo ""
echo "=========================================="
echo " Installation complete."
echo " Clock script: $DEST_SCRIPT"
echo " Launcher:     $LAUNCHER"
echo " Autostart:    $AUTOSTART_DIR/idle-clock-launcher.desktop"
echo " Reboot recommended."
echo "=========================================="
