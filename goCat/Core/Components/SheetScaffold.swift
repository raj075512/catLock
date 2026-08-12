import SwiftUI

/// Shared chrome for the presented sheets: `background` fill, a Title-24
/// heading beside a Done button, and an optional leading action.
///
/// Every sheet in the app uses this so the family reads as one surface. The
/// grabber comes from `.presentationDragIndicator(.visible)` at the
/// presentation site rather than being drawn here.
struct SheetScaffold<Content: View>: View {
    let title: String
    var subtitle: String?
    /// Sits between the title and Done — the Tasks sheet's `+`.
    var accessory: AnyView?
    /// Draws a hairline under the header. Tasks does; the rest don't.
    var showsHeaderDivider: Bool = false
    let onDone: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                HStack(alignment: .firstTextBaseline, spacing: AppSpacing.medium) {
                    Text(title)
                        .font(AppFonts.title)
                        .foregroundStyle(AppColors.textPrimary)

                    Spacer(minLength: AppSpacing.small)

                    if let accessory {
                        accessory
                    }

                    Button("Done", action: onDone)
                        .font(AppFonts.headline)
                        .foregroundStyle(AppColors.primary)
                }

                if let subtitle {
                    Text(subtitle)
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, AppSpacing.medium)
            .padding(.top, AppSpacing.large)
            .padding(.bottom, AppSpacing.medium)

            if showsHeaderDivider {
                Rectangle()
                    .fill(AppColors.hairline)
                    .frame(height: 1)
            }

            content()
        }
        .background(AppColors.background)
    }
}

/// A screen pushed *inside* a sheet's own navigation stack — About,
/// Accessibility. A chevron and a title, never a second sheet on top of the
/// first.
struct PushedScreen<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView {
            content()
                .padding(.horizontal, AppSpacing.medium)
                .padding(.bottom, AppSpacing.xLarge)
        }
        .background(AppColors.background)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
