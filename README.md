# sketchybar_config

# sketchybar_config

Personal SketchyBar configuration for macOS.

This setup provides a clean, minimal status bar with dynamic updates, Google Calendar integration, and custom system indicators.

---

## Features

- Dynamic spaces (Yabai integration)
- Front application display
- Google Calendar (next event in bar)
- Hover popup with full daily schedule
- Custom clock
- Volume indicator
- Wi-Fi indicator
- Bluetooth indicator
- Battery percentage
- Minimal transparent styling

---

## Folder Structure

sketchybar_config
│
├── sketchybarrc
├── plugins/
│   ├── google_calendar.py
│   ├── volume_custom.sh
│   ├── wifi_custom.sh
│   ├── bluetooth_custom.sh
│   ├── battery_custom.sh
│   ├── clock_custom.sh
│   └── front_app.sh

Note:
The `google/` folder containing API credentials is intentionally excluded from this repository.

---

## Requirements

Install dependencies using Homebrew:

brew install sketchybar
brew install yabai
brew install jq

Recommended font:
JetBrainsMono Nerd Font

---

## Installation

1. Copy this repository into:

~/.config/sketchybar/

2. Make plugin scripts executable:

chmod +x ~/.config/sketchybar/plugins/*

3. Reload SketchyBar:

sketchybar --reload

---

## Google Calendar Setup (Optional)

This configuration supports Google Calendar API integration.

Steps:

1. Create a Google Cloud project.
2. Enable the Google Calendar API.
3. Generate OAuth credentials.
4. Place credentials inside:

~/.config/sketchybar/google/

---

## Reloading

After editing configuration files:

sketchybar --reload

If issues occur:

brew services restart sketchybar

---

## Notes

- The main bar shows the next upcoming timed event.
- Hovering over the calendar item toggles a popup.
- Styling is transparent with blur.
- Designed for macOS with Yabai tiling window manager.

---
