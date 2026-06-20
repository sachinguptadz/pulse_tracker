package com.pulsetrack.app

import android.content.Intent
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.TimeUnit

class MainActivity : FlutterFragmentActivity() {
    private val haptic = HapticChannel()
    private val fontScale by lazy { FontScaleEventChannel(this) }
    private val deepLink = DeepLinkChannel()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        haptic.register(flutterEngine.dartExecutor.binaryMessenger, this)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "pulsetrack/font_scale").setStreamHandler(fontScale)
        deepLink.register(flutterEngine.dartExecutor.binaryMessenger)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "pulsetrack/sync_native").setMethodCallHandler { call, result ->
            when (call.method) {
                "schedule" -> {
                    scheduleWork()
                    result.success(null)
                }
                "flushBadge" -> result.success(null)
                else -> result.notImplemented()
            }
        }
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
    }

    override fun onConfigurationChanged(newConfig: android.content.res.Configuration) {
        super.onConfigurationChanged(newConfig)
        fontScale.emit(newConfig.fontScale)
    }

    private fun handleIntent(intent: Intent?) {
        val uri = intent?.data?.toString() ?: return
        deepLink.receive(uri)
    }

    private fun scheduleWork() {
        val request = PeriodicWorkRequestBuilder<SyncWorker>(15, TimeUnit.MINUTES).build()
        WorkManager.getInstance(this).enqueueUniquePeriodicWork("pulsetrack-sync", ExistingPeriodicWorkPolicy.UPDATE, request)
    }
}
