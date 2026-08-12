import SwiftUI

struct RootView: View {
    private var state: AppState { AppState.shared }

    var body: some View {
        Group {
            if state.hasCompletedOnboarding {
                // Home is the whole app surface — everything else is a sheet
                // or lives behind the overflow menu. No tab bar, by design.
                HomeView()
            } else {
                OnboardingView()
            }
        }
        .background(AppColors.background)
    }
}

#Preview {
    RootView()
}
