#!/bin/bash

if [ "$SELECTED" = "true" ]; then
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
