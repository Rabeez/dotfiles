#!/bin/bash

# If audio service says that airpods are the current active audio decice, then get battery level of left/right airpods from bluetooth service and set label as average battery level
sketchybar --set "$NAME" label=$(system_profiler SPAudioDataType | rg -A5 -B2 "Default Output Device: Yes" | rg -q "AirPods" && echo $(system_profiler SPBluetoothDataType | rg -B6 "Minor Type: Headphones" | rg "Battery Level" | tr -cd "[[:digit:]]\n" | jq -s "add/length | floor")"%" || echo "")
