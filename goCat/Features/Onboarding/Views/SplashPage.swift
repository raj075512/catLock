import Combine
import SwiftUI

/// Screen 1. Cold-start frame: the wordmark over the first video frame, so
/// launch and screen 2 are visually continuous.
///
/// No spinner unless load exceeds a second, and then only a 3-dot pulse.
struct SplashPage: View {
    let onReady: () -> Void

    @State private var isSlowToLoad = false

    private var state: AppState { AppState.shared }

    var body: some View {
        ZStack {
            CatSceneBackground(room: state.selectedRoom, playback: .once)

            VStack(spacing: AppSpacing.large) {
                Text("catLock")
                    .largeTitleTracking()
                    .foregroundStyle(.white)

                if isSlowToLoad {
                    LoadingDots()
                }
            }
        }
        .preferredColorScheme(.light)
        .task {
            try? await Task.sleep(for: .seconds(1))
            withAnimation(AppAnimation.standard) { isSlowToLoad = true }
            try? await Task.sleep(for: .milliseconds(400))
            onReady()
        }
    }
}

/// The only loading indicator in the app, and only past one second.
struct LoadingDots: View {
    @State private var activeIndex = 0

    private let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: AppSpacing.small) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(AppColors.textSecondary)
                    .frame(width: 6, height: 6)
                    .opacity(activeIndex == index ? 1 : 0.35)
            }
        }
        .padding(.top, AppSpacing.large)
        .onReceive(timer) { _ in
            activeIndex = (activeIndex + 1) % 3
        }
        .accessibilityLabel("Loading")
    }
}

#Preview {
    SplashPage {}
}
