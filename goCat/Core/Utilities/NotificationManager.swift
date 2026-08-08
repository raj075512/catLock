import Foundation
import OSLog
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            AppLogger.app.error("Notification authorization failed: \(error.localizedDescription)")
            return false
        }
    }
}
