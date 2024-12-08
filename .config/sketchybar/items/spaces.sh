#!/bin/bash

sketchybar --add event aerospace_workspace_change

for sid in $(aerospace list-workspaces --monitor focused); do
	clr=$(aerospace list-windows --workspace "$sid" | rg -q ".*" && echo "$WHITE" || echo "$GREY")
	active_ws=$(aerospace list-workspaces --focused)
	if [[ $active_ws == "$sid" ]]; then
		clr=$MAUVE
	fi
	sketchybar --add item space."$sid" left \
		--subscribe space."$sid" aerospace_workspace_change \
		--set space."$sid" \
		background.drawing=off \
		label="$sid" \
		label.font="$FONT:Bold:14.0" \
		label.color="$clr" \
		label.align=left \
		padding_left=2 \
		padding_right=2 \
		click_script="aerospace workspace $sid" \
		script="$CONFIG_DIR/plugins/aerospace.sh $sid"
done
