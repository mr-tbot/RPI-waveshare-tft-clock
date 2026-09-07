# Third-party software & attributions

RPI Waveshare TFT Clock is MIT-licensed (see [LICENSE](LICENSE)). Its own code
is four original files — an installer, a PyGObject clock, a launcher and the
documentation. No third-party source, binaries, fonts or images are bundled or
redistributed. Everything the clock needs at run time is installed from the
user's own Debian / Raspberry Pi OS apt mirror by `install.sh` and stays under
its own license.

## Runtime dependencies (installed from your own apt mirror, never shipped here)

### GTK 3 / PyGObject / GObject-Introspection (`python3-gi`, `python3-gi-cairo`, `gir1.2-gtk-3.0`)
- **License:** LGPL-2.1-or-later — the GNOME Project
- **Role:** `bin/clock_gtk.py` calls the public GTK 3 API through GObject-Introspection at run time. No GTK, GLib or PyGObject source is copied, statically linked or redistributed; the LGPL's dynamic-use terms are met by ordinary runtime binding.

### Python 3.11
- **License:** PSF-2.0 — Python Software Foundation
- **Role:** interpreter for `clock_gtk.py`. Provided by the OS.

### xprintidle
- **License:** GPL-2.0-or-later
- **Role:** the launcher polls it as a subprocess to read X11 idle time. Not bundled.

### xdotool
- **License:** BSD-3-Clause
- **Role:** invoked as a subprocess to clear the GNOME overview at login. Not bundled.

## Trademarks
"Waveshare" is a trademark of Waveshare Electronics; "Raspberry Pi" of Raspberry
Pi Ltd; "GNOME" and "Debian" of the GNOME Foundation and Software in the Public
Interest, Inc. respectively. This project is an independent third-party utility,
named for compatibility only, and is not endorsed by or affiliated with any of
them. No Waveshare driver, firmware or kernel module is downloaded, installed or
redistributed by anything in this repository.
