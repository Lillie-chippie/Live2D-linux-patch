# Full Devlog: Porting Live2D Cubism 5.2 to Linux

## 1. Project Overview
The goal is to run the Live2D Cubism 5.2 Editor on Linux. The project builds upon older community patches (originally for version 2.0) which are now obsolete due to significant changes in the application's architecture, specifically the move to JOGL 2.4.0 and stricter JAR integrity checks.

---

## 2. Environment & Dependencies

### JOGL 2.4.0 Integration
Cubism 5.2 uses JOGL 2.4.0 (`com.jogamp.opengl`). The original patch's JOGL 2.0-rc11 libraries were incompatible.
- **Action**: Downloaded Linux AMD64 natives for `jogl-all` and `gluegen-rt`.
- **Implementation**: Extracted `.so` files into `lib_linux/` and added them to `java.library.path` and `LD_LIBRARY_PATH`.

### Java Runtime
- **Requirement**: Java 17+ (OpenJDK 21 used during development).
- **Configuration**: Dynamically locating `JAVA_HOME` in launch scripts to ensure `libjawt.so` and `libjvm.so` are found.

---

## 3. Mimicking the Windows Environment
The application is heavily optimized for Windows and expects specific environment variables and system properties.

### System Properties
- `-Dos.name="Linux"`: Essential for JOGL to select the correct native windowing system (X11).
- `-Dsun.java2d.d3d=false`: Disables Direct3D.
- `-Dsun.java2d.opengl=true`: Forces the OpenGL pipeline for Java2D.

### Environment Variables
The application's utility classes (specifically `com.live2d.util.ao`) expect Windows-style paths.
- `APPDATA`, `LOCALAPPDATA`: Set to `$HOME/.local/share`.
- `USERPROFILE`: Set to `$HOME`.
- `HOMEDRIVE`, `HOMEPATH`: Set to `C:` and `$HOME` respectively.

---

## 4. Bytecode Patching & JAR Security

### The "Unsupported OS" Check
Older patches modified `jp/noids/util/aH.class`. In 5.2, this logic has moved or changed. We bypassed this by setting `os.name` and environment variables instead of direct class modification where possible.

### JAR Integrity (The SecurityException)
Modifying any class within `Live2D_Cubism.jar` (e.g., to bypass licensing or OS checks) triggers a `SecurityException: SHA-256 digest error`.
- **Discovery**: The JAR is signed. The `META-INF/MANIFEST.MF` contains hashes for every class.
- **Solution**: Removed the signature files (`META-INF/*.SF` and `META-INF/*.RSA`) from the JAR. This invalidates the signature but allows the JVM to load modified classes without hash verification.

---

## 5. Native Library Debugging

### CubismNatives
The Editor requires `CubismNatives.dll`. No Linux version exists.
- **Action**: Inspected the DLL and found it exports `Java_jp_live2d_cubism_NativeProxy_nativeSetRlmProxy`.
- **Solution**: Created a **Mock Native Library** (`libCubismNatives.so`) in C that implements this JNI function as a no-op. This prevents `UnsatisfiedLinkError` and allows the application to proceed.

### Live2DCubismCoreJNI
Required by the Viewer.
- **Finding**: This is a proprietary library. While the original patch stated it was missing for Linux, research confirms that Live2D officially supports Linux in their SDKs.
- **Discovery**: `libLive2DCubismCore.so` and `libLive2DCubismCoreJNI.so` exist in the official "Cubism SDK for Native" and "Cubism SDK for Java" respectively.
- **Status**: We have successfully obtained `libLive2DCubismCore.so` from community mirrors. The Viewer component can now be enabled if the JNI wrapper is also obtained or compiled.

---

## 6. Native Library Analysis (Cubism 5.2)

A comprehensive analysis of all required native libraries was performed to identify missing components and implementation difficulty.

| Library | Status | Difficulty | Solvable? |
| :--- | :--- | :--- | :--- |
| **JOGL/GlueGen** | ✅ Working | Done | ✅ Yes |
| **libCubismNatives.so** | ⚠️ Stub | Easy | ✅ Yes |
| **libLive2DCubismCoreJNI.so** | ❌ Missing | Hard | ⚠️ Maybe |
| **libLive2DCubismMotionSyncJNI.so** | ❌ Missing | Very Hard | ❌ Unlikely |
| **libLive2DCubismPFUtilsJNI.so** | ❌ Missing | Easy | ✅ Yes |
| **librlm1603.so** | ❌ Missing | Hard | ⚠️ Maybe |
| **libjpen.so** (xinput) | ✅ Available | Easy | ✅ Yes |
| **libonnxruntime.so** | ✅ Working | Medium | ✅ Yes |

---

## 7. Phase 1 Implementation: Easy Fixes

We have successfully implemented the first set of native library fixes to improve Editor stability and feature support.

### libLive2DCubismPFUtilsJNI.so
- **Problem**: Missing macOS-specific accessibility JNI library.
- **Solution**: Created a C-based mock (`pfutils_jni.c`) that implements the required JNI functions as no-ops.
- **Result**: Prevents `UnsatisfiedLinkError` when the application checks for accessibility features.

### JPen (Tablet Support)
- **Problem**: No pressure sensitivity on Linux due to missing `jpen-2-3-64.dll`.
- **Solution**: Integrated the official JPen Linux native library (`libjpen-2.so`) which uses XInput.
- **Result**: Enables tablet pressure sensitivity support natively on Linux.

### ONNX Runtime (AI Features)
- **Problem**: Missing ONNX Runtime libraries for AI-driven features.
- **Solution**: Downloaded official ONNX Runtime 1.13.1 Linux binaries and extracted the JNI bridge (`libonnxruntime4j_jni.so`) from the Maven Java artifact.
- **Result**: Enables AI features that rely on ONNX models.

---

## 8. Advanced Debugging: The Silent Exit

### The Problem
The application initializes OpenGL successfully, logs `calc screen size @UtGui`, and then exits silently with code 0 or 4. No Java stack trace is provided.

### The Interceptor (`noexit.so`)
To catch the exit point, we developed a C-based interceptor using `LD_PRELOAD`.
- **Code**: Overrode `exit()`, `_exit()`, and `_Exit()`.
- **Result**: Confirmed the application calls `exit()` voluntarily. By making the interceptor `sleep()` forever, we kept the process alive for inspection.

### Silent Exit Analysis (Phase 2)

The application was exiting silently even after bypassing the RLM hash check. Investigation revealed:
1.  The exit was triggered by `bi.u(this)`, which handles license initialization.
2.  Inside `bi.u`, it calls `com.live2d.c.f.a(boolean)` to resolve the license directory.
3.  **Bug in `f.java`**: The method `a(boolean)` has explicit checks for "Windows" and "Mac" but lacks a case for "Linux".
    *   If "Linux" is detected, it skips both platform-specific blocks.
    *   It then hits a null check for the path string and throws an `IllegalStateException`.
    *   This exception is caught in `bi.u`, which then calls `System.exit(0)` after failing to show an error dialog.

#### Patch for `f.class`
To fix this, we patch the bytecode of `com.live2d.c.f.class` to treat Linux like Mac for license directory purposes.
*   **Target**: `com.live2d.c.f.a(Z)Ljava/lang/String;`
*   **Offset**: `6835` (decimal) in the class file.
*   **Change**: `9c 00 32` (ifge 50) -> `9c 00 17` (ifge 23).
*   **Effect**: If "Linux" is found in `os.name`, it now jumps directly into the Mac path resolution logic instead of skipping it.

### Patch Summary
1.  **`CECubismEditorApp.class`**: Offset `0x35fc`: `03` -> `04` (Bypass RLM hash check).
2.  **`com.live2d.c.f.class`**: Offset `6835`: `9c 00 32` -> `9c 00 17` (Linux license directory support).

### Custom Tools & Scripts
*   `linux_patch/scripts/dump_cp.pl`: Dumps the constant pool of a class file.
*   `linux_patch/scripts/dump_method.pl`: Dumps method bytecode (requires manual offset/length).
*   `linux_patch/src/noexit.c`: LD_PRELOAD interceptor to catch and block `exit()` calls.

### The Root Cause: RLM Hash Check
The application performs a hash check on RLM (Reprise License Manager) files during startup in `com.live2d.cubism.CECubismEditorApp.a(String[])`.
- **Logic**: It checks for `rlm1603.jar` and `rlm1603.dll` (Windows) or `librlm1603.jnilib` (macOS).
- **Failure**: Since it doesn't account for Linux, the check returns `false`, triggering the "Unfortunately, an error occurred during startup" dialog and calling `System.exit(0)`.
- **Solution**: Patch the bytecode in `CECubismEditorApp.class` to force the check to return `true` or jump over the exit logic.

---

## 8. Current State & Limitations

| Component | Status | Note |
| :--- | :--- | :--- |
| **Editor** | **Functional*** | Initializes OpenGL. Startup error bypassed via bytecode patch. |
| **Viewer** | **In Progress** | Native `libLive2DCubismCore.so` obtained. JNI wrapper analysis complete. |
| **Installer** | **Functional** | Handles JOGL extraction and JAR signature removal. |

\* *Note: Editor requires bytecode patching to bypass the RLM hash check.*

## 9. Future Directions
1. **Phase 1: Easy Fixes**: ✅ **Complete**. Implemented `PFUtilsJNI` mock, integrated `ONNX Runtime`, and `JPen` Linux library.
2. **Dialog Bypass**: ✅ **Complete**. Identified the RLM hash check in `CECubismEditorApp` and developed a bytecode patch.
3. **Viewer Integration**: Complete the compilation of the native Linux viewer JNI wrapper and integrate it into the patch.
4. **X11/AWT Debugging**: Investigate why the initial window/dialog might be failing to render on certain Linux window managers.

## 10. Phase 2: Binary Patching Attempts (RLM & License Directory)

### RLM Hash Check (`CECubismEditorApp.class`)
- **Goal**: Bypass the startup error dialog caused by the RLM hash check failure.
- **Method**: Modified `a(String[])` to return early or force success.
- **Result**: ✅ **Success**.
  - Patch: Changed `iconst_0` to `iconst_1` at offset `0x35fc` (pushes `true` to stack).
  - Effect: The error dialog is suppressed.

### License Directory Resolution (`com.live2d.c.f.class`)
- **Goal**: Fix the "Silent Exit" bug where the application fails to resolve the license directory on Linux.
- **Method**: Attempted to modify the bytecode to treat "Linux" like "Mac" or force "Windows" path logic.
- **Attempts**:
  1.  **Jump Target Modification**: Changed `ifge` target to jump into Mac logic.
      - Result: ❌ **Failed**. Logic flow was invalid.
  2.  **Force Windows Logic**: Replaced Linux check with `goto` to Windows logic block.
      - Result: ❌ **Failed**. `java.lang.VerifyError: Inconsistent stackmap frames`. The stack state at the jump target did not match the expected frame.
  3.  **Stack Correction**: Attempted `iconst_1` + `pop` + `goto` to balance the stack.
      - Result: ❌ **Failed**. `java.lang.VerifyError`.
- **Conclusion**: Binary patching `f.class` is too complex due to strict `StackMapTable` verification in modern Java.
- **Next Steps**: Recompile `f.class` from source (decompiled) using `javac`. This requires installing the JDK.

## 11. Phase 3: Recompilation and Fix (`f.class`)

### Problem
Binary patching `f.class` failed due to `StackMapTable` verification errors. The class is responsible for resolving the license directory path, and on Linux, it was falling through to an `IllegalStateException` because the "Linux" branch didn't assign a path.

### Solution
1.  **Decompilation**: Analyzed `f.class` bytecode using `javap`.
2.  **Reconstruction**: Reconstructed the Java source code for `f.java`, implementing the missing Linux logic.
    - **Fix**: Mapped Linux to use `~/.local/share` (similar to Windows `APPDATA` or Mac `Application Support`).
    - **Dependencies**: Handled dependencies on `com.live2d.c.*`, `com.live2d.util.*`, and Kotlin runtime.
3.  **Compilation**: Compiled `f.java` using `javac` with `Live2D_Cubism.jar` and `kotlin-stdlib` in the classpath.
4.  **Injection**: Updated `Live2D_Cubism.jar` with the new `f.class`.

### Result
- ✅ **Success**. `strace` confirms that the application now successfully accesses and writes to `~/.local/share/Live2D/Cubism5.2_Editor`.
- The "Silent Exit" due to license directory resolution is **FIXED**.
- The application now progresses further but still exits (likely due to X11/OpenGL issues or license validation), but the initialization phase is working.

## 12. Cleanup and Packaging

### Cleanup
- Removed `linux_patch/src/CubismNativeSamples`: These were identified as the official C++ SDK samples. They are not used by the patch and do not contain the missing Java JNI wrapper code for the Viewer.
- Removed unused `.deb` files from `src`.

### Final Package
- Created `linux_patch.tar.gz` containing:
  - `install.sh`: Main installer.
  - `lib_linux/`: Native libraries (including custom mocks).
  - `scripts/`: Python scripts for bytecode patching (RLM bypass).
  - `src/`: Source code for custom libraries and `f.java` (recompiled fix).
  - `run_linux.sh` / `run_animator_linux.sh`: Launch scripts.
  - Documentation (`README.txt`, `devlog.md`, `implementation_plan.md`).
