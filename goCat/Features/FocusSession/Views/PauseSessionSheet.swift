import SwiftUI

struct PauseSessionSheet: View {
    let onResume: () -> Void
    let onEnd: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.large) {
            Text("Session paused")
                .font(AppFonts.title)

            PrimaryButton("Resume", systemImage: "play.fill", action: onResume)
            Button("End Session", action: onEnd)
                .buttonStyle(.bordered)
        }
        .padding(AppSpacing.large)
    }
}
