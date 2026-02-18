#!/bin/bash
export DISPLAY=:0
export XAUTHORITY=/run/user/1000/gdm/Xauthority

# Clear the workspace overview

sleep 5
xdotool key Super
# sleep 0.2
# xdotool key Super

# Wait a set amount of time idle until clock appears

IDLE_MS=10000


while true; do
  idle=$(xprintidle 2>/dev/null || echo 0)

  if [ "$idle" -ge "$IDLE_MS" ]; then
    # Launch if not already running
    if ! pgrep -f "/home/mr_tbot/bin/clock_gtk.py" >/dev/null 2>&1; then
      /usr/bin/python3.11 /home/mr_tbot/bin/clock_gtk.py >/dev/null 2>&1 &
      sleep 1
    fi
  fi

  sleep 2
done


