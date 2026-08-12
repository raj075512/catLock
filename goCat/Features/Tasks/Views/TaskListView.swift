import SwiftData
import SwiftUI

/// Screens 22 and 23. A scratchpad for "what am I doing in this session",
/// not a task manager.
///
/// No due dates, no priorities, no projects, no reminders — anything more and
/// it starts competing with the timer, which is the one thing this screen must
/// not do. Tasks are hidden during a session (rule 2), so this is a
/// before-and-after surface.
struct TaskListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \TaskItem.createdAt, order: .reverse) private var tasks: [TaskItem]

    @State private var isAddingTask = false

    var body: some View {
        SheetScaffold(
            title: "Tasks",
            accessory: AnyView(addButton),
            showsHeaderDivider: true,
            onDone: { dismiss() }
        ) {
            if tasks.isEmpty {
                emptyState
            } else {
                populatedList
            }
        }
        .sheet(isPresented: $isAddingTask) {
            AddTaskView()
                .presentationDetents([.height(260)])
                .presentationDragIndicator(.visible)
        }
        .onAppear(perform: clearYesterdaysCompletedTasks)
    }

    private var addButton: some View {
        Button {
            isAddingTask = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppColors.primary)
                .frame(width: AppLayout.minimumTapTarget, height: AppLayout.minimumTapTarget)
        }
        .accessibilityIdentifier("addTaskToolbarButton")
        .accessibilityLabel("Add a task")
    }

    /// A `List` rather than a `LazyVStack`, because swipe-to-delete is part of
    /// the spec and only `List` provides it.
    private var populatedList: some View {
        List {
            Section {
                ForEach(tasks) { task in
                    TaskRow(task: task) { toggle(task) }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(AppColors.surface)
                        .listRowSeparatorTint(AppColors.hairline)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                modelContext.delete(task)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            } footer: {
                Text("Completed tasks clear themselves at midnight.")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(AppColors.background)
    }

    /// Screen 23. An invitation with a reason attached — it answers "why would
    /// I type here" rather than announcing "no tasks", and the question doubles
    /// as a prompt for what to write.
    private var emptyState: some View {
        VStack(spacing: AppSpacing.medium) {
            Spacer(minLength: 0)

            Image(systemName: "checklist")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(AppColors.disabled)
                .frame(height: 120)
                .accessibilityHidden(true)

            Text("What's this session for?")
                .font(AppFonts.title)
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            Text("Write one thing down. It makes starting easier — and the cat likes knowing the plan.")
                .font(AppFonts.body)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, AppSpacing.large)

            CapsuleButton("Add a task", style: .primary, fillsWidth: false) {
                isAddingTask = true
            }
            .accessibilityIdentifier("addFirstTaskButton")
            .padding(.top, AppSpacing.small)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, AppSpacing.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func toggle(_ task: TaskItem) {
        withAnimation(AppAnimation.quick) {
            task.toggle()
        }
        HapticManager.shared.selection()
    }

    /// Completed rows stay struck through until midnight — stated in the
    /// footer so nothing disappears unexplained — then clear on next open.
    private func clearYesterdaysCompletedTasks() {
        let startOfToday = Calendar.current.startOfDay(for: .now)
        for task in tasks where task.isCompleted {
            guard let completedAt = task.completedAt, completedAt < startOfToday else { continue }
            modelContext.delete(task)
        }
    }
}

/// One task row. Completing it restyles the row in place — it does not
/// reorder or vanish, because a row that moves the moment you tap it makes
/// the list feel unstable.
struct TaskRow: View {
    let task: TaskItem
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.medium) {
            Button(action: onToggle) {
                ZStack {
                    Circle()
                        .strokeBorder(task.isCompleted ? .clear : AppColors.disabled, lineWidth: 1.5)
                        .background(Circle().fill(task.isCompleted ? AppColors.accent : .clear))
                        .frame(width: 22, height: 22)

                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(.plain)

            Text(task.title)
                .font(AppFonts.body)
                .foregroundStyle(task.isCompleted ? AppColors.textSecondary : AppColors.textPrimary)
                .strikethrough(task.isCompleted, color: AppColors.textSecondary)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, AppSpacing.large)
        .padding(.vertical, AppSpacing.medium)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("taskRow")
        .accessibilityLabel(task.title)
        .accessibilityValue(task.isCompleted ? "Completed" : "Not completed")
        .accessibilityAddTraits(.isButton)
        // `.combine` absorbs the circle's own Button, so without this the row
        // advertises a button trait and then does nothing when VoiceOver
        // activates it — a task that can be read but never ticked off.
        .accessibilityAction(.default, onToggle)
    }
}

#Preview {
    TaskListView()
        .modelContainer(AppModelContainer.inMemory())
}
