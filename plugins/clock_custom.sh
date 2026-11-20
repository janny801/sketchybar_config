#!/bin/bash

# 12-hour format with day of week: 12:03 PM Wed 11/18/2026
TIME_STRING=$(date +"%I:%M %p %a %m/%d/%Y")

sketchybar --set "$NAME" icon="󰥔" label="$TIME_STRING"