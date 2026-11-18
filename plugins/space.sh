#!/bin/bash

# Handle clicks to switch desktops
if [ "$1" = "click" ]; then
  TARGET_SID="${2:-${NAME#space.}}"

  # Attempt yabai space focus first
  yabai -m space --focus "$TARGET_SID" 2>/dev/null && exit 0

  # Fallback to macOS Mission Control keycodes:
  # 1->18, 2->19, 3->20, 4->21, 5->23, 6->22, 7->26, 8->28, 9->25
  case "$TARGET_SID" in
    1) KEY=18 ;;
    2) KEY=19 ;;
    3) KEY=20 ;;
    4) KEY=21 ;;
    5) KEY=23 ;;
    6) KEY=22 ;;
    7) KEY=26 ;;
    8) KEY=28 ;;
    9) KEY=25 ;;
    *) KEY="" ;;
  esac

  if [ -n "$KEY" ]; then
    osascript -e "tell application \"System Events\" to key code $KEY using control down" 2>/dev/null
  fi
  exit 0
fi

# Visual state update:
# SketchyBar passes $SELECTED as "true" or "false" for space items
if [ -n "$SELECTED" ]; then
  IS_ACTIVE="$SELECTED"
else
  # Fallback if invoked outside of a SketchyBar space event
  SID="${NAME#space.}"
  FOCUSED_SPACE="$(yabai -m query --spaces --space 2>/dev/null | jq -r '.index // empty')"
  if [ -n "$FOCUSED_SPACE" ] && [ "$FOCUSED_SPACE" = "$SID" ]; then
    IS_ACTIVE=true
  else
    IS_ACTIVE=false
  fi
fi

# Palette for space pill backgrounds
SPACE_COLORS=(
  "0xff8f47f6" # 1: Purple
  "0xffa7d6f6" # 2: Sky Blue
  "0xffdbc3fc" # 3: Lavender
  "0xfff7fcbd" # 4: Soft Yellow
  "0xfff6c177" # 5: Peach
  "0xffeb6f92" # 6: Rose
  "0xff9ccfd8" # 7: Foam
  "0xffc4a7e7" # 8: Iris
  "0xffea9a97" # 9: Coral
  "0xffe0def4" # 10: Frost
)

SID="${NAME#space.}"
COLOR_INDEX=$(( (SID - 1) % 10 ))
SPACE_COLOR="${SPACE_COLORS[$COLOR_INDEX]}"

if [ "$IS_ACTIVE" = "true" ]; then
  sketchybar --set "$NAME" \
    background.drawing=on \
    background.color="$SPACE_COLOR" \
    background.corner_radius=4 \
    background.height=24 \
    background.y_offset=0 \
    icon.color=0xff24273a \
    icon.background.drawing=off
else
  sketchybar --set "$NAME" \
    background.drawing=on \
    background.color=0xff343441 \
    background.corner_radius=4 \
    background.height=24 \
    background.y_offset=0 \
    icon.color=0xff888899 \
    icon.background.drawing=off
fi