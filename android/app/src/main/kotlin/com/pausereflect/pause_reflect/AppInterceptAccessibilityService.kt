package com.pausereflect.pause_reflect

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent
import org.json.JSONArray

/**
 * Pure detector + launcher. On a window-state change to a watched app (and when
 * not inside that app's grace window) it launches [InterceptActivity]. All
 * counting, prompt rotation, timing, and persistence live in Dart.
 *
 * Config + grace state are read straight from the `FlutterSharedPreferences`
 * file that the Dart `shared_preferences` plugin writes (keys prefixed
 * `flutter.`). This service MUST run in the default process (no
 * `android:process`) so it shares that prefs cache with the app.
 */
class AppInterceptAccessibilityService : AccessibilityService() {

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return

        val pkg = event.packageName?.toString() ?: return
        if (pkg == packageName) return            // ignore our own UI
        if (InterceptActivity.isShowing) return   // already pausing
        if (!isWatched(pkg)) return
        if (inGrace(pkg)) return

        launchPause(pkg)
    }

    override fun onInterrupt() { /* no-op */ }

    private fun prefs() =
        getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)

    private fun isWatched(pkg: String): Boolean {
        val raw = prefs().getString("flutter.watchedPackagesJson", null) ?: return false
        return try {
            val arr = JSONArray(raw)
            (0 until arr.length()).any { arr.getString(it) == pkg }
        } catch (_: Exception) {
            false
        }
    }

    private fun inGrace(pkg: String): Boolean {
        val p = prefs()
        // shared_preferences stores Dart ints as Long, prefixed with "flutter.".
        val lastAllowed = if (p.contains("flutter.grace_$pkg")) {
            p.getLong("flutter.grace_$pkg", 0L)
        } else {
            return false
        }
        val graceMinutes = if (p.contains("flutter.graceMinutes")) {
            p.getLong("flutter.graceMinutes", DEFAULT_GRACE_MINUTES).toInt()
        } else {
            DEFAULT_GRACE_MINUTES.toInt()
        }
        if (graceMinutes <= 0) return false
        return System.currentTimeMillis() - lastAllowed < graceMinutes * 60_000L
    }

    private fun launchPause(pkg: String) {
        val intent = Intent(this, InterceptActivity::class.java).apply {
            putExtra(InterceptActivity.EXTRA_TARGET, pkg)
            // Make FlutterActivity attach to the pre-warmed cached engine.
            putExtra("cached_engine_id", PauseApplication.PAUSE_ENGINE_ID)
            putExtra("destroy_engine_with_activity", false)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_NO_ANIMATION)
        }
        startActivity(intent)
    }

    companion object {
        private const val DEFAULT_GRACE_MINUTES = 5L
    }
}
