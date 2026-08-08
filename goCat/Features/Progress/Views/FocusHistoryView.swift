import SwiftUI

struct FocusHistoryView: View {
    let sessions: [FocusSession]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.medium) {
            Text("History")
                .font(AppFonts.headline)

            ForEach(sessions) { session in
                HStack {
                    Text(session.startedAt.shortDateText)
                    Spacer()
                    Text(session.state.title)
                        .foregroundStyle(AppColors.textSecondary)
                }
                .font(AppFonts.body)
            }
        }
        .cardSurface()
    }
}
