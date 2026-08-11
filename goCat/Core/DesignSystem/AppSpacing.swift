import Foundation

/// The whole scale. Nothing between these values — if a gap needs 20, one of
/// the two neighbours is wrong.
enum AppSpacing {
    static let xSmall: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let xLarge: CGFloat = 32
}

/// Fixed positions that aren't spacing between two things, so they don't
/// belong on the 4/8/16/24/32 scale.
enum AppLayout {
    /// Glass panels sit 16 from each side edge and 40 from the bottom.
    static let glassSideInset: CGFloat = AppSpacing.medium
    static let glassBottomInset: CGFloat = 40

    /// Minimum hit target anywhere in the app.
    static let minimumTapTarget: CGFloat = 44

    /// The overflow circle and the survey back chevron.
    static let circleButton: CGFloat = 40

    /// Sheet grabber, 40 × 5.
    static let grabberWidth: CGFloat = 40
    static let grabberHeight: CGFloat = 5
}
