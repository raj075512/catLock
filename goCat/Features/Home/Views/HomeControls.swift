import SwiftUI

/// A duration chip on Home's glass panel.
///
/// Selected is a solid `primary` fill with white text; unselected is the
/// inner-chip glass treatment, which is brighter than the panel it sits on so
/// the chips don't dissolve into it.
struct DurationChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .foregroundStyle(isSelected ? .white : AppColors.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background {
                    Capsule(style: .continuous)
                        .fill(isSelected ? AnyShapeStyle(AppColors.primary)
                                         : AnyShapeStyle(.white.opacity(AppGlass.innerChipFill)))
                }
                .overlay {
                    Capsule(style: .continuous)
                        .strokeBorder(
                            isSelected ? .clear : .white.opacity(AppGlass.innerChipBorder),
                            lineWidth: 1
                        )
                }
                .contentShape(Capsule(style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

/// Sounds · Room · Tasks. Secondary to Start Focus in every dimension —
/// smaller type, quieter fill — because they are adjustments, not the action.
struct QuickActionPill: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.small) {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .medium))

                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(AppColors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppSpacing.small)
            .padding(.horizontal, AppSpacing.small)
            .frame(minHeight: AppLayout.minimumTapTarget)
            .background {
                Capsule(style: .continuous)
                    .fill(.white.opacity(AppGlass.innerChipFill))
            }
            .overlay {
                Capsule(style: .continuous)
                    .strokeBorder(.white.opacity(AppGlass.innerChipBorder), lineWidth: 1)
            }
            .contentShape(Capsule(style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

/// The streak badge in Home's top-left.
///
/// Before the first completed session it reads "Day 1 starts here" over an
/// outlined flame, not "0 day streak" — a zero beside a flame reads as a score
/// already lost, which is exactly the tone this app avoids.
struct StreakPill: View {
    let streak: Int
    let hasEverCompleted: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            GlassPill {
                HStack(spacing: AppSpacing.small) {
                    Image(systemName: hasEverCompleted ? "flame.fill" : "flame")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(hasEverCompleted ? AppColors.secondary : AppColors.textSecondary)

                    Text(label)
                        .font(AppFonts.headline)
                        .foregroundStyle(hasEverCompleted ? AppColors.textPrimary : AppColors.textSecondary)
                        .contentTransition(.numericText())
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityHint("Opens Progress")
    }

    private var label: String {
        hasEverCompleted ? "\(streak) day streak" : "Day 1 starts here"
    }
}
