package com.memoryos.memoryos

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.util.Log
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

object DatabaseHelper {
    private const val TAG = "DatabaseHelper"
    private const val DB_NAME = "memoryos.db"
    private const val TABLE_NODES = "memory_nodes"
    private const val REGISTRY_SETTINGS_KEY = "app_category_registry_overrides"
    private const val DENIED_ALIASES_KEY = "deniedAliases"

    private data class NotificationImportance(
        val tier: String,
        val reason: String,
        val isPriorityEvent: Boolean,
        val registryCategory: String? = null,
        val conversationSender: String? = null,
        val conversationSnippet: String? = null
    )

    @Synchronized
    fun insertNode(
        context: Context,
        title: String,
        content: String,
        source: String,
        metadata: JSONObject,
        trail: String = "none"
    ) {
        var db: SQLiteDatabase? = null
        try {
            val dbFile = context.getDatabasePath(DB_NAME)
            val dbDir = dbFile.parentFile
            if (dbDir != null && !dbDir.exists()) {
                dbDir.mkdirs()
            }
            
            db = SQLiteDatabase.openOrCreateDatabase(dbFile, null)
            ensureSchema(db)

            if (source == "notification" && isUserDeniedNotification(db, metadata)) {
                val packageName = metadata.optString("packageName", "")
                val appName = metadata.optString("appName", "")
                Log.d(TAG, "Skipping notification from user-denied app. package=$packageName app=$appName")
                return
            }
            
            // Format timestamp in local device ISO 8601 format
            val df = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS", Locale.US)
            val now = Date()
            val isoTimestamp = df.format(now)

            if (source == "notification_removed") {
                Log.d(TAG, "Skipping notification removal event. MemoryOS records posted notifications only.")
                return
            }
            
            if (source == "notification" && isScreenshotCaptureNotification(title, content, metadata)) {
                Log.d(TAG, "Skipping screenshot system notification because the screenshot file observer records the filename itself. Title: $title")
                return
            }

            if (source == "notification") {
                val importance = classifyNotificationImportance(title, content, metadata)
                if (!metadata.has("importanceTier")) {
                    metadata.put("importanceTier", importance.tier)
                    metadata.put("importanceReason", importance.reason)
                    metadata.put("isPriorityEvent", importance.isPriorityEvent)
                    importance.registryCategory?.let { metadata.put("registryCategory", it) }
                    importance.conversationSender?.let { metadata.put("conversationSender", it) }
                    importance.conversationSnippet?.let { metadata.put("conversationSnippet", it) }
                }
                if (importance.tier == "suppress") {
                    Log.d(TAG, "Skipping suppressed notification. Reason: ${importance.reason}. Title: $title")
                    return
                }

                if (isMarketingNotification(title, content, metadata)) {
                    Log.d(TAG, "Skipping obvious marketing notification. Title: $title")
                    return
                }

                if (metadata.optBoolean("isOngoing", false) && isExistingOngoingNotification(db, title, metadata)) {
                    Log.d(TAG, "Skipping repeated ongoing notification. Title: $title")
                    return
                }

                val similarCutoffTimestamp = df.format(Date(now.time - 5 * 60 * 1000L))
                if (isRecentSimilarNotification(db, title, content, metadata, similarCutoffTimestamp)) {
                    Log.d(TAG, "Skipping similar short-window notification. Title: $title")
                    return
                }

                val cutoffTimestamp = df.format(Date(now.time - 2 * 60 * 1000L))
                if (isRecentDuplicateNotification(db, title, content, cutoffTimestamp)) {
                    Log.d(TAG, "Skipping duplicate notification already stored within the recent window. Title: $title")
                    return
                }
            }
            
            // Prevent duplicate screenshot photo nodes by filename
            if (source == "photo") {
                val filePath = metadata.optString("filePath", "")
                val explicitFileName = metadata.optString("fileName", "")
                val fileName = when {
                    explicitFileName.isNotEmpty() -> explicitFileName
                    filePath.isNotEmpty() -> java.io.File(filePath).name
                    else -> ""
                }
                if (fileName.isNotEmpty()) {
                    val cursor = db.rawQuery(
                        "SELECT id FROM memory_nodes WHERE source = 'photo' AND metadata LIKE ?",
                        arrayOf("%$fileName%")
                    )
                    val exists = cursor.count > 0
                    cursor.close()
                    if (exists) {
                        Log.d(TAG, "Screenshot already exists in SQLite (deduplicated by filename): $fileName. Skipping native insertion.")
                        return
                    }
                }
            }

            val values = ContentValues().apply {
                put("timestamp", isoTimestamp)
                put("title", title)
                put("content", content)
                put("source", source)
                put("metadata", metadata.toString())
                put("trail", trail)
                put("is_starred", 0)
            }

            val rowId = db.insert(TABLE_NODES, null, values)
            Log.d(TAG, "Inserted native node into SQLite at row $rowId. Title: $title")
            if (rowId != -1L) {
                PersistentService.recordCapture(context.applicationContext, source, title)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error inserting native node into SQLite: ${e.message}", e)
        } finally {
            db?.close()
        }
    }

    private fun ensureSchema(db: SQLiteDatabase) {
        db.execSQL(
            """
            CREATE TABLE IF NOT EXISTS memory_nodes (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp TEXT NOT NULL,
                title TEXT NOT NULL,
                content TEXT NOT NULL,
                source TEXT NOT NULL,
                metadata TEXT NOT NULL,
                trail TEXT NOT NULL,
                is_starred INTEGER NOT NULL DEFAULT 0,
                deleted_at TEXT
            )
            """.trimIndent()
        )

        addColumnIfMissing(db, TABLE_NODES, "deleted_at", "TEXT")

        db.execSQL(
            """
            CREATE TABLE IF NOT EXISTS settings (
                key TEXT PRIMARY KEY,
                value TEXT NOT NULL
            )
            """.trimIndent()
        )
    }

    private fun addColumnIfMissing(
        db: SQLiteDatabase,
        table: String,
        column: String,
        type: String
    ) {
        val cursor = db.rawQuery("PRAGMA table_info($table)", emptyArray())
        try {
            while (cursor.moveToNext()) {
                val name = cursor.getString(cursor.getColumnIndexOrThrow("name"))
                if (name == column) return
            }
        } finally {
            cursor.close()
        }
        db.execSQL("ALTER TABLE $table ADD COLUMN $column $type")
    }

    private fun isUserDeniedNotification(
        db: SQLiteDatabase,
        metadata: JSONObject
    ): Boolean {
        val deniedAliases = loadUserDeniedAliases(db)
        if (deniedAliases.isEmpty()) return false

        val packageName = metadata.optString("packageName", "")
        val appName = metadata.optString("appName", "")
        return deniedAliases.any { alias ->
            matchesRegistryAlias(
                alias = alias,
                packageName = packageName,
                appName = appName
            )
        }
    }

    private fun loadUserDeniedAliases(db: SQLiteDatabase): List<String> {
        val cursor = db.rawQuery(
            "SELECT value FROM settings WHERE key = ? LIMIT 1",
            arrayOf(REGISTRY_SETTINGS_KEY)
        )
        try {
            if (!cursor.moveToFirst()) return emptyList()
            val raw = cursor.getString(0) ?: return emptyList()
            val array = JSONObject(raw).optJSONArray(DENIED_ALIASES_KEY)
                ?: return emptyList()
            return (0 until array.length())
                .mapNotNull { index ->
                    array.optString(index, "").trim().lowercase(Locale.US)
                }
                .filter { it.isNotEmpty() }
                .distinct()
        } catch (e: Exception) {
            Log.d(TAG, "Unable to read user app denylist: ${e.message}")
            return emptyList()
        } finally {
            cursor.close()
        }
    }

    private fun matchesRegistryAlias(
        alias: String,
        packageName: String,
        appName: String
    ): Boolean {
        val normalizedAlias = alias.trim().lowercase(Locale.US)
        if (normalizedAlias.isEmpty()) return false

        val packageLower = packageName.lowercase(Locale.US)
        val appLower = appName.lowercase(Locale.US)
        if (packageLower == normalizedAlias || appLower == normalizedAlias) {
            return true
        }
        if (normalizedAlias.contains(".") && packageLower.contains(normalizedAlias)) {
            return true
        }

        val aliasWords = registryAliasWords(normalizedAlias)
        if (aliasWords.isEmpty()) return false
        return containsWordPhrase(registryAliasWords(packageLower), aliasWords) ||
            containsWordPhrase(registryAliasWords(appLower), aliasWords)
    }

    private fun registryAliasWords(value: String): List<String> {
        return value
            .lowercase(Locale.US)
            .split(Regex("""[^a-z0-9]+"""))
            .filter { it.isNotEmpty() }
    }

    private fun containsWordPhrase(words: List<String>, phrase: List<String>): Boolean {
        if (phrase.isEmpty() || words.size < phrase.size) return false
        for (index in 0..(words.size - phrase.size)) {
            if (words.subList(index, index + phrase.size) == phrase) {
                return true
            }
        }
        return false
    }

    private fun isRecentDuplicateNotification(
        db: SQLiteDatabase,
        title: String,
        content: String,
        cutoffTimestamp: String
    ): Boolean {
        val cursor = db.rawQuery(
            """
            SELECT id FROM memory_nodes
            WHERE source = ?
              AND title = ?
              AND content = ?
              AND timestamp >= ?
            LIMIT 1
            """.trimIndent(),
            arrayOf("notification", title, content, cutoffTimestamp)
        )
        val exists = cursor.count > 0
        cursor.close()
        return exists
    }

    private fun isRecentSimilarNotification(
        db: SQLiteDatabase,
        title: String,
        content: String,
        metadata: JSONObject,
        cutoffTimestamp: String
    ): Boolean {
        val packageName = metadata.optString("packageName", "").trim()
        val channelId = metadata.optString("channelId", "").trim()
        val combinedText = "$title $content"
        if (packageName.isEmpty() || channelId.isEmpty() ||
            !isShortWindowStatusLikeNotification(packageName, channelId, combinedText)
        ) {
            return false
        }

        val normalized = normalizeNotificationSimilarityText(combinedText)
        if (normalized.length < 8) return false

        val cursor = db.rawQuery(
            """
            SELECT title, content FROM memory_nodes
            WHERE source = ?
              AND timestamp >= ?
              AND metadata LIKE ? ESCAPE '\'
              AND metadata LIKE ? ESCAPE '\'
            """.trimIndent(),
            arrayOf(
                "notification",
                cutoffTimestamp,
                "%\"packageName\":\"${escapeLike(packageName)}\"%",
                "%\"channelId\":\"${escapeLike(channelId)}\"%"
            )
        )
        try {
            while (cursor.moveToNext()) {
                val existingTitle = cursor.getString(0) ?: ""
                val existingContent = cursor.getString(1) ?: ""
                if (normalizeNotificationSimilarityText("$existingTitle $existingContent") == normalized) {
                    return true
                }
            }
            return false
        } finally {
            cursor.close()
        }
    }

    private fun isExistingOngoingNotification(
        db: SQLiteDatabase,
        title: String,
        metadata: JSONObject
    ): Boolean {
        val notificationKey = metadata.optString("notificationKey", "").trim()
        if (notificationKey.isNotEmpty()) {
            val cursor = db.rawQuery(
                """
                SELECT id FROM memory_nodes
                WHERE source = ?
                  AND metadata LIKE ? ESCAPE '\'
                LIMIT 1
                """.trimIndent(),
                arrayOf(
                    "notification",
                    "%\"notificationKey\":\"${escapeLike(notificationKey)}\"%"
                )
            )
            val exists = cursor.count > 0
            cursor.close()
            if (exists) return true
        }

        val packageName = metadata.optString("packageName", "").trim()
        val channelId = metadata.optString("channelId", "").trim()
        if (packageName.isEmpty() || channelId.isEmpty() || title.isBlank()) {
            return false
        }

        val cursor = db.rawQuery(
            """
            SELECT id FROM memory_nodes
            WHERE source = ?
              AND title = ?
              AND metadata LIKE ? ESCAPE '\'
              AND metadata LIKE ? ESCAPE '\'
            LIMIT 1
            """.trimIndent(),
            arrayOf(
                "notification",
                title,
                "%\"packageName\":\"${escapeLike(packageName)}\"%",
                "%\"channelId\":\"${escapeLike(channelId)}\"%"
            )
        )
        val exists = cursor.count > 0
        cursor.close()
        return exists
    }

    private fun escapeLike(value: String): String {
        return value
            .replace("\\", "\\\\")
            .replace("%", "\\%")
            .replace("_", "\\_")
    }

    private fun isMarketingNotification(
        title: String,
        content: String,
        metadata: JSONObject
    ): Boolean {
        val packageName = metadata.optString("packageName", "").lowercase(Locale.US)
        val channelId = metadata.optString("channelId", "").lowercase(Locale.US)
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

        if (obviousPatterns.any { it.containsMatchIn(haystack) }) {
            return true
        }

        val promoChannel = Regex("""\b(promotions?|offers?|deals?|marketing|ads?|recommendations?)\b""")
            .containsMatchIn(channelId)
        val promoTerms = Regex("""\b(discount|coupon|voucher|sale|cashback|deal|offer|shop now|buy now)\b""")
            .findAll(haystack)
            .count()

        return promoChannel && promoTerms >= 1
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

    private fun isScreenshotCaptureNotification(
        title: String,
        content: String,
        metadata: JSONObject
    ): Boolean {
        val packageName = metadata.optString("packageName", "").lowercase(Locale.US)
        val channelId = metadata.optString("channelId", "").lowercase(Locale.US)
        val titleLower = title.lowercase(Locale.US)
        val contentLower = content.lowercase(Locale.US)
        val haystack = "$packageName $channelId $titleLower $contentLower"

        val looksLikeCaptureSurface = packageName.contains("systemui") ||
            packageName.contains("smartcapture") ||
            packageName.contains("screenshot") ||
            packageName.contains("screenrecorder") ||
            channelId.contains("capture") ||
            channelId.contains("screenshot") ||
            titleLower.contains("samsung capture") ||
            titleLower.contains("screenshot")

        if (!looksLikeCaptureSurface) {
            return false
        }

        return haystack.contains("screenshot") ||
            haystack.contains("screen shot") ||
            haystack.contains("screen capture")
    }

    private fun classifyNotificationImportance(
        title: String,
        content: String,
        metadata: JSONObject
    ): NotificationImportance {
        val packageName = metadata.optString("packageName", "").lowercase(Locale.US)
        val channelId = metadata.optString("channelId", "").lowercase(Locale.US)
        val category = metadata.optString("category", "").lowercase(Locale.US)
        val isOngoing = metadata.optBoolean("isOngoing", false)
        val combined = "$packageName $channelId $category ${title.lowercase(Locale.US)} ${content.lowercase(Locale.US)}"

        if (isMarketingNotification(title, content, metadata)) {
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

        if (isMessagingPackage(packageName) || category.contains("msg")) {
            val sender = conversationSenderFromTitle(title)
            val snippet = conversationSnippetFromContent(content)
            return if (looksLikeConversation(title, content, sender)) {
                NotificationImportance(
                    "high",
                    "Conversation from ${appLabelForPackage(packageName)}",
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

        if (isEmailPackage(packageName)) {
            if (looksLikeNewsletterOrDigest(combined)) {
                return NotificationImportance("low", "Email newsletter or digest", false, "email")
            }
            val sender = conversationSenderFromTitle(title)
            val snippet = conversationSnippetFromContent(content)
            val looksHumanOrProject = Regex("""\b(project|client|meeting|review|invoice|receipt|offer|deadline|call|handoff|proposal|ready|question|follow up|follow-up)\b""")
                .containsMatchIn(combined) || looksLikeConversation(title, content, sender)
            return NotificationImportance(
                if (looksHumanOrProject) "medium" else "low",
                if (looksHumanOrProject) "Email context from ${appLabelForPackage(packageName)}" else "Email notification",
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

    private fun appLabelForPackage(packageName: String): String {
        return when {
            packageName.contains("gmail") || packageName.contains("google.android.gm") -> "Gmail"
            packageName.contains("slack") -> "Slack"
            packageName.contains("teams") -> "Teams"
            packageName.contains("whatsapp") -> "WhatsApp"
            packageName.contains("orca") || packageName.contains("messenger") -> "Messenger"
            packageName.contains("discord") -> "Discord"
            else -> packageName.split(".").lastOrNull()?.replaceFirstChar {
                if (it.isLowerCase()) it.titlecase(Locale.getDefault()) else it.toString()
            } ?: "Unknown app"
        }
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
