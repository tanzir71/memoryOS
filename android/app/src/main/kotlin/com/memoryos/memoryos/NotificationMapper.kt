package com.memoryos.memoryos

import android.app.Notification
import android.os.Build
import android.os.Bundle
import org.json.JSONArray
import org.json.JSONObject

data class NotificationMessageData(
    val sender: String,
    val text: String,
    val time: Long,
)

data class NotificationExtrasData(
    val title: String? = null,
    val titleBig: String? = null,
    val conversationTitle: String? = null,
    val text: String? = null,
    val bigText: String? = null,
    val subText: String? = null,
    val summaryText: String? = null,
    val isGroupConversation: Boolean = false,
    val messages: List<NotificationMessageData> = emptyList(),
    val remoteInputHistory: List<String> = emptyList(),
    val textLines: List<String> = emptyList(),
    val people: List<String> = emptyList(),
)

object NotificationMapper {
    const val FLAG_ONGOING_EVENT = 0x00000002
    const val FLAG_GROUP_SUMMARY = 0x00000200

    fun map(
        pkg: String,
        channel: String,
        category: String,
        flags: Int,
        importance: Int,
        sbnKey: String,
        groupKey: String,
        isConversation: Boolean,
        postedAt: Long,
        extras: Bundle,
        redacted: Boolean = false,
    ): RawInboxRecord {
        return mapExtras(
            pkg = pkg,
            channel = channel,
            category = category,
            flags = flags,
            importance = importance,
            sbnKey = sbnKey,
            groupKey = groupKey,
            isConversation = isConversation,
            postedAt = postedAt,
            extras = fromBundle(extras),
            redacted = redacted,
        )
    }

    fun fromBundle(extras: Bundle): NotificationExtrasData {
        val messages = mutableListOf<NotificationMessageData>()
        if (extras.containsKey(Notification.EXTRA_MESSAGES)) {
            @Suppress("DEPRECATION")
            val raw = extras.getParcelableArray(Notification.EXTRA_MESSAGES)
            raw?.forEach { item ->
                if (item is Bundle) {
                    val sender = item.getCharSequence("sender")?.toString()?.trim()
                        ?: extractPersonName(item)
                        ?: ""
                    val text = item.getCharSequence("text")?.toString()?.trim() ?: ""
                    val time = item.getLong("time", 0L)
                    if (text.isNotEmpty()) {
                        messages.add(NotificationMessageData(sender, text, time))
                    }
                }
            }
        }

        val replies = try {
            extras.getCharSequenceArray(Notification.EXTRA_REMOTE_INPUT_HISTORY)
                ?.mapNotNull { it?.toString()?.trim() }
                ?.filter { it.isNotEmpty() }
                .orEmpty()
        } catch (_: Exception) {
            emptyList()
        }

        val lines = try {
            extras.getCharSequenceArray(Notification.EXTRA_TEXT_LINES)
                ?.mapNotNull { it?.toString()?.trim() }
                ?.filter { it.isNotEmpty() }
                .orEmpty()
        } catch (_: Exception) {
            emptyList()
        }

        val people = mutableListOf<String>()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            @Suppress("DEPRECATION")
            val list = extras.getParcelableArrayList<android.app.Person>(Notification.EXTRA_PEOPLE_LIST)
            list?.forEach { person ->
                val name = person.name?.toString()?.trim()
                if (!name.isNullOrEmpty()) people.add(name)
            }
        }

        return NotificationExtrasData(
            title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString(),
            titleBig = extras.getCharSequence(Notification.EXTRA_TITLE_BIG)?.toString(),
            conversationTitle = extras.getCharSequence(Notification.EXTRA_CONVERSATION_TITLE)?.toString(),
            text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString(),
            bigText = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString(),
            subText = extras.getCharSequence(Notification.EXTRA_SUB_TEXT)?.toString(),
            summaryText = extras.getCharSequence(Notification.EXTRA_SUMMARY_TEXT)?.toString(),
            isGroupConversation = extras.getBoolean(Notification.EXTRA_IS_GROUP_CONVERSATION, false),
            messages = messages,
            remoteInputHistory = replies,
            textLines = lines,
            people = people,
        )
    }

    fun mapExtras(
        pkg: String,
        channel: String,
        category: String,
        flags: Int,
        importance: Int,
        sbnKey: String,
        groupKey: String,
        isConversation: Boolean,
        postedAt: Long,
        extras: NotificationExtrasData,
        redacted: Boolean = false,
    ): RawInboxRecord {
        val conversationTitle = extras.conversationTitle?.trim() ?: ""
        val rawTitle = firstNonEmpty(extras.title, extras.titleBig, conversationTitle)
        val rawText = extras.text?.trim() ?: ""
        val rawBigText = extras.bigText?.trim() ?: ""

        val resolvedIsConversation =
            isConversation || extras.messages.isNotEmpty() || conversationTitle.isNotEmpty()

        val messagesArray = JSONArray()
        for (m in extras.messages) {
            if (m.text.isNotEmpty()) {
                messagesArray.put(
                    JSONObject().apply {
                        put("sender", m.sender)
                        put("text", m.text)
                        put("time", m.time)
                        put("isSelf", m.sender.isEmpty())
                    }
                )
            }
        }

        val repliesArray = JSONArray()
        extras.remoteInputHistory.filter { it.isNotEmpty() }.forEach { repliesArray.put(it) }

        val textLinesArray = JSONArray()
        extras.textLines.filter { it.isNotEmpty() }.forEach { textLinesArray.put(it) }

        val peopleSet = LinkedHashSet<String>()
        extras.messages.map { it.sender.trim() }.filter { it.isNotEmpty() }.forEach { peopleSet.add(it) }
        extras.people.map { it.trim() }.filter { it.isNotEmpty() }.forEach { peopleSet.add(it) }
        if (peopleSet.isEmpty() && rawTitle.isNotEmpty()) {
            peopleSet.add(rawTitle)
        }
        val peopleArray = JSONArray()
        peopleSet.forEach { peopleArray.put(it) }

        val extrasObj = JSONObject().apply {
            if (conversationTitle.isNotEmpty()) put("conversationTitle", conversationTitle)
            if (messagesArray.length() > 0) put("messages", messagesArray)
            if (repliesArray.length() > 0) put("remoteInputHistory", repliesArray)
            if (textLinesArray.length() > 0) put("textLines", textLinesArray)
            val sub = extras.subText?.trim()
            if (!sub.isNullOrEmpty()) put("subText", sub)
            val sum = extras.summaryText?.trim()
            if (!sum.isNullOrEmpty()) put("summaryText", sum)
            put("isGroupSummary", (flags and FLAG_GROUP_SUMMARY) != 0)
            put("isOngoing", (flags and FLAG_ONGOING_EVENT) != 0)
        }

        val resolvedText = when {
            rawText.isNotEmpty() -> rawText
            extras.messages.isNotEmpty() -> extras.messages.last().text
            extras.textLines.isNotEmpty() -> extras.textLines.joinToString("\n")
            else -> ""
        }

        return RawInboxRecord(
            source = "notification",
            pkg = pkg,
            channel = channel,
            category = category,
            flags = flags,
            importance = importance,
            sbnKey = sbnKey,
            groupKey = groupKey,
            isConversation = resolvedIsConversation,
            isGroup = extras.isGroupConversation,
            title = if (redacted) "" else rawTitle,
            text = if (redacted) "" else resolvedText,
            bigText = if (redacted) "" else rawBigText,
            peopleJson = if (redacted) "[]" else peopleArray.toString(),
            extrasJson = if (redacted) "{}" else extrasObj.toString(),
            postedAt = postedAt,
            redacted = redacted,
        )
    }

    private fun extractPersonName(msgBundle: Bundle): String? {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            @Suppress("DEPRECATION")
            val p = msgBundle.getParcelable<android.app.Person>("sender_person")
            if (p != null) return p.name?.toString()?.trim()
        }
        return msgBundle.getCharSequence("sender_person")?.toString()?.trim()
    }

    private fun firstNonEmpty(vararg candidates: String?): String {
        return candidates.firstOrNull { !it.isNullOrBlank() }?.trim() ?: ""
    }
}
