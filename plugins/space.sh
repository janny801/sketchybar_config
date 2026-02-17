#!/bin/bash

if [ "$SELECTED" = "true" ]; then
  sketchybar --set "$NAME" \
    background.drawing=on \
    background.height=2 \
    background.y_offset=12 \
    background.color=0xffffffff
else
  sketchybar --set "$NAME" \
    background.drawing=off
fi
