#!/bin/bash

VOLUME="$(osascript -e 'output volume of (get volume settings)' 2>/dev/null || echo 0)"
MUTED="$(osascript -e 'output muted of (get volume settings)' 2>/dev/null || echo false)"

if [[ "$MUTED" == "true" || "$VOLUME" == "0" ]]; then
  ICON="󰖁"
  LABEL="muted"
else
  ICON="󰕾"
  LABEL="${VOLUME}%"
fi

sketchybar --set "$NAME" icon="$ICON" label="$LABEL"
