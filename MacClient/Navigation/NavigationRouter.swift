import SwiftUI

enum NavigationRoute: Hashable {
    case chat
    case files
    case settings
    case github
    
    var title: String {
        switch self {
        case .chat:
            return "Chat"
        case .files:
            return "Files"
        case .settings:
            return "Settings"
        case .github:
            return "GitHub"
        }
    }
    
    var icon: String {
        switch self {
        case .chat:
            return "bubble.left.and.bubble.right"
        case .files:
            return "folder"
        case .settings:
            return "gear"
        case .github:
            return "terminal"
        }
    }
}

class NavigationRouter: ObservableObject {
    @Published var selectedRoute: NavigationRoute = .chat
    @Published var navigationStack: [NavigationRoute] = []
    
    func navigate(to route: NavigationRoute) {
        selectedRoute = route
    }
    
    func push(_ route: NavigationRoute) {
        navigationStack.append(route)
    }
    
    func pop() {
        if !navigationStack.isEmpty {
            navigationStack.removeLast()
        }
    }
    
    func popToRoot() {
        navigationStack.removeAll()
    }
}