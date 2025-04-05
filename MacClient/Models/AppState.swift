import Foundation
import Combine

/// Main state container for the application
class AppState: ObservableObject {
    // Singleton instance
    static let shared = AppState()
    
    // Published properties will automatically notify observers when changed
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var error: Error? = nil
    
    // Child state containers
    @Published var conversationStore = ConversationStore()
    @Published var fileStore = FileStore()
    @Published var settingsStore = SettingsStore()
    @Published var authStore = AuthStore()
    
    // Private initializer for singleton
    private init() {}
    
    // Reset the entire app state
    func reset() {
        isAuthenticated = false
        isLoading = false
        error = nil
        conversationStore = ConversationStore()
        fileStore = FileStore()
        settingsStore = SettingsStore()
        authStore = AuthStore()
    }
}

/// Store for managing chat conversations
class ConversationStore: ObservableObject {
    @Published var conversations: [String: Conversation] = [:]
    @Published var currentConversationId: String? = nil
    @Published var isLoadingMessages: Bool = false
    @Published var messagesByConversationId: [String: [ChatMessage]] = [:]
    
    // Add more conversation-related state and methods here
}

/// Store for managing file operations
class FileStore: ObservableObject {
    @Published var files: [String: FileItem] = [:]
    @Published var currentDirectory: String = "/"
    @Published var isLoadingFiles: Bool = false
    
    // Add more file-related state and methods here
}

/// Store for managing user settings
class SettingsStore: ObservableObject {
    @Published var settings: [String: Any] = [:]
    @Published var isLoadingSettings: Bool = false
    
    // Add more settings-related state and methods here
}

/// Store for managing authentication
class AuthStore: ObservableObject {
    @Published var token: String? = nil
    @Published var user: User? = nil
    @Published var isAuthenticating: Bool = false
    
    // Add more auth-related state and methods here
}



struct FileItem: Codable {
    var path: String
    var name: String
    var isDirectory: Bool
    var size: Int64
    var modifiedAt: Date
}

struct User: Codable {
    var id: String
    var username: String
    var avatarUrl: String?
}