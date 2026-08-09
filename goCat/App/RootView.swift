import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState: AppState?

    var body: some View {
        Group {
            if appState?.preferences.hasCompletedOnboarding == true {
                // HomeView is the whole app surface — full-bleed scene with
                // everything reachable from its glass panel and overflow menu.
                // No tab bar, by design (see DESIGN.md, Information Architecture).
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
        .environment(AppState())
}
