#!/usr/bin/env bash
# 01-global.sh — NSGlobalDomain (key repeat, autocorrect off, etc.)

defaults_set NSGlobalDomain KeyRepeat "-int" "2"
defaults_set NSGlobalDomain InitialKeyRepeat "-int" "15"
defaults_set NSGlobalDomain ApplePressAndHoldEnabled "-bool" "false"
defaults_set NSGlobalDomain NSAutomaticCapitalizationEnabled "-bool" "false"
defaults_set NSGlobalDomain NSAutomaticDashSubstitutionEnabled "-bool" "false"
defaults_set NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled "-bool" "false"
defaults_set NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled "-bool" "false"
defaults_set NSGlobalDomain NSAutomaticSpellingCorrectionEnabled "-bool" "false"
defaults_set NSGlobalDomain NSAutomaticInlinePredictionEnabled "-bool" "false"
defaults_set NSGlobalDomain AppleShowAllExtensions "-bool" "true"
defaults_set NSGlobalDomain NSNavPanelExpandedStateForSaveMode "-bool" "true"
defaults_set NSGlobalDomain NSTableViewDefaultSizeMode "-int" "1"
defaults_set NSGlobalDomain AppleEdgeResizeExteriorSize "-int" "10"
