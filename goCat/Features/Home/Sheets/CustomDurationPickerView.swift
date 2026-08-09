import SwiftUI

/// A big circular dial for picking a custom session length, capped at 2
/// hours. The ring is a visual readout of the chosen duration (empty at
/// 0, full at the 2-hour cap); the actual hour/minute selection happens on
/// the wheel pickers below it, which is far more precise and reliable than
/// a drag-around-the-face gesture for the same result.
struct CustomDurationPickerView: View {
    /// In minutes. Callers pass the current selection in; on tap of "Set",
    /// this is updated in place and the sheet dismisses itself.
    @Binding var totalMinutes: Int

    @Environment(\.dismiss) private var dismiss

    @State private var hours: Int
    @State private var minutes: Int

    static let maxMinutes = 120
    private static let minuteStep = 5

    init(totalMinutes: Binding<Int>) {
        _totalMinutes = totalMinutes
        let clamped = min(max(totalMinutes.wrappedValue, 0), Self.maxMinutes)
        _hours = State(initialValue: clamped / 60)
        _minutes = State(initialValue: (clamped % 60) / Self.minuteStep * Self.minuteStep)
    }

    private var selectedTotal: Int {
        min(hours * 60 + minutes, Self.maxMinutes)
    }

    private var progress: CGFloat {
        CGFloat(selectedTotal) / CGFloat(Self.maxMinutes)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.xLarge) {
                dial

                HStack(spacing: 0) {
                    Picker("Hours", selection: $hours) {
                        ForEach(0...2, id: \.self) { hour in
                            Text("\(hour) hr").tag(hour)
                        }
                    }
                    .pickerStyle(.wheel)
                    .onChange(of: hours) { _, newValue in
                        if newValue >= 2 {
                            minutes = 0
                        }
                    }

                    Picker("Minutes", selection: $minutes) {
                        ForEach(Array(stride(from: 0, to: 60, by: Self.minuteStep)), id: \.self) { minute in
                            Text("\(minute) min").tag(minute)
                        }
                    }
                    .pickerStyle(.wheel)
                    .disabled(hours >= 2)
                    .opacity(hours >= 2 ? 0.4 : 1)
                }
                .frame(height: 150)

                Text("Up to 2 hours")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)

                Spacer(minLength: 0)
            }
            .padding(AppSpacing.large)
            .background(AppColors.background)
            .navigationTitle("Custom duration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Set") {
                        totalMinutes = max(selectedTotal, Self.minuteStep)
                        dismiss()
                    }
                }
            }
        }
    }

    private var dial: some View {
        ZStack {
            Circle()
                .stroke(AppColors.elevatedSurface, lineWidth: 14)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(AppColors.primary, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(AppAnimation.standard, value: progress)

            VStack(spacing: 4) {
                Text(String(format: "%d:%02d", hours, minutes))
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(AppColors.textPrimary)

                Text("hr : min")
                    .font(AppFonts.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
        .frame(width: 220, height: 220)
        .padding(.top, AppSpacing.large)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(hours) hours \(minutes) minutes selected")
    }
}

#Preview {
    CustomDurationPickerView(totalMinutes: .constant(80))
}
