import BackgroundTasks
import Flutter
import UIKit

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
