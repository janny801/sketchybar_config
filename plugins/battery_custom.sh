#!/bin/bash

# ==============================================================================
# Battery Plugin for SketchyBar
# - Not plugged in: Level-based icon & gradient color (Green -> Yellow -> Red)
# - Low Power Mode: Animated breathing yellow glow
# - Charging: Animated electric blue fill sequence
# ==============================================================================

ANIM_PID_FILE="/tmp/sketchybar_battery_anim.pid"
STATE_FILE="/tmp/sketchybar_battery_state"

kill_animator() {
  if [ -f "$ANIM_PID_FILE" ]; then
    local pid
    pid=$(cat "$ANIM_PID_FILE" 2>/dev/null)
    if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null
    fi
    rm -f "$ANIM_PID_FILE"
  fi
}

get_battery_icon() {
  local p="$1"
  if [ "$p" -ge 95 ]; then
    echo "󰁹"
  elif [ "$p" -ge 85 ]; then
    echo "󰂂"
  elif [ "$p" -ge 75 ]; then
    echo "󰂁"
  elif [ "$p" -ge 65 ]; then
    echo "󰂀"
  elif [ "$p" -ge 55 ]; then
    echo "󰁿"
  elif [ "$p" -ge 45 ]; then
    echo "󰁾"
  elif [ "$p" -ge 35 ]; then
    echo "󰁽"
  elif [ "$p" -ge 25 ]; then
    echo "󰁼"
  elif [ "$p" -ge 15 ]; then
    echo "󰁻"
  elif [ "$p" -ge 5 ]; then
    echo "󰁺"
  else
    echo "󰂃"
  fi
}

get_discharging_color() {
  local p="$1"
  if [ "$p" -ge 70 ]; then
    echo "0xff4cd964" # Vibrant Green
  elif [ "$p" -ge 50 ]; then
    echo "0xffa6e3a1" # Yellow-Green
  elif [ "$p" -ge 30 ]; then
    echo "0xffffcc00" # Warm Yellow
  elif [ "$p" -ge 15 ]; then
    echo "0xffff9500" # Orange
  else
    echo "0xffff3b30" # Alert Red
  fi
}

run_charging_loop() {
  trap 'rm -f "$ANIM_PID_FILE"; exit 0' SIGTERM SIGINT EXIT
  
  local frames=("󰢜" "󰂆" "󰂈" "󰢝" "󰂊" "󰂅")
  local blue="0xff38bdf8"
  
  while true; do
    pgrep -x sketchybar >/dev/null || exit 0
    
    local b_info
    b_info=$(pmset -g batt)
    if ! echo "$b_info" | grep -qE "AC Power|charging"; then
      exit 0
    fi
    
    local pct
    pct=$(echo "$b_info" | grep -Eo "[0-9]+%" | head -n 1 | tr -d '%')
    pct="${pct:-100}"
    
    for frame in "${frames[@]}"; do
      sketchybar --set battery \
        icon="$frame" \
        icon.font="JetBrainsMono Nerd Font:Regular:14" \
        icon.color="$blue" \
        label="${pct}%" \
        label.color="$blue" \
        label.drawing=on
      sleep 0.5
    done
  done
}

run_lowpower_loop() {
  trap 'rm -f "$ANIM_PID_FILE"; exit 0' SIGTERM SIGINT EXIT
  
  local yellow_bright="0xffffcc00"
  local yellow_dim="0x66ffcc00"
  
  while true; do
    pgrep -x sketchybar >/dev/null || exit 0
    
    local lpm
    lpm=$(pmset -g | grep -w "lowpowermode" | awk '{print $2}')
    if [ "$lpm" != "1" ]; then
      exit 0
    fi
    
    local b_info
    b_info=$(pmset -g batt)
    local pct
    pct=$(echo "$b_info" | grep -Eo "[0-9]+%" | head -n 1 | tr -d '%')
    pct="${pct:-50}"
    
    local icon
    icon=$(get_battery_icon "$pct")
    
    sketchybar --animate sin 20 --set battery \
      icon="$icon" \
      icon.font="JetBrainsMono Nerd Font:Regular:14" \
      icon.color="$yellow_bright" \
      label="${pct}%" \
      label.color="$yellow_bright" \
      label.drawing=on
    sleep 0.8
    
    sketchybar --animate sin 20 --set battery \
      icon.color="$yellow_dim" \
      label.color="$yellow_dim"
    sleep 0.8
  done
}

# 1. Read battery info from macOS pmset
BATTERY_INFO=$(pmset -g batt)
BATTERY_PERCENT=$(echo "$BATTERY_INFO" | grep -Eo "[0-9]+%" | head -n 1 | tr -d '%')

if [ -z "$BATTERY_PERCENT" ]; then
  exit 0
fi

IS_CHARGING=$(echo "$BATTERY_INFO" | grep -E "AC Power|charging")
LOW_POWER_MODE=$(pmset -g | grep -w "lowpowermode" | awk '{print $2}')

# 2. Determine target state
if [ -n "$IS_CHARGING" ]; then
  TARGET_STATE="charging"
elif [ "$LOW_POWER_MODE" = "1" ]; then
  TARGET_STATE="lowpower"
else
  TARGET_STATE="discharging"
fi

PREV_STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "")

# If state transitioned, kill existing animator
if [ "$TARGET_STATE" != "$PREV_STATE" ]; then
  kill_animator
  echo "$TARGET_STATE" > "$STATE_FILE"
fi

# Check if animator is currently alive
ANIM_RUNNING=false
if [ -f "$ANIM_PID_FILE" ]; then
  CURRENT_PID=$(cat "$ANIM_PID_FILE" 2>/dev/null)
  if [ -n "$CURRENT_PID" ] && kill -0 "$CURRENT_PID" 2>/dev/null; then
    ANIM_RUNNING=true
  fi
fi

# 3. Handle state execution
case "$TARGET_STATE" in
  "charging")
    if [ "$ANIM_RUNNING" = false ]; then
      run_charging_loop &
      echo $! > "$ANIM_PID_FILE"
    fi
    ;;

  "lowpower")
    if [ "$ANIM_RUNNING" = false ]; then
      run_lowpower_loop &
      echo $! > "$ANIM_PID_FILE"
    fi
    ;;

  "discharging")
    kill_animator
    ICON=$(get_battery_icon "$BATTERY_PERCENT")
    COLOR=$(get_discharging_color "$BATTERY_PERCENT")
    
    sketchybar --set battery \
      icon="$ICON" \
      icon.font="JetBrainsMono Nerd Font:Regular:14" \
      icon.color="$COLOR" \
      label="${BATTERY_PERCENT}%" \
      label.color="$COLOR" \
      label.drawing=on
    ;;
esac