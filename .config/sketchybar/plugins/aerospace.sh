#!/usr/bin/env bash

# make sure it's executable with:
# chmod +x ~/.config/sketchybar/plugins/aerospace.sh
source "$CONFIG_DIR/colors.sh"

#  aerospace list-windows --workspace 4 | rg -q ".*" && echo "•" || echo " "

if [ "$1" = "$FOCUSED_WORKSPACE" ]; then
	sketchybar --set "$NAME" label.color="$MAUVE2"
else
	# IS_NONEMPTY=$(aerospace list-windows --workspace "$1" | rg -q ".*" && echo "•" || echo "")
	# if [[ "$IS_NONEMPTY" == "•" ]]; then
	sketchybar --set "$NAME" label.color="$WHITE"
	# else
	# 	sketchybar --set "$NAME" label.color="$GREY"
	# fi
fi
