import SwiftUI

struct AccessibilitySettingsView: View {
    @Bindable var viewModel: SettingsViewModel

    var body: some View {
        Toggle("Session Notifications", isOn: $viewModel.preferences.notificationsEnabled)
            .onChange(of: viewModel.preferences.notificationsEnabled) {
                viewModel.save()
            }
    }
}
