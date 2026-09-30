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