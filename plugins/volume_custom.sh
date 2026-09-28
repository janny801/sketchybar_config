#!/bin/bash

VOLUME="$(osascript -e 'output volume of (get volume settings)')"
MUTED="$(osascript -e 'output muted of (get volume settings)')"

if [[ "$MUTED" == "true" || "$VOLUME" == "0" ]]; then
  ICON=""
else
  ICON=""
fi

sketchybar --set volume_icon icon="$ICON"
sketchybar --set volume_bar slider.percentage="$VOLUME"
