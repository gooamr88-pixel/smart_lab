## Flutter / Dart
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

## google_generative_ai — prevent R8 from stripping Gemini API classes
-keep class com.google.ai.** { *; }
-dontwarn com.google.ai.**

## OkHttp / BoringSSL — required for HTTPS in release mode
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

## WebView (model_viewer_plus uses WebView under the hood)
-keep class android.webkit.** { *; }
-dontwarn android.webkit.**

## SharedPreferences
-keep class androidx.datastore.** { *; }

## Prevent stripping Flutter embedding
-keep class io.flutter.embedding.** { *; }

## Google Fonts
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

## General: keep annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses,EnclosingMethod

## 🚨 الحل الخاص بمشكلة الـ Build الأخيرة (Play Core) 🚨
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**