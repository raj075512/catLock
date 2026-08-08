import SwiftUI

struct SessionCompletedView: View {
    var body: some View {
        EmptyStateView(
            title: "Session complete",
            message: "Your focus time has been saved.",
            systemImage: "checkmark.circle.fill"
        )
    }
}
