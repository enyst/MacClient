import SwiftUI

struct ContentView: View {
    @StateObject private var navigationRouter = NavigationRouter()
    @StateObject private var appState = AppState()
    
    var body: some View {
        NavigationSplitView {
            SidebarView()
                .environmentObject(navigationRouter)
                .environmentObject(appState)
        } detail: {
            ContentPanelView()
                .environmentObject(navigationRouter)
                .environmentObject(appState)
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 900, minHeight: 600)
        .onAppear {
            // Initialize services and load initial data
            appState.initialize()
        }
    }
}

#Preview {
    ContentView()
}