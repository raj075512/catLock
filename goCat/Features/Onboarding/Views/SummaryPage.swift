import SwiftUI

/// Screen 8. Pays back the five questions with three concrete consequences,
/// each labelled with the answer that caused it.
///
/// Rows are read-only — all three are changeable later in Settings — and the
/// closing caption is the point of the whole screen: none of this left the
/// phone.
struct SummaryPage: View {
    let answers: SurveyAnswers
    let onContinue: () -> Void

    private var minutes: Int {
        answers.focusSpan?.defaultMinutes ?? 25
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            completedBar

            VStack(alignment: .leading, spacing: AppSpacing.small) {
                Text("\(minutes)-minute sessions it is.")
                    .largeTitleTracking()
                    .foregroundStyle(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Here's what your answers changed.")
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding(.top, AppSpacing.xLarge)
            .padding(.horizontal, AppSpacing.large)
            .padding(.bottom, AppSpacing.large)

            VStack(spacing: AppSpacing.small) {
                SummaryCard(
                    systemImage: "clock",
                    title: "Default length · \(minutes) min",
                    caption: fromAnswer
                )

                SummaryCard(
                    systemImage: "speaker.wave.2.fill",
                    title: "Sound · Rain",
                    caption: "Quietest option, for work sessions"
                )

                if let hardest = answers.hardestPart {
                    SummaryCard(
                        systemImage: "flag.fill",
                        title: hardest.summaryTitle,
                        caption: hardest.summaryCaption
                    )
                }
            }
            .padding(.horizontal, AppSpacing.medium)

            Spacer(minLength: AppSpacing.large)

            VStack(spacing: AppSpacing.small) {
                CapsuleButton("Sounds good", style: .primary, action: onContinue)

                Text("All of this stays on your phone.")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .padding(.horizontal, AppSpacing.medium)
            .padding(.bottom, AppSpacing.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppColors.background)
    }

    private var fromAnswer: String {
        guard let span = answers.focusSpan else { return "The default, since you skipped that one" }
        return "From \"\(span.label) before drifting\""
    }

    /// The bar is complete here — all five answered.
    private var completedBar: some View {
        HStack(spacing: AppSpacing.xSmall) {
            ForEach(0..<5, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(AppColors.accent)
                    .frame(height: 5)
            }
        }
        .padding(.horizontal, AppSpacing.medium)
        .padding(.top, AppSpacing.xLarge)
        .accessibilityHidden(true)
    }
}

struct SummaryCard: View {
    let systemImage: String
    let title: String
    let caption: String

    var body: some View {
        HStack(spacing: AppSpacing.medium) {
            RoundedRectangle(cornerRadius: AppCornerRadius.medium, style: .continuous)
                .fill(AppColors.elevatedSurface)
                .frame(width: AppSpacing.xLarge, height: AppSpacing.xLarge)
                .overlay {
                    Image(systemName: systemImage)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppColors.primary)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFonts.headline)
                    .foregroundStyle(AppColors.textPrimary)

                Text(caption)
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(AppSpacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                .strokeBorder(AppColors.hairline, lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    SummaryPage(
        answers: SurveyAnswers(
            source: .reddit,
            useCase: .work,
            focusSpan: .fifteenToTwentyFive,
            hardestPart: .gettingStarted,
            timeOfDay: .morning
        )
    ) {}
}
