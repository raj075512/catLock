import Foundation

#if os(iOS)
import UIKit
#endif

/// Every haptic in the app goes through here so the Accessibility toggle has
/// exactly one thing to switch off. Turning haptics off silences the
/// completion tap; the trophy screen still appears — feedback is never the
/// only way the app says something happened.
@MainActor
final class HapticManager {
    static let shared = HapticManager()

    private init() {}

    private var isEnabled: Bool { AppState.shared.haptics }

    func impact(_ style: HapticStyle = .medium) {
#if os(iOS)
        guard isEnabled else { return }
        UIImpactFeedbackGenerator(style: style.uiImpactFeedbackStyle).impactOccurred()
#endif
    }

    /// Light tick for picking between equivalent options (e.g. session length).
    func selection() {
#if os(iOS)
        guard isEnabled else { return }
        UISelectionFeedbackGenerator().selectionChanged()
#endif
    }

    func success() {
#if os(iOS)
        guard isEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
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
