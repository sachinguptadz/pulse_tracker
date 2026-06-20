package com.pulsetrack.app

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class DeepLinkChannel : EventChannel.StreamHandler {
    private var sink: EventChannel.EventSink? = null
    private var initialLink: String? = null

    fun register(messenger: BinaryMessenger) {
        EventChannel(messenger, "pulsetrack/deep_links").setStreamHandler(this)
        MethodChannel(messenger, "pulsetrack/deep_link_method").setMethodCallHandler { call, result ->
            if (call.method == "initialLink") result.success(initialLink) else result.notImplemented()
        }
    }

    fun receive(uri: String) {
        if (initialLink == null) initialLink = uri
        sink?.success(uri)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
        initialLink?.let { events?.success(it) }
    }

    override fun onCancel(arguments: Any?) {
        sink = null
    }
}
