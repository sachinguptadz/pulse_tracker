import Flutter
import UIKit

final class HapticChannel {
    static func register(with controller: FlutterViewController) {
        let channel = FlutterMethodChannel(name: "pulsetrack/haptic", binaryMessenger: controller.binaryMessenger)
        channel.setMethodCallHandler { call, result in
            guard call.method == "play" else {
                result(FlutterMethodNotImplemented)
                return
            }
            let args = call.arguments as? [String: Any]
            let pattern = args?["pattern"] as? String ?? "light"
            play(pattern)
            result(nil)
        }
    }

    private static func play(_ pattern: String) {
        let timings: [TimeInterval]
        let styles: [UIImpactFeedbackGenerator.FeedbackStyle]
        switch pattern {
        case "success":
            timings = [0.0, 0.07, 0.16]
            styles = [.light, .medium, .heavy]
        case "error":
            timings = [0.0, 0.06, 0.12, 0.20]
            styles = [.heavy, .medium, .heavy, .heavy]
        default:
            timings = [0.0]
            styles = [.light]
        }
        for index in 0..<timings.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + timings[index]) {
                let generator = UIImpactFeedbackGenerator(style: styles[index])
                generator.prepare()
                generator.impactOccurred()
            }
        }
    }
}
