# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# R8: ignore missing Play Store classes (not used)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# WebView
-keep class android.webkit.** { *; }
-dontwarn android.webkit.**

# Record package
-keep class com.instalite.** { *; }
