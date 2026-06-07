package com.pausereflect.pause_reflect

import android.app.Application
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor

/**
 * Pre-warms a cached Flutter engine running the `pauseMain` entrypoint so the
 * pause screen appears with no cold-start lag when a watched app is opened.
 *
 * The engine is built once at process start and reused by every
 * [InterceptActivity] launch.
 */
class PauseApplication : Application() {
    override fun onCreate() {
        super.onCreate()

        val engine = FlutterEngine(this)
        val entrypoint = DartExecutor.DartEntrypoint(
            FlutterInjector.instance().flutterLoader().findAppBundlePath(),
            "pauseMain",
        )
        engine.dartExecutor.executeDartEntrypoint(entrypoint)
        // Register plugins (shared_preferences, path_provider, sqlite3, …) on the
        // standalone engine so the pause isolate can read settings and the DB.
        io.flutter.plugins.GeneratedPluginRegistrant.registerWith(engine)

        FlutterEngineCache.getInstance().put(PAUSE_ENGINE_ID, engine)
    }

    companion object {
        const val PAUSE_ENGINE_ID = "pause_engine"
    }
}
