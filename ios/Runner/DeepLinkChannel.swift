import Flutter
import UIKit

final class DeepLinkChannel: NSObject, FlutterStreamHandler {
    static let shared = DeepLinkChannel()
    private var sink: FlutterEventSink?
    private var initialLink: String?

    static func register(with controller: FlutterViewController) {
        let events = FlutterEventChannel(name: "pulsetrack/deep_links", binaryMessenger: controller.binaryMessenger)
        events.setStreamHandler(shared)
        let methods = FlutterMethodChannel(name: "pulsetrack/deep_link_method", binaryMessenger: controller.binaryMessenger)
        methods.setMethodCallHandler { call, result in
            if call.method == "initialLink" {
                result(shared.initialLink)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }

    func receive(_ url: URL) {
        let value = url.absoluteString
        if initialLink == nil { initialLink = value }
        sink?(value)
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        if let initialLink { events(initialLink) }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        return nil
    }
}
