#!/bin/bash

# Reload Hyprland config
hyprctl reload

# Kill existing quickshell instances
killall qs quickshell ydotool

# Start quickshell in the background and log output
nohup qs -c yoru > /tmp/qs_debug.log 2>&1 &

echo "Hyprland and Quickshell have been reloaded!"
echo "If the bar doesn't appear, check the log with: cat /tmp/qs_debug.log"
