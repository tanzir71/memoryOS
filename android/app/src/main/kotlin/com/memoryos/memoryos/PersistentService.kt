package com.memoryos.memoryos

import android.Manifest
import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.telephony.TelephonyManager
import android.util.Log
import org.json.JSONObject
import java.util.Locale

class PersistentService : Service() {
    private var dcimObserver: ScreenshotObserver? = null
    private var picturesObserver: ScreenshotObserver? = null
    private var bluetoothReceiverRegistered = false
    private var locationManager: LocationManager? = null
    private var locationListener: LocationListener? = null
    private var latestObservedLocation: Location? = null
    private val locationSampleHandler = Handler(Looper.getMainLooper())
    private var locationSampleRunnable: Runnable? = null

    companion object {
        private const val TAG = "PersistentService"
        private const val CHANNEL_ID = "memoryos_passive_channel"
        private const val NOTIFICATION_ID = 1001
        private const val LOCATION_MIN_TIME_MS = 10 * 60 * 1000L
        private const val LOCATION_MIN_DISTANCE_METERS = 75f
        private const val LOCATION_SAMPLE_INTERVAL_MS = 4 * 60 * 60 * 1000L
        private const val ACTION_PAUSE_LISTENING = "com.memoryos.memoryos.action.PAUSE_LISTENING"
        private const val ACTION_RESUME_LISTENING = "com.memoryos.memoryos.action.RESUME_LISTENING"

        fun recordCapture(context: Context, source: String, title: String) {
            try {
                val sharedPref = context.getSharedPreferences("memoryos_prefs", Context.MODE_PRIVATE)
                val newCount = sharedPref.getInt("recorded_event_count", 0) + 1
                with(sharedPref.edit()) {
                    putInt("recorded_event_count", newCount)
                    putString("last_capture_source", source)
                    putString("last_capture_title", title)
                    putLong("last_capture_at", System.currentTimeMillis())
                    apply()
                }

                createNotificationChannel(context)
                val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                notificationManager.notify(NOTIFICATION_ID, buildNotification(context))
            } catch (e: Exception) {
                Log.e(TAG, "Failed to update foreground status notification: ${e.message}", e)
            }
        }

        private fun createNotificationChannel(context: Context) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val channel = NotificationChannel(
                    CHANNEL_ID,
                    "MemoryOS Passive Enclave",
                    NotificationManager.IMPORTANCE_LOW
                ).apply {
                    description = "Active passive stream tracker indicator"
                    setShowBadge(false)
                }
                val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                notificationManager.createNotificationChannel(channel)
            }
        }

        private fun buildNotification(context: Context): Notification {
            val sharedPref = context.getSharedPreferences("memoryos_prefs", Context.MODE_PRIVATE)
            val isPaused = sharedPref.getBoolean("listening_paused", false)
            val notificationIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
            val pendingIntent = if (notificationIntent != null) {
                PendingIntent.getActivity(
                    context,
                    0,
                    notificationIntent,
                    pendingIntentFlags
                )
            } else {
                null
            }
            val actionIntent = Intent(context, PersistentService::class.java).apply {
                action = if (isPaused) ACTION_RESUME_LISTENING else ACTION_PAUSE_LISTENING
            }
            val actionPendingIntent = PendingIntent.getService(
                context,
                if (isPaused) 1003 else 1002,
                actionIntent,
                pendingIntentFlags
            )

            val notificationBuilder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Notification.Builder(context, CHANNEL_ID)
            } else {
                @Suppress("DEPRECATION")
                Notification.Builder(context)
            }

            return notificationBuilder
                .setContentTitle(if (isPaused) "MemoryOS is paused" else "MemoryOS is listening")
                .setContentText(statusText(sharedPref))
                .setSubText(activeCollectors(sharedPref))
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setContentIntent(pendingIntent)
                .addAction(
                    if (isPaused) android.R.drawable.ic_media_play else android.R.drawable.ic_media_pause,
                    if (isPaused) "Resume" else "Pause",
                    actionPendingIntent
                )
                .setOngoing(true)
                .setCategory(Notification.CATEGORY_SERVICE)
                .build()
        }

        private fun statusText(sharedPref: android.content.SharedPreferences): String {
            if (sharedPref.getBoolean("listening_paused", false)) {
                return "Passive collectors paused. Tap Resume to continue."
            }

            val count = sharedPref.getInt("recorded_event_count", 0)
            val lastTitle = sharedPref.getString("last_capture_title", null)
            val lastSource = sharedPref.getString("last_capture_source", null)

            return if (!lastTitle.isNullOrBlank() && !lastSource.isNullOrBlank()) {
                "Last ${prettySource(lastSource)}: ${lastTitle.take(36)}"
            } else {
                "Passive collectors armed. $count events recorded."
            }
        }

        private fun activeCollectors(sharedPref: android.content.SharedPreferences): String {
            if (sharedPref.getBoolean("listening_paused", false)) {
                return "Paused"
            }

            val active = listOf(
                "notification" to "Notifications",
                "photo" to "Screenshots",
                "location" to "Location",
                "bluetooth" to "Bluetooth",
                "calendar" to "Calendar",
                "reading" to "Clipboard"
            ).filter { (key, _) -> sharedPref.getBoolean("toggle_$key", false) }
                .joinToString(", ") { (_, label) -> label }

            return if (active.isBlank()) "No collectors enabled" else active
        }

        private fun prettySource(source: String): String {
            return source.replace("_", " ")
                .replaceFirstChar { if (it.isLowerCase()) it.titlecase(Locale.US) else it.toString() }
        }
    }

    private val bluetoothReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (!isSourceEnabled("bluetooth")) return

            val action = intent.action ?: return
            try {
                val device = bluetoothDeviceFromIntent(intent)
                val deviceName = safeDeviceName(device)
                val deviceAddress = safeDeviceAddress(device)

                when (action) {
                    BluetoothDevice.ACTION_ACL_CONNECTED -> {
                        recordBluetoothEvent("connected", "Bluetooth Connected", "Connected to device: $deviceName ($deviceAddress)", deviceName, deviceAddress)
                    }
                    BluetoothDevice.ACTION_ACL_DISCONNECTED -> {
                        recordBluetoothEvent("disconnected", "Bluetooth Disconnected", "Disconnected from device: $deviceName ($deviceAddress)", deviceName, deviceAddress)
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

                        val metadata = JSONObject().apply {
                            put("bluetoothState", stateStr)
                            put("bluetoothEvent", "adapter_state_changed")
                        }

                        DatabaseHelper.insertNode(
                            context = applicationContext,
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
        createNotificationChannel(this)
        showNotification()
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_PAUSE_LISTENING -> {
                setListeningPaused(true)
                stopCollectors()
                showNotification()
                return START_STICKY
            }
            ACTION_RESUME_LISTENING -> {
                setListeningPaused(false)
                showNotification()
                syncCollectors()
                return START_STICKY
            }
        }
        showNotification()
        syncCollectors()
        return START_STICKY
    }

    private fun showNotification() {
        val notification = buildNotification(this)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            var foregroundType = android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
            if (isSourceEnabled("location") && hasLocationPermission()) {
                foregroundType = foregroundType or android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION
            }
            startForeground(
                NOTIFICATION_ID,
                notification,
                foregroundType
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    private fun syncCollectors() {
        startObservers()
        syncBluetoothReceiver()
        syncLocationUpdates()
    }

    private fun setListeningPaused(isPaused: Boolean) {
        val sharedPref = getSharedPreferences("memoryos_prefs", Context.MODE_PRIVATE)
        sharedPref.edit().putBoolean("listening_paused", isPaused).apply()
        Log.d(TAG, "Persistent listening ${if (isPaused) "paused" else "resumed"} from notification action")
    }

    private fun stopCollectors() {
        try {
            dcimObserver?.stopWatching()
            picturesObserver?.stopWatching()
            dcimObserver = null
            picturesObserver = null
        } catch (e: Exception) {
            Log.e(TAG, "Failed to stop screenshot observers while pausing: ${e.message}", e)
        }

        if (bluetoothReceiverRegistered) {
            try {
                unregisterReceiver(bluetoothReceiver)
            } catch (e: Exception) {
                Log.e(TAG, "Failed to unregister Bluetooth receiver while pausing: ${e.message}", e)
            }
            bluetoothReceiverRegistered = false
        }

        stopLocationUpdates()
    }

    private fun startObservers() {
        val isPhotoEnabled = isSourceEnabled("photo")

        try {
            dcimObserver?.stopWatching()
            dcimObserver = null
            picturesObserver?.stopWatching()
            picturesObserver = null
            Log.d(TAG, "Stopped existing screenshot observers")
        } catch (e: Exception) {
            // Ignore
        }

        if (isPhotoEnabled) {
            try {
                dcimObserver = ScreenshotObserver(applicationContext, "/storage/emulated/0/DCIM/Screenshots")
                dcimObserver?.startWatching()
                Log.d(TAG, "Started watching native DCIM/Screenshots directory")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to start observer on DCIM/Screenshots: ${e.message}")
            }

            try {
                picturesObserver = ScreenshotObserver(applicationContext, "/storage/emulated/0/Pictures/Screenshots")
                picturesObserver?.startWatching()
                Log.d(TAG, "Started watching native Pictures/Screenshots directory")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to start observer on Pictures/Screenshots: ${e.message}")
            }
        } else {
            Log.d(TAG, "Screenshot observers are disabled in native settings")
        }
    }

    private fun syncBluetoothReceiver() {
        val isBluetoothEnabled = isSourceEnabled("bluetooth")
        if (isBluetoothEnabled && !bluetoothReceiverRegistered) {
            val filter = IntentFilter().apply {
                addAction(BluetoothDevice.ACTION_ACL_CONNECTED)
                addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED)
                addAction(BluetoothAdapter.ACTION_STATE_CHANGED)
            }

            try {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    registerReceiver(bluetoothReceiver, filter, Context.RECEIVER_EXPORTED)
                } else {
                    @Suppress("DEPRECATION")
                    registerReceiver(bluetoothReceiver, filter)
                }
                bluetoothReceiverRegistered = true
                Log.d(TAG, "Registered persistent Bluetooth receiver")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to register Bluetooth receiver: ${e.message}", e)
            }
        } else if (!isBluetoothEnabled && bluetoothReceiverRegistered) {
            try {
                unregisterReceiver(bluetoothReceiver)
            } catch (e: Exception) {
                Log.e(TAG, "Failed to unregister Bluetooth receiver: ${e.message}", e)
            }
            bluetoothReceiverRegistered = false
        }
    }

    private fun syncLocationUpdates() {
        if (!isSourceEnabled("location")) {
            stopLocationUpdates()
            return
        }

        if (!hasLocationPermission()) {
            Log.d(TAG, "Location collector enabled but permission is missing")
            stopLocationUpdates()
            return
        }

        if (locationListener != null) {
            scheduleLocationSampling()
            return
        }

        try {
            val manager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
            locationManager = manager
            val listener = object : LocationListener {
                override fun onLocationChanged(location: Location) {
                    latestObservedLocation = location
                    Log.d(TAG, "Location provider refreshed latest sample candidate from ${location.provider ?: "device"}")
                }

                @Deprecated("Deprecated in Android SDK")
                override fun onStatusChanged(provider: String?, status: Int, extras: Bundle?) {
                    // No-op
                }

                override fun onProviderEnabled(provider: String) {
                    // No-op
                }

                override fun onProviderDisabled(provider: String) {
                    // No-op
                }
            }
            locationListener = listener

            val providers = listOf(
                LocationManager.NETWORK_PROVIDER,
                LocationManager.GPS_PROVIDER,
                LocationManager.PASSIVE_PROVIDER
            ).filter { provider ->
                try {
                    manager.isProviderEnabled(provider)
                } catch (e: Exception) {
                    false
                }
            }

            for (provider in providers) {
                manager.requestLocationUpdates(
                    provider,
                    LOCATION_MIN_TIME_MS,
                    LOCATION_MIN_DISTANCE_METERS,
                    listener,
                    mainLooper
                )
            }

            recordBestAvailableLocation("startup_sample")
            scheduleLocationSampling()

            Log.d(TAG, "Location collector started with providers: $providers")
        } catch (e: SecurityException) {
            Log.e(TAG, "Missing location permission while starting location collector: ${e.message}", e)
            stopLocationUpdates()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start location collector: ${e.message}", e)
            stopLocationUpdates()
        }
    }

    private fun scheduleLocationSampling() {
        if (locationSampleRunnable != null) return

        val runnable = object : Runnable {
            override fun run() {
                if (!isSourceEnabled("location")) {
                    locationSampleRunnable = null
                    return
                }

                recordBestAvailableLocation("scheduled_4h_sample")
                locationSampleHandler.postDelayed(this, LOCATION_SAMPLE_INTERVAL_MS)
            }
        }

        locationSampleRunnable = runnable
        locationSampleHandler.postDelayed(runnable, nextLocationSampleDelayMs())
    }

    private fun nextLocationSampleDelayMs(): Long {
        val sharedPref = getSharedPreferences("memoryos_prefs", Context.MODE_PRIVATE)
        val lastDeviceAt = sharedPref.getLong("last_location_capture_at", 0L)
        val lastCellAt = sharedPref.getLong("last_cell_location_capture_at", 0L)
        val lastSampleAt = maxOf(lastDeviceAt, lastCellAt)

        if (lastSampleAt == 0L) return LOCATION_SAMPLE_INTERVAL_MS

        val elapsed = System.currentTimeMillis() - lastSampleAt
        return (LOCATION_SAMPLE_INTERVAL_MS - elapsed).coerceAtLeast(0L)
    }

    private fun recordBestAvailableLocation(event: String) {
        if (!hasLocationPermission()) return

        val manager = try {
            locationManager ?: (getSystemService(Context.LOCATION_SERVICE) as LocationManager).also {
                locationManager = it
            }
        } catch (e: Exception) {
            Log.e(TAG, "Unable to access LocationManager for scheduled sample: ${e.message}", e)
            recordCellTowerSnapshot("${event}_cell_tower")
            return
        }

        val providers = listOf(
            LocationManager.NETWORK_PROVIDER,
            LocationManager.GPS_PROVIDER,
            LocationManager.PASSIVE_PROVIDER
        )

        val bestLocation = (listOfNotNull(latestObservedLocation) + providers.mapNotNull { provider ->
            try {
                manager.getLastKnownLocation(provider)
            } catch (e: SecurityException) {
                null
            } catch (e: Exception) {
                null
            }
        }).maxByOrNull { it.time }

        if (bestLocation != null) {
            recordLocation(bestLocation, event)
        } else {
            recordCellTowerSnapshot("${event}_cell_tower")
        }
    }

    private fun stopLocationUpdates() {
        try {
            val listener = locationListener
            if (listener != null) {
                locationManager?.removeUpdates(listener)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to stop location updates: ${e.message}", e)
        }
        locationListener = null
        locationManager = null
        latestObservedLocation = null
        locationSampleRunnable?.let { locationSampleHandler.removeCallbacks(it) }
        locationSampleRunnable = null
    }

    private fun recordLocation(location: Location, event: String) {
        val roundedLat = String.format(Locale.US, "%.4f", location.latitude)
        val roundedLon = String.format(Locale.US, "%.4f", location.longitude)
        val sharedPref = getSharedPreferences("memoryos_prefs", Context.MODE_PRIVATE)
        val now = System.currentTimeMillis()
        val lastAt = sharedPref.getLong("last_location_capture_at", 0L)
        val lastLat = sharedPref.getString("last_location_lat", null)
        val lastLon = sharedPref.getString("last_location_lon", null)

        val isScheduledSample = event.startsWith("scheduled_")
        if (!isScheduledSample && now - lastAt < LOCATION_SAMPLE_INTERVAL_MS) {
            return
        }

        if (isScheduledSample && now - lastAt < LOCATION_MIN_TIME_MS && roundedLat == lastLat && roundedLon == lastLon) {
            return
        }

        with(sharedPref.edit()) {
            putLong("last_location_capture_at", now)
            putString("last_location_lat", roundedLat)
            putString("last_location_lon", roundedLon)
            apply()
        }

        val provider = location.provider ?: "device"
        val metadata = JSONObject().apply {
            put("locationName", "Device location")
            put("latitude", roundedLat)
            put("longitude", roundedLon)
            put("accuracyMeters", if (location.hasAccuracy()) location.accuracy else JSONObject.NULL)
            put("provider", provider)
            put("locationEvent", event)
            put("sampleIntervalHours", LOCATION_SAMPLE_INTERVAL_MS / (60 * 60 * 1000L))
        }

        DatabaseHelper.insertNode(
            context = applicationContext,
            title = "Location sample",
            content = "Location sample recorded from $provider provider.",
            source = "location",
            metadata = metadata,
            trail = "none"
        )
    }

    private fun recordCellTowerSnapshot(event: String) {
        val sharedPref = getSharedPreferences("memoryos_prefs", Context.MODE_PRIVATE)
        val now = System.currentTimeMillis()
        val lastAt = maxOf(
            sharedPref.getLong("last_location_capture_at", 0L),
            sharedPref.getLong("last_cell_location_capture_at", 0L)
        )
        val minSpacing = if (event.startsWith("scheduled_")) {
            LOCATION_MIN_TIME_MS
        } else {
            LOCATION_SAMPLE_INTERVAL_MS
        }
        if (now - lastAt < minSpacing) {
            return
        }

        try {
            val telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
            val cells = telephonyManager.allCellInfo
            if (cells.isNullOrEmpty()) {
                Log.d(TAG, "No device location or cell tower data available for $event")
                return
            }

            val primaryCell = cells.firstOrNull { it.isRegistered } ?: cells.first()
            with(sharedPref.edit()) {
                putLong("last_cell_location_capture_at", now)
                apply()
            }

            val metadata = JSONObject().apply {
                put("locationName", "Cell tower fallback")
                put("provider", "cell_tower")
                put("locationEvent", event)
                put("fallbackReason", "device_location_unavailable")
                put("sampleIntervalHours", LOCATION_SAMPLE_INTERVAL_MS / (60 * 60 * 1000L))
                put("cellCount", cells.size)
                put("cellTechnology", primaryCell.javaClass.simpleName.removePrefix("CellInfo"))
                put("isRegisteredCell", primaryCell.isRegistered)
                put("cellTowerSummary", primaryCell.toString().take(700))
            }

            DatabaseHelper.insertNode(
                context = applicationContext,
                title = "Cell tower fallback",
                content = "Cell tower snapshot recorded because GPS/network location was unavailable.",
                source = "location",
                metadata = metadata,
                trail = "none"
            )
        } catch (e: SecurityException) {
            Log.e(TAG, "Missing permission while reading cell tower fallback: ${e.message}", e)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to record cell tower fallback: ${e.message}", e)
        }
    }

    private fun recordBluetoothEvent(
        event: String,
        title: String,
        content: String,
        deviceName: String,
        deviceAddress: String
    ) {
        val metadata = JSONObject().apply {
            put("deviceName", deviceName)
            put("deviceAddress", deviceAddress)
            put("bluetoothEvent", event)
        }

        DatabaseHelper.insertNode(
            context = applicationContext,
            title = title,
            content = content,
            source = "bluetooth",
            metadata = metadata,
            trail = "none"
        )
    }

    private fun isSourceEnabled(source: String): Boolean {
        val sharedPref = getSharedPreferences("memoryos_prefs", Context.MODE_PRIVATE)
        return !sharedPref.getBoolean("listening_paused", false) &&
            sharedPref.getBoolean("toggle_$source", false)
    }

    private fun hasLocationPermission(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED ||
                checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED
        } else {
            true
        }
    }

    private fun bluetoothDeviceFromIntent(intent: Intent): BluetoothDevice? {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE, BluetoothDevice::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
        }
    }

    private fun safeDeviceName(device: BluetoothDevice?): String {
        if (device == null) return "Unknown Device"
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED
            ) {
                "Unknown Device (Permission Missing)"
            } else {
                device.name ?: "Unknown Device"
            }
        } catch (e: SecurityException) {
            "Unknown Device (Permission Missing)"
        }
    }

    private fun safeDeviceAddress(device: BluetoothDevice?): String {
        if (device == null) return "Unknown Address"
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED
            ) {
                "Permission Missing"
            } else {
                device.address ?: "Unknown Address"
            }
        } catch (e: SecurityException) {
            "Permission Missing"
        }
    }

    override fun onDestroy() {
        try {
            dcimObserver?.stopWatching()
            picturesObserver?.stopWatching()
            Log.d(TAG, "Stopped watching native screenshot directories")
        } catch (e: Exception) {
            // Ignore
        }

        if (bluetoothReceiverRegistered) {
            try {
                unregisterReceiver(bluetoothReceiver)
            } catch (e: Exception) {
                Log.e(TAG, "Failed to unregister Bluetooth receiver: ${e.message}", e)
            }
            bluetoothReceiverRegistered = false
        }

        stopLocationUpdates()
        super.onDestroy()
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        val sharedPref = getSharedPreferences("memoryos_prefs", Context.MODE_PRIVATE)
        val isPersistent = sharedPref.getBoolean("is_persistent", false)

        Log.d(TAG, "onTaskRemoved called. isPersistent: $isPersistent")

        if (isPersistent) {
            try {
                val restartIntent = Intent().apply {
                    setClassName(packageName, "de.julianassmann.flutter_background.IsolateHolderService")
                    action = "START"
                }

                val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    PendingIntent.FLAG_ONE_SHOT or PendingIntent.FLAG_IMMUTABLE
                } else {
                    PendingIntent.FLAG_ONE_SHOT
                }

                val pendingIntent = PendingIntent.getService(
                    this,
                    999,
                    restartIntent,
                    flags
                )

                val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
                val triggerTime = System.currentTimeMillis() + 800

                alarmManager.set(
                    AlarmManager.RTC_WAKEUP,
                    triggerTime,
                    pendingIntent
                )
                Log.d(TAG, "Successfully scheduled restart of IsolateHolderService")
            } catch (e: Exception) {
                Log.e(TAG, "Error scheduling restart of service: ${e.message}")
            }
        } else {
            Log.d(TAG, "Skipping restart since isPersistent is false")
        }

        super.onTaskRemoved(rootIntent)
    }
}
