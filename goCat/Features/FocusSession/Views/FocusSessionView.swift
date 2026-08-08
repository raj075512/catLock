import SwiftUI

struct FocusSessionView: View {
    @State private var viewModel = FocusSessionViewModel()

    var body: some View {
        VStack(spacing: AppSpacing.large) {
            if viewModel.session.state == .completed {
                SessionCompletedView()
            } else {
                SessionSceneView()
                SessionTimerView(timeText: viewModel.formattedRemainingTime)
                SessionControlsView(
                    state: viewModel.session.state,
                    onStart: viewModel.start,
                    onPause: viewModel.pause,
                    onComplete: viewModel.complete
                )
            }
        }
        .padding(AppSpacing.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}
