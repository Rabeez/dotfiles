#!/usr/bin/env bash

# make sure it's executable with:
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh
source "$CONFIG_DIR/colors.sh"

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
	sketchybar --set $NAME label.color=$MAUVE
else
	sketchybar --set $NAME label.color=$WHITE
fi
