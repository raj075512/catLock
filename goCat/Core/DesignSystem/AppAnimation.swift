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

    /// A survey row tints, then the flow moves on. Long enough to see which
    /// row was hit, short enough not to feel like a wait.
    static let surveyAdvance = Animation.easeOut(duration: 0.18)
    static let surveyAdvanceDelay: Double = 0.18

    /// The session strip growing into an end-state panel, radius 26 → 32.
    static let panelGrow = Animation.easeOut(duration: 0.3)

    /// The streak pill counting 7 → 8 as the completion screen arrives.
    static let streakCountUp = Animation.easeOut(duration: 0.4)

    /// The final-minute hairline crossing the strip. Linear because it is a
    /// clock: any easing would make it lie about how much time is left.
    static let finalMinuteSweep = Animation.linear(duration: 60)
}
