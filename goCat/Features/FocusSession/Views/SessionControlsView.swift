import SwiftUI

struct SessionControlsView: View {
    let state: FocusSessionState
    let onStart: () -> Void
    let onPause: () -> Void
    let onComplete: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.medium) {
            IconButton(
                systemImage: state == .running ? "pause.fill" : "play.fill",
                accessibilityTitle: state == .running ? "Pause" : "Start",
                action: state == .running ? onPause : onStart
            )

            IconButton(
                systemImage: "checkmark",
                accessibilityTitle: "Complete",
                action: onComplete
            )
        }
    }
}
