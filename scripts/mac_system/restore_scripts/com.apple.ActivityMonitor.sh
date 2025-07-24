#!/bin/bash
# Restore settings for com.apple.ActivityMonitor
echo "Restoring com.apple.ActivityMonitor settings..."

# Dictionary value for Column Width - may need manual handling
# defaults write "com.apple.ActivityMonitor" "Column Width" '{'
# Dictionary value for CPU - may need manual handling
# defaults write "com.apple.ActivityMonitor" "CPU" '{'
defaults write "com.apple.ActivityMonitor" "12HRPower" -int 80
defaults write "com.apple.ActivityMonitor" "AppSleep" -int 70
defaults write "com.apple.ActivityMonitor" "Architecture" -int 88
defaults write "com.apple.ActivityMonitor" "AveragePowerScore" -int 120
defaults write "com.apple.ActivityMonitor" "CPUTime" -int 70
defaults write "com.apple.ActivityMonitor" "CPUUsage" -int 75
defaults write "com.apple.ActivityMonitor" "Command" -int 100
defaults write "com.apple.ActivityMonitor" "GPUTime" -int 75
defaults write "com.apple.ActivityMonitor" "GPUUsage" -int 75
defaults write "com.apple.ActivityMonitor" "IdleWakeUps" -int 98
defaults write "com.apple.ActivityMonitor" "InstantOff" -int 86
defaults write "com.apple.ActivityMonitor" "PID" -int 40
defaults write "com.apple.ActivityMonitor" "Ports" -int 48
defaults write "com.apple.ActivityMonitor" "PowerScore" -int 100
defaults write "com.apple.ActivityMonitor" "Private" -int 88
defaults write "com.apple.ActivityMonitor" "PurgeableMem" -int 104
defaults write "com.apple.ActivityMonitor" "ResidentSize" -int 72
defaults write "com.apple.ActivityMonitor" "Sandbox" -int 58
defaults write "com.apple.ActivityMonitor" "Shared" -int 88
defaults write "com.apple.ActivityMonitor" "Threads" -int 60
defaults write "com.apple.ActivityMonitor" "UID" -int 80
defaults write "com.apple.ActivityMonitor" "anonymousMemory" -int 64
defaults write "com.apple.ActivityMonitor" "bytesRead" -int 92
defaults write "com.apple.ActivityMonitor" "bytesWritten" -int 92
defaults write "com.apple.ActivityMonitor" "compressedMemory" -int 110
defaults write "com.apple.ActivityMonitor" "powerAssertion" -int 96
defaults write "com.apple.ActivityMonitor" "restricted" -int 96
defaults write "com.apple.ActivityMonitor" "rxBytes" -int 70
defaults write "com.apple.ActivityMonitor" "rxPackets" -int 80
defaults write "com.apple.ActivityMonitor" "txBytes" -int 80
defaults write "com.apple.ActivityMonitor" "txPackets" -int 80
# Dictionary value for Memory - may need manual handling
# defaults write "com.apple.ActivityMonitor" "Memory" '{'
defaults write "com.apple.ActivityMonitor" "12HRPower" -int 80
defaults write "com.apple.ActivityMonitor" "AppSleep" -int 70
defaults write "com.apple.ActivityMonitor" "Architecture" -int 88
defaults write "com.apple.ActivityMonitor" "AveragePowerScore" -int 120
defaults write "com.apple.ActivityMonitor" "CPUTime" -int 70
defaults write "com.apple.ActivityMonitor" "CPUUsage" -int 75
defaults write "com.apple.ActivityMonitor" "Command" -int 535
defaults write "com.apple.ActivityMonitor" "GPUTime" -int 75
defaults write "com.apple.ActivityMonitor" "GPUUsage" -int 75
defaults write "com.apple.ActivityMonitor" "IdleWakeUps" -int 98
defaults write "com.apple.ActivityMonitor" "InstantOff" -int 86
defaults write "com.apple.ActivityMonitor" "PID" -int 40
defaults write "com.apple.ActivityMonitor" "Ports" -int 48
defaults write "com.apple.ActivityMonitor" "PowerScore" -int 100
defaults write "com.apple.ActivityMonitor" "Private" -int 88
defaults write "com.apple.ActivityMonitor" "PurgeableMem" -int 104
defaults write "com.apple.ActivityMonitor" "ResidentSize" -int 72
defaults write "com.apple.ActivityMonitor" "Sandbox" -int 58
defaults write "com.apple.ActivityMonitor" "Shared" -int 88
defaults write "com.apple.ActivityMonitor" "Threads" -int 60
defaults write "com.apple.ActivityMonitor" "UID" -int 80
defaults write "com.apple.ActivityMonitor" "anonymousMemory" -int 64
defaults write "com.apple.ActivityMonitor" "bytesRead" -int 92
defaults write "com.apple.ActivityMonitor" "bytesWritten" -int 92
defaults write "com.apple.ActivityMonitor" "compressedMemory" -int 110
defaults write "com.apple.ActivityMonitor" "powerAssertion" -int 96
defaults write "com.apple.ActivityMonitor" "restricted" -int 96
defaults write "com.apple.ActivityMonitor" "rxBytes" -int 70
defaults write "com.apple.ActivityMonitor" "rxPackets" -int 80
defaults write "com.apple.ActivityMonitor" "txBytes" -int 80
defaults write "com.apple.ActivityMonitor" "txPackets" -int 80
# Dictionary value for NSTableView Columns v3 cacheTableColumns - may need manual handling
# defaults write "com.apple.ActivityMonitor" "NSTableView Columns v3 cacheTableColumns" '{length = 827, bytes = 0x62706c69 73743030 d4010203 04050607 ... 00000000 0000025f }'
# Dictionary value for NSTableView Sort Ordering v2 cacheTableColumns - may need manual handling
# defaults write "com.apple.ActivityMonitor" "NSTableView Sort Ordering v2 cacheTableColumns" '{length = 413, bytes = 0x62706c69 73743030 d4010203 04050607 ... 00000000 0000012b }'
defaults write "com.apple.ActivityMonitor" "NSTableView Supports v2 cacheTableColumns" -int 1
defaults write "com.apple.ActivityMonitor" "NSWindow Frame ProcessInspector" "32 3 1676 1063 0 0 1710 1074 "
defaults write "com.apple.ActivityMonitor" "NSWindow Frame main window" "32 3 1676 1063 0 0 1710 1074 "
defaults write "com.apple.ActivityMonitor" "OpenMainWindow" -int 0
defaults write "com.apple.ActivityMonitor" "SelectedTab" -int 0
defaults write "com.apple.ActivityMonitor" "ShowCategory" -int 102
