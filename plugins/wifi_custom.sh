#!/bin/bash

DEVICE="en0"

POWER_STATE="$(/usr/sbin/networksetup -getairportpower "$DEVICE" 2>/dev/null)"
ASSOCIATED="$(/sbin/ifconfig "$DEVICE" 2>/dev/null | grep -c 'status: active')"

ICON_ON=""   # Nerd Font wifi icon

if [[ "$POWER_STATE" != *"On"* ]] || [[ "$ASSOCIATED" -eq 0 ]]; then
  sketchybar --set "$NAME" drawing=off
else
  sketchybar --set "$NAME" drawing=on icon="$ICON_ON" label.drawing=off
fi
