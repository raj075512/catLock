import Foundation

struct ProgressSummary: Codable, Hashable {
    var completedSessions: Int
    var totalFocusTime: TimeInterval
    var currentStreak: Int
    var weeklyFocusTime: TimeInterval

    var formattedTotalFocusTime: String {
        let hours = Int(totalFocusTime / 3600)
        let minutes = Int(totalFocusTime.truncatingRemainder(dividingBy: 3600) / 60)
        return "\(hours)h \(minutes)m"
    }

    static let sample = ProgressSummary(
        completedSessions: 12,
        totalFocusTime: 9 * 3600,
        currentStreak: 4,
        weeklyFocusTime: 3 * 3600
    )
}
