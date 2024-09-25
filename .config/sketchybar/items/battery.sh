#!/bin/bash

battery=(
	script="$PLUGIN_DIR/battery.sh"
	icon.font="$FONT:Regular:19.0"
	# icon.color="$GREEN"
	icon.padding_left=15
	icon.padding_right=5
	label.padding_left=0
	label.padding_right=0
	background.padding_left=0
	background.padding_right=0
	label.drawing=on
	update_freq=120
	updates=on
)
sketchybar --add item battery right \
	--set battery "${battery[@]}" \
	--subscribe battery power_source_change system_woke
	
status_bracket=(
	background.color="$BACKGROUND_1"
	background.border_color="$MAUVE"
	background.border_width=1
	background.height=30
)
sketchybar --add bracket status volume_alias battery \
	--set status "${status_bracket[@]}"
