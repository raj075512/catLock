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
    ContentView()
        .environment(AppState())
        .modelContainer(for: Item.self, inMemory: true)
}
