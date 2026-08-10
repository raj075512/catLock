import SwiftUI

/// The screen immediately after the splash — the one the "Get Started" button
/// leads to. Full-bleed green field, four rows explaining the loop, one large
/// pill button.
///
/// It exists to set the expectation that a session **cannot be paused** before
/// the user meets that rule mid-session and reads it as a bug. Framed here it
/// is the product's whole premise; discovered later it is a complaint.
struct HowItWorksPage: View {
    let onContinue: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Drives the staggered entrance. Flipped once, on appear.
    @State private var hasAppeared = false

    private struct Step: Identifiable {
        let id = UUID()
        let symbol: String
        let title: String
        /// Shown as a small pill instead of an icon, like "New" in the
        /// reference. Only the first row uses it.
        let badge: String?

        init(symbol: String, title: String, badge: String? = nil) {
            self.symbol = symbol
            self.title = title
            self.badge = badge
        }
    }

    private let steps: [Step] = [
        Step(symbol: "clock", title: "Pick how long you'll focus", badge: "Start"),
        Step(symbol: "pawprint.fill", title: "Your cat settles in and stays with you"),
        Step(symbol: "lock.fill", title: "No pause, no going back — only cancel"),
        Step(symbol: "flame.fill", title: "Finish the session and grow your streak")
    ]

    var body: some View {
        ZStack {
            AppColors.onboardingBottom
                .ignoresSafeArea()

            LinearGradient(
                colors: [AppColors.onboardingTop, AppColors.onboardingBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.top, AppSpacing.xLarge)

                Spacer(minLength: AppSpacing.large)

                stepList

                Spacer(minLength: AppSpacing.large)

                continueButton
                    .padding(.bottom, AppSpacing.large)
            }
            .padding(.horizontal, AppSpacing.large)
        }
        .onAppear {
            guard !hasAppeared else { return }
            if reduceMotion {
                hasAppeared = true
            } else {
                withAnimation(AppAnimation.entrance) { hasAppeared = true }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: AppSpacing.small) {
            Text("How it works")
                .font(AppFonts.largeTitle)
                .foregroundStyle(AppColors.onOnboarding)
                .multilineTextAlignment(.center)

            Text("Takes about a minute")
                .font(AppFonts.body)
                .foregroundStyle(AppColors.onOnboardingMuted)
        }
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : -12)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    // MARK: - Steps

    private var stepList: some View {
        VStack(alignment: .leading, spacing: AppSpacing.large) {
            ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                stepRow(step)
                    .opacity(hasAppeared ? 1 : 0)
                    .offset(y: hasAppeared ? 0 : 24)
                    .animation(
                        reduceMotion
                            ? nil
                            : AppAnimation.entrance.delay(Double(index) * AppAnimation.staggerStep),
                        value: hasAppeared
                    )
            }
        }
    }

    private func stepRow(_ step: Step) -> some View {
        HStack(spacing: AppSpacing.medium) {
            badge(for: step)

            Text(step.title)
                .font(AppFonts.title)
                .foregroundStyle(AppColors.onOnboarding)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(step.title)
    }

    @ViewBuilder
    private func badge(for step: Step) -> some View {
        if let text = step.badge {
            Text(text)
                .font(AppFonts.headline)
                .foregroundStyle(AppColors.onboardingBottom)
                .padding(.horizontal, AppSpacing.medium)
                .padding(.vertical, AppSpacing.small)
                .background {
                    Capsule(style: .continuous)
                        .fill(AppColors.onOnboarding)
                }
                .frame(width: 76)
        } else {
            Image(systemName: step.symbol)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(AppColors.onOnboarding)
                .frame(width: 52, height: 52)
                .background {
                    RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                        .fill(AppColors.onOnboarding.opacity(0.18))
                }
                .frame(width: 76)
        }
    }

    // MARK: - Button

    private var continueButton: some View {
        Button(action: onContinue) {
            Text("Let's go")
                .font(.system(size: 19, weight: .semibold, design: .rounded))
                .foregroundStyle(AppColors.onboardingBottom)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background {
                    Capsule(style: .continuous)
                        .fill(AppColors.onOnboarding)
                }
                .contentShape(Capsule(style: .continuous))
        }
        .buttonStyle(PressableButtonStyle())
        .opacity(hasAppeared ? 1 : 0)
        .offset(y: hasAppeared ? 0 : 20)
        .animation(
            reduceMotion
                ? nil
                : AppAnimation.entrance.delay(Double(steps.count) * AppAnimation.staggerStep),
            value: hasAppeared
        )
        .accessibilityLabel("Let's go")
        .accessibilityHint("Continues to set up your first session")
    }
}

/// Shrinks slightly while held. The stock `.plain` style gives no feedback at
/// all on a large filled button, which makes it feel unresponsive.
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(AppAnimation.quick, value: configuration.isPressed)
    }
}

#Preview {
    HowItWorksPage {}
}
