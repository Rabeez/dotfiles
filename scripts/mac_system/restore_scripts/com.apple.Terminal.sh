#!/bin/bash
# Restore settings for com.apple.Terminal
echo "Restoring com.apple.Terminal settings..."

defaults write "com.apple.Terminal" "Default Window Settings" "catppuccin-mocha"
defaults write "com.apple.Terminal" "Man Page Window Settings" "Man Page"
defaults write "com.apple.Terminal" "NSNavPanelExpandedSizeForOpenMode" "{800, 448}"
# Dictionary value for NSOSPLastRootDirectory - may need manual handling
# defaults write "com.apple.Terminal" "NSOSPLastRootDirectory" '{length = 752, bytes = 0x626f6f6b f0020000 00000410 30000000 ... 90010000 00000000 }'
defaults write "com.apple.Terminal" "NSWindow Frame NSFontPanel" "470 336 752 278 0 0 1710 1074 "
defaults write "com.apple.Terminal" "NSWindow Frame NSNavPanelAutosaveName" "456 423 800 448 0 0 1710 1074 "
defaults write "com.apple.Terminal" "NSWindow Frame TTAppPreferences" "522 389 667 568 0 0 1710 1074 "
defaults write "com.apple.Terminal" "NSWindow Frame TTWindow" "855 9 850 1057 0 0 1710 1074 "
defaults write "com.apple.Terminal" "NSWindow Frame TTWindow Basic" "855 9 850 1057 0 0 1710 1074 "
defaults write "com.apple.Terminal" "NSWindow Frame TTWindow catppuccin-mocha" "855 -7 850 1073 0 0 1710 1074 "
defaults write "com.apple.Terminal" "Startup Window Settings" "catppuccin-mocha"
defaults write "com.apple.Terminal" "TTAppPreferences Selected Tab" -int 1
# Dictionary value for catppuccin-mocha - may need manual handling
# defaults write "com.apple.Terminal" "catppuccin-mocha" '{'
# Dictionary value for ANSIBlackColor - may need manual handling
# defaults write "com.apple.Terminal" "ANSIBlackColor" '{length = 273, bytes = 0x62706c69 73743030 d4010203 04050607 ... 00000000 000000d8 }'
# Dictionary value for ANSIBlueColor - may need manual handling
# defaults write "com.apple.Terminal" "ANSIBlueColor" '{length = 273, bytes = 0x62706c69 73743030 d4010203 04050607 ... 00000000 000000d8 }'
# Dictionary value for ANSIBrightBlackColor - may need manual handling
# defaults write "com.apple.Terminal" "ANSIBrightBlackColor" '{length = 274, bytes = 0x62706c69 73743030 d4010203 04050607 ... 00000000 000000d9 }'
# Dictionary value for ANSIBrightBlueColor - may need manual handling
# defaults write "com.apple.Terminal" "ANSIBrightBlueColor" '{length = 273, bytes = 0x62706c69 73743030 d4010203 04050607 ... 00000000 000000d8 }'
# Dictionary value for ANSIBrightCyanColor - may need manual handling
# defaults write "com.apple.Terminal" "ANSIBrightCyanColor" '{length = 274, bytes = 0x62706c69 73743030 d4010203 04050607 ... 00000000 000000d9 }'
# Dictionary value for ANSIBrightGreenColor - may need manual handling
# defaults write "com.apple.Terminal" "ANSIBrightGreenColor" '{length = 271, bytes = 0x62706c69 73743030 d4010203 04050607 ... 00000000 000000d6 }'
# Dictionary value for ANSIBrightMagentaColor - may need manual handling
# defaults write "com.apple.Terminal" "ANSIBrightMagentaColor" '{length = 273, bytes = 0x62706c69 73743030 d4010203 04050607 ... 00000000 000000d8 }'
# Dictionary value for ANSIBrightRedColor - may need manual handling
# defaults write "com.apple.Terminal" "ANSIBrightRedColor" '{length = 274, bytes = 0x62706c69 73743030 d4010203 04050607 ... 00000000 000000d9 }'
# Dictionary value for ANSIBrightWhiteColor - may need manual handling
# defaults write "com.apple.Terminal" "ANSIBrightWhiteColor" '{length = 273, bytes = 0x62706c69 73743030 d4010203 04050607 ... 00000000 000000d8 }'
# Dictionary value for ANSIBrightYellowColor - may need manual handling
# defaults write "com.apple.Terminal" "ANSIBrightYellowColor" '{length = 274, bytes = 0x62706c69 73743030 d4010203 04050607 ... 00000000 000000d9 }'
# Dictionary value for ANSICyanColor - may need manual handling
# defaults write "com.apple.Terminal" "ANSICyanColor" '{length = 274, bytes = 0x62706c69 73743030 d4010203 04050607 ... 00000000 000000d9 }'
# Dictionary value for ANSIGreenColor - may need manual handling
# defaults write "com.apple.Terminal" "ANSIGreenColor" '{length = 271, bytes = 0x62706c69 73743030 d4010203 04050607 ... 00000000 000000d6 }'
# Dictionary value for ANSIMagentaColor - may need manual handling
# defaults write "com.apple.Terminal" "ANSIMagentaColor" '{length = 273, bytes = 0x62706c69 73743030 d4010203 04050607 ... 00000000 000000d8 }'
# Dictionary value for ANSIRedColor - may need manual handling
# defaults write "com.apple.Terminal" "ANSIRedColor" '{length = 274, bytes = 0x62706c69 73743030 d4010203 04050607 ... 00000000 000000d9 }'
# Dictionary value for ANSIWhiteColor - may need manual handling
# defaults write "com.apple.Terminal" "ANSIWhiteColor" '{length = 272, bytes = 0x62706c69 73743030 d4010203 04050607 ... 00000000 000000d7 }'
# Dictionary value for ANSIYellowColor - may need manual handling
# defaults write "com.apple.Terminal" "ANSIYellowColor" '{length = 274, bytes = 0x62706c69 73743030 d4010203 04050607 ... 00000000 000000d9 }'
defaults write "com.apple.Terminal" "BackgroundBlur" -int 0
# Dictionary value for BackgroundColor - may need manual handling
# defaults write "com.apple.Terminal" "BackgroundColor" '{length = 273, bytes = 0x62706c69 73743030 d4010203 04050607 ... 00000000 000000d8 }'
defaults write "com.apple.Terminal" "Bell" -int 0
# Dictionary value for BoldTextColor - may need manual handling
# defaults write "com.apple.Terminal" "BoldTextColor" '{length = 274, bytes = 0x62706c69 73743030 d4010203 04050607 ... 00000000 000000d9 }'
# Dictionary value for CursorColor - may need manual handling
# defaults write "com.apple.Terminal" "CursorColor" '{length = 274, bytes = 0x62706c69 73743030 d4010203 04050607 ... 00000000 000000d9 }'
defaults write "com.apple.Terminal" "DisableANSIColor" -int 0
# Dictionary value for Font - may need manual handling
# defaults write "com.apple.Terminal" "Font" '{length = 274, bytes = 0x62706c69 73743030 d4010203 04050607 ... 00000000 000000d6 }'
defaults write "com.apple.Terminal" "FontHeightSpacing" -int 1
defaults write "com.apple.Terminal" "ProfileCurrentVersion" "2.07"
# Dictionary value for SelectionColor - may need manual handling
# defaults write "com.apple.Terminal" "SelectionColor" '{length = 274, bytes = 0x62706c69 73743030 d4010203 04050607 ... 00000000 000000d9 }'
# Dictionary value for TextColor - may need manual handling
# defaults write "com.apple.Terminal" "TextColor" '{length = 274, bytes = 0x62706c69 73743030 d4010203 04050607 ... 00000000 000000d9 }'
defaults write "com.apple.Terminal" "UseBrightBold" -int 0
defaults write "com.apple.Terminal" "name" "catppuccin-mocha"
defaults write "com.apple.Terminal" "type" "Window Settings"
