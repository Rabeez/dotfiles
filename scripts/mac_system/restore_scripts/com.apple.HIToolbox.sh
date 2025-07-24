#!/bin/bash
# Restore settings for com.apple.HIToolbox
echo "Restoring com.apple.HIToolbox settings..."

defaults write "com.apple.HIToolbox" "AppleCurrentKeyboardLayoutInputSourceID" "com.apple.keylayout.ABC"
defaults write "com.apple.HIToolbox" "AppleDictationAutoEnable" -int 1
defaults write "com.apple.HIToolbox" "Bundle ID" "com.apple.CharacterPaletteIM"
defaults write "com.apple.HIToolbox" "InputSourceKind" "Non Keyboard Input Method"
defaults write "com.apple.HIToolbox" "Bundle ID" "com.apple.inputmethod.ironwood"
defaults write "com.apple.HIToolbox" "InputSourceKind" "Non Keyboard Input Method"
defaults write "com.apple.HIToolbox" "Bundle ID" "com.apple.PressAndHold"
defaults write "com.apple.HIToolbox" "InputSourceKind" "Non Keyboard Input Method"
defaults write "com.apple.HIToolbox" "AppleFnUsageType" -int 0
# Array value for AppleSelectedInputSources - may need manual handling
# defaults write "com.apple.HIToolbox" "AppleSelectedInputSources" '('
defaults write "com.apple.HIToolbox" "KeyboardLayout ID" -int 252
defaults write "com.apple.HIToolbox" "KeyboardLayout Name" "ABC"
defaults write "com.apple.HIToolbox" "Bundle ID" "com.apple.PressAndHold"
