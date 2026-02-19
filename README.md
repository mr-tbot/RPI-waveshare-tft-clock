RPI Waveshare TFT Clock

A fullscreen, touch-dismissable, idle-activated digital clock for Raspberry Pi running Debian + GNOME.

Designed specifically for Waveshare TFT displays on Raspberry Pi 5, but works on any X11-based GNOME desktop.

This project turns a Raspberry Pi into a wall-mounted time appliance:

• After 60 seconds of inactivity → clock appears
• Tap the screen → clock disappears
• Idle again → clock returns
• No GNOME screensaver hacks
• No compositor fighting
• No kiosk mode required

Features

Fullscreen GTK3 application

12-hour clock with AM / PM (uppercase)

Date in MM-DD-YYYY format

Weekday shown above date

Centered layout

Orange time, grey date

Black background

Touch or mouse tap to close

Automatically reappears after idle

GNOME Overview auto-dismiss on boot

Designed for Python 3.11

Directory Structure
RPI-waveshare-tft-clock/
├── bin/
│   └── clock_gtk.py
├── service-launchers/
│   └── idle_clock_launcher.sh
├── install.sh
└── README.md

Requirements

Debian Bookworm (or compatible)

GNOME running on X11

Python 3.11

Waveshare TFT or compatible display

Installation

Clone the repository into your home directory:

git clone https://github.com/mr-tbot/RPI-waveshare-tft-clock.git
cd RPI-waveshare-tft-clock


Run the installer:

chmod +x install.sh
./install.sh


Reboot:

sudo reboot

How It Works

At login:

GNOME starts

The launcher exits the Activities overview

A background idle watcher starts

After 60 seconds of no input → clock launches

Tap screen → clock exits

Idle again → clock relaunches

No GNOME screensaver is used.

Idle detection is handled using:

xprintidle


Clock rendering is handled by:

GTK3 via PyGObject

Configuration
Change Idle Timeout

Edit:

service-launchers/idle_clock_launcher.sh


Modify:

IDLE_MS=60000


Example for 30 seconds:

IDLE_MS=30000

Change Colors or Font Size

Edit:

bin/clock_gtk.py


Modify CSS section:

ORANGE = "#ff8c00"
GREY = "#9aa0a6"


Adjust font sizes:

font: 64px monospace;
font: 28px monospace;

Troubleshooting
Clock does not appear

Check idle detection:

xprintidle


If it errors, confirm:

echo $DISPLAY


Should be :0.

Python gi import error

Verify:

/usr/bin/python3.11 -c "import gi"


If that fails:

sudo apt install python3-gi gir1.2-gtk-3.0

GNOME boots into Activities Overview

The launcher automatically presses Super once at login.

If behavior changes, modify:

service-launchers/idle_clock_launcher.sh

Design Philosophy

This project intentionally avoids:

GNOME screensaver

xscreensaver

Kiosk mode

Mutter hacks

Wayland complexity

Instead it uses:

Deterministic X11 behavior

Idle polling

A clean GTK fullscreen window

Simple shell supervision

The goal is stability and predictability, not cleverness.

Future Ideas

Wayland compatibility

Fade-in animation

Ambient brightness auto-adjust

Network status indicator

Temperature overlay

Systemd user service instead of autostart

License

MIT

Author

Built by TBOT
https://mr-tbot.com