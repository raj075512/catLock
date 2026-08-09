import SwiftUI

struct FocusProgressView: View {
    @State private var viewModel = ProgressViewModel()

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.large) {
                    WeeklySummaryView(summary: viewModel.summary)
                    StreakView(streak: viewModel.summary.currentStreak)
                    FocusHistoryView(sessions: viewModel.sessions)
                }
                .padding(AppSpacing.medium)
            }
            .background(AppColors.background)
            .navigationTitle("Progress")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
