#!/bin/bash

# Query current microphone input volume (0 = muted)
MIC_VOL="$(osascript -e 'input volume of (get volume settings)' 2>/dev/null || echo "100")"

if [[ "$MIC_VOL" == "0" ]]; then
  # Muted: Red icon with slashed microphone on soft pink pill
  sketchybar --set "$NAME" icon="" icon.color=0xffe64553 background.color=0xfff5c2e7
else
  # Active: Dark contrast icon with active microphone on soft pink pill
  sketchybar --set "$NAME" icon="" icon.color=0xff24273a background.color=0xfff5c2e7
fi
