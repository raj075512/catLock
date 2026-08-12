import SwiftUI

/// Screen 28. Version and legal, in one place, two taps from Home.
///
/// Both legal links are App Review requirements and open in an in-app Safari
/// view. Rate and Contact support are additions beyond the brief: a paid app
/// with no support route fails review in practice.
struct AboutView: View {
    @Environment(\.openURL) private var openURL

    private var version: String {
        let short = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(short) (\(build))"
    }

    var body: some View {
        PushedScreen(title: "About") {
            VStack(spacing: AppSpacing.large) {
                VStack(spacing: AppSpacing.small) {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppColors.elevatedSurface)
                        .frame(width: 80, height: 80)
                        .overlay {
                            Image(systemName: "cat.fill")
                                .font(.system(size: 34))
                                .foregroundStyle(AppColors.primary)
                        }
                        .accessibilityHidden(true)

                    Text("catLock")
                        .font(AppFonts.title)
                        .foregroundStyle(AppColors.textPrimary)

                    Text(version)
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.textSecondary)

                    Text("A focus timer you can't pause, with a cat who waits it out with you.")
                        .font(AppFonts.body)
                        .foregroundStyle(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, AppSpacing.small)
                }
                .padding(.top, AppSpacing.large)

                SettingsGroup {
                    SettingsRow(title: "Privacy Policy", isExternalLink: true) {
                        open("https://catlock.app/privacy")
                    }
                    RowDivider()
                    SettingsRow(title: "Terms of Use", isExternalLink: true) {
                        open("https://catlock.app/terms")
                    }
                    RowDivider()
                    SettingsRow(title: "Licences") {}
                }

                SettingsGroup {
                    SettingsRow(title: "Rate catLock", isExternalLink: true) {
                        open("https://apps.apple.com/app/id0000000000?action=write-review")
                    }
                    RowDivider()
                    SettingsRow(title: "Contact support", isExternalLink: true) {
                        open("mailto:support@catlock.app")
                    }
                }

                Text("Cat and chair animated by hand. No analytics SDKs.")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, AppSpacing.xSmall)
            }
        }
    }

    private func open(_ string: String) {
        guard let url = URL(string: string) else { return }
        openURL(url)
    }
}

#Preview {
    NavigationStack { AboutView() }
}
