import SwiftUI

/// Customization is intentionally limited to Room and Sound. The session
/// companion (cat + chair) is a fixed default — see `CatSceneBackground`
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

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                switch kind {
                case .room:
                    SceneSelectionView(selection: $viewModel.selectedScene)
                case .sound:
                    SoundSelectionView(viewModel: viewModel)
                }
            }
            .navigationTitle(kind.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
