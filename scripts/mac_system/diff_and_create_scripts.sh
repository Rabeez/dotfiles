#!/usr/bin/env bash

# Create restore directory
mkdir -p restore

# Array of domains
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

# Function to format defaults command based on value type
format_defaults_command() {
    local domain="$1"
    local key="$2"
    local value="$3"
    
    # Handle NSGlobalDomain flag
    local domain_flag
    if [[ "$domain" == "NSGlobalDomain" ]]; then
        domain_flag="-g"
    else
        domain_flag="\"$domain\""
    fi
    
    # Remove trailing semicolon
    value=$(echo "$value" | sed 's/;$//')
    
    # Detect value type and format accordingly
    if [[ $value =~ ^[0-9]+$ ]]; then
        # Integer
        echo "defaults write $domain_flag \"$key\" -int $value"
    elif [[ $value =~ ^[0-9]*\.[0-9]+$ ]]; then
        # Float
        echo "defaults write $domain_flag \"$key\" -float $value"
    elif [[ $value =~ ^(0|1)$ ]]; then
        # Boolean
        [[ $value == "1" ]] && bool="true" || bool="false"
        echo "defaults write $domain_flag \"$key\" -bool $bool"
    elif [[ $value =~ ^\( ]]; then
        # Array - handle specially
        echo "# Array value for $key - may need manual handling"
        echo "# defaults write $domain_flag \"$key\" '$value'"
    elif [[ $value =~ ^\{ ]]; then
        # Dictionary - handle specially  
        echo "# Dictionary value for $key - may need manual handling"
        echo "# defaults write $domain_flag \"$key\" '$value'"
    else
        # String
        value=$(echo "$value" | sed 's/^"//' | sed 's/"$//')
        echo "defaults write $domain_flag \"$key\" \"$value\""
    fi
}

echo "Generating restore scripts..."

# No master script needed

for domain in "${domains[@]}"; do
    orig_file="orig/${domain}.txt"
    modi_file="modi/${domain}.txt"
    restore_script="restore/${domain}.sh"
    
    # Skip if files don't exist
    if [[ ! -f "$orig_file" ]] || [[ ! -f "$modi_file" ]]; then
        echo "Skipping $domain - missing files"
        continue
    fi
    
    echo "Processing $domain..."
    
    # Get differences (only changed/added lines from modi)
    diff_output=$(diff "$orig_file" "$modi_file" | grep "^>" | sed 's/^> *//')
    
    # Collect commands first
    commands=()
    while IFS= read -r line; do
        # Skip empty lines and structural lines
        [[ -z "$line" ]] && continue
        [[ "$line" =~ ^[[:space:]]*[\{\}\(\)].*$ ]] && continue
        [[ "$line" =~ ^[[:space:]]*$ ]] && continue
        
        # Extract key = value pairs
        if [[ $line =~ ^[[:space:]]*([^=]+)[[:space:]]*=[[:space:]]*(.+)$ ]]; then
            key=$(echo "${BASH_REMATCH[1]}" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' | sed 's/^"//' | sed 's/"$//')
            value="${BASH_REMATCH[2]}"
            
            # Generate defaults command
            cmd=$(format_defaults_command "$domain" "$key" "$value")
            commands+=("$cmd")
        fi
    done <<< "$diff_output"
    
    # Only create script if there are commands
    if [[ ${#commands[@]} -gt 0 ]]; then
        # Create domain-specific script header
        cat > "$restore_script" << EOF
#!/usr/bin/env bash
# Restore settings for $domain
echo "Restoring $domain settings..."

EOF
        
        # Add commands to script
        for cmd in "${commands[@]}"; do
            echo "$cmd" >> "$restore_script"
        done
        
        # Make executable
        chmod +x "$restore_script"
        
        echo "  Generated ${#commands[@]} commands for $domain"
    else
        echo "  No changes found for $domain - skipping script creation"
    fi
done

echo ""
echo "Restore scripts generated in restore/ directory:"
echo "- Individual domain scripts ready to run manually"
echo ""
ls -la restore/!/bin/bash

# Create restore directory
mkdir -p restore


# Function to format defaults command based on value type
format_defaults_command() {
    local domain="$1"
    local key="$2"
    local value="$3"
    
    # Handle NSGlobalDomain flag
    local domain_flag
    if [[ "$domain" == "NSGlobalDomain" ]]; then
        domain_flag="-g"
    else
        domain_flag="\"$domain\""
    fi
    
    # Remove trailing semicolon
    value=$(echo "$value" | sed 's/;$//')
    
    # Detect value type and format accordingly
    if [[ $value =~ ^[0-9]+$ ]]; then
        # Integer
        echo "defaults write $domain_flag \"$key\" -int $value"
    elif [[ $value =~ ^[0-9]*\.[0-9]+$ ]]; then
        # Float
        echo "defaults write $domain_flag \"$key\" -float $value"
    elif [[ $value =~ ^(0|1)$ ]]; then
        # Boolean
        [[ $value == "1" ]] && bool="true" || bool="false"
        echo "defaults write $domain_flag \"$key\" -bool $bool"
    elif [[ $value =~ ^\( ]]; then
        # Array - handle specially
        echo "# Array value for $key - may need manual handling"
        echo "# defaults write $domain_flag \"$key\" '$value'"
    elif [[ $value =~ ^\{ ]]; then
        # Dictionary - handle specially  
        echo "# Dictionary value for $key - may need manual handling"
        echo "# defaults write $domain_flag \"$key\" '$value'"
    else
        # String
        value=$(echo "$value" | sed 's/^"//' | sed 's/"$//')
        echo "defaults write $domain_flag \"$key\" \"$value\""
    fi
}

echo "Generating restore scripts..."

# No master script needed

for domain in "${domains[@]}"; do
    orig_file="orig/${domain}.txt"
    modi_file="modi/${domain}.txt"
    restore_script="restore/${domain}.sh"
    
    # Skip if files don't exist
    if [[ ! -f "$orig_file" ]] || [[ ! -f "$modi_file" ]]; then
        echo "Skipping $domain - missing files"
        continue
    fi
    
    echo "Processing $domain..."
    
    # Get differences (only changed/added lines from modi)
    diff_output=$(diff "$orig_file" "$modi_file" | grep "^>" | sed 's/^> *//')
    
    # Collect commands first
    commands=()
    while IFS= read -r line; do
        # Skip empty lines and structural lines
        [[ -z "$line" ]] && continue
        [[ "$line" =~ ^[[:space:]]*[\{\}\(\)].*$ ]] && continue
        [[ "$line" =~ ^[[:space:]]*$ ]] && continue
        
        # Extract key = value pairs
        if [[ $line =~ ^[[:space:]]*([^=]+)[[:space:]]*=[[:space:]]*(.+)$ ]]; then
            key=$(echo "${BASH_REMATCH[1]}" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' | sed 's/^"//' | sed 's/"$//')
            value="${BASH_REMATCH[2]}"
            
            # Generate defaults command
            cmd=$(format_defaults_command "$domain" "$key" "$value")
            commands+=("$cmd")
        fi
    done <<< "$diff_output"
    
    # Only create script if there are commands
    if [[ ${#commands[@]} -gt 0 ]]; then
        # Create domain-specific script header
        cat > "$restore_script" << EOF
#!/bin/bash
# Restore settings for $domain
echo "Restoring $domain settings..."

EOF
        
        # Add commands to script
        for cmd in "${commands[@]}"; do
            echo "$cmd" >> "$restore_script"
        done
        
        # Make executable
        chmod +x "$restore_script"
        
        echo "  Generated ${#commands[@]} commands for $domain"
    else
        echo "  No changes found for $domain - skipping script creation"
    fi
done

echo ""
echo "Restore scripts generated in restore/ directory:"
echo "- Individual domain scripts ready to run manually"
echo ""
ls -la restore/
