#!/bin/bash

# Format matching screenshot: 18:14 06/10/2021
TIME_STRING=$(date +"%H:%M %m/%d/%Y")

sketchybar --set "$NAME" icon="󰥔" label="$TIME_STRING"