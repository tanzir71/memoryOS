package com.memoryos.memoryos

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import android.service.notification.NotificationListenerService
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.memoryos.memoryos/persistent"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Start the PersistentService to listen for task removal if configured persistent
        try {
            val sharedPref = getSharedPreferences("memoryos_prefs", Context.MODE_PRIVATE)
            val isPersistent = sharedPref.getBoolean("is_persistent", false)
            if (isPersistent) {
                val serviceIntent = Intent(this, PersistentService::class.java)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    startForegroundService(serviceIntent)
                } else {
                    startService(serviceIntent)
                }
                Log.d("MainActivity", "Cold start: Started PersistentService based on preferences")
            }
        } catch (e: Exception) {
            // Ignore
        }

        // Force requestRebind for NotificationListener to ensure OS reconnection
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                val cn = ComponentName(this, NotificationListener::class.java)
                NotificationListenerService.requestRebind(cn)
                Log.d("MainActivity", "Successfully requested NotificationListener rebind.")
            }
        } catch (e: Exception) {
            Log.e("MainActivity", "Error requesting rebind: ${e.message}")
        }
    }

    override fun onResume() {
        super.onResume()
        
        // Force requestRebind for NotificationListener on resume to ensure immediate reconnection
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                val cn = ComponentName(this, NotificationListener::class.java)
                NotificationListenerService.requestRebind(cn)
                Log.d("MainActivity", "onResume: Successfully requested NotificationListener rebind.")
            }
        } catch (e: Exception) {
            Log.e("MainActivity", "onResume: Error requesting rebind: ${e.message}")
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setPersistent" -> {
                    val args = call.arguments as? Map<*, *>
                    val isPersistent = args?.get("isPersistent") as? Boolean ?: false
                    val isPhotoEnabled = args?.get("isPhotoEnabled") as? Boolean ?: false
                    val isNotificationEnabled = args?.get("isNotificationEnabled") as? Boolean ?: false
                    val sourceToggles = args?.get("sourceToggles") as? Map<*, *>
                    
                    // Save to native SharedPreferences so PersistentService can access it
                    val sharedPref = getSharedPreferences("memoryos_prefs", Context.MODE_PRIVATE)
                    with(sharedPref.edit()) {
                        putBoolean("is_persistent", isPersistent)
                        putBoolean("toggle_photo", isPhotoEnabled)
                        putBoolean("toggle_notification", isNotificationEnabled)
                        sourceToggles?.forEach { entry ->
                            val key = entry.key as? String
                            val value = entry.value as? Boolean
                            if (key != null && value != null) {
                                putBoolean("toggle_$key", value)
                            }
                        }
                        apply()
                    }
                    
                    try {
                        val serviceIntent = Intent(this, PersistentService::class.java)
                        if (isPersistent) {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                startForegroundService(serviceIntent)
                            } else {
                                startService(serviceIntent)
                            }
                            Log.d("MainActivity", "MethodChannel: Started PersistentService")
                        } else {
                            stopService(serviceIntent)
                            Log.d("MainActivity", "MethodChannel: Stopped PersistentService")
                        }
                    } catch (e: Exception) {
                        Log.e("MainActivity", "MethodChannel: Error managing PersistentService: ${e.message}")
                    }

                    // Force requestRebind for NotificationListener when persistent settings update
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                            val cn = ComponentName(this, NotificationListener::class.java)
                            NotificationListenerService.requestRebind(cn)
                            Log.d("MainActivity", "MethodChannel: Requested NotificationListener rebind.")
                        }
                    } catch (e: Exception) {
                        Log.e("MainActivity", "MethodChannel: Error requesting rebind: ${e.message}")
                    }
                    
                    result.success(null)
                }
                "isIgnoringBatteryOptimizations" -> {
                    val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
                    val isIgnoring = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        powerManager.isIgnoringBatteryOptimizations(packageName)
                    } else {
                        true
                    }
                    result.success(isIgnoring)
                }
                "openBatterySettings" -> {
                    try {
                        // 1. Try to request battery exemption directly
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            val intent = Intent(android.provider.Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                                data = android.net.Uri.parse("package:$packageName")
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                            result.success(null)
                            return@setMethodCallHandler
                        }
                    } catch (e: Exception) {
                        // Ignore and fall through to secondary options
                    }

                    try {
                        // 2. Fallback to ignore battery optimization settings page
                        val intent = Intent(android.provider.Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        try {
                            // 3. Last resort fallback to general app details settings page
                            val intent = Intent(android.provider.Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                                data = android.net.Uri.fromParts("package", packageName, null)
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                            result.success(null)
                        } catch (ex: Exception) {
                            result.error("SettingsError", ex.message, null)
                        }
                    }
                }
                "isNotificationListenerPermissionGranted" -> {
                    val cn = ComponentName(this, NotificationListener::class.java)
                    val flat = Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
                    val isGranted = flat != null && flat.contains(cn.flattenToString())
                    result.success(isGranted)
                }
                "requestNotificationListenerPermission" -> {
                    try {
                        val intent = Intent("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS").apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SettingsError", e.message, null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
