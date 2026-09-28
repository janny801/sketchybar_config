#!/bin/bash

SID="${NAME#space.}"

FOCUSED_SPACE="$(yabai -m query --spaces --space 2>/dev/null | jq -r '.index // empty')"

if [ -n "$FOCUSED_SPACE" ]; then
  if [ "$FOCUSED_SPACE" = "$SID" ]; then
    IS_ACTIVE=true
  else
    IS_ACTIVE=false
  fi
else
  if [ "$SELECTED" = "true" ]; then
    IS_ACTIVE=true
  else
    IS_ACTIVE=false
  fi
fi

if [ "$IS_ACTIVE" = "true" ]; then
  sketchybar --set "$NAME" \
    background.drawing=on \
    background.height=2 \
    background.y_offset=12 \
    background.corner_radius=1 \
    background.color=0xffffffff \
    icon.background.drawing=on \
    icon.background.color=0x22ffffff \
    icon.background.corner_radius=6 \
    icon.background.height=18 \
    icon.background.padding_left=6 \
    icon.background.padding_right=6
else
  sketchybar --set "$NAME" \
    background.drawing=off \
    icon.background.drawing=off
fi