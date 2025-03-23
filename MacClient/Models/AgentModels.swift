import Foundation
import Combine

/// Store for managing agent state
class AgentStore: ObservableObject {
    @Published var status: AgentStatus = .idle
    @Published var capabilities: [AgentCapability] = []
    @Published var currentTask: AgentTask? = nil
    @Published var history: [AgentTask] = []
    @Published var isLoading: Bool = false
    
    /// Reset the agent store
    func reset() {
        status = .idle
        capabilities = []
        currentTask = nil
        history = []
        isLoading = false
    }
}

/// Agent status
enum AgentStatus: String, Codable {
    case idle = "idle"
    case thinking = "thinking"
    case executing = "executing"
    case waiting = "waiting"
    case error = "error"
}

/// Agent capability
struct AgentCapability: Identifiable, Codable {
    var id: String
    var name: String
    var description: String
    var category: String
    var parameters: [AgentCapabilityParameter]
}

/// Agent capability parameter
struct AgentCapabilityParameter: Identifiable, Codable {
    var id: String
    var name: String
    var type: String
    var description: String
    var required: Bool
    var defaultValue: String?
}

/// Agent task
struct AgentTask: Identifiable, Codable {
    var id: String
    var type: String
    var status: AgentTaskStatus
    var input: String
    var output: String?
    var startedAt: Date
    var completedAt: Date?
    var error: String?
}

/// Agent task status
enum AgentTaskStatus: String, Codable {
    case pending = "pending"
    case running = "running"
    case completed = "completed"
    case failed = "failed"
    case cancelled = "cancelled"
}