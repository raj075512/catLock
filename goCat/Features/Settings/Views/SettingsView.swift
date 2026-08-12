import SwiftUI

/// Screen 27.
///
/// Account and money first, because that is what people open Settings to
/// find. Everything else is one group below, and the list ends rather than
/// scrolling into filler.
///
/// Signed out is a complete, unnagged state: one row offering sync, no badge,
/// no red dot, no banner. Manage Subscription is deliberately *not* here — it
/// lives inside Plan & Billing so there is exactly one money surface.
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    private var state: AppState { AppState.shared }

    @State private var isShowingSounds = false

    var body: some View {
        NavigationStack {
            SheetScaffold(title: "Settings", onDone: { dismiss() }) {
                ScrollView {
                    VStack(spacing: AppSpacing.large) {
                        accountGroup
                        preferencesGroup
                        replayGroup

                        Text("catLock 1.0 · your data stays on this device")
                            .font(AppFonts.caption)
                            .foregroundStyle(AppColors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, AppSpacing.xSmall)
                    }
                    .padding(.horizontal, AppSpacing.medium)
                    .padding(.bottom, AppSpacing.xLarge)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: SettingsDestination.self) { destination in
                switch destination {
                case .about: AboutView()
                case .accessibility: AccessibilityView()
                }
            }
            .sheet(isPresented: $isShowingSounds) {
                SoundsSheet().presentationDragIndicator(.visible)
            }
        }
    }

    /// Accounts and subscriptions are designed (screens 33–43) but not built —
    /// there is no backend and StoreKit is not wired up. These rows state the
    /// real state rather than linking to screens that don't exist yet.
    private var accountGroup: some View {
        SettingsGroup {
            SettingsRow(
                title: "Sign in",
                value: nil,
                systemImage: "person.crop.circle",
                showsChevron: false
            ) {}
            .disabled(true)
            .opacity(0.5)

            RowDivider()

            SettingsRow(
                title: "Plan & Billing",
                value: "Free",
                showsChevron: false
            ) {}
            .disabled(true)
            .opacity(0.5)
        }
    }

    private var preferencesGroup: some View {
        SettingsGroup {
            SettingsRow(title: "Sounds", value: state.selectedSound?.name ?? "Silence") {
                isShowingSounds = true
            }

            RowDivider()

            NavigationLink(value: SettingsDestination.accessibility) {
                SettingsRowLabel(title: "Accessibility")
            }

            RowDivider()

            NavigationLink(value: SettingsDestination.about) {
                SettingsRowLabel(title: "About")
            }
        }
    }

    private var replayGroup: some View {
        SettingsGroup {
            SettingsRow(title: "Replay intro", showsChevron: false, tint: AppColors.primary) {
                state.replayIntro()
                dismiss()
            }
        }
    }
}

enum SettingsDestination: Hashable {
    case about
    case accessibility
}

/// The row body used inside a `NavigationLink`, which supplies its own tap
/// handling — so this is a label, not a button.
struct SettingsRowLabel: View {
    let title: String
    var value: String?

    var body: some View {
        HStack(spacing: AppSpacing.medium) {
            Text(title)
                .font(AppFonts.body)
                .foregroundStyle(AppColors.textPrimary)

            Spacer(minLength: AppSpacing.small)

            if let value {
                Text(value)
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppColors.disabled)
        }
        .padding(AppSpacing.medium)
        .frame(minHeight: AppLayout.minimumTapTarget)
        .contentShape(Rectangle())
    }
}

#Preview {
    SettingsView()
}
