#!/bin/bash

chevron=(
	icon='󰄾'
	icon.font="$FONT:Bold:20.0"
	# label.font="OperatorMono Nerd Font:Bold Italic:14.0"
	icon.color="$MAUVE"
	padding_right=0
	padding_left=5
)
sketchybar --add item chevron left \
	--set chevron "${chevron[@]}"

front_app=(
	label.font="$FONT:Black:12.0"
	label.drawing=on
	icon.background.drawing=on
	icon.background.image.scale=0.75
	display=active
	script="$PLUGIN_DIR/front_app.sh"
	click_script="open -a 'Mission Control'"
	padding_right=0
)
sketchybar --add item front_app left \
	--set front_app "${front_app[@]}" \
	--subscribe front_app front_app_switched
