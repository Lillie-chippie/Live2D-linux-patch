Live2D Cubism 2.0 Linux Patch
=============================

This package enables Live2D Cubism 2.0 to run natively on Linux.

Contents:
- lib_linux/: Contains Linux-compatible JOGL libraries.
- run_linux.sh: A launch script for Linux.
- install.sh: An automated installer script.
- patch_jar.py: A helper script used by the installer.

Instructions:
-------------
1. Extract this folder (`linux_patch`) into your "Live2D Cubism 2.0" directory.
   
   Example:
   /path/to/Live2D Cubism 2.0/linux_patch/

2. Open a terminal and navigate to the `linux_patch` directory.

   cd "/path/to/Live2D Cubism 2.0/linux_patch"

3. Run the installer script:

   ./install.sh

   This script will:
   - Backup your original `app/lib/Live2D_Cubism.jar`.
   - Patch the jar to bypass the "Unsupported OS" check.
   - Copy the Linux libraries and launch script to the main folder.

4. Once finished, go back to the main directory and run the application:

   Modeler:
   cd ..
   ./run_linux.sh

   Animator:
   ./run_animator_linux.sh

Troubleshooting:
----------------
- Ensure you have `zip`, `unzip`, and `python3` installed.
- Ensure you have a Java Runtime Environment (JRE) installed.
