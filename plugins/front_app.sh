#!/bin/bash

# $INFO contains the name of the focused app
APP_NAME="$INFO"

# Choose an icon based on app
case "$APP_NAME" in
  "Brave Browser"|"Google Chrome"|"Safari"|"Firefox"|"Arc")
    ICON="󰖟"
    ;;
  "Antigravity"|"Code"|"VS Code"|"Cursor"|"Neovim"|"Xcode")
    ICON="󰅩"
    ;;
  "Terminal"|"iTerm2"|"Alacritty"|"Kitty"|"WezTerm")
    ICON="󰆍"
    ;;
  "Spotify"|"Music")
    ICON="󰓇"
    ;;
  "Messages"|"Slack"|"Discord"|"Telegram")
    ICON="󰭹"
    ;;
  "Finder")
    ICON="󰀶"
    ;;
  "System Settings"|"System Preferences")
    ICON="󰒓"
    ;;
  *)
    ICON="󰣆"
    ;;
esac

sketchybar --set "$NAME" icon="$ICON" label="$APP_NAME"
