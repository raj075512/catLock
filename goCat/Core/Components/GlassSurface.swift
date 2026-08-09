import SwiftUI

/// Frosted-glass surfaces used by the landing screen, which sits directly on
/// top of the full-bleed cat scene. These read as translucent panels floating
/// over the artwork rather than opaque cards, so the room stays visible behind
/// the controls.
///
/// Kept in `Core/Components/` (not inline in the feature) because the same
/// treatment is reused by the active-session overlay.
struct GlassSurface<Content: View>: View {
    var cornerRadius: CGFloat = 28
    var tint: Color = .white.opacity(0.18)
    var borderOpacity: Double = 0.35
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(tint)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(.white.opacity(borderOpacity), lineWidth: 0.8)
                    }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

/// A compact frosted pill — used for the streak badge and the overflow button
/// in the landing screen's top bar.
struct GlassPill<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        GlassSurface(cornerRadius: 22, tint: .white.opacity(0.14)) {
            content()
                .padding(.horizontal, AppSpacing.medium)
                .padding(.vertical, 10)
        }
    }
}

/// A selectable duration chip (15 / 25 / 45 min, or Custom). The selected
/// chip brightens rather than changing shape, keeping the row visually calm.
struct DurationChip: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    init(minutes: Int, isSelected: Bool, action: @escaping () -> Void) {
        self.title = "\(minutes) min"
        self.systemImage = isSelected ? "clock" : "alarm"
        self.isSelected = isSelected
        self.action = action
    }

    init(title: String, systemImage: String, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.isSelected = isSelected
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .medium))

                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .foregroundStyle(AppColors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background {
                Capsule(style: .continuous)
                    .fill(.white.opacity(isSelected ? 0.55 : 0.16))
            }
            .overlay {
                Capsule(style: .continuous)
                    .strokeBorder(.white.opacity(isSelected ? 0.7 : 0.3), lineWidth: 0.8)
            }
            .contentShape(Capsule(style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

/// A secondary action pill in the bottom row (Sounds / Room / Tasks).
struct QuickActionPill: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 15, weight: .medium))

                Text(title)
                    .font(.system(size: 15, weight: .medium))
            }
            .foregroundStyle(AppColors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background {
                Capsule(style: .continuous)
                    .fill(.white.opacity(0.16))
            }
            .overlay {
                Capsule(style: .continuous)
                    .strokeBorder(.white.opacity(0.3), lineWidth: 0.8)
            }
            .contentShape(Capsule(style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
