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

# Suppress ProGuard/R8 warnings for optional ML Kit text recognition classes for different languages
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.chinese.ChineseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.devanagari.DevanagariTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.japanese.JapaneseTextRecognizerOptions
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions$Builder
-dontwarn com.google.mlkit.vision.text.korean.KoreanTextRecognizerOptions