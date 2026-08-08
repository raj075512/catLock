import SwiftUI

struct StartFocusButton: View {
    let action: () -> Void

    var body: some View {
        PrimaryButton("Start Focus", systemImage: "play.fill", action: action)
    }
}
