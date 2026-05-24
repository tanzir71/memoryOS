package com.memoryos.memoryos

import android.content.Context
import android.os.FileObserver
import android.util.Log
import org.json.JSONObject
import java.io.File

class ScreenshotObserver(
    private val context: Context,
    private val directoryPath: String
) : FileObserver(File(directoryPath), CLOSE_WRITE) {

    companion object {
        private val processedFiles = mutableSetOf<String>()

        @Synchronized
        fun isAlreadyProcessed(fileName: String): Boolean {
            if (processedFiles.contains(fileName)) {
                return true
            }
            processedFiles.add(fileName)
            if (processedFiles.size > 100) {
                processedFiles.remove(processedFiles.first())
            }
            return false
        }
    }

    override fun onEvent(event: Int, path: String?) {
        if (path == null) return

        Log.d("ScreenshotObserver", "Screenshot event for path: $path in folder $directoryPath")

        if (!path.endsWith(".png", true) &&
            !path.endsWith(".jpg", true) &&
            !path.endsWith(".jpeg", true)
        ) {
            return
        }

        val sourceFile = File(directoryPath, path)
        val displayName = sourceFile.name
        if (isAlreadyProcessed(displayName)) {
            Log.d("ScreenshotObserver", "Screenshot already processed in-memory: $displayName. Skipping event.")
            return
        }

        try {
            try {
                Thread.sleep(300)
            } catch (e: Exception) {
                // Ignore: the file name and path are enough even if size is still settling.
            }

            val metadata = JSONObject().apply {
                put("fileName", displayName)
                put("isScreenshot", true)
                put("observerDetected", true)
            }

            Log.d("ScreenshotObserver", "Screenshot file detected: $displayName")

            DatabaseHelper.insertNode(
                context = context,
                title = "Screenshot file",
                content = displayName,
                source = "photo",
                metadata = metadata,
                trail = "none"
            )
        } catch (e: Exception) {
            Log.e("ScreenshotObserver", "Error handling screenshot observer event: ${e.message}", e)
        }
    }
}
