import SwiftUI

struct CustomizationSummaryView: View {
    let scene: SceneOption
    let sound: SoundOption
    let action: (CustomizationSheet.Kind) -> Void

    var body: some View {
        VStack(spacing: AppSpacing.small) {
            customizationRow(title: "Room", value: scene.name, kind: .room)
            customizationRow(title: "Sound", value: sound.name, kind: .sound)
        }
        .cardSurface()
    }

    private func customizationRow(title: String, value: String, kind: CustomizationSheet.Kind) -> some View {
        Button {
            action(kind)
        } label: {
            HStack {
                Text(title)
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.textPrimary)

                Spacer()

                Text(value)
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppColors.textSecondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
