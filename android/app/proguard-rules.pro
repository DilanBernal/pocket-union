# Supabase / Ktor
-keep class io.github.jan.supabase.** { *; }
-keep class io.ktor.** { *; }
-dontwarn io.ktor.**
-keepattributes *Annotation*

# Kotlin serialization
-keepclassmembers class ** {
    @kotlinx.serialization.SerialName <fields>;
}
-keep @kotlinx.serialization.Serializable class ** { *; }

# sqflite
-keep class com.tekartik.sqflite.** { *; }

# shared_preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Google Fonts
-dontwarn com.google.fonts.**