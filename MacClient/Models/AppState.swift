import Foundation
import Combine

/// Main state container for the application
class AppState: ObservableObject {
    // Published properties will automatically notify observers when changed
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var error: Error? = nil
    @Published var conversations: [Conversation] = []
    @Published var currentConversation: Conversation?
    @Published var currentUser: User?
    
    // Child state containers
    @Published var conversationStore = ConversationStore()
    @Published var fileStore = FileStore()
    @Published var settingsStore = SettingsStore()
    @Published var authStore = AuthStore()
    @Published var githubStore = GitHubStore()
    
    // Services
    private var authService: AuthService?
    private var conversationService: ConversationService?
    private var fileService: FileService?
    private var webSocketService: WebSocketService?
    
    // Cancellables for managing subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Empty initializer for use with @StateObject
    }
    
    func initialize() {
        // Initialize services
        authService = AuthService()
        conversationService = ConversationService()
        fileService = FileService()
        webSocketService = WebSocketService()
        
        // Load initial data
        loadSampleData()
        
        // Set up subscriptions
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        // Example: Listen for auth changes
        authStore.$user
            .sink { [weak self] user in
                self?.currentUser = user
                self?.isAuthenticated = user != nil
            }
            .store(in: &cancellables)
        
        // Example: Listen for conversation changes
        conversationStore.$conversations
            .sink { [weak self] conversationDict in
                self?.conversations = Array(conversationDict.values)
                    .sorted(by: { $0.updatedAt > $1.updatedAt })
            }
            .store(in: &cancellables)
    }
    
    // Load sample data for development
    private func loadSampleData() {
        // Sample user
        currentUser = User(id: "1", name: "Test User", username: "testuser", avatarUrl: nil)
        
        // Sample conversations
        let sampleConversations = [
            Conversation(
                id: "1",
                title: "First Conversation",
                messages: [
                    Message(id: "1", content: "Hello, how can I help you?", sender: .agent),
                    Message(id: "2", content: "I need help with my code", sender: .user)
                ],
                lastMessagePreview: "I need help with my code"
            ),
            Conversation(
                id: "2",
                title: "GitHub Integration",
                messages: [
                    Message(id: "3", content: "Let's work on GitHub integration", sender: .user),
                    Message(id: "4", content: "Sure, I can help with that", sender: .agent)
                ],
                lastMessagePreview: "Sure, I can help with that"
            )
        ]
        
        conversations = sampleConversations
        if let first = conversations.first {
            currentConversation = first
        }
    }
    
    // Select a conversation
    func selectConversation(_ conversation: Conversation) {
        currentConversation = conversation
    }
    
    // Reset the entire app state
    func reset() {
        isAuthenticated = false
        isLoading = false
        error = nil
        conversations = []
        currentConversation = nil
        currentUser = nil
        conversationStore = ConversationStore()
        fileStore = FileStore()
        settingsStore = SettingsStore()
        authStore = AuthStore()
        githubStore = GitHubStore()
        
        // Cancel all subscriptions
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}

/// Store for managing chat conversations
class ConversationStore: ObservableObject {
    @Published var conversations: [String: Conversation] = [:]
    @Published var currentConversationId: String? = nil
    @Published var isLoadingMessages: Bool = false
    
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

// Models
struct Conversation: Identifiable {
    var id: String
    var title: String
    var messages: [Message] = []
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var lastMessagePreview: String = ""
    var isActive: Bool = false
}

struct Message: Identifiable {
    var id: String
    var content: String
    var sender: MessageSender
    var timestamp: Date = Date()
    var isTyping: Bool = false
    var metadata: [String: Any]? = nil
}

enum MessageSender {
    case user
    case agent
}

struct FileItem: Identifiable {
    var id: String { path }
    var path: String
    var name: String
    var isDirectory: Bool
    var size: Int64
    var modifiedAt: Date
    var children: [FileItem]? = nil
}

struct User {
    var id: String
    var name: String
    var username: String
    var avatarUrl: String?
}

// GitHub models
class GitHubStore: ObservableObject {
    @Published var repositories: [GitHubRepository] = []
    @Published var selectedRepository: GitHubRepository?
    @Published var branches: [GitHubBranch] = []
    @Published var selectedBranch: GitHubBranch?
    @Published var isLoading: Bool = false
}

struct GitHubRepository: Identifiable {
    var id: Int
    var name: String
    var fullName: String
    var description: String?
    var owner: GitHubUser
    var isPrivate: Bool
    var htmlUrl: String
    var updatedAt: Date
}

struct GitHubBranch: Identifiable {
    var id: String { name }
    var name: String
    var commit: GitHubCommit
    var protected: Bool
}

struct GitHubCommit {
    var sha: String
    var url: String
}

struct GitHubUser: Identifiable {
    var id: Int
    var login: String
    var avatarUrl: String?
    var htmlUrl: String
}