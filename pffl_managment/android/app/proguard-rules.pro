# PFFL ProGuard Rules
# Basic rules for Flutter apps
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep classes for Dio HTTP client
-keep class com.google.gson.** { *; }
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }

# Keep classes for device info
-keep class io.flutter.plugins.deviceinfo.** { *; }

# Keep classes for shared preferences
-keep class android.content.SharedPreferences { *; }

# Keep classes for file picker
-keep class io.flutter.plugins.filepicker.** { *; }

# Keep classes for image picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# Keep classes for notifications
-keep class io.flutter.plugins.flutterlocalnotifications.** { *; }

# Keep classes for PDF generation
-keep class io.flutter.plugins.pdf.** { *; }

# Keep custom classes
-keep class com.pffl.managment.** { *; }

# Ignore warnings
-ignorewarnings
