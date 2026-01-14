# Live2D Cubism 5.2 Linux Native Library Analysis

Complete analysis of all native libraries required to run Live2D Cubism 5.2 on Linux.

---

## Summary

| Library | Status | Functions | Difficulty | Solvable? |
|---------|--------|-----------|------------|-----------|
| **JOGL/GlueGen** | ✅ Working | N/A | Done | ✅ Yes |
| **libCubismNatives.so** | ⚠️ Stub | 1 | Easy | ✅ Yes |
| **libLive2DCubismCoreJNI.so** | ❌ Missing | 12 | Hard | ⚠️ Maybe |
| **libLive2DCubismMotionSyncJNI.so** | ❌ Missing | 8 | Very Hard | ❌ Unlikely |
| **libLive2DCubismPFUtilsJNI.so** | ❌ Missing | 2 | Easy | ✅ Yes |
| **librlm1603.so** | ❌ Missing | 78 | Hard | ⚠️ Maybe |
| **libjpen.so** (xinput) | ✅ Available | N/A | Easy | ✅ Yes |
| **libonnxruntime.so** | ❌ Missing | Many | Medium | ✅ Yes |

---

## 1. libCubismNatives.so (Current Mock)

### Current State
Only implements 1 no-op function:
```c
void Java_jp_live2d_cubism_NativeProxy_nativeSetRlmProxy(...) {
    printf("Mocked nativeSetRlmProxy called\n");
}
```

### Analysis
This is a proxy for RLM licensing. The mock is sufficient if we also mock or bypass licensing.

### Recommendation
**Keep as mock** - this is working correctly as a no-op stub.

---

## 2. libLive2DCubismCoreJNI.so (CRITICAL - Viewer)

### Required Native Methods (12 functions)
```
getVersion()
getLatestMocVersion()
getMocVersion([B)I
hasMocConsistency([B)Z
instantiateMoc([B)J           // Returns native pointer
destroyMoc(J)V
instantiateModel(J)J          // Returns native pointer  
destroyModel(J)V
updateModel(J)V
partialUpdateModel(J[I[I[I[I)V
resetDrawableDynamicFlags(J)V
syncToNativeModel(CubismModel)V
syncFromNativeModel(CubismModel)V
initializeJavaModelWithNativeModel(CubismModel)V
receiveLogFromNative(String)V
```

### Analysis
- Wraps libLive2DCubismCore.so (already present!)
- Official Live2D SDK for Java exists but isn't publicly distributed for Linux

### Options
1. **Build from SDK** - Download "Cubism SDK for Java" and compile JNI wrapper
2. **Reverse engineer** - Create JNI layer calling `libLive2DCubismCore.so` 
3. **Request from Live2D** - Contact Live2D Inc. for Linux JNI binaries

### Recommendation
This is the **most critical missing library** for viewer functionality.
The core library exists (`libLive2DCubismCore.so`), we only need the JNI wrapper.

---

## 3. libLive2DCubismMotionSyncJNI.so

### Required Native Methods (8 functions)
```
loadEngine(String)J
unloadEngine(J)V
getEngineVersion(J)I
getEngineName(J)Ljava/lang/String;
initializeEngine(J)V
disposeEngine(J)V
createContextCRI(J[CubismMotionSyncMappingInfo;II)J
deleteContext(JJ)V
analyzeCRI(JJ[FIFIFCRI, CubismMotionSyncAnalysisResult)I
```

### Analysis
- Requires proprietary CRI Middleware engine (`Live2DCubismMotionSyncEngine_CRI.dll`)
- No Linux version available from CRI Middleware
- Used for real-time lip-sync from audio

### Recommendation
**Not solvable** - Proprietary CRI Middleware has no Linux support.
This feature will remain unavailable on Linux.

---

## 4. libLive2DCubismPFUtilsJNI.so (EASY)

### Required Native Methods (2 functions)
```
accessibilityEnabledInMacOS()Z      // Returns boolean
showAccessibilityPreferenceInMacOS()V
```

### Analysis
- **macOS-specific only!** These are Accessibility API calls
- On Linux, both can return no-op values

### Implementation
```c
#include <jni.h>

JNIEXPORT jboolean JNICALL Java_com_live2d_cubism_pfutils_Live2DCubismPFUtilsJNI_accessibilityEnabledInMacOS
  (JNIEnv *env, jclass cls) {
    return JNI_FALSE;  // Not on macOS
}

JNIEXPORT void JNICALL Java_com_live2d_cubism_pfutils_Live2DCubismPFUtilsJNI_showAccessibilityPreferenceInMacOS
  (JNIEnv *env, jclass cls) {
    // No-op on Linux
}
```

### Recommendation
**Easy fix** - Create simple mock that returns false/no-op.

---

## 5. librlm1603.so (Licensing - COMPLEX)

### Required Native Methods (78 functions!)
Key functions:
```
rlmInit(String, String, String)J
rlmClose(J)I
rlmStat(J)I
rlmHostID(JI[B)I
rlmProducts(JStringString)J
rlmProductName(J)String
rlmProductExpDays(J)I
rlmProductExpiration(J)String
... (70+ more)
```

### Analysis
- RLM (Reprise License Manager) by Reprise Software
- Commercial license server software
- **Linux version exists!** RLM officially supports Linux

### Options
1. **Obtain RLM Linux** - Download from reprisesoftware.com
2. **Mock licensing** - Create stub that simulates valid license (for testing only)
3. **Bytecode patch** - Modify license check in Java (already partially done)

### Recommendation
RLM Linux libraries exist officially. Check if you have a license.
Current bytecode patching may be sufficient to bypass.

---

## 6. JPen (Tablet Support - ALREADY WORKS)

### Analysis
JPen already includes **Linux xinput provider**:
- `jpen/provider/xinput/XiBus.class`
- `jpen/provider/xinput/XiDevice.class`
- `jpen/provider/xinput/XinputProvider.class`

The jar needs the native library `libjpen-2.so` compiled for Linux with xinput support.

### Native Methods for XiBus
```
create()
destroy()
getXiDevicesSize()
getDevicesSize(I)I
getXiDeviceName(I)String
setXiDevice(I)V
refreshXiDeviceInfo()
... etc
```

### Recommendation
**JPen has official Linux support!** 
Download or compile `libjpen-2.so` from jpen.sourceforge.net

---

## 7. ONNX Runtime (AI Features - AVAILABLE)

### Analysis
- ONNX Runtime officially supports Linux
- Just need to download `libonnxruntime.so` and `libonnxruntime4j_jni.so`
- Available from github.com/microsoft/onnxruntime

### Recommendation
**Easy fix** - Download official Linux builds from Microsoft.

---

## Proposed Implementation Plan

### Phase 1: Easy Fixes (Immediate)
1. [x] `libCubismNatives.so` - Keep current mock
2. [ ] Create `libLive2DCubismPFUtilsJNI.so` - Simple no-op mock
3. [ ] Download `libonnxruntime.so` from Microsoft
4. [ ] Compile or download `libjpen-2.so` for xinput

### Phase 2: Medium Difficulty
5. [ ] Research RLM Linux availability
6. [ ] Test if bytecode patching bypasses RLM entirely

### Phase 3: Hard (Viewer Support)
7. [ ] Build `libLive2DCubismCoreJNI.so` wrapper
8. [ ] Test with CubismNativeSamples code in `src/`

### Phase 4: Bytecode Patching (Startup & License)

1.  **Bypass RLM Hash Check**: ✅ **Done**
    *   File: `com.live2d.cubism.CECubismEditorApp.class`
    *   Patch: `iconst_0` -> `iconst_1` (Offset `0x35fc`)
    *   Status: Error dialog suppressed.

2.  **Fix License Directory Resolution**: ⚠️ **Pending**
    *   File: `com.live2d.c.f.class`
    *   Issue: Binary patching failed due to `VerifyError`.
    *   Plan: Recompile class using `javac`.

### Phase 5: Recompilation (New)
10. [x] Install `default-jdk`
11. [x] Decompile `f.class` (using `javap` or similar)
12. [x] Reconstruct source code for `f.java` with Linux fix
13. [x] Compile `f.java` -> `f.class`
14. [x] Inject new `f.class` into JAR

### Not Fixable
- ❌ Motion Sync (CRI Middleware - proprietary, no Linux)
