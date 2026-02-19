#!/usr/bin/python3.11
#
# clock_gtk.py — Fullscreen idle clock for Raspberry Pi + Waveshare TFT
#
# Config values below are written by install.sh.
# To change them, edit the CONFIG section in install.sh and re-run it.
#
# ---------------------------------------------------------------------------
# CONFIG — written by install.sh, do not edit directly
# ---------------------------------------------------------------------------
COLOR_BG    = "#000000"   # Window background
COLOR_TIME  = "#ff8c00"   # Time digits
COLOR_DATE  = "#9aa0a6"   # Date text
COLOR_LABEL = "#9aa0a6"   # Label text (shown above clock)
LABEL_TEXT  = "BOTSERVER-HK"  # Text for the top label
SHOW_LABEL  = True        # Show the label above the clock
CLOCK_24HR  = False       # True = 24-hour, False = 12-hour with AM/PM
DATE_STYLE  = "weekday-mdy"
# DATE_STYLE options:
#   weekday-mdy  →  Wednesday / 02-19-2026
#   weekday-dmy  →  Wednesday / 19-02-2026
#   weekday-iso  →  Wednesday / 2026-02-19
#   mdy          →  02-19-2026
#   dmy          →  19-02-2026
#   iso          →  2026-02-19
#   none         →  (no date shown)
# ---------------------------------------------------------------------------

import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, Gdk, GLib
from datetime import datetime


def _build_css():
    return f"""
window {{
  background: {COLOR_BG};
}}

#label {{
  color: {COLOR_LABEL};
  font: 18px monospace;
}}

#time {{
  color: {COLOR_TIME};
  font: 64px monospace;
  font-weight: 700;
}}

#date {{
  color: {COLOR_DATE};
  font: 28px monospace;
}}
"""


def _time_string(now):
    if CLOCK_24HR:
        return now.strftime("%H:%M:%S")
    return now.strftime("%I:%M:%S %p").lstrip("0").upper()


def _date_string(now):
    if DATE_STYLE == "weekday-mdy":
        return now.strftime("%A\n%m-%d-%Y")
    if DATE_STYLE == "weekday-dmy":
        return now.strftime("%A\n%d-%m-%Y")
    if DATE_STYLE == "weekday-iso":
        return now.strftime("%A\n%Y-%m-%d")
    if DATE_STYLE == "mdy":
        return now.strftime("%m-%d-%Y")
    if DATE_STYLE == "dmy":
        return now.strftime("%d-%m-%Y")
    if DATE_STYLE == "iso":
        return now.strftime("%Y-%m-%d")
    return ""  # DATE_STYLE == "none" or unrecognised


class Clock(Gtk.Window):
    def __init__(self):
        super().__init__(title="Clock")

        self.set_decorated(False)
        self.fullscreen()
        self.set_keep_above(True)
        self.set_type_hint(Gdk.WindowTypeHint.SPLASHSCREEN)

        # Receive touch/mouse events so tapping closes
        self.add_events(Gdk.EventMask.BUTTON_PRESS_MASK)
        self.connect("button-press-event", self.on_tap)
        self.connect("key-press-event", self.on_key)

        # Apply CSS
        provider = Gtk.CssProvider()
        provider.load_from_data(_build_css().encode("utf-8"))
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
        )

        # Root container — full screen
        root = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        root.set_hexpand(True)
        root.set_vexpand(True)
        self.add(root)

        # Centered content column
        center = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        center.set_hexpand(True)
        center.set_vexpand(True)
        center.set_halign(Gtk.Align.FILL)
        center.set_valign(Gtk.Align.CENTER)

        # Optional top label
        if SHOW_LABEL:
            self.label_lbl = Gtk.Label(label=LABEL_TEXT)
            self.label_lbl.set_name("label")
            self.label_lbl.set_hexpand(True)
            self.label_lbl.set_halign(Gtk.Align.CENTER)
            center.pack_start(self.label_lbl, False, False, 8)

        # Time
        self.time_lbl = Gtk.Label()
        self.time_lbl.set_name("time")
        self.time_lbl.set_hexpand(True)
        self.time_lbl.set_halign(Gtk.Align.CENTER)
        center.pack_start(self.time_lbl, False, False, 0)

        # Date (may be multiline)
        if DATE_STYLE != "none":
            self.date_lbl = Gtk.Label()
            self.date_lbl.set_name("date")
            self.date_lbl.set_hexpand(True)
            self.date_lbl.set_halign(Gtk.Align.CENTER)
            self.date_lbl.set_justify(Gtk.Justification.CENTER)
            center.pack_start(self.date_lbl, False, False, 0)
        else:
            self.date_lbl = None

        root.pack_start(center, True, True, 0)

        self.update()
        GLib.timeout_add(250, self.update)

    def on_tap(self, *_args):
        Gtk.main_quit()

    def on_key(self, _widget, event):
        if Gdk.keyval_name(event.keyval) in ("Escape", "q", "Q"):
            Gtk.main_quit()

    def update(self):
        now = datetime.now()
        self.time_lbl.set_text(_time_string(now))
        if self.date_lbl is not None:
            self.date_lbl.set_text(_date_string(now))
        return True


if __name__ == "__main__":
    win = Clock()
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    Gtk.main()
