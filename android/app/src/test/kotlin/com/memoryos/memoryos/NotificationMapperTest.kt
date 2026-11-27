package com.memoryos.memoryos

import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class NotificationMapperTest {

    @Test
    fun mapsWhatsAppMessageWithMessagesAndInlineReplies() {
        val extras = NotificationExtrasData(
            title = "Nabila Rahman",
            text = "Can you send the revised quote today?",
            conversationTitle = "Nabila Rahman",
            isGroupConversation = false,
            messages = listOf(
                NotificationMessageData("Nabila Rahman", "Can you send the revised quote today?", 1795752840000L),
                NotificationMessageData("", "Sure, sending before 5 pm", 1795752900000L),
            ),
            remoteInputHistory = listOf("Sure, sending before 5 pm"),
        )

        val rec = NotificationMapper.mapExtras(
            pkg = "com.whatsapp",
            channel = "chat_messages",
            category = "msg",
            flags = 0,
            importance = 4,
            sbnKey = "0|com.whatsapp|1|nabila|1000",
            groupKey = "0|com.whatsapp|g:messages",
            isConversation = true,
            postedAt = 1795752840000L,
            extras = extras,
        )

        assertEquals("notification", rec.source)
        assertEquals("com.whatsapp", rec.pkg)
        assertTrue(rec.isConversation)
        assertFalse(rec.isGroup)
        assertEquals("Nabila Rahman", rec.title)
        assertEquals("Can you send the revised quote today?", rec.text)
        val parsedExtras = JSONObject(rec.extrasJson)
        val messages = parsedExtras.getJSONArray("messages")
        assertEquals(2, messages.length())
        assertFalse(messages.getJSONObject(0).getBoolean("isSelf"))
        assertTrue(messages.getJSONObject(1).getBoolean("isSelf"))
        val replies = parsedExtras.getJSONArray("remoteInputHistory")
        assertEquals(1, replies.length())
        assertEquals("Sure, sending before 5 pm", replies.getString(0))
    }

    @Test
    fun mapsWhatsAppMessageWhenInlineRepliesMissing() {
        val extras = NotificationExtrasData(
            title = "Sadia Karim",
            text = "Running 5 late, start without me.",
        )

        val rec = NotificationMapper.mapExtras(
            pkg = "com.whatsapp",
            channel = "chat",
            category = "msg",
            flags = 0,
            importance = 4,
            sbnKey = "0|com.whatsapp|2|sadia|1000",
            groupKey = "",
            isConversation = true,
            postedAt = 1795770000000L,
            extras = extras,
        )

        val parsedExtras = JSONObject(rec.extrasJson)
        assertFalse(parsedExtras.has("remoteInputHistory"))
        assertEquals("Running 5 late, start without me.", rec.text)
    }

    @Test
    fun mapsGmailNotificationWithBigText() {
        val extras = NotificationExtrasData(
            title = "Nabila Rahman",
            text = "Re: Website quote, scope changes",
            bigText = "Re: Website quote, scope changes\nAttached the updated scope notes for Thursday.",
        )

        val rec = NotificationMapper.mapExtras(
            pkg = "com.google.android.gm",
            channel = "mail",
            category = "email",
            flags = 0,
            importance = 3,
            sbnKey = "0|com.google.android.gm|55|null|1000",
            groupKey = "",
            isConversation = false,
            postedAt = 1795755900000L,
            extras = extras,
        )

        assertEquals("email", rec.category)
        assertEquals("Nabila Rahman", rec.title)
        assertEquals("Re: Website quote, scope changes", rec.text)
        assertTrue(rec.bigText.contains("updated scope notes"))
        assertFalse(rec.isConversation)
    }

    @Test
    fun mapsOngoingCallNotification() {
        val extras = NotificationExtrasData(
            title = "Design sync",
            text = "Ongoing Google Meet call",
        )

        val rec = NotificationMapper.mapExtras(
            pkg = "com.google.android.apps.tachyon",
            channel = "ongoing_calls",
            category = "call",
            flags = NotificationMapper.FLAG_ONGOING_EVENT,
            importance = 4,
            sbnKey = "0|com.google.android.apps.tachyon|9|call|1000",
            groupKey = "",
            isConversation = false,
            postedAt = 1795770120000L,
            extras = extras,
        )

        assertEquals("call", rec.category)
        assertTrue((rec.flags and NotificationMapper.FLAG_ONGOING_EVENT) != 0)
        assertEquals(null, rec.removedAt)
        val parsedExtras = JSONObject(rec.extrasJson)
        assertTrue(parsedExtras.getBoolean("isOngoing"))
    }

    @Test
    fun mapsGroupSummaryNotification() {
        val extras = NotificationExtrasData(
            title = "WhatsApp",
            summaryText = "4 messages from 2 chats",
            textLines = listOf("Nabila: Quote?", "Sadia: Running late"),
        )

        val rec = NotificationMapper.mapExtras(
            pkg = "com.whatsapp",
            channel = "chat",
            category = "msg",
            flags = NotificationMapper.FLAG_GROUP_SUMMARY,
            importance = 3,
            sbnKey = "0|com.whatsapp|0|summary|1000",
            groupKey = "0|com.whatsapp|g:messages",
            isConversation = false,
            postedAt = 1795770200000L,
            extras = extras,
        )

        val parsedExtras = JSONObject(rec.extrasJson)
        assertTrue(parsedExtras.getBoolean("isGroupSummary"))
        assertEquals(2, parsedExtras.getJSONArray("textLines").length())
    }
}
