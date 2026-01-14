/*
 * libLive2DCubismPFUtilsJNI.so - Linux mock implementation
 * 
 * These are macOS-specific accessibility functions.
 * On Linux, they simply return no-op values.
 * 
 * Compile with:
 *   gcc -shared -fPIC -o libLive2DCubismPFUtilsJNI.so pfutils_jni.c
 */

// Minimal JNI definitions to avoid dependency on jni.h
typedef unsigned char jboolean;
typedef void* JNIEnv;
typedef void* jclass;
#define JNIEXPORT __attribute__((visibility("default")))
#define JNICALL
#define JNI_FALSE 0
#define JNI_TRUE 1

/*
 * Class:     com_live2d_cubism_pfutils_Live2DCubismPFUtilsJNI
 * Method:    accessibilityEnabledInMacOS
 * Signature: ()Z
 */
JNIEXPORT jboolean JNICALL Java_com_live2d_cubism_pfutils_Live2DCubismPFUtilsJNI_accessibilityEnabledInMacOS
  (JNIEnv *env, jclass cls) {
    // Not on macOS, always return false
    return JNI_FALSE;
}

/*
 * Class:     com_live2d_cubism_pfutils_Live2DCubismPFUtilsJNI
 * Method:    showAccessibilityPreferenceInMacOS  
 * Signature: ()V
 */
JNIEXPORT void JNICALL Java_com_live2d_cubism_pfutils_Live2DCubismPFUtilsJNI_showAccessibilityPreferenceInMacOS
  (JNIEnv *env, jclass cls) {
    // No-op on Linux
}
