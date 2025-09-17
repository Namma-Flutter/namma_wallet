# Keep all MediaPipe classes
-keep class com.google.mediapipe.** { *; }
-dontwarn com.google.mediapipe.**

# Keep all Protocol Buffer classes
-keep class com.google.protobuf.** { *; }
-dontwarn com.google.protobuf.**

# Keep AutoValue generated classes
-keep class com.google.auto.value.** { *; }
-dontwarn com.google.auto.value.**

# Keep OkHttp optional dependencies
-dontwarn org.bouncycastle.**
-dontwarn org.conscrypt.**
-dontwarn org.openjsse.**

# Keep javax.lang.model classes (used by annotation processors)
-dontwarn javax.lang.model.**

# Keep Flutter Gemma related classes
-keep class io.flutter.plugins.flutter_gemma.** { *; }
-dontwarn io.flutter.plugins.flutter_gemma.**