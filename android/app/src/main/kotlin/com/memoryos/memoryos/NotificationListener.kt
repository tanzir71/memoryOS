package com.memoryos.memoryos

import android.Manifest
import android.app.Notification
import android.bluetooth.BluetoothDevice
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import org.json.JSONObject
import java.util.concurrent.ConcurrentHashMap

class NotificationListener : NotificationListenerService() {
    private val tag = "NotificationListener"
    private var btRegistered = false
    private val activeBluetooth = ConcurrentHashMap<String, Pair<String, Long>>()

    private val bluetoothReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val prefs = context.getSharedPreferences("memoryos_prefs", Context.MODE_PRIVATE)
            if (StatusNotifier.isPaused(context)) return
            if (!prefs.getBoolean("toggle_bluetooth", true)) return

            val device = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE, BluetoothDevice::class.java)
            } else {
                @Suppress("DEPRECATION")
                intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
            } ?: return

            val address = safeAddress(device)
            val name = safeName(device)
            val now = System.currentTimeMillis()

            when (intent.action) {
                BluetoothDevice.ACTION_ACL_CONNECTED -> {
                    activeBluetooth[address] = Pair(name, now)
                }
                BluetoothDevice.ACTION_ACL_DISCONNECTED -> {
                    val started = activeBluetooth.remove(address)
                    val startMs = started?.second ?: now
                    val resolvedName = started?.first ?: name
                    val extras = JSONObject().apply {
                        put("deviceName", resolvedName)
                        put("deviceAddress", address)
                        put("durationSec", ((now - startMs) / 1000L).coerceAtLeast(0L))
                    }
                    InboxDatabase.getInstance(context).insertRecord(
                        RawInboxRecord(
                            source = "bluetooth",
                            title = resolvedName,
                            text = "Connected",
                            extrasJson = extras.toString(),
                            postedAt = startMs,
                            removedAt = now,
                        )
                    )
                }
            }
        }
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        registerBluetoothReceiver()
        StatusNotifier.refresh(this)
    }

    override fun onListenerDisconnected() {
        unregisterBluetoothReceiver()
        super.onListenerDisconnected()
    }

    override fun onDestroy() {
        unregisterBluetoothReceiver()
        super.onDestroy()
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?, rankingMap: RankingMap?) {
        if (sbn == null) return
        val pkg = sbn.packageName ?: return
        if (pkg == packageName) return
        if (StatusNotifier.isPaused(this)) return

        try {
            val ranking = Ranking()
            val hasRanking = rankingMap?.getRanking(sbn.key, ranking) == true
            val importance = if (hasRanking) ranking.importance else 3
            val isConversation = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && hasRanking) {
                ranking.isConversation
            } else {
                false
            }
            val notification = sbn.notification
            val extras = notification.extras ?: Bundle()
            val channel = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                notification.channelId ?: ""
            } else {
                ""
            }
            val redacted = notification.visibility == Notification.VISIBILITY_PRIVATE &&
                extras.isEmpty

            val record = NotificationMapper.map(
                pkg = pkg,
                channel = channel,
                category = notification.category ?: "",
                flags = notification.flags,
                importance = importance,
                sbnKey = sbn.key ?: "",
                groupKey = sbn.groupKey ?: "",
                isConversation = isConversation,
                postedAt = sbn.postTime,
                extras = extras,
                redacted = redacted,
            )

            InboxDatabase.getInstance(applicationContext).insertOrUpdateNotification(record)
        } catch (e: Exception) {
            Log.e(tag, "Failed to store notification: ${e.message}", e)
        }
    }

    override fun onNotificationRemoved(
        sbn: StatusBarNotification?,
        rankingMap: RankingMap?,
        reason: Int
    ) {
        if (sbn == null) return
        if (sbn.packageName == packageName) return
        try {
            val key = sbn.key ?: return
            InboxDatabase.getInstance(applicationContext)
                .markRemovedBySbnKey(key, System.currentTimeMillis(), reason)
        } catch (e: Exception) {
            Log.e(tag, "Failed to store notification removal: ${e.message}", e)
        }
    }

    private fun registerBluetoothReceiver() {
        if (btRegistered) return
        val filter = IntentFilter().apply {
            addAction(BluetoothDevice.ACTION_ACL_CONNECTED)
            addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED)
        }
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                registerReceiver(bluetoothReceiver, filter, Context.RECEIVER_EXPORTED)
            } else {
                @Suppress("DEPRECATION")
                registerReceiver(bluetoothReceiver, filter)
            }
            btRegistered = true
        } catch (e: Exception) {
            Log.e(tag, "Bluetooth receiver registration failed: ${e.message}")
        }
    }

    private fun unregisterBluetoothReceiver() {
        if (!btRegistered) return
        try {
            unregisterReceiver(bluetoothReceiver)
        } catch (_: Exception) {
        }
        btRegistered = false
    }

    private fun safeName(device: BluetoothDevice): String {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED
            ) {
                "Bluetooth device"
            } else {
                device.name ?: "Bluetooth device"
            }
        } catch (_: SecurityException) {
            "Bluetooth device"
        }
    }

    private fun safeAddress(device: BluetoothDevice): String {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED
            ) {
                "unknown"
            } else {
                device.address ?: "unknown"
            }
        } catch (_: SecurityException) {
            "unknown"
        }
    }
}
