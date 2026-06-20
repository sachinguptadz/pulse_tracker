package com.pulsetrack.app

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlin.coroutines.resume

class SyncWorker(appContext: Context, params: WorkerParameters) : CoroutineWorker(appContext, params) {
    override suspend fun doWork(): Result {
        val engine = FlutterEngine(applicationContext)
        GeneratedPluginRegistrant.registerWith(engine)
        engine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())
        val ok = suspendCancellableCoroutine { cont ->
            MethodChannel(engine.dartExecutor.binaryMessenger, "pulsetrack/background").invokeMethod("syncOverdueHabits", null, object : MethodChannel.Result {
                override fun success(result: Any?) { cont.resume(true) }
                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) { cont.resume(false) }
                override fun notImplemented() { cont.resume(false) }
            })
        }
        engine.destroy()
        return if (ok) Result.success() else Result.retry()
    }
}
