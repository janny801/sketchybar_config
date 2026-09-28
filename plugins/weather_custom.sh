#!/bin/bash

# ==============================================================================
# Weather Plugin for SketchyBar
# Displays current outdoor weather condition (minimal icon) and temperature.
# Automatically detects user location via IP or uses WEATHER_LOCATION if set.
# ==============================================================================

CACHE_FILE="/tmp/sketchybar_weather.json"
CACHE_MAX_AGE=900 # 15 minutes in seconds

LOCATION="${WEATHER_LOCATION:-}"
SHOW_UNIT="${WEATHER_SHOW_UNIT:-false}"

fetch_weather() {
  local url="https://wttr.in/${LOCATION}?format=j1"
  local tmp_file="${CACHE_FILE}.tmp"
  
  if curl -s --max-time 6 "$url" > "$tmp_file" 2>/dev/null; then
    # Verify the downloaded file is valid JSON
    if jq -e '.current_condition[0]' "$tmp_file" >/dev/null 2>&1; then
      mv "$tmp_file" "$CACHE_FILE"
      sketchybar --trigger weather_update &>/dev/null
    else
      rm -f "$tmp_file"
    fi
  else
    rm -f "$tmp_file"
  fi
}

# If force refresh requested or cache doesn't exist, fetch
if [ "$1" = "refresh" ] || [ ! -f "$CACHE_FILE" ]; then
  if [ ! -f "$CACHE_FILE" ]; then
    fetch_weather
  else
    (fetch_weather) &
  fi
else
  # Check cache age
  NOW=$(date +%s)
  CACHE_TIME=$(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)
  AGE=$((NOW - CACHE_TIME))
  if [ "$AGE" -gt "$CACHE_MAX_AGE" ]; then
    (fetch_weather) &
  fi
fi

# If no cache exists yet, exit cleanly
if [ ! -f "$CACHE_FILE" ]; then
  exit 0
fi

# Parse weather data
TEMP_F=$(jq -r '.current_condition[0].temp_F // empty' "$CACHE_FILE" 2>/dev/null)
TEMP_C=$(jq -r '.current_condition[0].temp_C // empty' "$CACHE_FILE" 2>/dev/null)
CODE=$(jq -r '.current_condition[0].weatherCode // empty' "$CACHE_FILE" 2>/dev/null)
DESC=$(jq -r '.current_condition[0].weatherDesc[0].value // empty' "$CACHE_FILE" 2>/dev/null)

if [ -z "$TEMP_F" ] || [ -z "$CODE" ]; then
  exit 0
fi

# Detect temperature unit (Fahrenheit vs Celsius)
UNIT_SETTING="${WEATHER_UNIT:-auto}"
if [ "$UNIT_SETTING" = "auto" ]; then
  MAC_UNIT=$(defaults read -g AppleTemperatureUnit 2>/dev/null || echo "Fahrenheit")
  if [ "$MAC_UNIT" = "Celsius" ]; then
    UNIT="C"
  else
    UNIT="F"
  fi
else
  UNIT="$UNIT_SETTING"
fi

if [ "$UNIT" = "C" ]; then
  VAL="$TEMP_C"
  UNIT_SYM="°C"
else
  VAL="$TEMP_F"
  UNIT_SYM="°F"
fi

if [ "$SHOW_UNIT" = "true" ]; then
  TEMP_LABEL="${VAL}${UNIT_SYM}"
else
  TEMP_LABEL="${VAL}°"
fi

# Determine Day vs Night
HOUR=$(date +%H)
if [ "$HOUR" -ge 6 ] && [ "$HOUR" -lt 19 ]; then
  IS_DAY=true
else
  IS_DAY=false
fi

# Map weather code to minimal Nerd Font icon
ICON=""
case "$CODE" in
  113) # Sunny / Clear
    if [ "$IS_DAY" = true ]; then
      ICON="󰖙" # Day sunny
    else
      ICON="󰖔" # Night clear
    fi
    ;;
  116) # Partly cloudy
    if [ "$IS_DAY" = true ]; then
      ICON="󰖕" # Day partly cloudy
    else
      ICON="󰖔" # Night partly cloudy
    fi
    ;;
  119|122) # Cloudy / Overcast
    ICON="󰖐"
    ;;
  143|248|260) # Fog / Mist / Freezing Fog
    ICON="󰖑"
    ;;
  176|263|266|293|296|299|302|353|356) # Patchy / Light / Moderate Rain
    ICON="󰖖"
    ;;
  305|308|359) # Heavy / Torrential Rain
    ICON="󰖗"
    ;;
  200|386|389|392|395) # Thunderstorm / Lightning
    ICON="󰙾"
    ;;
  179|227|230|323|326|329|332|335|338|368|371) # Snow / Blizzard
    ICON="󰖘"
    ;;
  182|185|281|284|311|314|317|320|350|362|365|374|377) # Sleet / Ice / Freezing Rain
    ICON="󰖒"
    ;;
  *)
    # Text-based fallback matching
    DESC_LOWER=$(echo "$DESC" | tr '[:upper:]' '[:lower:]')
    if [[ "$DESC_LOWER" == *"thunder"* ]] || [[ "$DESC_LOWER" == *"lightning"* ]]; then
      ICON="󰙾"
    elif [[ "$DESC_LOWER" == *"snow"* ]] || [[ "$DESC_LOWER" == *"blizzard"* ]] || [[ "$DESC_LOWER" == *"flurr"* ]]; then
      ICON="󰖘"
    elif [[ "$DESC_LOWER" == *"sleet"* ]] || [[ "$DESC_LOWER" == *"ice"* ]] || [[ "$DESC_LOWER" == *"hail"* ]]; then
      ICON="󰖒"
    elif [[ "$DESC_LOWER" == *"heavy"* ]] && [[ "$DESC_LOWER" == *"rain"* ]]; then
      ICON="󰖗"
    elif [[ "$DESC_LOWER" == *"rain"* ]] || [[ "$DESC_LOWER" == *"drizzle"* ]] || [[ "$DESC_LOWER" == *"shower"* ]]; then
      ICON="󰖖"
    elif [[ "$DESC_LOWER" == *"fog"* ]] || [[ "$DESC_LOWER" == *"mist"* ]] || [[ "$DESC_LOWER" == *"haze"* ]]; then
      ICON="󰖑"
    elif [[ "$DESC_LOWER" == *"cloud"* ]] || [[ "$DESC_LOWER" == *"overcast"* ]]; then
      ICON="󰖐"
    else
      if [ "$IS_DAY" = true ]; then
        ICON="󰖙"
      else
        ICON="󰖔"
      fi
    fi
    ;;
esac

sketchybar --set "${NAME:-weather}" \
  icon="$ICON" \
  icon.font="JetBrainsMono Nerd Font:Regular:14" \
  icon.color=0xffffffff \
  label="$TEMP_LABEL" \
  label.drawing=on
