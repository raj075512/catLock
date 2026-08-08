import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState: AppState?
    @State private var viewModel = OnboardingViewModel()

    var body: some View {
        VStack {
            Spacer()

            currentPage
                .padding(AppSpacing.large)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }

    @ViewBuilder
    private var currentPage: some View {
        switch viewModel.currentStep {
        case .welcome:
            WelcomePage(onContinue: viewModel.advance)
        case .focusGoal:
            FocusGoalPage(onContinue: viewModel.advance)
        case .notifications:
            NotificationPermissionPage {
                Task {
                    _ = await NotificationManager.shared.requestAuthorization()
                    appState?.completeOnboarding()
                }
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AppState())
}
