import SwiftUI

struct StreakView: View {
    let streak: Int

    var body: some View {
        HStack {
            Label("\(streak) day streak", systemImage: "flame.fill")
                .font(AppFonts.headline)
                .foregroundStyle(AppColors.warning)

            Spacer()
        }
        .cardSurface()
    }
}
