#!/bin/bash
# Restore settings for NSGlobalDomain
echo "Restoring NSGlobalDomain settings..."

defaults write -g "AppleEdgeResizeExteriorSize" -int 10
defaults write -g "AppleEnableSwipeNavigateWithScrolls" -int 0
defaults write -g "ApplePressAndHoldEnabled" -int 0
defaults write -g "AppleShowAllExtensions" -int 1
defaults write -g "InitialKeyRepeat" -int 15
defaults write -g "KB_DoubleQuoteOption" "\\U201cabc\\U201d"
defaults write -g "KB_SingleQuoteOption" "\\U2018abc\\U2019"
# Dictionary value for KB_SpellingLanguage - may need manual handling
# defaults write -g "KB_SpellingLanguage" '{'
defaults write -g "KB_SpellingLanguageIsAutomatic" -int 1
defaults write -g "KeyRepeat" -int 2
defaults write -g "NSAutomaticCapitalizationEnabled" -int 0
defaults write -g "NSAutomaticDashSubstitutionEnabled" -int 0
defaults write -g "NSAutomaticInlinePredictionEnabled" -int 0
defaults write -g "NSAutomaticPeriodSubstitutionEnabled" -int 0
defaults write -g "NSAutomaticQuoteSubstitutionEnabled" -int 0
defaults write -g "NSAutomaticSpellingCorrectionEnabled" -int 0
defaults write -g "NSLinguisticDataAssetsRequestTime" "2025-07-23 17:08:11 +0000"
defaults write -g "NSNavPanelExpandedStateForSaveMode" -int 1
defaults write -g "NSNavPanelFileLastListModeForOpenModeKey" -int 2
defaults write -g "NSNavPanelFileListModeForOpenMode2" -int 2
# Dictionary value for NSPreferredWebServices - may need manual handling
# defaults write -g "NSPreferredWebServices" '{'
# Dictionary value for NSWebServicesProviderWebSearch - may need manual handling
# defaults write -g "NSWebServicesProviderWebSearch" '{'
defaults write -g "NSDefaultDisplayName" "Google"
defaults write -g "NSProviderIdentifier" "com.google.www"
defaults write -g "NSSpellCheckerContainerTransitionComplete" -int 1
defaults write -g "NSSpellCheckerInputAnalyticsTime" "2024-09-19 18:30:29 +0000"
defaults write -g "replace" "rric"
defaults write -g "with" "rabeezriaz@icloud.com"
defaults write -g "on" -int 1
defaults write -g "replace" "rrmck"
defaults write -g "with" "rabeez_riaz@mckinsey.com"
defaults write -g "on" -int 1
defaults write -g "replace" "rrgm"
defaults write -g "with" "ruoter123@gmail.com"
# Array value for NSUserQuotesArray - may need manual handling
# defaults write -g "NSUserQuotesArray" '('
defaults write -g "NavPanelFileListModeForOpenMode" -int 2
defaults write -g "WebAutomaticSpellingCorrectionEnabled" -int 0
# Dictionary value for _AKBAACertMarkerKey - may need manual handling
# defaults write -g "_AKBAACertMarkerKey" '{length = 32, bytes = 0xaa5e52a5 d740b7a7 c0ce7a32 d65bb75d ... ea56dd8c 08fea281 }'
defaults write -g "_HIHideMenuBar" -int 1
defaults write -g "com.aone.keka.KekaFinderIntegration" -int 0
# Array value for com.aone.keka.KekaFinderIntegration - may need manual handling
# defaults write -g "com.aone.keka.KekaFinderIntegration" '('
# Dictionary value for com.apple.gms.availability.accessNotGrantedUseCases - may need manual handling
# defaults write -g "com.apple.gms.availability.accessNotGrantedUseCases" '{length = 42, bytes = 0x62706c69 73743030 a0080000 00000000 ... 00000000 00000009 }'
# Dictionary value for com.apple.gms.availability.disabledUseCases - may need manual handling
# defaults write -g "com.apple.gms.availability.disabledUseCases" '{length = 82, bytes = 0x62706c69 73743030 a1015f10 23636f64 ... 00000000 00000030 }'
# Dictionary value for com.apple.gms.availability.disallowedUseCases - may need manual handling
# defaults write -g "com.apple.gms.availability.disallowedUseCases" '{length = 42, bytes = 0x62706c69 73743030 a0080000 00000000 ... 00000000 00000009 }'
# Dictionary value for com.apple.gms.availability.essentialAssetReadiness - may need manual handling
# defaults write -g "com.apple.gms.availability.essentialAssetReadiness" '{length = 4, bytes = 0x74727565}'
# Dictionary value for com.apple.gms.availability.key - may need manual handling
# defaults write -g "com.apple.gms.availability.key" '{length = 46, bytes = 0x62706c69 73743030 a1011000 080a0000 ... 00000000 0000000c }'
# Array value for com.apple.gms.availability.osEligibilityReasons - may need manual handling
# defaults write -g "com.apple.gms.availability.osEligibilityReasons" '('
# Dictionary value for com.apple.gms.availability.useCasesWhoseAssetsAreOutOfStorage - may need manual handling
# defaults write -g "com.apple.gms.availability.useCasesWhoseAssetsAreOutOfStorage" '{length = 42, bytes = 0x62706c69 73743030 a0080000 00000000 ... 00000000 00000009 }'
# Dictionary value for com.apple.gms.availability.useCasesWhoseAssetsNotReady - may need manual handling
# defaults write -g "com.apple.gms.availability.useCasesWhoseAssetsNotReady" '{length = 42, bytes = 0x62706c69 73743030 a0080000 00000000 ... 00000000 00000009 }'
defaults write -g "com.apple.sound.beep.sound" "/System/Library/Sounds/Tink.aiff"
defaults write -g "com.apple.sound.uiaudio.enabled" -int 0
defaults write -g "com.apple.trackpad.forceClick" -int 0
defaults write -g "com.apple.trackpad.scaling" "0.875"
defaults write -g "com.apple.trackpad.scrolling" "0.4412"
