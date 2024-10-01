#!/bin/bash

source "$CONFIG_DIR/colors.sh"

sketchybar --add alias "Control Center,Sound" right \
	--rename "Control Center,Sound" volume_alias \
	--set volume_alias icon.drawing=on \
	# script="$PLUGIN_DIR/audio.sh" \
	update_freq=60 \
	updates=on \
	label.drawing=on \
	label.color=$WHITE \
	icon.color=$WHITE \
	alias.color=$WHITE \
	icon.padding_left=0 \
	icon.padding_right=0 \
	label.padding_left=0 \
	label.padding_right=0 \
	background.padding_left=0 \
	background.padding_right=0 \
	width=30
