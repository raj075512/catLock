import SwiftUI

/// Frosted panels that float over the full-bleed cat video.
///
/// Depth in this design comes from translucency and the scrim — there are no
/// shadows anywhere — so the fill opacity is doing real work and each surface
/// gets its own. The session strip is the most transparent of the three
/// because while a session runs the cat has to stay the brightest thing on
/// screen.
///
/// "Higher contrast panels" in Accessibility replaces all of it with an opaque
/// `surface` and a `textSecondary` border. A design built on translucency
/// needs an opaque escape hatch, and this is the single place that provides it.
struct GlassSurface<Content: View>: View {
    enum Style {
        /// Home's control panel and the end-state panels.
        case panel
        /// The session strip — lower opacity on purpose.
        case sessionStrip
        /// The trial-ending banner.
        case banner
        /// The streak pill and the overflow circle.
        case pill

        var fillOpacity: Double {
            switch self {
            case .panel: AppGlass.panelFill
            case .sessionStrip: AppGlass.sessionStripFill
            case .banner: AppGlass.bannerFill
            case .pill: AppGlass.panelFill
            }
        }
    }

    var cornerRadius: CGFloat = AppCornerRadius.panel
    var style: Style = .panel
    @ViewBuilder let content: () -> Content

    private var state: AppState { AppState.shared }

    init(
        cornerRadius: CGFloat = AppCornerRadius.panel,
        style: Style = .panel,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.style = style
        self.content = content
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    var body: some View {
        content()
            .background {
                if state.higherContrastPanels {
                    shape
                        .fill(AppColors.surface)
                        .overlay { shape.strokeBorder(AppColors.textSecondary, lineWidth: 1) }
                } else {
                    shape
                        .fill(.ultraThinMaterial)
                        .overlay { shape.fill(.white.opacity(style.fillOpacity)) }
                        .overlay {
                            shape.strokeBorder(
                                .white.opacity(AppGlass.borderOpacity),
                                lineWidth: 1
                            )
                        }
                }
            }
            .clipShape(shape)
    }
}

/// The streak pill and the overflow circle in Home's top bar.
struct GlassPill<Content: View>: View {
    var horizontalPadding: CGFloat = AppSpacing.medium
    var verticalPadding: CGFloat = 10
    @ViewBuilder let content: () -> Content

    var body: some View {
        GlassSurface(cornerRadius: AppCornerRadius.capsule, style: .pill) {
            content()
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
        }
    }
}
