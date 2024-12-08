#!/usr/bin/env bash

# make sure it's executable with:
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh
source "$CONFIG_DIR/colors.sh"

# if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
# 	sketchybar --set "$NAME" label.color="$MAUVE"
# else
clr=$(aerospace list-windows --workspace "$1" | rg -q ".*" && echo "$WHITE" || echo "$GREY")
active_ws=$(aerospace list-workspaces --focused)
if [[ $active_ws == "$1" ]]; then
	clr=$MAUVE
fi
sketchybar --set "$NAME" label.color="$clr"
# fi
