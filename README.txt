Live2D Cubism 5.2 Linux Patch
=============================

This package enables Live2D Cubism 5.2 to run natively on Linux.

Contents:
- lib_linux/: Contains Linux-compatible JOGL natives (2.4.0).
- run_linux.sh: Launch script for the Editor.
- run_animator_linux.sh: Launch script for the Viewer.
- install.sh: Installer script.

Instructions:
-------------
1. Extract this folder (`linux_patch`) into your "Live2D Cubism 5.2" directory.
   
   Example:
   /path/to/Live2D Cubism 5.2/linux_patch/

2. Open a terminal and navigate to the `linux_patch` directory.

   cd "/path/to/Live2D Cubism 5.2/linux_patch"

3. Run the installer script:

   ./install.sh

   This script will copy the necessary libraries and launch scripts to the main folder.

4. Once finished, go back to the main directory and run the application:

   Editor:
   cd ..
   ./run_linux.sh

   Viewer:
   ./run_animator_linux.sh

Requirements:
-------------
- Java Runtime Environment (JRE) or JDK 11+ installed and in PATH.
- Standard Linux libraries (GLIBC, etc.).

Important Notes:
----------------
- The EDITOR (run_linux.sh) works fully on Linux.
- The VIEWER (run_animator_linux.sh) is NOT SUPPORTED because it requires
  the proprietary Live2DCubismCoreJNI library which is only available for
  Windows and macOS. This is a Live2D SDK limitation, not a patch issue.
