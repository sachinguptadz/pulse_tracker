import Flutter
import UIKit

final class FontScaleEventChannel: NSObject, FlutterStreamHandler {
    private var sink: FlutterEventSink?

    static func register(with controller: FlutterViewController) {
        let channel = FlutterEventChannel(name: "pulsetrack/font_scale", binaryMessenger: controller.binaryMessenger)
        let handler = FontScaleEventChannel()
        channel.setStreamHandler(handler)
    }

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        emit()
        NotificationCenter.default.addObserver(self, selector: #selector(emit), name: UIContentSizeCategory.didChangeNotification, object: nil)
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self)
        sink = nil
        return nil
    }

    @objc private func emit() {
        let category = UIApplication.shared.preferredContentSizeCategory
        let value: Double
        switch category {
        case .extraSmall, .small, .medium, .large:
            value = 1.0
        case .extraLarge, .extraExtraLarge:
            value = 1.18
        default:
            value = 1.38
        }
        sink?(value)
    }
}
