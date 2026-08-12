import SwiftUI

/// Screen 29. Three toggles and one hand-off.
///
/// Text size is deliberately *not* duplicated here — it lives in iOS Settings,
/// and this row says so rather than inventing a second source of truth that
/// can disagree with the system.
struct AccessibilityView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion

    private var state: AppState { AppState.shared }

    var body: some View {
        PushedScreen(title: "Accessibility") {
            VStack(spacing: AppSpacing.large) {
                SettingsGroup(
                    footer: "Reduce motion replaces the video with a still room. The timer still runs; the rocking is decoration, never information."
                ) {
                    SettingsToggleRow(
                        title: "Reduce motion",
                        isOn: Binding(
                            get: { state.prefersReducedMotion(system: systemReduceMotion) },
                            set: { state.setReduceMotion($0) }
                        )
                    )

                    RowDivider()

                    SettingsToggleRow(
                        title: "Haptics",
                        isOn: Binding(get: { state.haptics }, set: { state.setHaptics($0) })
                    )
                }

                SettingsGroup(
                    footer: "Higher contrast makes glass panels solid instead of translucent. catLock supports all iOS text sizes up to Accessibility XXXL."
                ) {
                    SettingsToggleRow(
                        title: "Higher contrast panels",
                        isOn: Binding(
                            get: { state.higherContrastPanels },
                            set: { state.setHigherContrastPanels($0) }
                        )
                    )

                    RowDivider()

                    SettingsRow(title: "Text size", value: "Follows iOS", showsChevron: false) {}

                    RowDivider()

                    SettingsRow(title: "Open iOS Settings", isExternalLink: true) {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            openURL(url)
                        }
                    }
                }
            }
            .padding(.top, AppSpacing.medium)
        }
    }
}

#Preview {
    NavigationStack { AccessibilityView() }
}
