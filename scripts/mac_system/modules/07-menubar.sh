#!/usr/bin/env bash
# 07-menubar.sh — Control center, clock format

# 24-hour clock with date
defaults_set com.apple.menuextra.clock DateFormat "-string" "EEE d MMM HH:mm"
defaults_set com.apple.menuextra.clock Show24Hour "-bool" "true"
defaults_set com.apple.menuextra.clock ShowDate "-int" "1"
defaults_set com.apple.menuextra.clock ShowSeconds "-bool" "false"
