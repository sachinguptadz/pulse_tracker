package com.pulsetrack.app

import android.content.Context
import io.flutter.plugin.common.EventChannel

class FontScaleEventChannel(private val context: Context) : EventChannel.StreamHandler {
    private var sink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
        emit(context.resources.configuration.fontScale)
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }

    fun emit(value: Float) {
        sink?.success(value.toDouble())
    }
}
