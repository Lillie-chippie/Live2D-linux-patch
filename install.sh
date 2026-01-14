#!/bin/bash

# Live2D Cubism 2.0 Linux Patch Installer
# ---------------------------------------

set -e

echo "Installing Live2D Cubism 2.0 Linux Patch..."

# Check if we are in the correct directory (should be run from inside linux_patch folder, but we assume user might extract it over the app)
# We expect to find ../app/lib/Live2D_Cubism.jar if we are in the patch folder inside the app folder
# OR we expect to find ./app/lib/Live2D_Cubism.jar if the user extracted the contents of this folder into the app root.

BASE_DIR="$(dirname "$0")"
cd "$BASE_DIR"

# Try to locate the Jar
JAR_PATH=""
if [ -f "../app/lib/Live2D_Cubism.jar" ]; then
    JAR_PATH="../app/lib/Live2D_Cubism.jar"
    ROOT_DIR=".."
elif [ -f "app/lib/Live2D_Cubism.jar" ]; then
    JAR_PATH="app/lib/Live2D_Cubism.jar"
    ROOT_DIR="."
else
    echo "Error: Could not find app/lib/Live2D_Cubism.jar"
    echo "Please extract this folder into the Live2D Cubism 2.0 directory."
    exit 1
fi

echo "Found Jar at: $JAR_PATH"

# Check for dependencies
if ! command -v zip &> /dev/null; then
    echo "Error: 'zip' command not found. Please install it (e.g., sudo apt install zip)."
    exit 1
fi
if ! command -v unzip &> /dev/null; then
    echo "Error: 'unzip' command not found. Please install it (e.g., sudo apt install unzip)."
    exit 1
fi
if ! command -v python3 &> /dev/null; then
    echo "Error: 'python3' command not found. Please install it."
    exit 1
fi

# Backup Jar
if [ ! -f "${JAR_PATH}.bak" ]; then
    echo "Backing up original jar..."
    cp "$JAR_PATH" "${JAR_PATH}.bak"
fi

# Create temp dir
TEMP_DIR=$(mktemp -d)
echo "Working in $TEMP_DIR..."

# Extract the specific class file
CLASS_FILE="jp/noids/util/aH.class"
echo "Extracting $CLASS_FILE..."
unzip -q "$JAR_PATH" "$CLASS_FILE" -d "$TEMP_DIR"

# Patch the class file
echo "Patching class file..."
python3 patch_jar.py "$TEMP_DIR/$CLASS_FILE"

# Update the Jar
echo "Updating Jar..."
cd "$TEMP_DIR"
zip -u "$OLDPWD/$JAR_PATH" "$CLASS_FILE"
cd "$OLDPWD"

# Clean up
rm -rf "$TEMP_DIR"

# Install libraries and script
echo "Installing Linux libraries..."
if [ "$ROOT_DIR" == ".." ]; then
    # We are in a subdir, copy to root
    cp -r lib_linux "$ROOT_DIR/"
    cp run_linux.sh "$ROOT_DIR/"
    cp run_animator_linux.sh "$ROOT_DIR/"
else
    # We are in root (contents extracted), nothing to move if structure matches, 
    # but likely user extracted a folder 'linux_patch' into root.
    # If this script is running, we are in 'linux_patch'.
    cp -r lib_linux "$ROOT_DIR/"
    cp run_linux.sh "$ROOT_DIR/"
    cp run_animator_linux.sh "$ROOT_DIR/"
fi

chmod +x "$ROOT_DIR/run_linux.sh"
chmod +x "$ROOT_DIR/run_animator_linux.sh"

echo "-------------------------------------------------------"
echo "Patch applied successfully!"
echo "You can now run:"
echo "  Modeler:  ./run_linux.sh"
echo "  Animator: ./run_animator_linux.sh"
echo "-------------------------------------------------------"
