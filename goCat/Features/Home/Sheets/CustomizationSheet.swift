import SwiftUI

/// Customization is intentionally limited to Room and Sound. The session
/// companion (cat + chair) is a fixed default — see `SessionVideoPlayerView`
/// — so there is no character/chair switching here, keeping setup quick and
/// the app's scope small.
struct CustomizationSheet: View {
    enum Kind: String, Identifiable {
        case room
        case sound

        var id: String {
            rawValue
        }

        var title: String {
            switch self {
            case .room:
                "Room"
            case .sound:
                "Sound"
            }
        }
    }

    let kind: Kind
    @Bindable var viewModel: HomeViewModel

    var body: some View {
        NavigationStack {
            Group {
                switch kind {
                case .room:
                    SceneSelectionView(selection: $viewModel.selectedScene)
                case .sound:
                    SoundSelectionView(selection: $viewModel.selectedSound)
                }
            }
            .navigationTitle(kind.title)
        }
    }
}
