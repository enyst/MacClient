import SwiftUI

struct ContentPanelView: View {
    @EnvironmentObject var navigationRouter: NavigationRouter
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Group {
            switch navigationRouter.selectedRoute {
            case .chat:
                ChatView()
                    .environmentObject(appState)
            case .files:
                FileExplorerView()
                    .environmentObject(appState)
            case .github:
                GitHubView()
                    .environmentObject(appState)
            case .settings:
                SettingsView()
                    .environmentObject(appState)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Import the actual views
import SwiftUI