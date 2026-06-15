# Flutter wrapper — keep Flutter embedding classes.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# sqflite uses no reflection of note, but keep its plugin classes to be safe.
-keep class com.tekartik.sqflite.** { *; }

# Suppress warnings for optional Play Core (deferred components) classes that
# Flutter references but this app does not use.
-dontwarn com.google.android.play.core.**
