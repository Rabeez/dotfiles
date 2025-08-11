#!/bin/bash

source "$CONFIG_DIR/colors.sh"

sketchybar --add alias "Control Centre,Sound" right \
	--rename "Control Centre,Sound" volume_alias \
	--set volume_alias icon.drawing=on \
	update_freq=60 \
	updates=on \
	label.drawing=on \
	label.color="$WHITE" \
	icon.color="$WHITE" \
	alias.color="$WHITE" \
	icon.padding_left=0 \
	icon.padding_right=0 \
	label.padding_left=0 \
	label.padding_right=0 \
	background.padding_left=10 \
	background.padding_right=10 \
	width=30
