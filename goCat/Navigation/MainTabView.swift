import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        TabView(selection: selectedTab) {
            HomeView()
                .tabItem { Label(TabItem.home.title, systemImage: TabItem.home.systemImage) }
                .tag(TabItem.home)

            TaskListView()
                .tabItem { Label(TabItem.tasks.title, systemImage: TabItem.tasks.systemImage) }
                .tag(TabItem.tasks)

            RoomView()
                .tabItem { Label(TabItem.room.title, systemImage: TabItem.room.systemImage) }
                .tag(TabItem.room)

            FocusProgressView()
                .tabItem { Label(TabItem.progress.title, systemImage: TabItem.progress.systemImage) }
                .tag(TabItem.progress)

            SettingsView()
                .tabItem { Label(TabItem.settings.title, systemImage: TabItem.settings.systemImage) }
                .tag(TabItem.settings)
        }
    }

    private var selectedTab: Binding<TabItem> {
        Binding(
            get: { appState.router.selectedTab },
            set: { appState.router.selectedTab = $0 }
        )
    }
}

#Preview {
    MainTabView()
        .environment(AppState())
}
