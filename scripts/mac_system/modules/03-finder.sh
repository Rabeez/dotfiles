#!/usr/bin/env bash
# 03-finder.sh — Finder (list view, extensions, path/status bar)

defaults_set com.apple.finder FXPreferredViewStyle "-string" "Nlsv"
defaults_set com.apple.finder FXDefaultSearchScope "-string" "SCcf"
defaults_set com.apple.finder FXRemoveOldTrashItems "-bool" "true"
defaults_set com.apple.finder ShowStatusBar "-bool" "true"
defaults_set com.apple.finder ShowPathbar "-bool" "true"
