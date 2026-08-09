import SwiftUI

enum AppColors {
    static let background = Color(hex: "#F7F4EF")
    static let surface = Color(hex: "#FFFFFF")
    static let elevatedSurface = Color(hex: "#F0EEE8")
    static let primary = Color(hex: "#2F6F73")
    static let secondary = Color(hex: "#D98C5F")
    static let accent = Color(hex: "#6E8B58")
    static let textPrimary = Color(hex: "#1E2525")
    static let textSecondary = Color(hex: "#69706F")
    static let warning = Color(hex: "#B85C38")
    /// Reserved for the active-session countdown and the Cancel action —
    /// a clear red (distinct from `warning`'s burnt orange) so a running
    /// timer reads as urgent at a glance.
    static let danger = Color(hex: "#D14343")
}
