#!/bin/bash

# Query yabai space type
MODE=$(yabai -m query --spaces --space 2>/dev/null | jq -r '.type')

case "$MODE" in
  bsp)
    sketchybar --set "$NAME" \
      icon="󰕰" \
      label="BSP" \
      icon.color=0xff24273a \
      label.color=0xff24273a \
      background.color=0xffa6da95
    ;;
  float)
    sketchybar --set "$NAME" \
      icon="󰀻" \
      label="FLOAT" \
      icon.color=0xffcad3f5 \
      label.color=0xffcad3f5 \
      background.color=0xff363a4f
    ;;
  *)
    # Fallback if yabai offline or query empty
    sketchybar --set "$NAME" \
      icon="󰕰" \
      label="--" \
      icon.color=0xffcad3f5 \
      label.color=0xffcad3f5 \
      background.color=0xff343441
    ;;
esac
