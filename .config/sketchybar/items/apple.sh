#!/bin/bash

# POPUP_OFF='sketchybar --set apple.logo popup.drawing=off'
# POPUP_CLICK_SCRIPT='sketchybar --set $NAME popup.drawing=toggle'

# apple_logo=(
# 	label=":apple:"
# 	label.font="$FONT:Regular:25.0"
# 	label.color="$BLUE"
# 	# icon.color="$BLUE"
# 	padding_right=15
# 	# label.drawing=off
# 	# click_script="$POPUP_CLICK_SCRIPT"
# 	# popup.height=35
# )

apple_logo=(
	icon=$APPLE
	icon.font.size=16
)

# apple_prefs=(
# 	icon=$PREFERENCES
# 	label="Preferences"
# 	click_script="open -a 'System Preferences'; $POPUP_OFF"
# )
#
# apple_activity=(
# 	icon=$ACTIVITY
# 	label="Activity"
# 	click_script="open -a 'Activity Monitor'; $POPUP_OFF"
# )
#
# apple_lock=(
# 	icon=$LOCK
# 	label="Lock Screen"
# 	click_script="pmset displaysleepnow; $POPUP_OFF"
# )

sketchybar --add item apple.logo left \
	--set apple.logo "${apple_logo[@]}" \
			click_script="sketchybar -m --animate tanh 2000 --set \$NAME popup.drawing=toggle"   \
			popup.background.border_width=2                                  \
			popup.background.corner_radius=3                                 \
			popup.background.border_color=$POPUP_BORDER_COLOR                \
			popup.background.background_color=$POPUP_BACKGROUND_COLOR        \
# --add item apple.prefs popup.apple.logo \
# --set apple.prefs "${apple_prefs[@]}" \
# \
# --add item apple.activity popup.apple.logo \
# --set apple.activity "${apple_activity[@]}" \
# \
# --add item apple.lock popup.apple.logo \
# --set apple.lock "${apple_lock[@]}"

sketchybar --add item apple.preferences popup.apple.logo \
		   --set apple.preferences icon=􀺽 \
		   				label="Preferences" \
		   				click_script="open -a 'System Preferences'; 
		   								sketchybar -m --set apple.logo popup.drawing=off"\
		   --add item apple.activity popup.apple.logo \
		   --set apple.activity icon=􀒓 \
		   				label="Activity" \
		   				click_script="open -a 'Activity Monitor';                       
		   								sketchybar -m --set apple.logo popup.drawing=off"\
		   --add item apple.lock popup.apple.logo \
		   --set apple.lock icon=􀒳 \
		   				label="Lock Screen" \
		   				click_script="pmset displaysleepnow;                           
		   								sketchybar -m --set apple.logo popup.drawing=off"
