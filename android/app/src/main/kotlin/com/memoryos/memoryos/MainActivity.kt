package com.memoryos.memoryos

import android.content.ComponentName
import android.os.Build
import android.os.Bundle
import android.service.notification.NotificationListenerService
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestListenerRebind()
    }

    override fun onResume() {
        super.onResume()
        requestListenerRebind()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        CaptureHostApi.setUp(
            flutterEngine.dartExecutor.binaryMessenger,
            CaptureApiImpl(applicationContext)
        )
    }

    private fun requestListenerRebind() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                val cn = ComponentName(this, NotificationListener::class.java)
                NotificationListenerService.requestRebind(cn)
            }
        } catch (e: Exception) {
            Log.e("MainActivity", "Error requesting rebind: ${e.message}")
        }
    }
}
