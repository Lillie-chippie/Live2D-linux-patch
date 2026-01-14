#!/bin/bash

# Live2D Cubism 2.0 Linux Launcher
# Created by reverse engineering the Windows batch file and replacing JOGL libraries.

# Change to the script's directory
cd "$(dirname "$0")"

# Check for Java
if ! command -v java &> /dev/null; then
    echo "Error: Java is not installed or not in PATH."
    echo "Please install a Java Runtime Environment (JRE) or Java Development Kit (JDK)."
    exit 1
fi

# Configuration
JAVA_EXE="java"
MAX_MEMORY="4000"
LIB="app/lib"
LIB_LINUX="lib_linux"
POLICY="app/res/live2d.policy"

# Construct Classpath
# We use the downloaded Linux-compatible JOGL 2.3.2 libraries instead of the bundled Windows ones.
CP=""
CP="$CP:$LIB_LINUX/jogl-all-2.0-rc11.jar"
CP="$CP:$LIB_LINUX/jogl-all-2.0-rc11-natives-linux-amd64.jar"
CP="$CP:$LIB_LINUX/gluegen-rt-2.0-rc11.jar"
CP="$CP:$LIB_LINUX/gluegen-rt-2.0-rc11-natives-linux-amd64.jar"

# Bundled libraries
CP="$CP:$LIB/Live2D_Cubism.jar"
CP="$CP:$LIB/commons-codec.jar"
CP="$CP:$LIB/commons-httpclient.jar"
CP="$CP:$LIB/commons-logging.jar"
CP="$CP:$LIB/jdom.jar"
CP="$CP:$LIB/jl1.0.1.jar"
CP="$CP:$LIB/jsonic.jar"
CP="$CP:$LIB/mp3spi1.9.5.jar"
CP="$CP:$LIB/tritonus_share-0.3.6.jar"
CP="$CP:$LIB/rlm1112_x64.jar"

# Launch
echo "Starting Live2D Cubism 2.0 on Linux..."
echo "Using Memory: ${MAX_MEMORY}MB"

$JAVA_EXE -Duser.language=en \
    -Xmx${MAX_MEMORY}m \
    -Dos.name="Linux  " \
    --add-exports=java.desktop/sun.swing=ALL-UNNAMED \
    --add-opens=java.desktop/sun.swing=ALL-UNNAMED \
    -Djava.security.manager \
    -Djava.security.policy="$POLICY" \
    -Djava.library.path="$LIB_LINUX" \
    -classpath "$CP" \
    jp.live2d.cubism.CubismApp "$@"
