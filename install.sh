#!/bin/bash

# Live2D Cubism 5.2 Linux Patch Installer
# ---------------------------------------

set -e

echo "Installing Live2D Cubism 5.2 Linux Patch..."

BASE_DIR="$(dirname "$0")"
cd "$BASE_DIR"

# Check for target directory structure
if [ -d "../app/lib" ]; then
    ROOT_DIR=".."
elif [ -d "app/lib" ]; then
    ROOT_DIR="."
else
    echo "Error: Could not find app/lib directory."
    echo "Please extract this folder into the Live2D Cubism 5.2 directory."
    exit 1
fi

echo "Target directory: $ROOT_DIR"

# Extract native libraries from jars
echo "Extracting native libraries..."
if [ -d "lib_linux" ]; then
    cd lib_linux
    if [ ! -f "libgluegen_rt.so" ]; then
        unzip -o -q gluegen-rt-natives-linux-amd64.jar "natives/linux-amd64/*" 2>/dev/null || true
        unzip -o -q jogl-all-natives-linux-amd64.jar "natives/linux-amd64/*" 2>/dev/null || true
        if [ -d "natives/linux-amd64" ]; then
            mv natives/linux-amd64/* .
            rm -rf natives
        fi
    fi
    cd ..
fi

# Clean up temporary files in lib_linux
echo "Cleaning up temporary files..."
find lib_linux -name "*.zip" -delete
find lib_linux -name "*.jar" -delete
find lib_linux -name "*.tgz" -delete
rm -rf lib_linux/onnxruntime-linux-x64-1.13.1

# Copy Linux Libraries
echo "Installing Linux libraries..."
cp -r lib_linux "$ROOT_DIR/"

# Copy Launch Scripts
echo "Installing launch scripts..."
cp run_linux.sh "$ROOT_DIR/"
cp run_animator_linux.sh "$ROOT_DIR/"

# Set Permissions
chmod +x "$ROOT_DIR/run_linux.sh"
chmod +x "$ROOT_DIR/run_animator_linux.sh"

# Patch Live2D_Cubism.jar (Remove signatures)
JAR_FILE="$ROOT_DIR/app/lib/Live2D_Cubism.jar"
if [ -f "$JAR_FILE" ]; then
    echo "Patching $JAR_FILE (removing signatures)..."
    
    # Apply Bytecode Patches & Unsign JAR
    echo "Applying bytecode patches (RLM fix + License fix) and unsigning..."
    if command -v python3 &> /dev/null; then
        python3 scripts/apply_patches.py
    else
        echo "Error: python3 not found. Cannot apply bytecode patches."
        echo "Please install python3 and run 'python3 scripts/apply_patches.py' manually."
    fi
    
    echo "Patching complete."
else
    echo "Warning: $JAR_FILE not found. Skipping JAR patch."
fi

echo "-------------------------------------------------------"
echo "Patch applied successfully!"
echo "You can now run:"
echo "  Editor:  ./run_linux.sh"
echo "  Viewer:  ./run_animator_linux.sh"
echo "-------------------------------------------------------"
