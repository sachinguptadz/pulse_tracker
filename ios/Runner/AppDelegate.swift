import BackgroundTasks
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        registerPulseChannels()
        BackgroundTaskHandler.register()
        if let url = launchOptions?[.url] as? URL {
            DeepLinkChannel.shared.receive(url)
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func registerPulseChannels() {
        guard let nativeRegistrar = self.registrar(forPlugin: "PulseTrackNativeChannels") else {
            return
        }

        let messenger = nativeRegistrar.messenger()
        HapticChannel.register(with: messenger)
        FontScaleEventChannel.register(with: messenger)
        DeepLinkChannel.register(with: messenger)

        let syncChannel = FlutterMethodChannel(name: "pulsetrack/sync_native", binaryMessenger: messenger)
        syncChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            if call.method == "schedule" {
                BackgroundTaskHandler.schedule()
                result(nil as Any?)
            } else if call.method == "flushBadge" {
                result(nil as Any?)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }

    override func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        DeepLinkChannel.shared.receive(url)
        return true
    }

    override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let url = userActivity.webpageURL {
            DeepLinkChannel.shared.receive(url)
            return true
        }
        return false
    }
}

final class HapticChannel {
    static func register(with messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(name: "pulsetrack/haptic", binaryMessenger: messenger)
        channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard call.method == "play" else {
                result(FlutterMethodNotImplemented)
                return
            }
            let args = call.arguments as? [String: Any]
            let pattern = args?["pattern"] as? String ?? "light"
            play(pattern)
            result(nil as Any?)
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

final class FontScaleEventChannel: NSObject, FlutterStreamHandler {
    private var sink: FlutterEventSink?
    private static let shared = FontScaleEventChannel()

    static func register(with messenger: FlutterBinaryMessenger) {
        let channel = FlutterEventChannel(name: "pulsetrack/font_scale", binaryMessenger: messenger)
        channel.setStreamHandler(shared)
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

final class DeepLinkChannel: NSObject, FlutterStreamHandler {
    static let shared = DeepLinkChannel()
    private var sink: FlutterEventSink?
    private var initialLink: String?

    static func register(with messenger: FlutterBinaryMessenger) {
        let events = FlutterEventChannel(name: "pulsetrack/deep_links", binaryMessenger: messenger)
        events.setStreamHandler(shared)
        let methods = FlutterMethodChannel(name: "pulsetrack/deep_link_method", binaryMessenger: messenger)
        methods.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
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

final class BackgroundTaskHandler {
    static let identifier = "app.pulsetrack.refresh"
    private static var engine: FlutterEngine?

    static func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: identifier, using: nil as DispatchQueue?) { task in
            guard let task = task as? BGAppRefreshTask else {
                task.setTaskCompleted(success: false)
                return
            }
            handle(task)
        }
    }

    static func schedule() {
        let request = BGAppRefreshTaskRequest(identifier: identifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {}
    }

    private static func handle(_ task: BGAppRefreshTask) {
        schedule()
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        queue.addOperation {
            let flutterEngine = FlutterEngine(name: "PulseTrackBackgroundEngine")
            flutterEngine.run()
            GeneratedPluginRegistrant.register(with: flutterEngine)
            engine = flutterEngine
            let channel = FlutterMethodChannel(name: "pulsetrack/background", binaryMessenger: flutterEngine.binaryMessenger)
            channel.invokeMethod("syncOverdueHabits", arguments: nil as Any?) { _ in
                task.setTaskCompleted(success: true)
            }
        }
    }
}
