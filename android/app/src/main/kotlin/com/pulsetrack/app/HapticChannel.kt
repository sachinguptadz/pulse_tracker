package com.pulsetrack.app

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

class HapticChannel {
    fun register(messenger: BinaryMessenger, context: Context) {
        MethodChannel(messenger, "pulsetrack/haptic").setMethodCallHandler { call, result ->
            if (call.method != "play") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val pattern = call.argument<String>("pattern") ?: "light"
            play(context, pattern)
            result.success(null)
        }
    }

    private fun play(context: Context, pattern: String) {
        val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val manager = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            manager.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }
        val timings = when (pattern) {
            "success" -> longArrayOf(0, 18, 42, 34, 70, 50)
            "error" -> longArrayOf(0, 55, 35, 55, 35, 70)
            else -> longArrayOf(0, 20)
        }
        val amplitudes = when (pattern) {
            "success" -> intArrayOf(0, 70, 0, 130, 0, 210)
            "error" -> intArrayOf(0, 230, 0, 180, 0, 230)
            else -> intArrayOf(0, 70)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(VibrationEffect.createWaveform(timings, amplitudes, -1))
        } else {
            @Suppress("DEPRECATION")
            vibrator.vibrate(timings, -1)
        }
    }
}
