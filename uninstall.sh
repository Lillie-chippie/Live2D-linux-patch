#!/bin/bash

# Live2D Cubism 3.2 Linux Patch Uninstaller
# -----------------------------------------

echo "Uninstalling Live2D Cubism 3.2 Linux Patch..."

BASE_DIR="$(dirname "$0")"
cd "$BASE_DIR"

# Check for target directory structure
if [ -d "../app/lib" ]; then
    ROOT_DIR=".."
elif [ -d "app/lib" ]; then
    ROOT_DIR="."
else
    echo "Error: Could not find app/lib directory."
    echo "Please run this script from the Live2D Cubism 3.2 directory or the linux_patch directory."
    exit 1
fi

ROOT_DIR=$(realpath "$ROOT_DIR")
echo "Target directory: $ROOT_DIR"

# 1. Restore the original JAR
JAR_FILE="$ROOT_DIR/app/lib/Live2D_Cubism.jar"
BACKUP_FILE="$ROOT_DIR/app/lib/Live2D_Cubism.jar.bak"

if [ -f "$BACKUP_FILE" ]; then
    echo "Restoring original Live2D_Cubism.jar..."
    mv "$BACKUP_FILE" "$JAR_FILE"
    echo "JAR restored."
else
    echo "Warning: Backup file not found ($BACKUP_FILE). JAR might already be original or bak missing."
fi

# 2. Remove added launch scripts
echo "Removing launch scripts..."
rm -f "$ROOT_DIR/run_linux.sh"
rm -f "$ROOT_DIR/run_animator_linux.sh"

# 3. Remove added directories
echo "Removing Linux libraries and natives..."
rm -rf "$ROOT_DIR/lib_linux"
rm -rf "$ROOT_DIR/natives"

echo "-------------------------------------------------------"
echo "Uninstallation complete!"
echo "The application has been restored to its original state."
echo "-------------------------------------------------------"
