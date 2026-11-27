package com.memoryos.memoryos

import android.Manifest
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings

class CaptureApiImpl(private val context: Context) : CaptureHostApi {

    private val prefs
        get() = context.getSharedPreferences("memoryos_prefs", Context.MODE_PRIVATE)

    override fun drainInbox(afterId: Long, limit: Long): List<RawInboxItem> {
        val db = InboxDatabase.getInstance(context)
        return db.drain(afterId, limit.toInt()).map { rec ->
            RawInboxItem(
                id = rec.id,
                source = rec.source,
                pkg = rec.pkg,
                channel = rec.channel,
                category = rec.category,
                flags = rec.flags.toLong(),
                importance = rec.importance.toLong(),
                sbnKey = rec.sbnKey,
                groupKey = rec.groupKey,
                isConversation = rec.isConversation,
                isGroup = rec.isGroup,
                title = rec.title,
                text = rec.text,
                bigText = rec.bigText,
                peopleJson = rec.peopleJson,
                extrasJson = rec.extrasJson,
                postedAt = rec.postedAt,
                removedAt = rec.removedAt,
                removalReason = rec.removalReason?.toLong(),
                redacted = rec.redacted,
            )
        }
    }

    override fun ackInbox(upToId: Long) {
        InboxDatabase.getInstance(context).ack(upToId)
    }

    override fun checkPermissions(): PermissionSnapshot {
        val cn = ComponentName(context, NotificationListener::class.java)
        val flat = Settings.Secure.getString(
            context.contentResolver,
            "enabled_notification_listeners"
        )
        val notifAccess = flat != null && flat.contains(cn.flattenToString())

        val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        val ignoringBattery = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            pm.isIgnoringBatteryOptimizations(context.packageName)
        } else {
            true
        }

        val bluetoothOk = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            hasPerm(Manifest.permission.BLUETOOTH_CONNECT)
        } else {
            true
        }

        return PermissionSnapshot(
            notificationAccess = notifAccess,
            sms = hasPerm(Manifest.permission.READ_SMS),
            callLog = hasPerm(Manifest.permission.READ_CALL_LOG),
            contacts = hasPerm(Manifest.permission.READ_CONTACTS),
            calendar = hasPerm(Manifest.permission.READ_CALENDAR),
            microphone = hasPerm(Manifest.permission.RECORD_AUDIO),
            bluetooth = bluetoothOk,
            ignoringBatteryOptimizations = ignoringBattery,
        )
    }

    override fun openNotificationListenerSettings() {
        val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    }

    override fun openAppInfoSettings() {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
            data = Uri.fromParts("package", context.packageName, null)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    }

    override fun openBatterySettings() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                    data = Uri.parse("package:${context.packageName}")
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                context.startActivity(intent)
                return
            }
        } catch (_: Exception) {
        }
        openAppInfoSettings()
    }

    override fun setCapturePausedUntil(epochMs: Long) {
        val paused = epochMs > System.currentTimeMillis()
        prefs.edit()
            .putLong("capture_paused_until", epochMs)
            .putBoolean("listening_paused", paused)
            .apply()
    }

    override fun getCapturePausedUntil(): Long {
        return prefs.getLong("capture_paused_until", 0L)
    }

    override fun setSourceEnabled(source: String, enabled: Boolean) {
        prefs.edit().putBoolean("toggle_$source", enabled).apply()
    }

    override fun updateStatusSummary(threadsToday: Long, setAsideToday: Long) {
        prefs.edit()
            .putInt("threads_today_count", threadsToday.toInt())
            .putInt("set_aside_today_count", setAsideToday.toInt())
            .apply()
    }

    override fun importSmsInbox(afterEpochMs: Long): ImportProgress {
        return ImportProgress(
            source = "sms",
            importedCount = 0L,
            totalCount = 0L,
            completed = true,
            error = null,
        )
    }

    override fun importCallLog(afterEpochMs: Long): ImportProgress {
        return ImportProgress(
            source = "call",
            importedCount = 0L,
            totalCount = 0L,
            completed = true,
            error = null,
        )
    }

    override fun importContacts(): ImportProgress {
        return ImportProgress(
            source = "contacts",
            importedCount = 0L,
            totalCount = 0L,
            completed = true,
            error = null,
        )
    }

    override fun importCalendarInstances(fromEpochMs: Long, toEpochMs: Long): ImportProgress {
        return ImportProgress(
            source = "calendar",
            importedCount = 0L,
            totalCount = 0L,
            completed = true,
            error = null,
        )
    }

    private fun hasPerm(permission: String): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            context.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
    }
}
