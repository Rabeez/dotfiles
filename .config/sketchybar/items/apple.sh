#!/bin/bash

apple_logo=(
	icon="$APPLE"
	icon.font.size=16
)
sketchybar --add item apple.logo left \
	--set apple.logo "${apple_logo[@]}"
