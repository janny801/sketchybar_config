#!/bin/bash

INFO="$(pmset -g batt)"
PERCENT=$(echo "$INFO" | grep -Eo '[0-9]+%' | tr -d '%')

CHARGING=0
echo "$INFO" | grep -qi "AC Power" && CHARGING=1

if [ "$CHARGING" -eq 1 ]; then
  ICON="󰂄"
else
  if [ "$PERCENT" -ge 80 ]; then ICON="󰁹"
  elif [ "$PERCENT" -ge 60 ]; then ICON="󰂀"
  elif [ "$PERCENT" -ge 40 ]; then ICON="󰁾"
  elif [ "$PERCENT" -ge 20 ]; then ICON="󰁼"
  else ICON="󰂎"
  fi
fi

sketchybar --set "$NAME" icon="$ICON" label="${PERCENT}%"
