import SwiftUI

enum AppFonts {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 24, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 16, weight: .regular, design: .default)
    static let caption = Font.system(size: 13, weight: .medium, design: .default)

    /// The session countdown. Monospaced so the digits don't jitter as they
    /// count down — apply `.monospacedDigit()` at the call site too.
    static let countdown = Font.system(size: 32, weight: .bold, design: .rounded)

    /// The custom-duration ring value and the Progress streak number. The
    /// largest type in the app outside the paywall's price.
    static let display = Font.system(size: 44, weight: .bold, design: .rounded)
}

extension Text {
    /// Large title carries −0.5 tracking per the type scale.
    func largeTitleTracking() -> some View {
        self.font(AppFonts.largeTitle).tracking(-0.5)
    }
}
