import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section("Preferences") {
                    SoundSettingsView(viewModel: viewModel)
                    AccessibilitySettingsView(viewModel: viewModel)
                }

                Section("Information") {
                    AboutView()
                }
            }
            .navigationTitle("Settings")
        }
    }
}
