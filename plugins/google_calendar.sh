#!/bin/bash

if [ "$SENDER" = "mouse.entered" ]; then
  ~/.config/sketchybar/plugins/google_calendar.py full
elif [ "$SENDER" = "mouse.exited" ]; then
  ~/.config/sketchybar/plugins/google_calendar.py
else
  ~/.config/sketchybar/plugins/google_calendar.py
fi
