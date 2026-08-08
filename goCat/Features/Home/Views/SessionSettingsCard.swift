import SwiftUI

struct SessionSettingsCard: View {
    @Binding var duration: TimeInterval

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Text("Session")
                .font(AppFonts.headline)
                .foregroundStyle(AppColors.textPrimary)

            Stepper(value: durationMinutes, in: 5...120, step: 5) {
                Text("\(Int(duration / 60)) minutes")
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .cardSurface()
    }

    private var durationMinutes: Binding<Int> {
        Binding(
            get: { Int(duration / 60) },
            set: { duration = TimeInterval($0 * 60) }
        )
    }
}
