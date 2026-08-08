import SwiftUI

extension View {
    func appAccessibilityLabel(_ label: String) -> some View {
        accessibilityLabel(Text(label))
    }

    func appAccessibilityHint(_ hint: String) -> some View {
        accessibilityHint(Text(hint))
    }
}
