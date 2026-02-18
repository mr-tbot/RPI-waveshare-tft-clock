#!/usr/bin/python3.11
import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, Gdk, GLib
from datetime import datetime

ORANGE = "#ff8c00"
GREY = "#9aa0a6"

CSS = f"""
window {{
  background: #000000;
}}

#server {{
  color: {GREY};
  font: 18px monospace;
}}

#time {{
  color: {ORANGE};
  font: 64px monospace;
  font-weight: 700;
}}

#date {{
  color: {GREY};
  font: 28px monospace;
}}
"""

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

        # Apply CSS styling
        provider = Gtk.CssProvider()
        provider.load_from_data(CSS.encode("utf-8"))
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
        )

        # Root container expands full screen
        root = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        root.set_hexpand(True)
        root.set_vexpand(True)
        self.add(root)

        # Centered content container
        center = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        center.set_hexpand(True)
        center.set_vexpand(True)
        center.set_halign(Gtk.Align.FILL)
        center.set_valign(Gtk.Align.CENTER)

        # Server label
        self.server_lbl = Gtk.Label(label="BOTSERVER-HK")
        self.server_lbl.set_name("server")
        self.server_lbl.set_hexpand(True)
        self.server_lbl.set_halign(Gtk.Align.CENTER)
        self.server_lbl.set_xalign(0.5)

        # Time label
        self.time_lbl = Gtk.Label()
        self.time_lbl.set_name("time")
        self.time_lbl.set_hexpand(True)
        self.time_lbl.set_halign(Gtk.Align.CENTER)
        self.time_lbl.set_xalign(0.5)

        # Date label (multiline, must be centered)
        self.date_lbl = Gtk.Label()
        self.date_lbl.set_name("date")
        self.date_lbl.set_hexpand(True)
        self.date_lbl.set_halign(Gtk.Align.CENTER)
        self.date_lbl.set_xalign(0.5)
        self.date_lbl.set_justify(Gtk.Justification.CENTER)

        center.pack_start(self.server_lbl, False, False, 8)
        center.pack_start(self.time_lbl, False, False, 0)
        center.pack_start(self.date_lbl, False, False, 0)

        root.pack_start(center, True, True, 0)

        # Keyboard exit too
        self.connect("key-press-event", self.on_key)

        self.update()
        GLib.timeout_add(250, self.update)

    def on_tap(self, *_args):
        Gtk.main_quit()

    def on_key(self, _widget, event):
        key = Gdk.keyval_name(event.keyval)
        if key in ("Escape", "q", "Q"):
            Gtk.main_quit()

    def update(self):
        now = datetime.now()

        # 12-hour time with AM/PM uppercase, no timezone
        time_str = now.strftime("%I:%M:%S %p").lstrip("0").upper()

        # Weekday + mm-dd-yyyy on separate lines
        date_str = now.strftime("%A\n%m-%d-%Y")

        self.time_lbl.set_text(time_str)
        self.date_lbl.set_text(date_str)
        return True

if __name__ == "__main__":
    win = Clock()
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    Gtk.main()
