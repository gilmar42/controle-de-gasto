# Flutter / Dart keeps
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# Provider / generated model classes (adjust as needed)
-keep class com.example.controle_gasto.** { *; }

# Keep Kotlin data classes (avoid stripping component functions)
-keepclassmembers class **$* {
    <fields>;
}

# Gson / JSON libraries
-keep class com.google.gson.** { *; }
-keep class sun.misc.Unsafe { *; }

# Retain enums
-keepclassmembers enum * { *; }

# Keep Play Core split install classes referenced by Flutter deferred components
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-dontwarn com.google.android.play.core.**

# Avoid warnings for annotations
-dontwarn javax.annotation.**
-dontwarn org.jetbrains.annotations.**

# Remove logging in release (optional)
-assumenosideeffects class android.util.Log {
    public static *** v(...);
    public static *** d(...);
    public static *** i(...);
    public static *** w(...);
    public static *** e(...);
}
