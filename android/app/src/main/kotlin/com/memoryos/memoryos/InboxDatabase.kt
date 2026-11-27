package com.memoryos.memoryos

import android.content.ContentValues
import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

data class RawInboxRecord(
    val id: Long = 0L,
    val source: String,
    val pkg: String = "",
    val channel: String = "",
    val category: String = "",
    val flags: Int = 0,
    val importance: Int = 3,
    val sbnKey: String = "",
    val groupKey: String = "",
    val isConversation: Boolean = false,
    val isGroup: Boolean = false,
    val title: String = "",
    val text: String = "",
    val bigText: String = "",
    val peopleJson: String = "[]",
    val extrasJson: String = "{}",
    val postedAt: Long,
    val removedAt: Long? = null,
    val removalReason: Int? = null,
    val redacted: Boolean = false,
)

class InboxDatabase private constructor(context: Context) :
    SQLiteOpenHelper(context.applicationContext, DB_NAME, null, DB_VERSION) {

    companion object {
        const val DB_NAME = "inbox.db"
        const val DB_VERSION = 1
        const val TABLE = "raw_inbox"

        @Volatile
        private var instance: InboxDatabase? = null

        fun getInstance(context: Context): InboxDatabase {
            return instance ?: synchronized(this) {
                instance ?: InboxDatabase(context).also { instance = it }
            }
        }
    }

    override fun onConfigure(db: SQLiteDatabase) {
        super.onConfigure(db)
        db.enableWriteAheadLogging()
    }

    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL(
            """
            CREATE TABLE IF NOT EXISTS $TABLE (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                source TEXT NOT NULL,
                pkg TEXT NOT NULL DEFAULT '',
                channel TEXT NOT NULL DEFAULT '',
                category TEXT NOT NULL DEFAULT '',
                flags INTEGER NOT NULL DEFAULT 0,
                importance INTEGER NOT NULL DEFAULT 3,
                sbn_key TEXT NOT NULL DEFAULT '',
                group_key TEXT NOT NULL DEFAULT '',
                is_conversation INTEGER NOT NULL DEFAULT 0,
                is_group INTEGER NOT NULL DEFAULT 0,
                title TEXT NOT NULL DEFAULT '',
                text TEXT NOT NULL DEFAULT '',
                big_text TEXT NOT NULL DEFAULT '',
                people_json TEXT NOT NULL DEFAULT '[]',
                extras_json TEXT NOT NULL DEFAULT '{}',
                posted_at INTEGER NOT NULL,
                removed_at INTEGER,
                removal_reason INTEGER,
                redacted INTEGER NOT NULL DEFAULT 0,
                consumed INTEGER NOT NULL DEFAULT 0
            )
            """.trimIndent()
        )
        db.execSQL("CREATE INDEX IF NOT EXISTS idx_raw_inbox_consumed_id ON $TABLE(consumed, id)")
        db.execSQL("CREATE INDEX IF NOT EXISTS idx_raw_inbox_sbn_key ON $TABLE(sbn_key, consumed)")
        db.execSQL("CREATE INDEX IF NOT EXISTS idx_raw_inbox_posted_at ON $TABLE(posted_at)")
    }

    override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) {
        // Version 1 initial schema.
    }

    @Synchronized
    fun insertOrUpdateNotification(record: RawInboxRecord): Long {
        val db = writableDatabase
        if (!record.isConversation && record.sbnKey.isNotEmpty()) {
            val existingId = findUnconsumedIdBySbnKey(db, record.sbnKey)
            if (existingId != null) {
                db.update(TABLE, record.toContentValues(), "id = ?", arrayOf(existingId.toString()))
                return existingId
            }
        }
        return db.insert(TABLE, null, record.toContentValues())
    }

    @Synchronized
    fun insertRecord(record: RawInboxRecord): Long {
        return writableDatabase.insert(TABLE, null, record.toContentValues())
    }

    @Synchronized
    fun markRemovedBySbnKey(sbnKey: String, removedAt: Long, reason: Int): Int {
        if (sbnKey.isEmpty()) return 0
        val db = writableDatabase
        val values = ContentValues().apply {
            put("removed_at", removedAt)
            put("removal_reason", reason)
            put("consumed", 0)
        }
        val cursor = db.rawQuery(
            "SELECT id FROM $TABLE WHERE sbn_key = ? ORDER BY id DESC LIMIT 1",
            arrayOf(sbnKey)
        )
        val targetId = cursor.use { if (it.moveToFirst()) it.getLong(0) else null } ?: return 0
        return db.update(TABLE, values, "id = ?", arrayOf(targetId.toString()))
    }

    @Synchronized
    fun drain(afterId: Long, limit: Int): List<RawInboxRecord> {
        val db = readableDatabase
        val safeLimit = limit.coerceIn(1, 500)
        val cursor = db.rawQuery(
            """
            SELECT id, source, pkg, channel, category, flags, importance,
                   sbn_key, group_key, is_conversation, is_group,
                   title, text, big_text, people_json, extras_json,
                   posted_at, removed_at, removal_reason, redacted
            FROM $TABLE
            WHERE consumed = 0 AND id > ?
            ORDER BY id ASC
            LIMIT ?
            """.trimIndent(),
            arrayOf(afterId.toString(), safeLimit.toString())
        )
        val items = mutableListOf<RawInboxRecord>()
        cursor.use {
            while (it.moveToNext()) {
                items.add(
                    RawInboxRecord(
                        id = it.getLong(0),
                        source = it.getString(1) ?: "",
                        pkg = it.getString(2) ?: "",
                        channel = it.getString(3) ?: "",
                        category = it.getString(4) ?: "",
                        flags = it.getInt(5),
                        importance = it.getInt(6),
                        sbnKey = it.getString(7) ?: "",
                        groupKey = it.getString(8) ?: "",
                        isConversation = it.getInt(9) == 1,
                        isGroup = it.getInt(10) == 1,
                        title = it.getString(11) ?: "",
                        text = it.getString(12) ?: "",
                        bigText = it.getString(13) ?: "",
                        peopleJson = it.getString(14) ?: "[]",
                        extrasJson = it.getString(15) ?: "{}",
                        postedAt = it.getLong(16),
                        removedAt = if (it.isNull(17)) null else it.getLong(17),
                        removalReason = if (it.isNull(18)) null else it.getInt(18),
                        redacted = it.getInt(19) == 1,
                    )
                )
            }
        }
        return items
    }

    @Synchronized
    fun ack(upToId: Long): Int {
        val values = ContentValues().apply { put("consumed", 1) }
        return writableDatabase.update(
            TABLE,
            values,
            "consumed = 0 AND id <= ?",
            arrayOf(upToId.toString())
        )
    }

    private fun findUnconsumedIdBySbnKey(db: SQLiteDatabase, sbnKey: String): Long? {
        val cursor = db.rawQuery(
            "SELECT id FROM $TABLE WHERE sbn_key = ? AND consumed = 0 ORDER BY id DESC LIMIT 1",
            arrayOf(sbnKey)
        )
        return cursor.use { if (it.moveToFirst()) it.getLong(0) else null }
    }

    private fun RawInboxRecord.toContentValues(): ContentValues {
        return ContentValues().apply {
            put("source", source)
            put("pkg", pkg)
            put("channel", channel)
            put("category", category)
            put("flags", flags)
            put("importance", importance)
            put("sbn_key", sbnKey)
            put("group_key", groupKey)
            put("is_conversation", if (isConversation) 1 else 0)
            put("is_group", if (isGroup) 1 else 0)
            put("title", title)
            put("text", text)
            put("big_text", bigText)
            put("people_json", peopleJson)
            put("extras_json", extrasJson)
            put("posted_at", postedAt)
            if (removedAt != null) put("removed_at", removedAt) else putNull("removed_at")
            if (removalReason != null) put("removal_reason", removalReason) else putNull("removal_reason")
            put("redacted", if (redacted) 1 else 0)
            put("consumed", 0)
        }
    }
}
