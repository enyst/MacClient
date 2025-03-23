import Foundation
import Combine

/// Store for managing chat state
class ChatStore: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var currentConversationId: String? = nil
    @Published var messages: [ChatMessage] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    
    /// Get the current conversation
    var currentConversation: Conversation? {
        guard let id = currentConversationId else { return nil }
        return conversations.first { $0.id == id }
    }
    
    /// Reset the chat store
    func reset() {
        conversations = []
        currentConversationId = nil
        messages = []
        isLoading = false
        error = nil
    }
}

/// Conversation model
struct Conversation: Identifiable, Codable {
    var id: String
    var title: String
    var createdAt: Date
    var updatedAt: Date
    var messageCount: Int
    var lastMessage: String?
}

/// Chat message model
struct ChatMessage: Identifiable, Codable {
    var id: String
    var conversationId: String
    var role: MessageRole
    var content: String
    var timestamp: Date
    var status: MessageStatus
    var metadata: MessageMetadata?
    
    /// Check if the message is from the user
    var isUser: Bool {
        return role == .user
    }
    
    /// Check if the message is from the assistant
    var isAssistant: Bool {
        return role == .assistant
    }
    
    /// Check if the message is a system message
    var isSystem: Bool {
        return role == .system
    }
    
    /// Check if the message is a tool call
    var isToolCall: Bool {
        return metadata?.toolCall != nil
    }
    
    /// Check if the message is a tool result
    var isToolResult: Bool {
        return metadata?.toolResult != nil
    }
}

/// Message role
enum MessageRole: String, Codable {
    case user = "user"
    case assistant = "assistant"
    case system = "system"
    case tool = "tool"
}

/// Message status
enum MessageStatus: String, Codable {
    case sending = "sending"
    case sent = "sent"
    case received = "received"
    case error = "error"
}

/// Message metadata
struct MessageMetadata: Codable {
    var toolCall: ToolCall?
    var toolResult: ToolResult?
    var codeBlock: CodeBlock?
    var fileReference: FileReference?
}

/// Tool call
struct ToolCall: Codable {
    var id: String
    var name: String
    var arguments: [String: AnyCodable]
}

/// Tool result
struct ToolResult: Codable {
    var callId: String
    var result: AnyCodable
    var error: String?
}

/// Code block
struct CodeBlock: Codable {
    var language: String
    var code: String
}

/// File reference
struct FileReference: Codable {
    var id: String
    var name: String
    var path: String
    var type: String
    var size: Int
}