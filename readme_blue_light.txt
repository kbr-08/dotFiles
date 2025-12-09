# Manual Blue Light Filter Setup for Hyprland (Fedora)

This setup allows for manual toggling of the blue light filter using terminal commands (`blue-on` and `blue-off`) rather than automated sunset/sunrise schedules.

## 1. Prerequisites
Ensure `hyprsunset` is installed.
* *Note: `wlsunset` should be uninstalled (`sudo dnf remove wlsunset`) to avoid conflicts.*

## 2. Create Scripts in Dotfiles
Store the source scripts in the version-controlled `dotFiles` directory.

### Create `~/dotFiles/blueLightFilter_ON.sh`
```bash
#!/bin/bash

# Kill any existing instance to ensure a clean start
pkill hyprsunset

# Start hyprsunset with 4000K temperature (Warm/Evening)
# '&' backgrounds the process
# 'disown' prevents the filter from closing when the terminal closes
hyprsunset --temperature 4000 & disown

echo "Blue light filter enabled (4000K)."

--------------------------------------------------------
# Ensure local bin exists
mkdir -p ~/.local/bin

# Link ON script
ln -s -f ~/dotFiles/blueLightFilter_ON.sh ~/.local/bin/blue-on

# Link OFF script
ln -s -f ~/dotFiles/blueLightFilter_OFF.sh ~/.local/bin/blue-off
--------------------------------------------------------
usage:
blue-on - to enable the filter
blue-off - to disable the filter