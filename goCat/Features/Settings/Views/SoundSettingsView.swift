import SwiftUI

struct SoundSettingsView: View {
    @Bindable var viewModel: SettingsViewModel

    var body: some View {
        Toggle("Ambient Sound", isOn: $viewModel.preferences.soundEnabled)
            .onChange(of: viewModel.preferences.soundEnabled) {
                viewModel.save()
            }
    }
}
