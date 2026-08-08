import SwiftUI

struct TaskRowView: View {
    let task: FocusTask
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: AppSpacing.medium) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isCompleted ? AppColors.primary : AppColors.textSecondary)

                Text(task.title)
                    .font(AppFonts.body)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(AppColors.textPrimary)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(task.title)
    }
}
