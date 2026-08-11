import SwiftUI

/// A grouped list block: `surface` fill, 1pt hairline border, radius 12, with
/// hairline dividers between rows. Groups are separated by 24.
///
/// Hand-rolled rather than a `List` with `.insetGrouped`, because the spec
/// pins the fill, border and divider colours to the app's own tokens and the
/// system style tints them differently.
struct SettingsGroup<Content: View>: View {
    var footer: String?
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            VStack(spacing: 0) {
                content()
            }
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                    .strokeBorder(AppColors.hairline, lineWidth: 1)
            }

            if let footer {
                Text(footer)
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, AppSpacing.xSmall)
            }
        }
    }
}

/// One row in a `SettingsGroup`. `value` is the grey text on the right —
/// "Free", "Rain", "Follows iOS".
struct SettingsRow: View {
    let title: String
    var value: String?
    var systemImage: String?
    var showsChevron: Bool = true
    var isExternalLink: Bool = false
    var tint: Color = AppColors.textPrimary
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.medium) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppColors.primary)
                        .frame(width: 24, height: 24)
                }

                Text(title)
                    .font(AppFonts.body)
                    .foregroundStyle(tint)

                Spacer(minLength: AppSpacing.small)

                if let value {
                    Text(value)
                        .font(AppFonts.body)
                        .foregroundStyle(AppColors.textSecondary)
                }

                if isExternalLink {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppColors.textSecondary)
                } else if showsChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(AppColors.disabled)
                }
            }
            .padding(AppSpacing.medium)
            .frame(minHeight: AppLayout.minimumTapTarget)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

/// A row whose control is a toggle rather than a chevron.
struct SettingsToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: AppSpacing.medium) {
            Text(title)
                .font(AppFonts.body)
                .foregroundStyle(AppColors.textPrimary)

            Spacer(minLength: AppSpacing.small)

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(AppColors.accent)
        }
        .padding(AppSpacing.medium)
        .frame(minHeight: AppLayout.minimumTapTarget)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
    }
}

/// The hairline between two rows in a group.
struct RowDivider: View {
    var body: some View {
        Rectangle()
            .fill(AppColors.hairline)
            .frame(height: 1)
            .padding(.leading, AppSpacing.medium)
    }
}
