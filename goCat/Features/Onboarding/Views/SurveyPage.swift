import SwiftUI

/// The shared layout for survey screens 3–7.
///
/// Back chevron and Skip on one row, then a five-segment progress bar, then a
/// Title-24 question and full-width answer rows. Selecting a row tints it and
/// advances after ~180ms — no Continue button anywhere in the survey.
struct SurveyPage<Option: Hashable>: View {
    let question: String
    var caption: String?
    let options: [Option]
    let label: (Option) -> String
    /// Answers given, 0–5. Drives the bar, which reflects answers rather than
    /// screens seen.
    let answeredCount: Int
    let onBack: () -> Void
    let onSkip: () -> Void
    let onSelect: (Option) -> Void

    @State private var pendingSelection: Option?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            progressBar
            questionBlock
            answers
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppColors.background)
    }

    private var header: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: AppSpacing.xLarge, height: AppSpacing.xLarge)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Back")

            Spacer()

            Button("Skip", action: onSkip)
                .font(AppFonts.body)
                .foregroundStyle(AppColors.textSecondary)
        }
        .padding(.horizontal, AppSpacing.medium)
        .padding(.top, AppSpacing.small)
        .padding(.bottom, AppSpacing.medium)
        .frame(minHeight: AppLayout.minimumTapTarget)
    }

    private var progressBar: some View {
        HStack(spacing: AppSpacing.xSmall) {
            ForEach(0..<5, id: \.self) { index in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(index < answeredCount ? AppColors.accent : AppColors.elevatedSurface)
                    .frame(height: 5)
            }
        }
        .padding(.horizontal, AppSpacing.medium)
        .accessibilityElement()
        .accessibilityLabel("Question \(min(answeredCount + 1, 5)) of 5")
    }

    private var questionBlock: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(question)
                .font(AppFonts.title)
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            if let caption {
                Text(caption)
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.top, AppSpacing.xLarge)
        .padding(.horizontal, AppSpacing.large)
        .padding(.bottom, AppSpacing.large)
    }

    private var answers: some View {
        VStack(spacing: AppSpacing.small) {
            ForEach(options, id: \.self) { option in
                OptionRow(
                    title: label(option),
                    isSelected: pendingSelection == option,
                    trailing: {
                        if pendingSelection == option {
                            SelectionDot()
                        }
                    },
                    action: { select(option) }
                )
            }
        }
        .padding(.horizontal, AppSpacing.medium)
    }

    /// Tint first, then move. Long enough to see which row was hit, short
    /// enough not to feel like a wait.
    private func select(_ option: Option) {
        guard pendingSelection == nil else { return }
        withAnimation(AppAnimation.surveyAdvance) { pendingSelection = option }
        HapticManager.shared.selection()

        Task {
            try? await Task.sleep(for: .milliseconds(180))
            onSelect(option)
            pendingSelection = nil
        }
    }
}
