#!/usr/bin/env bash
# 02-dock.sh — Dock (autohide, size, position, apps)

defaults_set com.apple.dock autohide "-bool" "true"
defaults_set com.apple.dock autohide-delay "-float" "0"
defaults_set com.apple.dock autohide-time-modifier "-float" "0"
defaults_set com.apple.dock orientation "-string" "left"
defaults_set com.apple.dock tilesize "-int" "44"
defaults_set com.apple.dock show-recents "-bool" "false"
defaults_set com.apple.dock mru-spaces "-bool" "false"
defaults_set com.apple.dock mineffect "-string" "scale"
defaults_set com.apple.dock minimize-to-application "-bool" "true"
defaults_set com.apple.dock expose-group-apps "-bool" "true"
defaults_set com.apple.dock size-immutable "-bool" "true"

# Import dock apps from canonical plist
DOCK_APPS_PLIST="$SCRIPT_DIR/plists/dock-apps.plist"
if [[ -f "$DOCK_APPS_PLIST" ]]; then
	defaults_write_key com.apple.dock persistent-apps "$DOCK_APPS_PLIST"
fi
