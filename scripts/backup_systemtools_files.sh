#!/usr/bin/env bash

echo " Starting setup script generation..."
echo ""

echo "   Creating Brewfile..."
if ./scripts/backup_brewfile.sh; then
    echo "    Brewfile created successfully."
else
    echo "    Error creating Brewfile."
    exit 1
fi
echo ""

echo "   Creating go-tools.txt..."
if ./scripts/backup_gotools_file.sh; then
    echo "    go-tools.txt created successfully."
else
    echo "    Error creating go-tools.txt."
    exit 1
fi
echo ""

echo "   Creating rust-tools.txt..."
if ./scripts/backup_rusttools_file.sh; then
    echo "    rust-tools.txt created successfully."
else
    echo "    Error creating rust-tools.txt."
    exit 1
fi
echo ""

echo "   Backing up Obsidian configs"
if ./scripts/backup_obsidian.sh; then
    echo "    Obsidian configs backed up successfully."
else
    echo "    Error backing up Obsidian configs."
    exit 1
fi
echo ""


echo "   Backing up Firefox/Zen configs"
if ./scripts/backup_firefox.sh; then
    echo "    Firefox/Zen configs backed up successfully."
else
    echo "    Error backing up Firefox/Zen configs."
    exit 1
fi
echo ""

echo " Setup script generation complete."
