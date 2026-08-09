import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()

    @Environment(\.dismiss) private var dismiss

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
