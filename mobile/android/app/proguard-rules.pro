# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Flutter Secure Storage
-keep class com.it_ne.flutter_secure_storage.** { *; }

# Gson / Dio / Serialization
-keep class com.google.gson.** { *; }
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod

# Play Store split install & deferred components
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

