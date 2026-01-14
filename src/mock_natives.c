#include <stdio.h>

// Minimal JNI types
typedef void* JNIEnv;
typedef void* jclass;
typedef void* jstring;
typedef void* jobject;
typedef unsigned char jboolean;

// Java_jp_live2d_cubism_NativeProxy_nativeSetRlmProxy
// Signature: (Ljava/lang/String;Ljava/lang/String;Ljava/lang/Object;Z)V
void Java_jp_live2d_cubism_NativeProxy_nativeSetRlmProxy(JNIEnv* env, jclass cls, jstring s1, jstring s2, jobject obj, jboolean b) {
    printf("Mocked nativeSetRlmProxy called\n");
}
