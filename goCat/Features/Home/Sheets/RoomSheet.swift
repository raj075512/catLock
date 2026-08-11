import SwiftUI

/// Screen 21. The only visual customisation in the app.
///
/// Rule 5, restated in the subhead so the absence reads as intent rather than
/// as a feature nobody finished: **same cat, same chair.** No collar, no hat,
/// no colour, no breed — not now and not later. Selecting a room swaps Home's
/// video immediately behind the sheet, so the choice is visible before Done.
struct RoomSheet: View {
    @Environment(\.dismiss) private var dismiss

    private var state: AppState { AppState.shared }

    private let columns = [
        GridItem(.flexible(), spacing: AppSpacing.medium),
        GridItem(.flexible(), spacing: AppSpacing.medium)
    ]

    var body: some View {
        SheetScaffold(
            title: "Room",
            subtitle: "Same cat, same chair. Different room.",
            onDone: { dismiss() }
        ) {
            ScrollView {
                LazyVGrid(columns: columns, spacing: AppSpacing.medium) {
                    ForEach(RoomOption.options) { room in
                        roomCell(room)
                    }
                }
                .padding(.horizontal, AppSpacing.medium)
                .padding(.bottom, AppSpacing.xLarge)
            }
        }
    }

    private func roomCell(_ room: RoomOption) -> some View {
        let isSelected = state.selectedRoom.id == room.id

        return Button {
            guard !room.isPremium else {
                HapticManager.shared.selection()
                return
            }
            state.selectRoom(room)
            HapticManager.shared.selection()
        } label: {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                CatScenePoster(room: room)
                    .frame(height: 132)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                            .strokeBorder(
                                isSelected ? AppColors.primary : AppColors.hairline,
                                lineWidth: isSelected ? 2 : 1
                            )
                    }

                HStack(spacing: AppSpacing.xSmall) {
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppColors.primary)
                    }

                    Text(room.name)
                        .font(AppFonts.caption)
                        .foregroundStyle(AppColors.textPrimary)
                        .lineLimit(1)

                    if room.isPremium {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
            .opacity(room.isPremium ? 0.62 : 1)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(room.name)
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        .accessibilityHint(room.isPremium ? "Requires catLock Plus" : "")
    }
}

#Preview {
    Color.gray.sheet(isPresented: .constant(true)) {
        RoomSheet().presentationDragIndicator(.visible)
    }
}
