#!/bin/bash

STATE="$(defaults read /Library/Preferences/com.apple.Bluetooth ControllerPowerState 2>/dev/null || echo 0)"

if [ "$STATE" = "1" ]; then
  ICON="󰂯"   # bluetooth on
  sketchybar --set "$NAME" icon="$ICON" label.drawing=off
else
  sketchybar --set "$NAME" drawing=off
fi
