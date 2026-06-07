package com.pausereflect.pause_reflect

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Full-screen interrupt host. Reuses the cached `pause_engine` (route driven by
 * the `pauseMain` Dart entrypoint) for instant display, and exposes the
 * `pause/intercept` channel so Dart can learn the target app and dismiss us.
 *
 * Launched by [AppInterceptAccessibilityService] with the cached-engine extras
 * set, so [getCachedEngineId] resolves to [PauseApplication.PAUSE_ENGINE_ID].
 */
class InterceptActivity : FlutterActivity() {

    private var target: String? = null

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        target = intent.getStringExtra(EXTRA_TARGET)
        isShowing = true
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getTarget" -> result.success(target)
                    "exit" -> {
                        val goHome = call.argument<Boolean>("goHome") ?: false
                        result.success(null)
                        finishAndRemoveTask()
                        if (goHome) {
                            val home = Intent(Intent.ACTION_MAIN)
                                .addCategory(Intent.CATEGORY_HOME)
                                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            startActivity(home)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onDestroy() {
        isShowing = false
        super.onDestroy()
    }

    companion object {
        const val EXTRA_TARGET = "target_package"
        private const val CHANNEL = "pause/intercept"

        /** True while a pause screen is on-screen; used to debounce re-launches. */
        @Volatile
        var isShowing: Boolean = false
    }
}
