#!/bin/bash

# Default formats (used if env not passed)
DATE_FORMAT="${DATE_FORMAT:-%A, %b %e}"
TIME_FORMAT="${TIME_FORMAT:-%I:%M %p}"

DATE=$(LC_TIME=en_US.UTF-8 date +"$DATE_FORMAT" | sed 's/  / /g')
TIME=$(LC_TIME=en_US.UTF-8 date +"$TIME_FORMAT")

# force lowercase
DATE=$(echo "$DATE" | tr '[:upper:]' '[:lower:]')
TIME=$(echo "$TIME" | tr '[:upper:]' '[:lower:]')

sketchybar --set "$NAME" label="$DATE  $TIME"
