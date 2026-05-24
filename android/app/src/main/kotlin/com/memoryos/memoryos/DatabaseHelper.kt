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
}
