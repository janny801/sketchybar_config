#!/bin/bash

ASSERTIONS_FILE="$HOME/Library/DoNotDisturb/DB/Assertions.json"

if [ -r "$ASSERTIONS_FILE" ] && jq -e '
  (.data[0].storeAssertionRecords // []) | length > 0
' "$ASSERTIONS_FILE" >/dev/null 2>&1; then
  sketchybar --set "$NAME" \
    drawing=on \
    icon="󰽥" \
    icon.font="JetBrainsMono Nerd Font:Regular:16" \
    icon.color=0xffffffff
else
  sketchybar --set "$NAME" drawing=off
fi
