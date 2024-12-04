#!/bin/bash

sketchybar --add event aerospace_workspace_change

# TODO: show indicator for empty/non-empty spaces
#       aerospace list-windows --workspace 4 | rg -q ".*" && echo "•" || echo " "
# Need to account for 'on-window-close'/'on-window-open' callbacks
for sid in $(aerospace list-workspaces --monitor focused); do
	sketchybar --add item space."$sid" left \
		--subscribe space."$sid" aerospace_workspace_change \
		--set space."$sid" \
		background.border_color="$MAUVE" \
		background.corner_radius=5 \
		background.height=20 \
		background.drawing=off \
		label="$sid" \
		label.font="$FONT:Bold:14.0" \
		label.color="$WHITE" \
		label.align=left \
		padding_left=2 \
		padding_right=2 \
		click_script="aerospace workspace $sid" \
		script="$CONFIG_DIR/plugins/aerospace.sh $sid"
done
