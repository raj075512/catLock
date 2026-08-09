import Foundation

#if os(iOS)
import UIKit
#endif

final class HapticManager {
    static let shared = HapticManager()

    private init() {}

    func impact(_ style: HapticStyle = .medium) {
#if os(iOS)
        UIImpactFeedbackGenerator(style: style.uiImpactFeedbackStyle).impactOccurred()
#endif
    }

    /// Light tick for picking between equivalent options (e.g. session length).
    func selection() {
#if os(iOS)
        UISelectionFeedbackGenerator().selectionChanged()
#endif
    }
}

enum HapticStyle {
    case light
    case medium
    case heavy

#if os(iOS)
    var uiImpactFeedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle {
        switch self {
        case .light:
            .light
        case .medium:
            .medium
        case .heavy:
            .heavy
        }
    }
#endif
}
