import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState: AppState?

    var body: some View {
        Group {
            if appState?.preferences.hasCompletedOnboarding == true {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .background(AppColors.background)
    }
}

#Preview {
    RootView()
        .environment(AppState())
}
