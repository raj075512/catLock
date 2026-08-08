import SwiftUI

struct CustomizationSheet: View {
    enum Kind: String, Identifiable {
        case scene
        case cat
        case chair
        case sound

        var id: String {
            rawValue
        }

        var title: String {
            switch self {
            case .scene:
                "Scene"
            case .cat:
                "Cat"
            case .chair:
                "Chair"
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
                case .scene:
                    SceneSelectionView(selection: $viewModel.selectedScene)
                case .cat:
                    CatSelectionView(selection: $viewModel.selectedCat)
                case .chair:
                    ChairSelectionView(selection: $viewModel.selectedChair)
                case .sound:
                    SoundSelectionView(selection: $viewModel.selectedSound)
                }
            }
            .navigationTitle(kind.title)
        }
    }
}
