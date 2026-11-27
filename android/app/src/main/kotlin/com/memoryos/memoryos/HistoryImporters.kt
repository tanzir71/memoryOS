package com.memoryos.memoryos

import android.Manifest
import android.content.ContentUris
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.provider.CalendarContract
import android.provider.CallLog
import android.provider.ContactsContract
import android.provider.Telephony
import org.json.JSONArray
import org.json.JSONObject

object HistoryImporters {

    fun importSmsInbox(context: Context, afterEpochMs: Long): ImportProgress {
        if (!hasPerm(context, Manifest.permission.READ_SMS)) {
            return ImportProgress("sms", 0L, 0L, false, "permission_denied")
        }
        val db = InboxDatabase.getInstance(context)
        var imported = 0L
        var total = 0L
        val projection = arrayOf(
            Telephony.Sms._ID,
            Telephony.Sms.ADDRESS,
            Telephony.Sms.BODY,
            Telephony.Sms.DATE
        )
        val selection = "${Telephony.Sms.DATE} > ?"
        val selectionArgs = arrayOf(afterEpochMs.toString())
        val cursor = context.contentResolver.query(
            Telephony.Sms.Inbox.CONTENT_URI,
            projection,
            selection,
            selectionArgs,
            "${Telephony.Sms.DATE} ASC"
        ) ?: return ImportProgress("sms", 0L, 0L, true, null)

        cursor.use {
            total = it.count.toLong()
            while (it.moveToNext()) {
                val smsId = it.getLong(0)
                val address = it.getString(1) ?: ""
                val body = it.getString(2) ?: ""
                val date = it.getLong(3)
                val extras = JSONObject().apply {
                    put("smsId", smsId)
                    put("address", address)
                }
                db.insertRecord(
                    RawInboxRecord(
                        source = "sms",
                        title = address,
                        text = body,
                        extrasJson = extras.toString(),
                        postedAt = date,
                    )
                )
                imported++
            }
        }
        return ImportProgress("sms", imported, total, true, null)
    }

    fun importCallLog(context: Context, afterEpochMs: Long): ImportProgress {
        if (!hasPerm(context, Manifest.permission.READ_CALL_LOG)) {
            return ImportProgress("call", 0L, 0L, false, "permission_denied")
        }
        val db = InboxDatabase.getInstance(context)
        var imported = 0L
        var total = 0L
        val projection = arrayOf(
            CallLog.Calls._ID,
            CallLog.Calls.NUMBER,
            CallLog.Calls.CACHED_NAME,
            CallLog.Calls.TYPE,
            CallLog.Calls.DATE,
            CallLog.Calls.DURATION
        )
        val cursor = context.contentResolver.query(
            CallLog.Calls.CONTENT_URI,
            projection,
            "${CallLog.Calls.DATE} > ?",
            arrayOf(afterEpochMs.toString()),
            "${CallLog.Calls.DATE} ASC"
        ) ?: return ImportProgress("call", 0L, 0L, true, null)

        cursor.use {
            total = it.count.toLong()
            while (it.moveToNext()) {
                val callId = it.getLong(0)
                val number = it.getString(1) ?: ""
                val cachedName = it.getString(2) ?: ""
                val callType = it.getInt(3)
                val date = it.getLong(4)
                val duration = it.getLong(5)
                val typeLabel = when (callType) {
                    CallLog.Calls.INCOMING_TYPE -> "incoming"
                    CallLog.Calls.OUTGOING_TYPE -> "outgoing"
                    CallLog.Calls.MISSED_TYPE -> "missed"
                    CallLog.Calls.REJECTED_TYPE -> "rejected"
                    else -> "other"
                }
                val extras = JSONObject().apply {
                    put("callId", callId)
                    put("number", number)
                    put("cachedName", cachedName)
                    put("callType", typeLabel)
                    put("durationSec", duration)
                }
                db.insertRecord(
                    RawInboxRecord(
                        source = "call",
                        category = typeLabel,
                        title = cachedName.ifEmpty { number },
                        text = number,
                        extrasJson = extras.toString(),
                        postedAt = date,
                        removedAt = if (duration > 0) date + duration * 1000L else null,
                    )
                )
                imported++
            }
        }
        return ImportProgress("call", imported, total, true, null)
    }

    fun importContacts(context: Context): ImportProgress {
        if (!hasPerm(context, Manifest.permission.READ_CONTACTS)) {
            return ImportProgress("contacts", 0L, 0L, false, "permission_denied")
        }
        val db = InboxDatabase.getInstance(context)
        val phonesByContact = mutableMapOf<Long, MutableList<String>>()
        val emailsByContact = mutableMapOf<Long, MutableList<String>>()

        context.contentResolver.query(
            ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
            arrayOf(
                ContactsContract.CommonDataKinds.Phone.CONTACT_ID,
                ContactsContract.CommonDataKinds.Phone.NUMBER
            ),
            null,
            null,
            null
        )?.use { c ->
            while (c.moveToNext()) {
                val cid = c.getLong(0)
                val num = c.getString(1)?.trim() ?: continue
                if (num.isNotEmpty()) {
                    phonesByContact.getOrPut(cid) { mutableListOf() }.add(num)
                }
            }
        }

        context.contentResolver.query(
            ContactsContract.CommonDataKinds.Email.CONTENT_URI,
            arrayOf(
                ContactsContract.CommonDataKinds.Email.CONTACT_ID,
                ContactsContract.CommonDataKinds.Email.ADDRESS
            ),
            null,
            null,
            null
        )?.use { c ->
            while (c.moveToNext()) {
                val cid = c.getLong(0)
                val addr = c.getString(1)?.trim() ?: continue
                if (addr.isNotEmpty()) {
                    emailsByContact.getOrPut(cid) { mutableListOf() }.add(addr)
                }
            }
        }

        var imported = 0L
        var total = 0L
        val now = System.currentTimeMillis()
        context.contentResolver.query(
            ContactsContract.Contacts.CONTENT_URI,
            arrayOf(
                ContactsContract.Contacts._ID,
                ContactsContract.Contacts.LOOKUP_KEY,
                ContactsContract.Contacts.DISPLAY_NAME_PRIMARY
            ),
            null,
            null,
            null
        )?.use { c ->
            total = c.count.toLong()
            while (c.moveToNext()) {
                val cid = c.getLong(0)
                val lookupKey = c.getString(1) ?: ""
                val displayName = c.getString(2)?.trim() ?: ""
                if (displayName.isEmpty()) continue
                val phones = phonesByContact[cid].orEmpty().distinct()
                val emails = emailsByContact[cid].orEmpty().distinct()
                if (phones.isEmpty() && emails.isEmpty()) continue
                val extras = JSONObject().apply {
                    put("lookupKey", lookupKey)
                    put("phones", JSONArray(phones))
                    put("emails", JSONArray(emails))
                }
                db.insertRecord(
                    RawInboxRecord(
                        source = "contacts",
                        title = displayName,
                        extrasJson = extras.toString(),
                        postedAt = now,
                    )
                )
                imported++
            }
        }
        return ImportProgress("contacts", imported, total, true, null)
    }

    fun importCalendarInstances(
        context: Context,
        fromEpochMs: Long,
        toEpochMs: Long
    ): ImportProgress {
        if (!hasPerm(context, Manifest.permission.READ_CALENDAR)) {
            return ImportProgress("calendar", 0L, 0L, false, "permission_denied")
        }
        val db = InboxDatabase.getInstance(context)
        val uriBuilder = CalendarContract.Instances.CONTENT_URI.buildUpon()
        ContentUris.appendId(uriBuilder, fromEpochMs)
        ContentUris.appendId(uriBuilder, toEpochMs)

        val projection = arrayOf(
            CalendarContract.Instances.EVENT_ID,
            CalendarContract.Instances.TITLE,
            CalendarContract.Instances.BEGIN,
            CalendarContract.Instances.END,
            CalendarContract.Instances.EVENT_LOCATION,
            CalendarContract.Instances.RRULE,
            CalendarContract.Instances.ORGANIZER
        )
        var imported = 0L
        var total = 0L
        context.contentResolver.query(
            uriBuilder.build(),
            projection,
            null,
            null,
            "${CalendarContract.Instances.BEGIN} ASC"
        )?.use { c ->
            total = c.count.toLong()
            while (c.moveToNext()) {
                val eventId = c.getLong(0)
                val title = c.getString(1) ?: ""
                val begin = c.getLong(2)
                val end = c.getLong(3)
                val location = c.getString(4) ?: ""
                val rrule = c.getString(5) ?: ""
                val organizer = c.getString(6) ?: ""
                val attendees = loadAttendees(context, eventId)

                val extras = JSONObject().apply {
                    put("eventId", eventId)
                    put("location", location)
                    put("rrule", rrule)
                    put("organizer", organizer)
                    put("attendees", attendees)
                }
                db.insertRecord(
                    RawInboxRecord(
                        source = "calendar",
                        title = title,
                        text = location,
                        peopleJson = attendees.toString(),
                        extrasJson = extras.toString(),
                        postedAt = begin,
                        removedAt = end,
                    )
                )
                imported++
            }
        }
        return ImportProgress("calendar", imported, total, true, null)
    }

    private fun loadAttendees(context: Context, eventId: Long): JSONArray {
        val arr = JSONArray()
        context.contentResolver.query(
            CalendarContract.Attendees.CONTENT_URI,
            arrayOf(
                CalendarContract.Attendees.ATTENDEE_NAME,
                CalendarContract.Attendees.ATTENDEE_EMAIL
            ),
            "${CalendarContract.Attendees.EVENT_ID} = ?",
            arrayOf(eventId.toString()),
            null
        )?.use { c ->
            while (c.moveToNext()) {
                val name = c.getString(0) ?: ""
                val email = c.getString(1) ?: ""
                if (name.isNotEmpty() || email.isNotEmpty()) {
                    arr.put(JSONObject().apply {
                        put("name", name)
                        put("email", email)
                    })
                }
            }
        }
        return arr
    }

    private fun hasPerm(context: Context, permission: String): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            context.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
    }
}
