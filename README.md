# sketchybar_config

Personal SketchyBar configuration for macOS.

This setup provides a clean, minimal status bar with dynamic updates, Google Calendar integration, and custom system indicators.

## Features

- Dynamic spaces (Yabai integration)
- Front application display
- Weather & outside temperature (auto-location, minimal Nerd Font condition icons, day/night aware)
- Microphone indicator (MicMute integration with hardware & software mute)
- Custom clock
- Volume indicator & slider
- Wi-Fi indicator
- Bluetooth indicator
- Focus status indicator (shown only while a Focus mode is active)
- Battery percentage
- Minimal transparent styling

## Folder Structure

```text
sketchybar_config/
├── sketchybarrc
├── plugins/
│   ├── weather_custom.sh
│   ├── mic_custom.sh
│   ├── volume_custom.sh
│   ├── wifi_custom.sh
│   ├── bluetooth_custom.sh
│   ├── battery_custom.sh
│   ├── clock_custom.sh
│   └── front_app.sh
```

**Note:**  
The `google/` folder containing API credentials is intentionally excluded from this repository.

## Requirements

Install dependencies using Homebrew:

brew install sketchybar
brew install yabai
brew install jq

Recommended font:
JetBrainsMono Nerd Font

## Installation

1. Copy this repository into:

```bash
~/.config/sketchybar/
```

2. Make plugin scripts executable:

```bash
chmod +x ~/.config/sketchybar/plugins/*
```

3. Reload SketchyBar:

```bash
sketchybar --reload
```

## Google Calendar Setup (Optional)

This configuration supports Google Calendar API integration.

### Steps

1. Create a Google Cloud project.
2. Enable the Google Calendar API.
3. Generate OAuth credentials.
4. Place credentials inside:

```bash
~/.config/sketchybar/google/
```

## Reloading

After editing configuration files:

```bash
sketchybar --reload
```

If issues occur:

```bash
brew services restart sketchybar
```

The Focus indicator reads macOS's Focus assertion database and uses Apple's
`moon.fill` glyph. It disappears when no Focus mode is active. SketchyBar
needs Full Disk Access to read the protected database; grant it to the
SketchyBar executable in System Settings > Privacy & Security, then reload
SketchyBar.

## Notes

- The main bar shows the next upcoming timed event.
- Hovering over the calendar item toggles a popup.
- Styling is transparent with blur.
- Designed for macOS with Yabai tiling window manager.
