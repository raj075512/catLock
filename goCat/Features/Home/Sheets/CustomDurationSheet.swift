import SwiftUI

/// Screen 14. The custom length picker.
///
/// The ring exists to turn an abstract number into a visible share of the
/// two-hour ceiling *before* committing to it — 1:20 fills two thirds of it,
/// so over-ambition is legible at a glance rather than only in hindsight.
struct CustomDurationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion

    private var state: AppState { AppState.shared }

    @State private var hours: Int
    @State private var minutes: Int

    private static let maximumHours = 2
    private static let minimumMinutes = 5
    private static let minuteStep = 5

    init() {
        let existing = AppState.shared.customMinutes ?? AppState.shared.selectedMinutes
        _hours = State(initialValue: min(existing / 60, Self.maximumHours))
        _minutes = State(initialValue: existing >= Self.maximumHours * 60 ? 0 : (existing % 60) / Self.minuteStep * Self.minuteStep)
    }

    private var totalMinutes: Int { hours * 60 + minutes }
    private var isValid: Bool { totalMinutes >= Self.minimumMinutes }
    /// At the ceiling the ring closes fully and the minutes wheel locks to 00.
    private var isAtCeiling: Bool { hours >= Self.maximumHours }

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.large) {
                ring
                    .padding(.top, AppSpacing.large)

                Text("Up to 2 hours.")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)

                wheels

                Spacer(minLength: 0)
            }
            .padding(.horizontal, AppSpacing.medium)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.background)
            .navigationTitle("Custom length")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    // Swipe-to-dismiss lands in the same place: nothing written.
                    Button("Cancel") { dismiss() }
                        .font(AppFonts.body)
                        .foregroundStyle(AppColors.primary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Set") {
                        state.setCustomDuration(totalMinutes)
                        HapticManager.shared.selection()
                        dismiss()
                    }
                    .font(AppFonts.headline)
                    .foregroundStyle(isValid ? AppColors.primary : AppColors.textSecondary)
                    .disabled(!isValid)
                }
            }
        }
        .onChange(of: hours) { _, newValue in
            if newValue >= Self.maximumHours { minutes = 0 }
        }
    }

    // MARK: - Ring

    private var ring: some View {
        ZStack {
            Circle()
                .stroke(AppColors.elevatedSurface, lineWidth: 16)

            Circle()
                .trim(from: 0, to: fillFraction)
                .stroke(AppColors.accent, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(
                    state.prefersReducedMotion(system: systemReduceMotion) ? nil : AppAnimation.quick,
                    value: fillFraction
                )

            Circle()
                .fill(AppColors.background)
                .frame(width: 188, height: 188)

            VStack(spacing: AppSpacing.xSmall) {
                Text(String(format: "%d:%02d", hours, minutes))
                    .font(AppFonts.display)
                    .foregroundStyle(AppColors.textPrimary)
                    .monospacedDigit()

                Text("hr : min")
                    .font(AppFonts.caption)
                    .tracking(2)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .frame(width: 220, height: 220)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Session length \(hours) hours \(minutes) minutes")
    }

    private var fillFraction: CGFloat {
        CGFloat(totalMinutes) / CGFloat(Self.maximumHours * 60)
    }

    // MARK: - Wheels

    private var wheels: some View {
        HStack(spacing: 0) {
            Picker("Hours", selection: $hours) {
                ForEach(0...Self.maximumHours, id: \.self) { value in
                    Text(value == 1 ? "1 hour" : "\(value) hours").tag(value)
                }
            }
            .pickerStyle(.wheel)

            Picker("Minutes", selection: $minutes) {
                ForEach(Array(stride(from: 0, to: 60, by: Self.minuteStep)), id: \.self) { value in
                    Text("\(value) min").tag(value)
                }
            }
            .pickerStyle(.wheel)
            .disabled(isAtCeiling)
            .opacity(isAtCeiling ? 0.4 : 1)
        }
        .frame(height: 160)
        .background(AppColors.elevatedSurface)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.large, style: .continuous))
    }
}

#Preview {
    Color.gray.sheet(isPresented: .constant(true)) {
        CustomDurationSheet()
            .presentationDragIndicator(.visible)
    }
}
