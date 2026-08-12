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

    // MARK: - Derived surfaces

    /// Hairline border on light surfaces — cards, list groups, dividers.
    static let hairline = Color(hex: "#E2DED5")

    /// Placeholder and disabled fills. Also the em dash in an empty stat card:
    /// "0 minutes" reads as a failed day, "—" reads as "not yet".
    static let disabled = Color(hex: "#C6C0B4")

    /// The grabber at the top of a presented sheet.
    static let grabber = Color(hex: "#D6D2C8")

    /// Dims the video behind a presented sheet.
    static let scrim = Color(red: 30 / 255, green: 37 / 255, blue: 37 / 255, opacity: 0.28)

    /// Selected row tint — primary at 8%, paired with a 1.5pt primary border.
    static let selectedRowTint = Color(hex: "#2F6F73").opacity(0.08)

    // MARK: - Onboarding

    /// Onboarding sits on a full-bleed green field rather than the app's warm
    /// off-white, so first-run reads as a distinct moment and the product
    /// proper feels like arriving somewhere calmer. Both tones are pulled
    /// toward `primary`/`accent` so it still belongs to the same palette.
    static let onboardingTop = Color(hex: "#4E8C63")
    static let onboardingBottom = Color(hex: "#22503C")

    /// Text and controls sitting on the onboarding field.
    static let onOnboarding = Color(hex: "#FFFFFF")
    static let onOnboardingMuted = Color(hex: "#D3E4D8")
}

/// Opacities for the frosted panels that float over the cat video.
///
/// The session strip is deliberately the most transparent of the three: while
/// a session runs the cat has to stay the brightest thing on screen, and the
/// countdown is the only thing competing with it.
enum AppGlass {
    static let panelFill: Double = 0.72
    static let sessionStripFill: Double = 0.55
    static let bannerFill: Double = 0.86

    /// Chips sitting *on* a glass panel, which would otherwise disappear into it.
    static let innerChipFill: Double = 0.5
    static let innerChipBorder: Double = 0.6

    static let borderOpacity: Double = 0.35
}
