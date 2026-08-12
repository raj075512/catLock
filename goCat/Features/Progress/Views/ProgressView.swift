import SwiftData
import SwiftUI

/// Screens 25 and 26. Answers three questions in descending order of how
/// often they get asked: what's my streak, what did I do today, is this week
/// normal.
///
/// The empty state keeps all four blocks in the same places so nothing
/// restructures once data arrives — the shape teaches what will fill it.
struct FocusProgressView: View {
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \CompletedSession.endedAt, order: .reverse) private var sessions: [CompletedSession]

    private var streakStore: StreakStore { StreakStore.shared }

    /// Dismisses the sheet and starts a session at Home's selected length.
    var onStartSession: () -> Void

    private var summary: ProgressSummary { ProgressSummary(sessions: sessions) }
    private var isEmpty: Bool { sessions.isEmpty }

    var body: some View {
        SheetScaffold(title: "Progress", onDone: { dismiss() }) {
            ScrollView {
                VStack(spacing: AppSpacing.medium) {
                    streakCard
                    statCards
                    weeklyChart

                    if isEmpty {
                        emptyFooter
                    } else {
                        recentList
                    }
                }
                .padding(.horizontal, AppSpacing.medium)
                .padding(.bottom, AppSpacing.xLarge)
            }
        }
    }

    // MARK: - Streak

    private var streakCard: some View {
        ProgressCard {
            if streakStore.hasEverCompleted {
                HStack(spacing: AppSpacing.medium) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 34))
                        .foregroundStyle(AppColors.secondary)

                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(streakStore.currentStreak)")
                            .font(AppFonts.display)
                            .foregroundStyle(AppColors.textPrimary)

                        Text("day streak · best is \(streakStore.bestStreak)")
                            .font(AppFonts.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }

                    Spacer(minLength: 0)
                }
            } else {
                // No zero here. The card explains the rule instead — and says
                // plainly that cancelling never breaks it.
                HStack(spacing: AppSpacing.medium) {
                    Image(systemName: "flame")
                        .font(.system(size: 34))
                        .foregroundStyle(AppColors.disabled)

                    VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                        Text("No streak yet")
                            .font(AppFonts.title)
                            .foregroundStyle(AppColors.textPrimary)

                        Text("One finished session starts it. Cancelling never breaks it.")
                            .font(AppFonts.caption)
                            .foregroundStyle(AppColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }
            }
        }
    }

    // MARK: - Today

    private var statCards: some View {
        HStack(spacing: AppSpacing.medium) {
            StatCard(
                value: isEmpty ? nil : "\(summary.minutesToday)",
                label: "minutes today"
            )
            StatCard(
                value: isEmpty ? nil : "\(summary.sessionsToday)",
                label: "sessions today"
            )
        }
    }

    // MARK: - This week

    private var weeklyChart: some View {
        ProgressCard {
            VStack(alignment: .leading, spacing: AppSpacing.medium) {
                Text(isEmpty ? "This week" : "This week · \(summary.formattedWeekTotal)")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)

                let peak = max(summary.weekMinutes.max() ?? 0, 1)
                let initials = ProgressSummary.weekdayInitials()

                HStack(alignment: .bottom, spacing: AppSpacing.small) {
                    ForEach(0..<7, id: \.self) { index in
                        VStack(spacing: AppSpacing.small) {
                            ZStack(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: AppCornerRadius.small, style: .continuous)
                                    .fill(AppColors.elevatedSurface)
                                    .frame(height: 80)

                                RoundedRectangle(cornerRadius: AppCornerRadius.small, style: .continuous)
                                    .fill(AppColors.accent)
                                    .frame(height: 80 * CGFloat(summary.weekMinutes[index]) / CGFloat(peak))
                            }

                            Text(initials[index])
                                .font(AppFonts.caption)
                                .fontWeight(index == summary.todayIndex ? .bold : .medium)
                                .foregroundStyle(
                                    index == summary.todayIndex
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary
                                )
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                // Bars are not tappable: no drill-down, no date range picker,
                // no export in v1.
                .accessibilityHidden(true)
            }
        }
    }

    // MARK: - Recent

    private var recentList: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text("Recent")
                .font(AppFonts.headline)
                .foregroundStyle(AppColors.textPrimary)
                .padding(.horizontal, AppSpacing.xSmall)
                .padding(.top, AppSpacing.small)

            SettingsGroup {
                ForEach(Array(sessions.prefix(3).enumerated()), id: \.element.id) { index, session in
                    HStack {
                        Text("\(session.minutes) min · \(session.soundName ?? "Silence")")
                            .font(AppFonts.body)
                            .foregroundStyle(AppColors.textPrimary)

                        Spacer(minLength: AppSpacing.small)

                        Text(session.endedAt.formatted(.relative(presentation: .named)))
                            .font(AppFonts.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                    .padding(AppSpacing.medium)

                    if index < min(sessions.count, 3) - 1 {
                        RowDivider()
                    }
                }
            }
        }
    }

    private var emptyFooter: some View {
        VStack(spacing: AppSpacing.medium) {
            Text("Your first session will show up here.")
                .font(AppFonts.body)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)

            CapsuleButton("Start one now", style: .accent, fillsWidth: false) {
                onStartSession()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.large)
        .background(AppColors.elevatedSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
    }
}

/// A `surface` card with a hairline border — the Progress sheet's one shape.
struct ProgressCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(AppSpacing.large)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                    .strokeBorder(AppColors.hairline, lineWidth: 1)
            }
    }
}

/// "75 / minutes today". A `nil` value shows an em dash, not a zero —
/// "0 minutes" reads as a failed day, "—" reads as "not yet".
struct StatCard: View {
    let value: String?
    let label: String

    var body: some View {
        ProgressCard {
            VStack(alignment: .leading, spacing: AppSpacing.xSmall) {
                Text(value ?? "—")
                    .font(AppFonts.title)
                    .foregroundStyle(value == nil ? AppColors.disabled : AppColors.textPrimary)

                Text(label)
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(value == nil ? "No \(label) yet" : "\(value ?? "") \(label)")
    }
}

#Preview {
    FocusProgressView {}
        .modelContainer(AppModelContainer.inMemory())
}
