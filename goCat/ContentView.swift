//
//  ContentView.swift
//  goCat
//
//  Created by User on 02/08/26.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    var body: some View {
        RootView()
    }
}

#Preview {
    // Skip onboarding in the canvas so it lands straight on the real app
    // (Home → Room/Sound customization, session video, etc.) instead of
    // the first-run flow — that's what you want visible while iterating.
    let previewState = AppState()
    previewState.preferences.hasCompletedOnboarding = true

    return ContentView()
        .environment(previewState)
        .modelContainer(for: Item.self, inMemory: true)
}
