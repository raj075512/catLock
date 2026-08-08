import SwiftUI

struct SessionTimerView: View {
    let timeText: String

    var body: some View {
        Text(timeText)
            .font(.system(size: 56, weight: .bold, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(AppColors.textPrimary)
            .accessibilityLabel("Remaining time \(timeText)")
    }
}
