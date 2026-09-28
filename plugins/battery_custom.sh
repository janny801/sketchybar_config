#!/bin/bash

BATTERY_INFO=$(pmset -g batt)

BATTERY_PERCENT=$(echo "$BATTERY_INFO" | grep -Eo "[0-9]+%" | tr -d '%')
CHARGING=$(echo "$BATTERY_INFO" | grep "AC Power")

# fallback protection
if [ -z "$BATTERY_PERCENT" ]; then
  exit 0
fi

if [[ "$CHARGING" != "" ]]; then
  ICON="󰂄"
else
  if [ "$BATTERY_PERCENT" -ge 90 ]; then
    ICON="󰁹"
  elif [ "$BATTERY_PERCENT" -ge 60 ]; then
    ICON="󰂀"
  elif [ "$BATTERY_PERCENT" -ge 30 ]; then
    ICON="󰁿"
  else
    ICON="󰁺"
  fi
fi

sketchybar --set battery \
  icon="$ICON" \
  icon.font="JetBrainsMono Nerd Font:Regular:14" \
  icon.color=0xffffffff \
  label="${BATTERY_PERCENT}%" \
  label.drawing=on