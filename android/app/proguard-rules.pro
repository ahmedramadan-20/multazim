# ── Flutter Wrapper ────────────────────────────────
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ── Play Core / Split Install (Generated Missing Rules) ──
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# ── ObjectBox (Critical for DB) ────────────────────
-keep class io.objectbox.** { *; }
-dontwarn io.objectbox.**
-keep @io.objectbox.annotation.Entity class * { *; }
-keepclassmembers class * {
    @io.objectbox.annotation.Id *;
    @io.objectbox.annotation.Index *;
    @io.objectbox.annotation.Unique *;
    @io.objectbox.annotation.Backlink *;
}
-keep class io.objectbox.relation.ToOne
-keep class io.objectbox.relation.ToMany

# ── Supabase & Serialization ───────────────────────
-keep class io.supabase.** { *; }
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod

# ── Notifications (Android 14+ Compatibility) ──────
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**
-keep class com.dexterous.flutter_local_notifications.** { *; }

# Keep notification icons and resources
-keepclassmembers class **.R$* {
    public static <fields>;
}
-keep class **.R
-keep class **.R$drawable { *; }
-keep class **.R$mipmap { *; }

# ── Connectivity & Kotlin ──────────────────────────
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
-dontwarn kotlin.**
-keep class dev.fluttercommunity.plus.connectivity.** { *; }

# ── General Optimization Settings ──────────────────
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile