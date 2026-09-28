#!/bin/bash

# Query current microphone input volume (0 = muted)
MIC_VOL="$(osascript -e 'input volume of (get volume settings)' 2>/dev/null || echo "100")"

if [[ "$MIC_VOL" == "0" ]]; then
  # Muted: Red icon with slashed microphone
  sketchybar --set "$NAME" icon="" icon.color=0xffff5555
else
  # Active: White icon with active microphone
  sketchybar --set "$NAME" icon="" icon.color=0xffffffff
fi
