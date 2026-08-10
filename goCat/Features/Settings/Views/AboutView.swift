import SwiftUI

struct AboutView: View {
    var body: some View {
        HStack {
            Label("catLock", systemImage: "pawprint.fill")
            Spacer()
            Text("1.0")
                .foregroundStyle(AppColors.textSecondary)
        }
    }
}
