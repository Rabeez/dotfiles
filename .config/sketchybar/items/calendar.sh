#!/bin/bash

calendar=(
	icon=cal
	icon.font="$FONT:Regular:14.0"
	icon.padding_left=20
	icon.padding_right=12
	label.font="$FONT:Regular:14.0"
	label.width=70
	label.align=right
	label.padding_right=20
	padding_left=2.5
	update_freq=30
	script="$PLUGIN_DIR/calendar.sh"
	# click_script="$PLUGIN_DIR/calendar_click.sh"
	background.color="$BG_2"
	background.border_color="$TRANSPARENT"
	background.height=30
)

sketchybar --add item calendar right \
	--set calendar "${calendar[@]}" \
	--subscribe calendar system_woke

calendar_bracket=(
	background.color="$BACKGROUND_1"
	background.border_color="$MAUVE"
	background.border_width=1
	background.height=30
)
sketchybar --add bracket cal calendar \
	--set cal "${calendar_bracket[@]}"
