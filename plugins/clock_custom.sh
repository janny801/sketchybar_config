#!/bin/bash
# Clock plugin (custom)
# Formats date like "Feb 16" and time like "11:42 PM"

DATE_FORMAT="${DATE_FORMAT:-%b %e}"      # "Feb 16"
TIME_FORMAT="${TIME_FORMAT:-%I:%M %p}"   # "11:42 PM"

DATE_STR="$(LC_TIME=en_US.UTF-8 date +"$DATE_FORMAT" | sed 's/  / /g')"
TIME_STR="$(LC_TIME=en_US.UTF-8 date +"$TIME_FORMAT")"

# If you want a separator dot, change "  " to "  •  "
sketchybar --set "$NAME" label="${DATE_STR}  ${TIME_STR}"
