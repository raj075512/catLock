import SwiftUI

enum AppAnimation {
    static let quick = Animation.easeOut(duration: 0.18)
    static let standard = Animation.easeInOut(duration: 0.28)
    static let slow = Animation.easeInOut(duration: 0.45)

    /// Content arriving on screen for the first time. Springy enough to feel
    /// alive, damped enough not to wobble — used for the staggered onboarding
    /// rows and the primary button.
    static let entrance = Animation.spring(response: 0.55, dampingFraction: 0.82)

    /// Delay between staggered items so a list assembles rather than appearing
    /// all at once. Four rows finish in under half a second.
    static let staggerStep: Double = 0.08
}
