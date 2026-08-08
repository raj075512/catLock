import Foundation
import UserNotifications

final class LocalNotificationService {
    static let shared = LocalNotificationService()

    private init() {}

    func scheduleFocusCompleteNotification(after seconds: TimeInterval) async throws {
        let content = UNMutableNotificationContent()
        content.title = "Focus complete"
        content.body = "Your focus session has finished."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(seconds, 1), repeats: false)
        let request = UNNotificationRequest(identifier: "focus-complete", content: content, trigger: trigger)
        try await UNUserNotificationCenter.current().add(request)
    }

    func cancelFocusNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["focus-complete"])
    }
}
