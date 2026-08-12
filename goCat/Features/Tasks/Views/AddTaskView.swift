import SwiftData
import SwiftUI

/// Screen 24. One field, two buttons, nothing to configure.
///
/// The sheet is deliberately short so the keyboard takes most of the screen —
/// this is a typing screen, not a form. No date picker, no repeat, no notes.
struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title = ""
    @FocusState private var isFieldFocused: Bool

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canAdd: Bool { !trimmedTitle.isEmpty }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                TextField("What are you working on?", text: $title)
                    .font(AppFonts.body)
                    .foregroundStyle(AppColors.textPrimary)
                    .focused($isFieldFocused)
                    .submitLabel(.done)
                    .onSubmit { add() }
                    .padding(AppSpacing.medium)
                    .background(AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous)
                            .strokeBorder(AppColors.primary, lineWidth: 1.5)
                    }

                Text("Keep it small enough to finish in one session.")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, AppSpacing.medium)
            .padding(.top, AppSpacing.medium)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.background)
            .navigationTitle("New task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(AppFonts.body)
                        .foregroundStyle(AppColors.primary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add", action: add)
                        .font(AppFonts.headline)
                        .foregroundStyle(canAdd ? AppColors.primary : AppColors.textSecondary)
                        .disabled(!canAdd)
                }
            }
        }
        .onAppear { isFieldFocused = true }
    }

    private func add() {
        guard canAdd else { return }
        modelContext.insert(TaskItem(title: trimmedTitle))
        HapticManager.shared.selection()
        dismiss()
    }
}

#Preview {
    AddTaskView()
        .modelContainer(AppModelContainer.inMemory())
}
