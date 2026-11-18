#!/bin/bash

# 12-hour format: 12:03 AM 11/18/2026
TIME_STRING=$(date +"%I:%M %p %m/%d/%Y")

sketchybar --set "$NAME" icon="󰥔" label="$TIME_STRING"