package com.memoryos.memoryos

import android.app.Notification
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Icon
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import org.json.JSONObject
import java.io.File
import java.util.Locale
import java.util.concurrent.ConcurrentHashMap

class NotificationListener : NotificationListenerService() {
    private val TAG = "NotificationListener"

    private data class NotificationImportance(
        val tier: String,
        val reason: String,
        val isPriorityEvent: Boolean,
        val registryCategory: String? = null,
        val conversationSender: String? = null,
        val conversationSnippet: String? = null
    )

    companion object {
        // High-precision concurrent map for sliding-window notification deduplication
        private val lastNotificationTimes = ConcurrentHashMap<String, Long>()
    }

    // Passive BroadcastReceiver to capture Bluetooth connection/adapter state events
    private val bluetoothReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val action = intent.action ?: return
            try {
                when (action) {
                    BluetoothDevice.ACTION_ACL_CONNECTED -> {
                        val device: BluetoothDevice? = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                        val deviceName = try {
                            device?.name ?: "Unknown Device"
                        } catch (e: SecurityException) {
                            "Unknown Device (Permission Missing)"
                        }
                        val deviceAddress = device?.address ?: "Unknown Address"
                        Log.d(TAG, "Bluetooth Connection Detected: $deviceName ($deviceAddress)")

                        val metadata = JSONObject().apply {
                            put("deviceName", deviceName)
                            put("deviceAddress", deviceAddress)
                            put("bluetoothEvent", "connected")
                        }

                        DatabaseHelper.insertNode(
                            context = context.applicationContext,
                            title = "Bluetooth Connected",
                            content = "Connected to device: $deviceName ($deviceAddress)",
                            source = "bluetooth",
                            metadata = metadata,
                            trail = "none"
                        )
                    }
                    BluetoothDevice.ACTION_ACL_DISCONNECTED -> {
                        val device: BluetoothDevice? = intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                        val deviceName = try {
                            device?.name ?: "Unknown Device"
                        } catch (e: SecurityException) {
                            "Unknown Device (Permission Missing)"
                        }
                        val deviceAddress = device?.address ?: "Unknown Address"
                        Log.d(TAG, "Bluetooth Disconnection Detected: $deviceName ($deviceAddress)")

                        val metadata = JSONObject().apply {
                            put("deviceName", deviceName)
                            put("deviceAddress", deviceAddress)
                            put("bluetoothEvent", "disconnected")
                        }

                        DatabaseHelper.insertNode(
                            context = context.applicationContext,
                            title = "Bluetooth Disconnected",
                            content = "Disconnected from device: $deviceName ($deviceAddress)",
                            source = "bluetooth",
                            metadata = metadata,
                            trail = "none"
                        )
                    }
                    BluetoothAdapter.ACTION_STATE_CHANGED -> {
                        val state = intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, BluetoothAdapter.ERROR)
                        val stateStr = when (state) {
                            BluetoothAdapter.STATE_OFF -> "OFF"
                            BluetoothAdapter.STATE_ON -> "ON"
                            BluetoothAdapter.STATE_TURNING_OFF -> "TURNING OFF"
                            BluetoothAdapter.STATE_TURNING_ON -> "TURNING ON"
                            else -> "UNKNOWN"
                        }
                        Log.d(TAG, "Bluetooth Adapter State Changed: $stateStr")

                        val metadata = JSONObject().apply {
                            put("bluetoothState", stateStr)
                            put("bluetoothEvent", "adapter_state_changed")
                        }

                        DatabaseHelper.insertNode(
                            context = context.applicationContext,
                            title = "Bluetooth Adapter State",
                            content = "Bluetooth adapter is now $stateStr",
                            source = "bluetooth",
                            metadata = metadata,
                            trail = "none"
                        )
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error processing Bluetooth broadcast: ${e.message}", e)
            }
        }
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "NotificationListener Service created.")
    }

    override fun onDestroy() {
        Log.d(TAG, "NotificationListener Service destroyed.")
        super.onDestroy()
    }

    override fun onListenerConnected() {
        Log.d(TAG, "Notification listener connected successfully. Synchronizing existing status bar items...")
        try {
            val activeNotifications = activeNotifications
            if (activeNotifications != null) {
                Log.d(TAG, "Syncing active notifications: ${activeNotifications.size} found.")
                for (sbn in activeNotifications) {
                    onNotificationPosted(sbn)
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error in onListenerConnected while reading active notifications: ${e.message}", e)
        }
    }

    private fun getFriendlyAppLabel(packageName: String): String {
        try {
            val pm = packageManager
            val info = pm.getApplicationInfo(packageName, 0)
            val label = pm.getApplicationLabel(info).toString()
            if (label.isNotEmpty()) return label
        } catch (e: Exception) {
            // Fall through
        }

        return when (packageName) {
            "com.whatsapp" -> "WhatsApp"
            "com.google.android.gm" -> "Gmail"
            "com.android.systemui" -> "System UI"
            "com.facebook.katana" -> "Facebook"
            "com.facebook.orca" -> "Messenger"
            "com.instagram.android" -> "Instagram"
            "com.twitter.android" -> "Twitter"
            "com.slack" -> "Slack"
            "com.microsoft.teams" -> "Teams"
            "com.google.android.apps.messaging" -> "Messages"
            "com.android.chrome" -> "Chrome"
            "com.google.android.youtube" -> "YouTube"
            else -> {
                val parts = packageName.split(".")
                if (parts.isNotEmpty()) {
                    parts.last().replaceFirstChar { if (it.isLowerCase()) it.titlecase(Locale.getDefault()) else it.toString() }
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
        } catch (e: Exception) {
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

        if (!looksLikeCaptureSurface) {
            return false
        }

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

            // Skip notifications from our own app to avoid recursive recording
            if (packageName == this.packageName) {
                return
            }

            // Check if notification recording is enabled in preferences
            val sharedPref = getSharedPreferences("memoryos_prefs", Context.MODE_PRIVATE)
            val isListeningPaused = sharedPref.getBoolean("listening_paused", false)
            if (isListeningPaused) {
                Log.d(TAG, "Notification capture is paused from foreground notification action. Skipping: $packageName")
                return
            }
            val isNotificationEnabled = sharedPref.getBoolean("toggle_notification", false)
            if (!isNotificationEnabled) {
                Log.d(TAG, "Notification capture is disabled in native settings. Skipping: $packageName")
                return
            }

            val extras = sbn.notification.extras ?: Bundle()
            val title = firstNonEmptyText(
                extras.getCharSequence(Notification.EXTRA_TITLE)?.toString(),
                extras.getCharSequence("android.title.big")?.toString(),
                extras.getCharSequence("android.conversationTitle")?.toString()
            )
            var text = extractNotificationBodyText(extras)
            val channelId = sbn.notification.channelId ?: "default"

            if (isSystemScreenshotNotification(packageName, channelId, title, text)) {
                Log.d(TAG, "Skipping duplicate System UI screenshot notification.")
                return
            }

            // Safe fallback for complex MessagingStyle notifications (e.g. Gmail or WhatsApp)
            if (extras.containsKey(Notification.EXTRA_MESSAGES)) {
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

            // Extract rich metadata texts if standard text is empty
            if (text.isEmpty()) {
                text = collectAnyTextFromExtras(extras, title)
            }

            if (title.isEmpty() && text.isEmpty()) {
                text = "Notification activity from ${getFriendlyAppLabel(packageName)}"
            }

            val isOngoing = (sbn.notification.flags and Notification.FLAG_ONGOING_EVENT) != 0
            val combinedText = "$title $text"
            val isShortWindowStatus = isShortWindowStatusLikeNotification(packageName, channelId, combinedText)
            val importance = classifyNotificationImportance(
                packageName = packageName,
                channelId = channelId,
                title = title,
                content = text,
                category = sbn.notification.category ?: "",
                isOngoing = isOngoing
            )

            if (importance.tier == "suppress") {
                Log.d(TAG, "Suppressed low-value notification: ${importance.reason}. Title: $title")
                return
            }

            // High-precision deduplication window to filter out duplicate/updated streams.
            // Ongoing status notifications, like charging, are keyed by their stable
            // Android notification key so text changes do not create repeat memories.
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
            if (now - lastTime < dedupeWindowMs) {
                Log.d(TAG, "Deduplicated rapid-fire notification event for key: $uniqueKey")
                return
            }
            
            // Housekeep map if it gets too large
            if (lastNotificationTimes.size > 200) {
                lastNotificationTimes.entries.removeIf { now - it.value > 10000 }
            }
            lastNotificationTimes[uniqueKey] = now

            val friendlyApp = getFriendlyAppLabel(packageName)
            Log.d(TAG, "Notification Intercepted: package=$packageName, title=$title, text=$text, ongoing=$isOngoing")

            val metadata = JSONObject().apply {
                put("packageName", packageName)
                put("appName", friendlyApp)
                put("channelId", channelId)
                put("notificationKey", sbn.key ?: "")
                put("postTime", sbn.postTime)
                put("category", sbn.notification.category ?: "")
                put("isNotificationListener", true)
                put("isOngoing", isOngoing)
                put("importanceTier", importance.tier)
                put("importanceReason", importance.reason)
                put("isPriorityEvent", importance.isPriorityEvent)
                importance.registryCategory?.let { put("registryCategory", it) }
                importance.conversationSender?.let { put("conversationSender", it) }
                importance.conversationSnippet?.let { put("conversationSnippet", it) }
            }

            // Issue 2: Extract large icon and big picture Bitmaps safely, handling URI permissions if necessary
            val bitmap = getNotificationBitmap(applicationContext, sbn.notification)
            if (bitmap != null) {
                val fileName = "notification_${sbn.postTime}_${sbn.id}.png"
                val targetFile = File(applicationContext.cacheDir, fileName)
                try {
                    targetFile.outputStream().use { out ->
                        bitmap.compress(Bitmap.CompressFormat.PNG, 100, out)
                    }
                    metadata.put("filePath", targetFile.absolutePath)
                    metadata.put("hasImage", true)
                    Log.d(TAG, "Successfully extracted and cached image to: ${targetFile.absolutePath}")
                } catch (e: Exception) {
                    Log.e(TAG, "Failed to write extracted notification image to file: ${e.message}", e)
                }
            }

            val trail = classifyTrailInKotlin(title, text)
            val prefix = if (isOngoing) "[Ongoing] " else ""
            val friendlyTitle = if (title.isNotEmpty()) "$prefix$friendlyApp: $title" else "$prefix$friendlyApp"

            DatabaseHelper.insertNode(
                context = applicationContext,
                title = friendlyTitle,
                content = text.ifEmpty { "Received alert from $friendlyApp" },
                source = "notification",
                metadata = metadata,
                trail = trail
            )
        } catch (e: Exception) {
            Log.e(TAG, "Error processing notification posted: ${e.message}", e)
        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        if (sbn == null) return

        val packageName = sbn.packageName ?: "unknown"
        if (packageName != this.packageName) {
            Log.d(TAG, "Notification removed ignored: package=$packageName")
        }
    }

    // Safely extract Bitmap from various notification properties
    private fun getNotificationBitmap(context: Context, notification: Notification): Bitmap? {
        val extras = notification.extras ?: return null

        // 1. Try EXTRA_PICTURE (Direct Bitmap)
        try {
            val picture = extras.get(Notification.EXTRA_PICTURE)
            if (picture is Bitmap) return picture
        } catch (e: Exception) {
            // Ignore
        }

        // 2. Try EXTRA_PICTURE_ICON (Android 12+ / API 31+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            try {
                val pictureIcon = extras.get(Notification.EXTRA_PICTURE_ICON)
                if (pictureIcon is Icon) {
                    val bitmap = extractBitmapFromIcon(context, pictureIcon)
                    if (bitmap != null) return bitmap
                }
            } catch (e: Exception) {
                // Ignore
            }
        }

        // 3. Try EXTRA_LARGE_ICON (Bitmap or Icon)
        try {
            val largeIcon = extras.get(Notification.EXTRA_LARGE_ICON)
            if (largeIcon is Bitmap) {
                return largeIcon
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && largeIcon is Icon) {
                val bitmap = extractBitmapFromIcon(context, largeIcon)
                if (bitmap != null) return bitmap
            }
        } catch (e: Exception) {
            // Ignore
        }

        // 4. Try EXTRA_LARGE_ICON_BIG (Bitmap or Icon)
        try {
            val largeIconBig = extras.get("android.largeIcon.big")
            if (largeIconBig is Bitmap) {
                return largeIconBig
            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && largeIconBig is Icon) {
                val bitmap = extractBitmapFromIcon(context, largeIconBig)
                if (bitmap != null) return bitmap
            }
        } catch (e: Exception) {
            // Ignore
        }

        // 5. Try background image URI
        try {
            val bgUriStr = extras.getString("android.backgroundImageUri")
            if (!bgUriStr.isNullOrEmpty()) {
                val uri = Uri.parse(bgUriStr)
                context.contentResolver.openInputStream(uri)?.use { stream ->
                    return android.graphics.BitmapFactory.decodeStream(stream)
                }
            }
        } catch (e: Exception) {
            // Ignore
        }

        return null
    }

    private fun extractBitmapFromIcon(context: Context, icon: Icon): Bitmap? {
        try {
            val drawable = icon.loadDrawable(context) ?: return null
            if (drawable is BitmapDrawable) {
                return drawable.bitmap
            }
            val bitmap = Bitmap.createBitmap(
                drawable.intrinsicWidth.coerceAtLeast(1),
                drawable.intrinsicHeight.coerceAtLeast(1),
                Bitmap.Config.ARGB_8888
            )
            val canvas = android.graphics.Canvas(bitmap)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)
            return bitmap
        } catch (e: Exception) {
            Log.e(TAG, "Failed to load/draw Icon drawable: ${e.message}", e)
        }
        return null
    }

    private fun classifyTrailInKotlin(title: String, content: String): String {
        val text = "$title $content".lowercase()
        return when {
            text.contains("tax") || text.contains("insurance") || text.contains("policy") || text.contains("invoice") || text.contains("receipt") -> "tax"
            text.contains("solar") || text.contains("battery") || text.contains("inverter") || text.contains("cabling") -> "project_memory"
            text.contains("health") || text.contains("medical") || text.contains("exercise") || text.contains("gym") || text.contains("workout") -> "health"
            text.contains("brother") || text.contains("mom") || text.contains("dad") || text.contains("wife") || text.contains("shared") || text.contains("family") -> "relationship_memory"
            text.contains("work") || text.contains("office") || text.contains("meeting") || text.contains("task") -> "work"
            else -> "none"
        }
    }

    private fun classifyNotificationImportance(
        packageName: String,
        channelId: String,
        title: String,
        content: String,
        category: String,
        isOngoing: Boolean
    ): NotificationImportance {
        val packageLower = packageName.lowercase(Locale.US)
        val channelLower = channelId.lowercase(Locale.US)
        val combined = "$packageLower $channelLower ${category.lowercase(Locale.US)} ${title.lowercase(Locale.US)} ${content.lowercase(Locale.US)}"

        if (isMarketingNotification(packageLower, channelLower, title, content)) {
            return NotificationImportance("suppress", "Promotional notification", false)
        }

        if (isShortWindowStatusLikeNotification(packageName, channelId, "$title $content")) {
            return NotificationImportance("low", "Device status update", false)
        }

        if (looksLikeWeather(combined)) {
            return NotificationImportance("high", "Weather summary", true)
        }

        if (looksLikeSecurityAlert(combined)) {
            return NotificationImportance("high", "Security or verification alert", true)
        }

        if (isMessagingPackage(packageLower) || category.lowercase(Locale.US).contains("msg")) {
            val sender = conversationSenderFromTitle(title)
            val snippet = conversationSnippetFromContent(content)
            return if (looksLikeConversation(title, content, sender)) {
                NotificationImportance(
                    "high",
                    "Conversation from ${getFriendlyAppLabel(packageName)}",
                    true,
                    "messaging",
                    sender,
                    snippet
                )
            } else {
                NotificationImportance("low", "Messaging status update", false, "messaging")
            }
        }

        if (looksLikeCalendarEvent(combined)) {
            return NotificationImportance("high", "Calendar or event reminder", true)
        }

        if (isEmailPackage(packageLower)) {
            if (looksLikeNewsletterOrDigest(combined)) {
                return NotificationImportance("low", "Email newsletter or digest", false, "email")
            }
            val sender = conversationSenderFromTitle(title)
            val snippet = conversationSnippetFromContent(content)
            val looksHumanOrProject = Regex("""\b(project|client|meeting|review|invoice|receipt|offer|deadline|call|handoff|proposal|ready|question|follow up|follow-up)\b""")
                .containsMatchIn(combined) || looksLikeConversation(title, content, sender)
            return NotificationImportance(
                if (looksHumanOrProject) "medium" else "low",
                if (looksHumanOrProject) "Email context from ${getFriendlyAppLabel(packageName)}" else "Email notification",
                looksHumanOrProject,
                "email",
                if (looksHumanOrProject) sender else null,
                if (looksHumanOrProject) snippet else null
            )
        }

        if (isOngoing) {
            return NotificationImportance("low", "Ongoing background status", false)
        }

        return NotificationImportance("medium", "Unclassified notification", false)
    }

    private fun isMarketingNotification(
        packageName: String,
        channelId: String,
        title: String,
        content: String
    ): Boolean {
        val haystack = "$packageName $channelId ${title.lowercase(Locale.US)} ${content.lowercase(Locale.US)}"
        val obviousPatterns = listOf(
            Regex("""\b\d{1,3}\s*%\s*off\b"""),
            Regex("""\b(use|apply)\s+(code|coupon|promo)\b"""),
            Regex("""\b(code|coupon|promo)\s+[a-z0-9]{3,}\b"""),
            Regex("""\b(flash|mega|summer|eid|holiday|clearance)\s+sale\b"""),
            Regex("""\bsale\s+(ends|starts|is live|now|today|tonight)\b"""),
            Regex("""\blimited\s+time\s+(offer|deal|discount)\b"""),
            Regex("""\bfree\s+(delivery|shipping|trial|gift)\b"""),
            Regex("""\b(shop|order|buy|subscribe|install|claim)\s+now\b"""),
            Regex("""\bbuy\s+\d+\s+get\s+\d+\b"""),
            Regex("""\b(cashback|voucher|reward points|deal of the day)\b"""),
            Regex("""\b(ad|sponsored|promoted)\b.*\b(shop|buy|install|subscribe)\b""")
        )
        if (obviousPatterns.any { it.containsMatchIn(haystack) }) return true

        val promoChannel = Regex("""\b(promotions?|offers?|deals?|marketing|ads?|recommendations?)\b""")
            .containsMatchIn(channelId)
        val promoTerms = Regex("""\b(discount|coupon|voucher|sale|cashback|deal|offer|shop now|buy now)\b""")
            .findAll(haystack)
            .count()
        return promoChannel && promoTerms >= 1
    }

    private fun isMessagingPackage(packageName: String): Boolean {
        return packageName.contains("whatsapp") ||
            packageName.contains("orca") ||
            packageName.contains("facebook.orca") ||
            packageName.contains("messaging") ||
            packageName.contains("messages") ||
            packageName.contains("google.android.apps.messaging") ||
            packageName.contains("samsung.android.messaging") ||
            packageName.contains("slack") ||
            packageName.contains("teams") ||
            packageName.contains("telegram") ||
            packageName.contains("signal") ||
            packageName.contains("messenger") ||
            packageName.contains("discord") ||
            packageName.contains("line") ||
            packageName.contains("wechat") ||
            packageName.contains("kakao") ||
            packageName.contains("viber") ||
            packageName.contains("skype") ||
            packageName.contains("snapchat") ||
            packageName.contains("linkedin") ||
            packageName.contains("reddit") ||
            packageName.contains("element") ||
            packageName.contains("matrix") ||
            packageName.contains("wire") ||
            packageName.contains("threema") ||
            packageName.contains("mattermost") ||
            packageName.contains("zulip") ||
            packageName.contains("rocket.chat")
    }

    private fun isEmailPackage(packageName: String): Boolean {
        return packageName.contains("gmail") ||
            packageName.contains("google.android.gm") ||
            packageName.contains("email") ||
            packageName.contains("outlook") ||
            packageName.contains("mail")
    }

    private fun conversationSenderFromTitle(title: String): String? {
        val clean = title
            .replace(Regex("""^\[[^\]]+\]\s*"""), "")
            .split(":")
            .last()
            .trim()
        if (clean.isEmpty()) return null
        val sender = clean
            .split(Regex("""\s+"""))
            .take(3)
            .joinToString(" ")
            .replace(Regex("""[^A-Za-z0-9 ._-]"""), "")
            .trim()
        val lower = sender.lowercase(Locale.US)
        if (sender.length < 3) return null
        if (Regex("""\b(user|cache|null|unknown|default|sync|notification|messages?|digest|newsletter|gmail|slack)\b""").containsMatchIn(lower)) {
            return null
        }
        return sender
    }

    private fun conversationSnippetFromContent(content: String): String? {
        val line = content
            .lines()
            .map { it.trim() }
            .firstOrNull { it.isNotEmpty() }
            ?: return null
        val raw = if (line.contains(":")) line.substringAfter(":").trim() else line
        if (raw.isEmpty() || looksLikeStatusNoise(raw.lowercase(Locale.US))) return null
        return if (raw.length <= 140) raw else raw.take(140).trim() + "..."
    }

    private fun looksLikeConversation(title: String, content: String, sender: String?): Boolean {
        val lower = content.lowercase(Locale.US).trim()
        if (lower.length < 8 || looksLikeStatusNoise(lower)) return false
        if (sender != null && sender.length >= 3 && lower.length >= 12) return true
        return Regex("""(\?|can you|could you|please|review|call|meeting|send|sent|shared|attached|thanks|thank you|where|when|today|tomorrow|before|after|standup|proposal|client|project|deadline)""")
            .containsMatchIn(lower)
    }

    private fun looksLikeStatusNoise(text: String): Boolean {
        return Regex("""\b(syncing|sync complete|checking|background|running|connected|backup|updating|refreshing|waiting|no new|new messages|notification activity|battery|charging|missed call|caller id)\b""")
            .containsMatchIn(text)
    }

    private fun looksLikeNewsletterOrDigest(text: String): Boolean {
        return Regex("""\b(newsletter|digest|weekly roundup|unsubscribe|view in browser|promotion|sponsored|recommended for you)\b""")
            .containsMatchIn(text)
    }

    private fun looksLikeWeather(text: String): Boolean {
        return Regex("""\b(weather|forecast|rain|storm|thunder|temperature|humid|humidity|wind|umbrella|heatwave|cyclone|flood|air quality|aqi)\b""")
            .containsMatchIn(text)
    }

    private fun looksLikeSecurityAlert(text: String): Boolean {
        return Regex("""\b(otp|one time password|verification code|security alert|login|sign-in|signin|password|2fa|two-factor|account alert)\b""")
            .containsMatchIn(text)
    }

    private fun looksLikeCalendarEvent(text: String): Boolean {
        return Regex("""\b(calendar|meeting|event|appointment|starts in|call at|deadline|due today|due tomorrow)\b""")
            .containsMatchIn(text)
    }
}
