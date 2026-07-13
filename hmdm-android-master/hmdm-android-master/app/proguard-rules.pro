# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in C:\Android\sdk/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Keep legacy SDK compatibility class
-keep class !ru.headwind.kiosk.**{ *; }
-keep class ru.headwind.kiosk.sdk.UpdateError {*;}

# ---- Jackson (JSON serialization/deserialization) ----
# Keep all JSON model classes used by Jackson so fields are not stripped
-keep class com.hmdm.launcher.json.** { *; }
-keepclassmembers class com.hmdm.launcher.json.** {
    <fields>;
    <init>();
}
-keep @com.fasterxml.jackson.annotation.JsonIgnoreProperties class * { *; }
-keepnames class com.fasterxml.jackson.** { *; }
-dontwarn com.fasterxml.jackson.databind.**

# ---- Retrofit / OkHttp ----
-keep class retrofit2.** { *; }
-keepattributes Signature
-keepattributes Exceptions
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn retrofit2.**
-keep interface com.hmdm.launcher.server.** { *; }

# ---- AIDL / Binder interfaces ----
-keep class com.hmdm.IMdmApi { *; }
-keep class com.hmdm.IMdmApi$** { *; }

# ---- WorkManager Workers ----
-keep class * extends androidx.work.Worker { *; }
-keep class * extends androidx.work.ListenableWorker { *; }
-keepclassmembers class * extends androidx.work.ListenableWorker {
    public <init>(android.content.Context, androidx.work.WorkerParameters);
}

# ---- Reflection (SystemProperties, TelephonyManager hidden APIs) ----
-keepclassmembers class android.telephony.TelephonyManager {
    public *;
}

# ---- Enum classes ----
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# ---- Paho MQTT ----
-keep class org.eclipse.paho.** { *; }
-dontwarn org.eclipse.paho.**

# ---- ZXing barcode scanner ----
-keep class com.google.zxing.** { *; }
-keep class com.journeyapps.** { *; }
-dontwarn com.journeyapps.**

# ---- Data Binding ----
-keep class androidx.databinding.** { *; }
-dontwarn androidx.databinding.**

# ---- Jakarta XML Bind (JAXB) ----
-dontwarn jakarta.xml.bind.**
-dontwarn org.glassfish.jaxb.**

# ---- General Android / AndroidX ----
-dontwarn androidx.**
-keep class androidx.core.app.CoreComponentFactory { *; }
