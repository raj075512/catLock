import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var customizationKind: CustomizationSheet.Kind?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.large) {
                    HomeHeaderView()

                    LiveSceneView(scene: viewModel.selectedScene)

                    CustomizationSummaryView(
                        scene: viewModel.selectedScene,
                        sound: viewModel.selectedSound,
                        action: { customizationKind = $0 }
                    )

                    SessionSettingsCard(duration: $viewModel.sessionDuration)

                    StartFocusButton {
                        _ = viewModel.startFocusSession()
                    }
                }
                .padding(AppSpacing.medium)
            }
            .background(AppColors.background)
            .navigationTitle("GoCat")
            .sheet(item: $customizationKind) { kind in
                CustomizationSheet(kind: kind, viewModel: viewModel)
            }
        }
    }
}

#Preview {
    HomeView()
}
