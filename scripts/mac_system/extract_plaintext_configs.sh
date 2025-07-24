#!/usr/bin/env bash

# Create modi directory
mkdir -p modi

# Array of domains to extract
domains=(
    "NSGlobalDomain"
    "com.apple.dock"
    "com.apple.finder"
    "com.apple.trackpad"
    "com.apple.AppleMultitouchTrackpad"
    "com.apple.driver.AppleBluetoothMultitouch.trackpad"
    "com.apple.AppleMultitouchMouse"
    "com.apple.mouse"
    "com.apple.keyboard"
    "com.apple.screensaver"
    "com.apple.screencapture"
    "com.apple.controlcenter"
    "com.apple.systemuiserver"
    "com.apple.menuextra.clock"
    "com.apple.menuextra.battery"
    "com.apple.menuextra.bluetooth"
    "com.apple.menuextra.volume"
    "com.apple.menuextra.airport"
    "com.apple.universalaccess"
    "com.apple.HIToolbox"
    "com.apple.desktop"
    "com.apple.touchbar"
    "com.apple.LaunchServices"
    "com.apple.loginwindow"
    "com.apple.TimeMachine"
    "com.apple.ActivityMonitor"
    "com.apple.Terminal"
    "com.apple.Spotlight"
    "com.apple.Displays-Settings.extension"
)

echo "Extracting domain settings to modi/ folder..."

for domain in "${domains[@]}"; do
    echo "Extracting $domain..."
    
    # Handle NSGlobalDomain special case (use -g flag)
    if [[ "$domain" == "NSGlobalDomain" ]]; then
        defaults read -g > "modi/${domain}.txt"
    else
        defaults read "$domain" > "modi/${domain}.txt" 2>/dev/null || echo "Warning: $domain not found or empty"
    fi
done

echo "Done. Settings extracted to modi/ folder."
echo "File count: $(ls modi/*.txt | wc -l)"
