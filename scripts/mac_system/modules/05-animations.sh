#!/usr/bin/env bash
# 05-animations.sh — Reduce motion, disable all animations

defaults_set com.apple.universalaccess reduceMotion "-bool" "true"
defaults_set NSGlobalDomain NSAutomaticWindowAnimationsEnabled "-bool" "false"
defaults_set NSGlobalDomain NSWindowResizeTime "-float" "0.001"
defaults_set NSGlobalDomain NSScrollAnimationEnabled "-bool" "false"
defaults_set NSGlobalDomain QLPanelAnimationDuration "-float" "0"
defaults_set com.apple.finder DisableAllAnimations "-bool" "true"
defaults_set com.apple.dock expose-animation-duration "-float" "0.1"
defaults_set com.apple.dock springboard-show-duration "-float" "0.1"
defaults_set com.apple.dock springboard-hide-duration "-float" "0.1"
