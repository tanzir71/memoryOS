package com.memoryos.memoryos

import android.app.Notification
import android.content.Context
import android.os.Bundle
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import org.json.JSONObject
import java.util.Locale
import java.util.concurrent.ConcurrentHashMap

class NotificationListener : NotificationListenerService() {
    private val TAG = "NotificationListener"

    companion object {
        private val lastNotificationTimes = ConcurrentHashMap<String, Long>()
    }

    override fun onListenerConnected() {
        try {
            val activeNotifications = activeNotifications
            if (activeNotifications != null) {
                for (sbn in activeNotifications) {
                    onNotificationPosted(sbn)
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error in onListenerConnected: ${e.message}", e)
        }
    }

    private fun getFriendlyAppLabel(packageName: String): String {
        try {
            val pm = packageManager
            val info = pm.getApplicationInfo(packageName, 0)
            val label = pm.getApplicationLabel(info).toString()
            if (label.isNotEmpty()) return label
        } catch (_: Exception) {
        }

        return when (packageName) {
            "com.whatsapp" -> "WhatsApp"
            "com.google.android.gm" -> "Gmail"
            "com.android.systemui" -> "System UI"
            "com.facebook.katana" -> "Facebook"
            "com.facebook.orca" -> "Messenger"
            "com.instagram.android" -> "Instagram"
            "com.slack" -> "Slack"
            "com.microsoft.teams" -> "Teams"
            "com.google.android.apps.messaging" -> "Messages"
            "com.android.chrome" -> "Chrome"
            "com.google.android.youtube" -> "YouTube"
            else -> {
                val parts = packageName.split(".")
                if (parts.isNotEmpty()) {
                    parts.last().replaceFirstChar {
                        if (it.isLowerCase()) it.titlecase(Locale.getDefault()) else it.toString()
                    }
                } else {
                    packageName
                }
            }
        }
    }

    private fun firstNonEmptyText(vararg candidates: String?): String {
        return candidates.firstOrNull { !it.isNullOrBlank() }?.trim() ?: ""
    }

    private fun extractNotificationBodyText(extras: Bundle): String {
        val standardText = firstNonEmptyText(
            extras.getCharSequence(Notification.EXTRA_TEXT)?.toString(),
            extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString(),
            extras.getCharSequence(Notification.EXTRA_SUMMARY_TEXT)?.toString(),
            extras.getCharSequence(Notification.EXTRA_INFO_TEXT)?.toString(),
            extras.getCharSequence(Notification.EXTRA_SUB_TEXT)?.toString()
        )
        if (standardText.isNotEmpty()) return standardText

        val lines = try {
            extras.getCharSequenceArray("android.textLines")
        } catch (_: Exception) {
            null
        }

        return lines
            ?.mapNotNull { it?.toString()?.trim() }
            ?.filter { it.isNotEmpty() }
            ?.distinct()
            ?.joinToString("\n")
            ?: ""
    }

    private fun collectAnyTextFromExtras(extras: Bundle, title: String): String {
        val collected = mutableListOf<String>()
        for (key in extras.keySet().sorted()) {
            @Suppress("DEPRECATION")
            val value = extras.get(key)
            when (value) {
                is CharSequence -> {
                    val text = value.toString().trim()
                    if (text.isNotEmpty() && text != title) {
                        collected.add(text)
                    }
                }
                is Array<*> -> {
                    value.mapNotNull { it?.toString()?.trim() }
                        .filter { it.isNotEmpty() && it != title }
                        .forEach { collected.add(it) }
                }
            }
        }

        return collected.distinct().take(6).joinToString("\n")
    }

    private fun isSystemScreenshotNotification(
        packageName: String,
        channelId: String,
        title: String,
        text: String
    ): Boolean {
        val packageLower = packageName.lowercase(Locale.US)
        val channelLower = channelId.lowercase(Locale.US)
        val titleLower = title.lowercase(Locale.US)
        val textLower = text.lowercase(Locale.US)
        val haystack = "$packageLower $channelLower $titleLower $textLower"
        val looksLikeCaptureSurface = packageLower.contains("systemui") ||
            packageLower.contains("smartcapture") ||
            packageLower.contains("screenshot") ||
            packageLower.contains("screenrecorder") ||
            channelLower.contains("capture") ||
            channelLower.contains("screenshot") ||
            titleLower.contains("samsung capture") ||
            titleLower.contains("screenshot")

        if (!looksLikeCaptureSurface) return false

        return haystack.contains("screenshot") ||
            haystack.contains("screen shot") ||
            haystack.contains("screen capture")
    }

    private fun isShortWindowStatusLikeNotification(
        packageName: String,
        channelId: String,
        text: String
    ): Boolean {
        val haystack = "${packageName.lowercase(Locale.US)} ${channelId.lowercase(Locale.US)} ${text.lowercase(Locale.US)}"
        return haystack.contains("bluetooth") ||
            haystack.contains("charging") ||
            haystack.contains("charger") ||
            haystack.contains("usb") ||
            haystack.contains("device connected") ||
            haystack.contains("device disconnected") ||
            haystack.contains("connected to") ||
            haystack.contains("disconnected from") ||
            haystack.contains("sync complete") ||
            haystack.contains("backup complete")
    }

    private fun normalizeNotificationSimilarityText(value: String): String {
        return value.lowercase(Locale.US)
            .replace(Regex("""https?://\S+"""), " url ")
            .replace(Regex("""\b[\w.\-]+@[\w.\-]+\.\w+\b"""), " email ")
            .replace(Regex("""\b([0-9a-f]{2}:){5}[0-9a-f]{2}\b"""), " mac ")
            .replace(Regex("""\b\d{1,2}:\d{2}\s*(am|pm)?\b"""), " time ")
            .replace(Regex("""\b\d+\s*(%|kb|mb|gb|sec|secs|seconds?|mins?|minutes?|hours?)\b"""), " number ")
            .replace(Regex("""\b\d+\b"""), " number ")
            .replace(Regex("""\b(number|time|ago|just|now|at|on|the|a|an)\b"""), " ")
            .replace(Regex("""[^a-z0-9]+"""), " ")
            .replace(Regex("""\s+"""), " ")
            .trim()
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        if (sbn == null) return

        try {
            val packageName = sbn.packageName ?: "unknown"
            if (packageName == this.packageName) return

            val sharedPref = getSharedPreferences("memoryos_prefs", Context.MODE_PRIVATE)
            if (sharedPref.getBoolean("listening_paused", false)) return
            if (!sharedPref.getBoolean("toggle_notification", false)) return

            val extras = sbn.notification.extras ?: Bundle()
            val title = firstNonEmptyText(
                extras.getCharSequence(Notification.EXTRA_TITLE)?.toString(),
                extras.getCharSequence("android.title.big")?.toString(),
                extras.getCharSequence("android.conversationTitle")?.toString()
            )
            var text = extractNotificationBodyText(extras)
            val channelId = sbn.notification.channelId ?: "default"

            if (isSystemScreenshotNotification(packageName, channelId, title, text)) return

            if (extras.containsKey(Notification.EXTRA_MESSAGES)) {
                @Suppress("DEPRECATION")
                val messages = extras.getParcelableArray(Notification.EXTRA_MESSAGES)
                if (messages != null && messages.isNotEmpty()) {
                    val messageTextBuilder = StringBuilder()
                    for (m in messages) {
                        if (m is Bundle) {
                            val sender = m.getCharSequence("sender") ?: m.getCharSequence("sender_person") ?: ""
                            val textContent = m.getCharSequence("text") ?: ""
                            if (textContent.isNotEmpty()) {
                                if (sender.isNotEmpty()) {
                                    messageTextBuilder.append("$sender: $textContent\n")
                                } else {
                                    messageTextBuilder.append("$textContent\n")
                                }
                            }
                        }
                    }
                    if (messageTextBuilder.isNotEmpty()) {
                        text = messageTextBuilder.toString().trim()
                    }
                }
            }

            if (text.isEmpty()) {
                text = collectAnyTextFromExtras(extras, title)
            }

            if (title.isEmpty() && text.isEmpty()) {
                text = "Notification activity from ${getFriendlyAppLabel(packageName)}"
            }

            val isOngoing = (sbn.notification.flags and Notification.FLAG_ONGOING_EVENT) != 0
            val combinedText = "$title $text"
            val isShortWindowStatus = isShortWindowStatusLikeNotification(packageName, channelId, combinedText)

            val uniqueKey = if (isOngoing) {
                "ongoing:${sbn.key ?: "$packageName:$channelId:$title"}"
            } else if (isShortWindowStatus) {
                "short:$packageName:$channelId:${normalizeNotificationSimilarityText(combinedText)}"
            } else {
                "$packageName:$title:$text"
            }
            val now = System.currentTimeMillis()
            val lastTime = lastNotificationTimes[uniqueKey] ?: 0L
            val dedupeWindowMs = if (isOngoing) {
                60 * 1000L
            } else if (isShortWindowStatus) {
                30 * 1000L
            } else {
                3000L
            }
            if (now - lastTime < dedupeWindowMs) return

            if (lastNotificationTimes.size > 200) {
                lastNotificationTimes.entries.removeIf { now - it.value > 10000 }
            }
            lastNotificationTimes[uniqueKey] = now

            val metadata = JSONObject().apply {
                put("packageName", packageName)
                put("channelId", channelId)
                put("notificationKey", sbn.key ?: "")
                put("postTime", sbn.postTime)
                put("category", sbn.notification.category ?: "")
                put("isNotificationListener", true)
                put("isOngoing", isOngoing)
            }

            val friendlyApp = getFriendlyAppLabel(packageName)
            val prefix = if (isOngoing) "[Ongoing] " else ""
            val friendlyTitle = if (title.isNotEmpty()) "$prefix$friendlyApp: $title" else "$prefix$friendlyApp"

            DatabaseHelper.insertNode(
                context = applicationContext,
                title = friendlyTitle,
                content = text.ifEmpty { "Received alert from $friendlyApp" },
                source = "notification",
                metadata = metadata,
                trail = "none"
            )
        } catch (e: Exception) {
            Log.e(TAG, "Error processing notification posted: ${e.message}", e)
        }
    }
}
