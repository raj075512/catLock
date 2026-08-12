import SwiftUI

/// The full-width selectable row shared by the onboarding survey and the
/// Sounds sheet: `surface` fill, hairline border, radius 12, 16 padding.
///
/// Selected state is a 1.5pt `primary` border over an 8% `primary` tint. The
/// heavier border is what carries the selection — the tint alone is too quiet
/// to read at a glance, and colour alone would fail for anyone who can't
/// distinguish it.
struct OptionRow<Trailing: View>: View {
    let title: String
    var subtitle: String?
    var systemImage: String?
    var isSelected: Bool = false
    /// Locked rows sit at 62% and open the paywall instead of selecting.
    var isLocked: Bool = false
    @ViewBuilder var trailing: () -> Trailing
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.medium) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(isSelected ? AppColors.primary : AppColors.textSecondary)
                        .frame(width: 24, height: 24)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppFonts.body)
                        .foregroundStyle(AppColors.textPrimary)
                        .multilineTextAlignment(.leading)

                    if let subtitle {
                        Text(subtitle)
                            .font(AppFonts.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }

                Spacer(minLength: AppSpacing.small)

                trailing()

                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            .padding(AppSpacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                    .fill(isSelected ? AppColors.selectedRowTint : AppColors.surface)
            )
            .overlay {
                RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                    .strokeBorder(
                        isSelected ? AppColors.primary : AppColors.hairline,
                        lineWidth: isSelected ? 1.5 : 1
                    )
            }
            .opacity(isLocked ? 0.62 : 1)
            .contentShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .accessibilityHint(isLocked ? "Requires catLock Plus" : "")
    }
}

extension OptionRow where Trailing == EmptyView {
    init(
        title: String,
        subtitle: String? = nil,
        systemImage: String? = nil,
        isSelected: Bool = false,
        isLocked: Bool = false,
        action: @escaping () -> Void
    ) {
        self.init(
            title: title,
            subtitle: subtitle,
            systemImage: systemImage,
            isSelected: isSelected,
            isLocked: isLocked,
            trailing: { EmptyView() },
            action: action
        )
    }
}

/// The 20pt filled dot on a selected survey row.
struct SelectionDot: View {
    var body: some View {
        Circle()
            .fill(AppColors.primary)
            .frame(width: 20, height: 20)
    }
}
