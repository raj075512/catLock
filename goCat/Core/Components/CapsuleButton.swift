import SwiftUI

/// Every button in the app is a full capsule. What changes between them is
/// fill, and the fill is the hierarchy:
///
/// - `accent` starts something (Get started, Start Focus, Start focusing).
/// - `primary` confirms or continues (Sounds good, Got it, Add a task).
/// - `outlined` and `text` are escape routes, and are deliberately full size —
///   a decline that is small or grey is a dark pattern, and this app's
///   product rules forbid it.
struct CapsuleButton: View {
    enum Style {
        case accent
        case primary
        case outlined
        case text
        case danger
    }

    let title: String
    var systemImage: String?
    var style: Style = .accent
    var isEnabled: Bool = true
    var fillsWidth: Bool = true
    let action: () -> Void

    init(
        _ title: String,
        systemImage: String? = nil,
        style: Style = .accent,
        isEnabled: Bool = true,
        fillsWidth: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.isEnabled = isEnabled
        self.fillsWidth = fillsWidth
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.small) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 16, weight: .semibold))
                }
                Text(title)
                    .font(AppFonts.headline)
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: fillsWidth ? .infinity : nil)
            .padding(.horizontal, fillsWidth ? AppSpacing.medium : AppSpacing.large)
            .padding(.vertical, AppSpacing.medium)
            .background(Capsule(style: .continuous).fill(background))
            .overlay {
                if style == .outlined {
                    Capsule(style: .continuous)
                        .strokeBorder(AppColors.primary, lineWidth: 1.5)
                }
            }
            .contentShape(Capsule(style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(title)
    }

    private var foreground: Color {
        guard isEnabled else { return AppColors.textSecondary }
        switch style {
        case .accent, .primary: return .white
        case .outlined, .text: return AppColors.primary
        case .danger: return .white
        }
    }

    private var background: Color {
        guard isEnabled else { return AppColors.elevatedSurface }
        switch style {
        case .accent: return AppColors.accent
        case .primary: return AppColors.primary
        case .danger: return AppColors.danger
        case .outlined, .text: return .clear
        }
    }
}
