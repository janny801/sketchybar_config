#!/bin/bash

# ==============================================================================
# Animated Synthwave Gradient Pulse for SketchyBar
# Continuously animates the bar color between deep synthwave night tones:
# Dark Indigo -> Deep Purple -> Dark Magenta -> Night Violet
# ==============================================================================

PID_FILE="/tmp/sketchybar_synthwave_bg.pid"

trap 'rm -f "$PID_FILE"; exit 0' SIGTERM SIGINT EXIT

# Gradient cycle palette (dark synthwave horizon tones)
COLORS=(
  "0xcc190a2c" # Dark Indigo
  "0xcc2a083d" # Deep Violet
  "0xcc3b0946" # Dark Plum
  "0xcc460c38" # Synthwave Magenta
  "0xcc3b0946" # Dark Plum
  "0xcc2a083d" # Deep Violet
  "0xcc190a2c" # Dark Indigo
  "0xcc0a122c" # Deep Midnight Blue
  "0xcc081b33" # Dark Cyan Night
  "0xcc0a122c" # Deep Midnight Blue
)

while true; do
  pgrep -x sketchybar >/dev/null || exit 0

  for color in "${COLORS[@]}"; do
    pgrep -x sketchybar >/dev/null || exit 0
    sketchybar --animate sin 25 --bar color="$color"
    sleep 2.2
  done
done
