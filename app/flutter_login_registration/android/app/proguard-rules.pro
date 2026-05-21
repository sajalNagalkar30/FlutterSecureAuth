# ── Flutter ───────────────────────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# ── Fix R8 missing class errors ───────────────────────────────────────────────
-dontwarn javax.lang.model.element.Modifier
-dontwarn javax.lang.model.**
-dontwarn com.google.errorprone.annotations.**
-dontwarn com.google.j2objc.annotations.**
-dontwarn org.checkerframework.**
-dontwarn afu.org.checkerframework.**
-dontwarn sun.misc.Unsafe

# ── flutter_secure_storage ────────────────────────────────────────────────────
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# ── Connectivity Plus ─────────────────────────────────────────────────────────
-keep class dev.fluttercommunity.plus.connectivity.** { *; }

# ── OkHttp / Dio (networking) ─────────────────────────────────────────────────
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# ── Remove all logging in release ────────────────────────────────────────────
-assumenosideeffects class android.util.Log {
    public static int v(...);
    public static int d(...);
    public static int i(...);
    public static int w(...);
    public static int e(...);
}

# ── Keep annotations and signatures ──────────────────────────────────────────
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# ── Kotlin ────────────────────────────────────────────────────────────────────
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
-dontwarn kotlin.**
