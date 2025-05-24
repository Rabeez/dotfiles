#!/bin/bash

calendar=(
    icon=cal
    icon.font="$FONT:Regular:14.0"
    icon.padding_left=0
    icon.padding_right=5
    label.font="$FONT:Regular:14.0"
    label.width=80
    label.align=right
    label.padding_right=20
    label.padding_left=0
    update_freq=30
    script="$PLUGIN_DIR/calendar.sh"
    background.color="$BG_2"
    background.border_color="$TRANSPARENT"
    background.height=30
)

sketchybar --add item calendar right \
    --set calendar "${calendar[@]}" \
    --subscribe calendar system_woke

calendar_bracket=(
    background.color="$TRANSPARENT"
    background.border_color="$TRANSPARENT"
    background.border_width=1
    background.height=30
)
sketchybar --add bracket cal calendar \
    --set cal "${calendar_bracket[@]}"
