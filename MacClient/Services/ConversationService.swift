import Foundation
import Combine

/// Service for handling chat conversations
class ConversationService {
    // Singleton instance
    static let shared = ConversationService()
    
    // API service
    private let apiService = APIService.shared
    
    // WebSocket service
    private let webSocketService = WebSocketService.shared
    
    // App state
    private let appState = AppState.shared
    
    // Cancellables for managing subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // Private initializer for singleton
    private init() {
        // Subscribe to WebSocket messages
        webSocketService.messagePublisher
            .sink { [weak self] message in
                self?.handleWebSocketMessage(message)
            }
            .store(in: &cancellables)
    }
    
    /// List all conversations
    /// - Returns: A publisher that emits an array of conversations or an error
    func listConversations() -> AnyPublisher<[Conversation], Error> {
        return apiService.get(endpoint: "conversations")
            .map { (response: ConversationListResponse) -> [Conversation] in
                // Update the conversation store
                let conversationDict = Dictionary(uniqueKeysWithValues: response.conversations.map { ($0.id, $0) })
                self.appState.conversationStore.conversations = conversationDict
                
                return response.conversations
            }
            .eraseToAnyPublisher()
    }
    
    /// Get a conversation by ID
    /// - Parameter id: The conversation ID
    /// - Returns: A publisher that emits a conversation or an error
    func getConversation(id: String) -> AnyPublisher<Conversation, Error> {
        appState.conversationStore.isLoadingMessages = true
        
        return apiService.get(endpoint: "conversations/\(id)")
            .map { (response: ConversationResponse) -> Conversation in
                // Update the conversation store
                self.appState.conversationStore.conversations[id] = response.conversation
                self.appState.conversationStore.currentConversationId = id
                self.appState.conversationStore.isLoadingMessages = false
                
                return response.conversation
            }
            .handleEvents(receiveCompletion: { completion in
                if case .failure = completion {
                    self.appState.conversationStore.isLoadingMessages = false
                }
            })
            .eraseToAnyPublisher()
    }
    
    /// Create a new conversation
    /// - Returns: A publisher that emits a conversation or an error
    func createConversation() -> AnyPublisher<Conversation, Error> {
        return apiService.post(endpoint: "conversations")
            .map { (response: ConversationResponse) -> Conversation in
                // Update the conversation store
                self.appState.conversationStore.conversations[response.conversation.id] = response.conversation
                self.appState.conversationStore.currentConversationId = response.conversation.id
                
                return response.conversation
            }
            .eraseToAnyPublisher()
    }
    
    /// Send a message in a conversation
    /// - Parameters:
    ///   - conversationId: The conversation ID
    ///   - content: The message content
    /// - Returns: A publisher that emits a message or an error
    func sendMessage(conversationId: String, content: String) -> AnyPublisher<ChatMessage, Error> {
        let parameters: [String: Any] = [
            "content": content
        ]
        
        return apiService.post(endpoint: "conversations/\(conversationId)/messages", parameters: parameters)
            .map { (response: MessageResponse) -> ChatMessage in
                // Update the conversation store
                // Append the new message to the messagesByConversationId dictionary
                // Ensure the array exists for the conversationId, creating it if necessary
                self.appState.conversationStore.messagesByConversationId[conversationId, default: []].append(response.message)
                
                return response.message
            }
            .eraseToAnyPublisher()
    }
    
    /// Connect to the WebSocket for real-time updates
    func connectWebSocket() {
        guard let token = appState.authStore.token else {
            print("Cannot connect WebSocket: No auth token")
            return
        }
        
        let url = URL(string: "wss://api.all-hands.dev/ws?token=\(token)")!
        webSocketService.connect(url: url)
    }
    
    /// Handle a WebSocket message
    /// - Parameter message: The WebSocket message
    private func handleWebSocketMessage(_ message: WebSocketMessage) {
        switch message.type {
        case "message":
            handleNewMessage(message)
        case "typing":
            handleTypingIndicator(message)
        case "read":
            handleReadReceipt(message)
        default:
            print("Unknown WebSocket message type: \(message.type)")
        }
    }
    
    /// Handle a new message from the WebSocket
    /// - Parameter message: The WebSocket message
    private func handleNewMessage(_ message: WebSocketMessage) {
        guard let conversationId = message.payload["conversationId"]?.value as? String,
              let messageData = try? JSONSerialization.data(withJSONObject: message.payload["message"]?.value as? [String: Any] ?? [:]),
              let newMessage = try? JSONDecoder().decode(ChatMessage.self, from: messageData) else {
            print("Failed to parse new message")
            return
        }
        
        // Update the conversation store
        // Append the new message to the messagesByConversationId dictionary
        // Ensure the array exists for the conversationId, creating it if necessary
        appState.conversationStore.messagesByConversationId[conversationId, default: []].append(newMessage)
    }
    
    /// Handle a typing indicator from the WebSocket
    /// - Parameter message: The WebSocket message
    private func handleTypingIndicator(_ message: WebSocketMessage) {
        // Handle typing indicator
    }
    
    /// Handle a read receipt from the WebSocket
    /// - Parameter message: The WebSocket message
    private func handleReadReceipt(_ message: WebSocketMessage) {
        // Handle read receipt
    }
}

/// Response model for conversation list
struct ConversationListResponse: Decodable {
    let conversations: [Conversation]
}

/// Response model for conversation
struct ConversationResponse: Decodable {
    let conversation: Conversation
}

/// Response model for message
struct MessageResponse: Decodable {
    let message: ChatMessage
}