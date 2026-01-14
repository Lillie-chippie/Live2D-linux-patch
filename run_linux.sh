#!/bin/bash

# Live2D Cubism 5.2 Linux Launcher (Editor)

cd "$(dirname "$0")"

# Configuration
JAVA_EXE="java"
MAX_MEMORY="4000"
APP_LIB="app/lib"
LINUX_LIB="lib_linux"

# Fix for potential NPE in com.live2d.util.ao (expecting Windows-style env vars)
export APPDATA="$HOME/.local/share"
export LOCALAPPDATA="$HOME/.local/share"
export USERPROFILE="$HOME"
export HOMEDRIVE="C:"
export HOMEPATH="$HOME"

# Find JRE lib paths for libjawt.so and libjvm.so
JAVA_HOME=$(java -XshowSettings:properties -version 2>&1 | grep "java.home" | awk '{print $3}')
if [ -d "$JAVA_HOME/lib" ]; then
    # Add both lib and lib/server (for libjvm.so)
    export LD_LIBRARY_PATH="$JAVA_HOME/lib:$JAVA_HOME/lib/server:$LINUX_LIB:$LD_LIBRARY_PATH"
    JAVA_LIB_PATH="$JAVA_HOME/lib:$JAVA_HOME/lib/server:$LINUX_LIB"
else
    export LD_LIBRARY_PATH="$LINUX_LIB:$LD_LIBRARY_PATH"
    JAVA_LIB_PATH="$LINUX_LIB"
fi

# Check for Java
if ! command -v java &> /dev/null; then
    echo "Error: Java is not installed or not in PATH."
    exit 1
fi

# Construct Classpath
CP=""
for jar in "$APP_LIB"/*.jar; do
    CP="$CP:$jar"
done
for jar in "$APP_LIB"/jogl/*.jar; do
    CP="$CP:$jar"
done
CP="$CP:$LINUX_LIB/jogl-all-natives-linux-amd64.jar"
CP="$CP:$LINUX_LIB/gluegen-rt-natives-linux-amd64.jar"

# Launch
echo "Starting Live2D Cubism 5.2 Editor on Linux..."

$JAVA_EXE -Duser.language=en \
    -Xmx${MAX_MEMORY}m \
    -Dos.name="Linux" \
    -XX:+ShowCodeDetailsInExceptionMessages \
    -Djogamp.gluegen.UseTempJarCache=false \
    -Dsun.java2d.d3d=false \
    -Dsun.java2d.opengl=true \
    -Djava.locale.providers=COMPAT,SPI \
    -Djava.library.path="$JAVA_LIB_PATH" \
    -classpath "$CP" \
    com.live2d.cubism.CECubismEditorApp "$@"
