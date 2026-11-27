package com.memoryos.memoryos

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

object StatusNotifier {
    const val CHANNEL_ID = "memoryos_status"
    const val NOTIFICATION_ID = 1001
    const val ACTION_PAUSE_1H = "com.memoryos.memoryos.ACTION_PAUSE_1H"
    const val ACTION_RESUME = "com.memoryos.memoryos.ACTION_RESUME"

    fun refresh(context: Context) {
        try {
            ensureChannel(context)
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.notify(NOTIFICATION_ID, build(context))
        } catch (_: Exception) {
        }
    }

    fun isPaused(context: Context): Boolean {
        val prefs = context.getSharedPreferences("memoryos_prefs", Context.MODE_PRIVATE)
        val pausedUntil = prefs.getLong("capture_paused_until", 0L)
        if (pausedUntil > System.currentTimeMillis()) return true
        return prefs.getBoolean("listening_paused", false) && pausedUntil == 0L
    }

    private fun ensureChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Capture status",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                setShowBadge(false)
            }
            val nm = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.createNotificationChannel(channel)
        }
    }

    private fun build(context: Context): Notification {
        val prefs = context.getSharedPreferences("memoryos_prefs", Context.MODE_PRIVATE)
        val pausedUntil = prefs.getLong("capture_paused_until", 0L)
        val paused = isPaused(context)

        val piFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }

        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        val contentIntent = launchIntent?.let {
            PendingIntent.getActivity(context, 0, it, piFlags)
        }

        val actionIntent = Intent(context, StatusActionReceiver::class.java).apply {
            action = if (paused) ACTION_RESUME else ACTION_PAUSE_1H
        }
        val actionPending = PendingIntent.getBroadcast(
            context,
            if (paused) 202 else 201,
            actionIntent,
            piFlags
        )

        val threadsToday = prefs.getInt("threads_today_count", 0)
        val setAsideToday = prefs.getInt("set_aside_today_count", 0)

        val title = if (paused) {
            val timeStr = if (pausedUntil > 0L) {
                SimpleDateFormat("h:mm a", Locale.US).format(Date(pausedUntil)).lowercase(Locale.US)
            } else {
                "resumed"
            }
            "Paused until $timeStr"
        } else {
            "Capturing"
        }

        val text = if (paused) {
            "Nothing is being read."
        } else {
            "$threadsToday threads today. $setAsideToday notifications set aside."
        }

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(context)
        }

        val actionLabel = if (paused) "Resume" else "Pause 1 hour"
        val iconRes = if (paused) R.drawable.ic_stat_memoryos_paused else R.drawable.ic_stat_memoryos

        builder
            .setSmallIcon(iconRes)
            .setColor(0xFF45398A.toInt())
            .setContentTitle(title)
            .setContentText(text)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setContentIntent(contentIntent)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            builder.addAction(Notification.Action.Builder(null, actionLabel, actionPending).build())
        } else {
            @Suppress("DEPRECATION")
            builder.addAction(0, actionLabel, actionPending)
        }

        return builder.build()
    }
}

class StatusActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val prefs = context.getSharedPreferences("memoryos_prefs", Context.MODE_PRIVATE)
        when (intent.action) {
            StatusNotifier.ACTION_PAUSE_1H -> {
                val until = System.currentTimeMillis() + 60 * 60 * 1000L
                prefs.edit()
                    .putLong("capture_paused_until", until)
                    .putBoolean("listening_paused", true)
                    .apply()
                StatusNotifier.refresh(context)
            }
            StatusNotifier.ACTION_RESUME -> {
                prefs.edit()
                    .putLong("capture_paused_until", 0L)
                    .putBoolean("listening_paused", false)
                    .apply()
                StatusNotifier.refresh(context)
            }
        }
    }
}
