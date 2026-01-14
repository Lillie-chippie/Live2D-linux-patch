#!/bin/bash

# Live2D Cubism 5.2 Linux Launcher (Viewer)

cd "$(dirname "$0")"

# Configuration
JAVA_EXE="java"
MAX_MEMORY="4000"
APP_LIB="app/lib"
LINUX_LIB="lib_linux"

# Fix for potential NPE in com.live2d.util.ao (expecting APPDATA)
export APPDATA="$HOME/.local/share"

# Find JRE lib paths for libjawt.so and libjvm.so
JAVA_HOME=$(java -XshowSettings:properties -version 2>&1 | grep "java.home" | awk '{print $3}')
if [ -d "$JAVA_HOME/lib" ]; then
    # Add both lib and lib/server (for libjvm.so)
    export LD_LIBRARY_PATH="$JAVA_HOME/lib:$JAVA_HOME/lib/server:$LINUX_LIB:$LD_LIBRARY_PATH"
else
    export LD_LIBRARY_PATH="$LINUX_LIB:$LD_LIBRARY_PATH"
fi

# Check for Java
if ! command -v java &> /dev/null; then
    echo "Error: Java is not installed or not in PATH."
    exit 1
fi

# Construct Classpath
# 1. Application Libraries
CP=""
for jar in "$APP_LIB"/*.jar; do
    CP="$CP:$jar"
done

# 2. JOGL Libraries (Bundled Java code)
for jar in "$APP_LIB"/jogl/*.jar; do
    CP="$CP:$jar"
done

# 3. Linux JOGL Natives (Downloaded)
CP="$CP:$LINUX_LIB/jogl-all-natives-linux-amd64.jar"
CP="$CP:$LINUX_LIB/gluegen-rt-natives-linux-amd64.jar"

# Launch
echo "Starting Live2D Cubism 5.2 Viewer on Linux..."

$JAVA_EXE -Duser.language=en \
    -Xmx${MAX_MEMORY}m \
    -Dos.name="Linux" \
    -Djava.library.path="$LINUX_LIB" \
    -Djogamp.gluegen.UseTempJarCache=false \
    -Dsun.java2d.d3d=false \
    -Djava.locale.providers=COMPAT,SPI \
    -classpath "$CP" \
    com.live2d.cubism.doc.modeling.ui.viewerForOriginalWorkflow.OWViewerDropFrame "$@"
