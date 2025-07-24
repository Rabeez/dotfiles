#!/bin/bash
# Restore settings for com.apple.finder
echo "Restoring com.apple.finder settings..."

# Dictionary value for ComputerViewSettings - may need manual handling
# defaults write "com.apple.finder" "ComputerViewSettings" '{'
defaults write "com.apple.finder" "CustomViewStyleVersion" -int 1
# Dictionary value for WindowState - may need manual handling
# defaults write "com.apple.finder" "WindowState" '{'
defaults write "com.apple.finder" "ContainerShowSidebar" -int 1
defaults write "com.apple.finder" "ShowSidebar" -int 1
defaults write "com.apple.finder" "ShowStatusBar" -int 0
defaults write "com.apple.finder" "ShowTabView" -int 0
defaults write "com.apple.finder" "ShowToolbar" -int 1
defaults write "com.apple.finder" "WindowBounds" "{{570, 3}, {569, 1063}}"
defaults write "com.apple.finder" "CopyProgressWindowLocation" "{655, 295}"
defaults write "com.apple.finder" "DataSeparatedDisplayNameCache" ""
defaults write "com.apple.finder" "EmptyTrashProgressWindowLocation" "{1709, 1084}"
defaults write "com.apple.finder" "FK_AppCentricShowSidebar" -int 1
# Dictionary value for FK_DefaultIconViewSettings - may need manual handling
# defaults write "com.apple.finder" "FK_DefaultIconViewSettings" '{'
defaults write "com.apple.finder" "arrangeBy" "name"
defaults write "com.apple.finder" "backgroundColorBlue" -int 1
defaults write "com.apple.finder" "backgroundColorGreen" -int 1
defaults write "com.apple.finder" "backgroundColorRed" -int 1
defaults write "com.apple.finder" "backgroundType" -int 0
defaults write "com.apple.finder" "gridOffsetX" -int 0
defaults write "com.apple.finder" "gridOffsetY" -int 0
defaults write "com.apple.finder" "gridSpacing" -int 54
defaults write "com.apple.finder" "iconSize" -int 64
defaults write "com.apple.finder" "labelOnBottom" -int 1
defaults write "com.apple.finder" "showIconPreview" -int 1
defaults write "com.apple.finder" "showItemInfo" -int 1
defaults write "com.apple.finder" "textSize" -int 12
defaults write "com.apple.finder" "viewOptionsVersion" -int 1
# Dictionary value for FK_DefaultListViewSettingsV2 - may need manual handling
# defaults write "com.apple.finder" "FK_DefaultListViewSettingsV2" '{'
defaults write "com.apple.finder" "calculateAllSizes" -int 0
# Array value for columns - may need manual handling
# defaults write "com.apple.finder" "columns" '('
defaults write "com.apple.finder" "ascending" -int 1
defaults write "com.apple.finder" "identifier" "name"
defaults write "com.apple.finder" "visible" -int 1
defaults write "com.apple.finder" "width" -int 472
defaults write "com.apple.finder" "ascending" -int 0
defaults write "com.apple.finder" "identifier" "ubiquity"
defaults write "com.apple.finder" "visible" -int 0
defaults write "com.apple.finder" "width" -int 35
defaults write "com.apple.finder" "ascending" -int 0
defaults write "com.apple.finder" "identifier" "dateModified"
defaults write "com.apple.finder" "visible" -int 0
defaults write "com.apple.finder" "width" -int 181
defaults write "com.apple.finder" "ascending" -int 0
defaults write "com.apple.finder" "identifier" "dateCreated"
defaults write "com.apple.finder" "visible" -int 0
defaults write "com.apple.finder" "width" -int 181
defaults write "com.apple.finder" "ascending" -int 0
defaults write "com.apple.finder" "identifier" "size"
defaults write "com.apple.finder" "visible" -int 1
defaults write "com.apple.finder" "width" -int 97
defaults write "com.apple.finder" "ascending" -int 1
defaults write "com.apple.finder" "identifier" "kind"
defaults write "com.apple.finder" "visible" -int 1
defaults write "com.apple.finder" "width" -int 115
defaults write "com.apple.finder" "ascending" -int 1
defaults write "com.apple.finder" "identifier" "label"
defaults write "com.apple.finder" "visible" -int 0
defaults write "com.apple.finder" "width" -int 100
defaults write "com.apple.finder" "ascending" -int 1
defaults write "com.apple.finder" "identifier" "version"
defaults write "com.apple.finder" "visible" -int 0
defaults write "com.apple.finder" "width" -int 75
defaults write "com.apple.finder" "ascending" -int 1
defaults write "com.apple.finder" "identifier" "comments"
defaults write "com.apple.finder" "visible" -int 0
defaults write "com.apple.finder" "width" -int 300
defaults write "com.apple.finder" "ascending" -int 0
defaults write "com.apple.finder" "identifier" "dateLastOpened"
defaults write "com.apple.finder" "visible" -int 0
defaults write "com.apple.finder" "width" -int 200
defaults write "com.apple.finder" "ascending" -int 0
defaults write "com.apple.finder" "identifier" "shareOwner"
defaults write "com.apple.finder" "visible" -int 0
defaults write "com.apple.finder" "width" -int 200
defaults write "com.apple.finder" "ascending" -int 0
defaults write "com.apple.finder" "identifier" "shareLastEditor"
defaults write "com.apple.finder" "visible" -int 0
defaults write "com.apple.finder" "width" -int 200
defaults write "com.apple.finder" "ascending" -int 0
defaults write "com.apple.finder" "identifier" "dateAdded"
defaults write "com.apple.finder" "visible" -int 1
defaults write "com.apple.finder" "width" -int 181
defaults write "com.apple.finder" "ascending" -int 0
defaults write "com.apple.finder" "identifier" "invitationStatus"
defaults write "com.apple.finder" "visible" -int 0
defaults write "com.apple.finder" "width" -int 210
defaults write "com.apple.finder" "iconSize" -int 16
defaults write "com.apple.finder" "showIconPreview" -int 1
defaults write "com.apple.finder" "sortColumn" "name"
defaults write "com.apple.finder" "textSize" -int 13
defaults write "com.apple.finder" "useRelativeDates" -int 1
defaults write "com.apple.finder" "userDidChangeSort" -int 1
defaults write "com.apple.finder" "viewOptionsVersion" -int 1
# Dictionary value for FK_StandardViewOptions2 - may need manual handling
# defaults write "com.apple.finder" "FK_StandardViewOptions2" '{'
# Dictionary value for ColumnViewOptions - may need manual handling
# defaults write "com.apple.finder" "ColumnViewOptions" '{'
defaults write "com.apple.finder" "ArrangeBy" "dnam"
defaults write "com.apple.finder" "ColumnShowFolderArrow" -int 1
defaults write "com.apple.finder" "ColumnShowIcons" -int 1
defaults write "com.apple.finder" "ColumnWidth" -int 245
defaults write "com.apple.finder" "FontSize" -int 13
defaults write "com.apple.finder" "PreviewDisclosureState" -int 1
defaults write "com.apple.finder" "SharedArrangeBy" "kipl"
defaults write "com.apple.finder" "ShowIconThumbnails" -int 1
defaults write "com.apple.finder" "ShowPreview" -int 1
# Dictionary value for FK_iCloudListViewSettingsV2 - may need manual handling
# defaults write "com.apple.finder" "FK_iCloudListViewSettingsV2" '{'
defaults write "com.apple.finder" "calculateAllSizes" -int 0
# Array value for columns - may need manual handling
# defaults write "com.apple.finder" "columns" '('
defaults write "com.apple.finder" "ascending" -int 1
defaults write "com.apple.finder" "identifier" "name"
defaults write "com.apple.finder" "visible" -int 1
defaults write "com.apple.finder" "width" -int 268
defaults write "com.apple.finder" "ascending" -int 0
defaults write "com.apple.finder" "identifier" "ubiquity"
defaults write "com.apple.finder" "visible" -int 0
defaults write "com.apple.finder" "width" -int 35
defaults write "com.apple.finder" "ascending" -int 0
defaults write "com.apple.finder" "identifier" "dateModified"
defaults write "com.apple.finder" "visible" -int 1
defaults write "com.apple.finder" "width" -int 181
defaults write "com.apple.finder" "ascending" -int 0
defaults write "com.apple.finder" "identifier" "dateCreated"
defaults write "com.apple.finder" "visible" -int 0
defaults write "com.apple.finder" "width" -int 181
defaults write "com.apple.finder" "ascending" -int 0
defaults write "com.apple.finder" "identifier" "size"
defaults write "com.apple.finder" "visible" -int 1
defaults write "com.apple.finder" "width" -int 97
defaults write "com.apple.finder" "ascending" -int 1
defaults write "com.apple.finder" "identifier" "kind"
defaults write "com.apple.finder" "visible" -int 0
defaults write "com.apple.finder" "width" -int 115
defaults write "com.apple.finder" "ascending" -int 1
defaults write "com.apple.finder" "identifier" "label"
defaults write "com.apple.finder" "visible" -int 0
defaults write "com.apple.finder" "width" -int 100
defaults write "com.apple.finder" "ascending" -int 1
defaults write "com.apple.finder" "identifier" "version"
defaults write "com.apple.finder" "visible" -int 0
defaults write "com.apple.finder" "width" -int 75
defaults write "com.apple.finder" "ascending" -int 1
defaults write "com.apple.finder" "identifier" "comments"
defaults write "com.apple.finder" "visible" -int 0
defaults write "com.apple.finder" "width" -int 300
defaults write "com.apple.finder" "ascending" -int 0
defaults write "com.apple.finder" "identifier" "dateLastOpened"
defaults write "com.apple.finder" "visible" -int 0
defaults write "com.apple.finder" "width" -int 200
defaults write "com.apple.finder" "ascending" -int 0
defaults write "com.apple.finder" "identifier" "shareOwner"
defaults write "com.apple.finder" "visible" -int 0
defaults write "com.apple.finder" "width" -int 200
defaults write "com.apple.finder" "ascending" -int 0
defaults write "com.apple.finder" "identifier" "shareLastEditor"
defaults write "com.apple.finder" "visible" -int 0
defaults write "com.apple.finder" "width" -int 200
defaults write "com.apple.finder" "ascending" -int 0
defaults write "com.apple.finder" "identifier" "dateAdded"
defaults write "com.apple.finder" "visible" -int 0
defaults write "com.apple.finder" "width" -int 181
defaults write "com.apple.finder" "ascending" -int 0
defaults write "com.apple.finder" "identifier" "invitationStatus"
defaults write "com.apple.finder" "visible" -int 0
defaults write "com.apple.finder" "width" -int 210
defaults write "com.apple.finder" "iconSize" -int 16
defaults write "com.apple.finder" "showIconPreview" -int 1
defaults write "com.apple.finder" "sortColumn" "dateModified"
defaults write "com.apple.finder" "textSize" -int 13
defaults write "com.apple.finder" "useRelativeDates" -int 1
defaults write "com.apple.finder" "viewOptionsVersion" -int 1
defaults write "com.apple.finder" "FXDefaultSearchScope" "SCcf"
# Dictionary value for FXDesktopVolumePositions - may need manual handling
# defaults write "com.apple.finder" "FXDesktopVolumePositions" '{'
# Dictionary value for Loom 0.269.3-arm64_0x1.68ac80afb3ee8p+29 - may need manual handling
# defaults write "com.apple.finder" "Loom 0.269.3-arm64_0x1.68ac80afb3ee8p+29" '{'
defaults write "com.apple.finder" "AnchorRelativeTo" -int 1
defaults write "com.apple.finder" "ScreenID" -int 0
defaults write "com.apple.finder" "xRelative" "-65"
defaults write "com.apple.finder" "yRelative" -int 78
# Dictionary value for NO NAME_-0x1.c3aa727p+29 - may need manual handling
# defaults write "com.apple.finder" "NO NAME_-0x1.c3aa727p+29" '{'
defaults write "com.apple.finder" "AnchorRelativeTo" -int 1
defaults write "com.apple.finder" "ScreenID" -int 0
defaults write "com.apple.finder" "xRelative" "-65"
defaults write "com.apple.finder" "yRelative" -int 78
# Dictionary value for NO NAME_-0x1.d27e44p+29 - may need manual handling
# defaults write "com.apple.finder" "NO NAME_-0x1.d27e44p+29" '{'
defaults write "com.apple.finder" "AnchorRelativeTo" -int 1
defaults write "com.apple.finder" "ScreenID" -int 0
defaults write "com.apple.finder" "xRelative" "-65"
defaults write "com.apple.finder" "yRelative" -int 414
# Dictionary value for Octoparse 8.7.7_0x1.6d89491p+29 - may need manual handling
# defaults write "com.apple.finder" "Octoparse 8.7.7_0x1.6d89491p+29" '{'
defaults write "com.apple.finder" "AnchorRelativeTo" -int 1
defaults write "com.apple.finder" "ScreenID" -int 0
defaults write "com.apple.finder" "xRelative" "-65"
defaults write "com.apple.finder" "yRelative" -int 78
# Dictionary value for PokeMMO_0x1.66d15708p+29 - may need manual handling
# defaults write "com.apple.finder" "PokeMMO_0x1.66d15708p+29" '{'
defaults write "com.apple.finder" "AnchorRelativeTo" -int 1
defaults write "com.apple.finder" "ScreenID" -int 0
defaults write "com.apple.finder" "xRelative" "-65"
defaults write "com.apple.finder" "yRelative" -int 414
# Dictionary value for RetroArch_0x1.607f6368p+29 - may need manual handling
# defaults write "com.apple.finder" "RetroArch_0x1.607f6368p+29" '{'
defaults write "com.apple.finder" "AnchorRelativeTo" -int 1
defaults write "com.apple.finder" "ScreenID" -int 0
defaults write "com.apple.finder" "xRelative" "-65"
defaults write "com.apple.finder" "yRelative" -int 414
# Dictionary value for TinkerTool 10_0x1.0a48f8b8p+29 - may need manual handling
# defaults write "com.apple.finder" "TinkerTool 10_0x1.0a48f8b8p+29" '{'
defaults write "com.apple.finder" "AnchorRelativeTo" -int 1
defaults write "com.apple.finder" "ScreenID" -int 0
defaults write "com.apple.finder" "xRelative" "-65"
defaults write "com.apple.finder" "yRelative" -int 84
# Dictionary value for WindscribeInstaller_0x1.676817a8p+29 - may need manual handling
# defaults write "com.apple.finder" "WindscribeInstaller_0x1.676817a8p+29" '{'
defaults write "com.apple.finder" "AnchorRelativeTo" -int 1
defaults write "com.apple.finder" "ScreenID" -int 0
defaults write "com.apple.finder" "xRelative" "-65"
defaults write "com.apple.finder" "yRelative" -int 40
defaults write "com.apple.finder" "FXDetachedDesktopProviderID" "com.apple.CloudDocs.iCloudDriveFileProvider/0BEE21B1-AEDA-48DA-8368-90AF214F6967"
defaults write "com.apple.finder" "FXDetachedDocumentsProviderID" "com.apple.CloudDocs.iCloudDriveFileProvider/0BEE21B1-AEDA-48DA-8368-90AF214F6967"
defaults write "com.apple.finder" "FXEnableExtensionChangeWarning" -int 1
defaults write "com.apple.finder" "FXICloudDriveDesktop" -int 1
defaults write "com.apple.finder" "FXICloudDriveDocuments" -int 1
defaults write "com.apple.finder" "FXICloudDriveFirstSyncDownComplete" -int 1
# Dictionary value for FXInfoPanesExpanded - may need manual handling
# defaults write "com.apple.finder" "FXInfoPanesExpanded" '{'
defaults write "com.apple.finder" "MetaData" -int 0
defaults write "com.apple.finder" "Preview" -int 0
defaults write "com.apple.finder" "FXLastSearchScope" "SCcf"
defaults write "com.apple.finder" "FXPreferencesWindow.Location" "{{10, 655}, {377, 402}}"
defaults write "com.apple.finder" "FXPreferredSearchViewStyleVersion" "%00%00%00%01"
defaults write "com.apple.finder" "FXPreferredViewStyle" "Nlsv"
defaults write "com.apple.finder" "FXRemoveOldTrashItems" -int 1
# Array value for FXSyncExtensionToolbarItemsAutomaticallyAdded - may need manual handling
# defaults write "com.apple.finder" "FXSyncExtensionToolbarItemsAutomaticallyAdded" '('
defaults write "com.apple.finder" "FinderSpawnTab" -int 0
# Dictionary value for ICloudViewSettings - may need manual handling
# defaults write "com.apple.finder" "ICloudViewSettings" '{'
# Dictionary value for WindowState - may need manual handling
# defaults write "com.apple.finder" "WindowState" '{'
defaults write "com.apple.finder" "ContainerShowSidebar" -int 1
defaults write "com.apple.finder" "ShowSidebar" -int 1
defaults write "com.apple.finder" "ShowStatusBar" -int 0
defaults write "com.apple.finder" "ShowTabView" -int 0
defaults write "com.apple.finder" "ShowToolbar" -int 1
defaults write "com.apple.finder" "WindowBounds" "{{2, 3}, {1706, 1063}}"
# Array value for TB Default Item Identifiers - may need manual handling
# defaults write "com.apple.finder" "TB Default Item Identifiers" '('
# Array value for TB Item Identifiers - may need manual handling
# defaults write "com.apple.finder" "TB Item Identifiers" '('
defaults write "com.apple.finder" "NewWindowTarget" "PfHm"
defaults write "com.apple.finder" "PreferencesWindow.LastSelection" "GNRL"
defaults write "com.apple.finder" "RecentsArrangeGroupViewBy" "Date Last Opened"
# Array value for SGTRecentFileSearches - may need manual handling
# defaults write "com.apple.finder" "SGTRecentFileSearches" '('
# Array value for attributes - may need manual handling
# defaults write "com.apple.finder" "attributes" '('
defaults write "com.apple.finder" "enforceStrictMatch" -int 0
defaults write "com.apple.finder" "exactMatch" -int 0
defaults write "com.apple.finder" "name" "map"
defaults write "com.apple.finder" "scope" -int 4
defaults write "com.apple.finder" "type" "com.apple.finder"
# Array value for values - may need manual handling
# defaults write "com.apple.finder" "values" '('
defaults write "com.apple.finder" "SearchRecentsSavedViewStyle" "Nlsv"
# Dictionary value for SearchRecentsViewSettings - may need manual handling
# defaults write "com.apple.finder" "SearchRecentsViewSettings" '{'
# Dictionary value for WindowState - may need manual handling
# defaults write "com.apple.finder" "WindowState" '{'
defaults write "com.apple.finder" "ContainerShowSidebar" -int 1
defaults write "com.apple.finder" "ShowSidebar" -int 1
defaults write "com.apple.finder" "ShowStatusBar" -int 0
defaults write "com.apple.finder" "ShowTabView" -int 0
defaults write "com.apple.finder" "ShowToolbar" -int 1
defaults write "com.apple.finder" "WindowBounds" "{{313, 424}, {920, 529}}"
# Dictionary value for SearchViewSettings - may need manual handling
# defaults write "com.apple.finder" "SearchViewSettings" '{'
# Dictionary value for WindowState - may need manual handling
# defaults write "com.apple.finder" "WindowState" '{'
defaults write "com.apple.finder" "ContainerShowSidebar" -int 1
defaults write "com.apple.finder" "ShowSidebar" -int 1
defaults write "com.apple.finder" "ShowStatusBar" -int 0
defaults write "com.apple.finder" "ShowTabView" -int 0
defaults write "com.apple.finder" "ShowToolbar" -int 1
defaults write "com.apple.finder" "WindowBounds" "{{2, 3}, {1706, 1063}}"
defaults write "com.apple.finder" "ShowMountedServersOnDesktop" -int 1
defaults write "com.apple.finder" "ShowPathbar" -int 1
defaults write "com.apple.finder" "ShowRemovableMediaOnDesktop" -int 0
defaults write "com.apple.finder" "ShowSidebar" -int 1
defaults write "com.apple.finder" "ShowStatusBar" -int 0
defaults write "com.apple.finder" "SidebarDevicesSectionDisclosedState" -int 1
defaults write "com.apple.finder" "SidebarShowingiCloudDesktop" -int 1
defaults write "com.apple.finder" "SidebarTagsSctionDisclosedState" -int 1
defaults write "com.apple.finder" "SidebarWidth" -int 128
defaults write "com.apple.finder" "width" -int 346
defaults write "com.apple.finder" "identifier" "ubiquity"
defaults write "com.apple.finder" "visible" -int 0
defaults write "com.apple.finder" "width" -int 35
defaults write "com.apple.finder" "ascending" -int 0
defaults write "com.apple.finder" "ascending" -int 0
defaults write "com.apple.finder" "identifier" "dateAdded"
defaults write "com.apple.finder" "visible" -int 0
defaults write "com.apple.finder" "width" -int 181
defaults write "com.apple.finder" "ascending" -int 0
defaults write "com.apple.finder" "identifier" "invitationStatus"
defaults write "com.apple.finder" "visible" -int 0
defaults write "com.apple.finder" "width" -int 210
defaults write "com.apple.finder" "width" -int 346
defaults write "com.apple.finder" "TagsCloudSerialNumber" -int 19
# Dictionary value for TrashViewSettings - may need manual handling
# defaults write "com.apple.finder" "TrashViewSettings" '{'
defaults write "com.apple.finder" "CustomViewStyleVersion" -int 1
# Dictionary value for WindowState - may need manual handling
# defaults write "com.apple.finder" "WindowState" '{'
defaults write "com.apple.finder" "ContainerShowSidebar" -int 1
defaults write "com.apple.finder" "ShowSidebar" -int 1
defaults write "com.apple.finder" "ShowStatusBar" -int 0
defaults write "com.apple.finder" "ShowTabView" -int 0
defaults write "com.apple.finder" "ShowToolbar" -int 1
defaults write "com.apple.finder" "WindowBounds" "{{2, 3}, {1706, 1063}}"
defaults write "com.apple.finder" "_FXSortFoldersFirst" -int 1
defaults write "com.apple.finder" "_FXSortFoldersFirstOnDesktop" -int 1
