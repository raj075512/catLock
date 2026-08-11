import Foundation

enum AppCornerRadius {
    static let small: CGFloat = 6
    static let medium: CGFloat = 8
    /// Cards, list groups, option rows — the workhorse radius.
    static let large: CGFloat = 12

    /// The session strip, the trial banner, and anything that grows into a panel.
    static let strip: CGFloat = 26
    /// The Home control panel, the end-state panels, and sheet tops.
    static let panel: CGFloat = 32

    /// Buttons and chips are full capsules. Use `Capsule()` directly where the
    /// shape is available; this exists for the places that need a number.
    static let capsule: CGFloat = 999
}
