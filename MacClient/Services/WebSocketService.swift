import Foundation
import Starscream
import Combine

/// Service for handling WebSocket connections
class WebSocketService: ObservableObject {
    // Singleton instance
    static let shared = WebSocketService()
    
    // WebSocket connection
    private var socket: WebSocket?
    
    // Connection status
    @Published var isConnected = false
    
    // Message subject for publishing received messages
    private let messageSubject = PassthroughSubject<WebSocketMessage, Never>()
    
    // Message publisher
    var messagePublisher: AnyPublisher<WebSocketMessage, Never> {
        return messageSubject.eraseToAnyPublisher()
    }
    
    // Private initializer for singleton
    private init() {}
    
    /// Connect to the WebSocket server
    /// - Parameter url: The WebSocket URL
    func connect(url: URL) {
        // Create a request with the URL
        var request = URLRequest(url: url)
        
        // Add auth token if available
        if let token = AppState.shared.authStore.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Create and connect the WebSocket
        socket = WebSocket(request: request)
        socket?.delegate = self
        socket?.connect()
    }
    
    /// Disconnect from the WebSocket server
    func disconnect() {
        socket?.disconnect()
        socket = nil
        isConnected = false
    }
    
    /// Send a message through the WebSocket
    /// - Parameter message: The message to send
    func send(message: WebSocketMessage) {
        guard let socket = socket, isConnected else {
            print("Cannot send message: WebSocket not connected")
            return
        }
        
        do {
            let data = try JSONEncoder().encode(message)
            socket.write(data: data)
        } catch {
            print("Failed to encode message: \(error)")
        }
    }
}

// MARK: - WebSocketDelegate
extension WebSocketService: WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: any WebSocketClient) {
        switch event {
        case .connected(_):
            isConnected = true
            print("WebSocket connected")
            
        case .disconnected(let reason, let code):
            isConnected = false
            print("WebSocket disconnected: \(reason) with code: \(code)")
            
        case .text(let string):
            handleTextMessage(string)
            
        case .binary(let data):
            handleBinaryMessage(data)
            
        case .ping(_):
            break
            
        case .pong(_):
            break
            
        case .viabilityChanged(_):
            break
            
        case .reconnectSuggested(_):
            break
            
        case .cancelled:
            isConnected = false
            print("WebSocket connection cancelled")
            
        case .error(let error):
            isConnected = false
            print("WebSocket error: \(String(describing: error))")
case .peerClosed:
            // Handle peer closing the connection if needed
            isConnected = false
            print("WebSocket peer closed connection")
            break
        }
    }
    
    /// Handle a text message from the WebSocket
    /// - Parameter text: The text message
    private func handleTextMessage(_ text: String) {
        guard let data = text.data(using: .utf8) else {
            print("Failed to convert text to data")
            return
        }
        
        do {
            let message = try JSONDecoder().decode(WebSocketMessage.self, from: data)
            messageSubject.send(message)
        } catch {
            print("Failed to decode message: \(error)")
        }
    }
    
    /// Handle a binary message from the WebSocket
    /// - Parameter data: The binary message
    private func handleBinaryMessage(_ data: Data) {
        do {
            let message = try JSONDecoder().decode(WebSocketMessage.self, from: data)
            messageSubject.send(message)
        } catch {
            print("Failed to decode binary message: \(error)")
        }
    }
}

/// WebSocket message model
struct WebSocketMessage: Codable {
    var type: String
    var payload: [String: AnyCodable]
    
    enum CodingKeys: String, CodingKey {
        case type
        case payload
    }
}

/// Type-erasing wrapper for Codable values
struct AnyCodable: Codable {
    public let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self.value = NSNull()
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let string = try? container.decode(String.self) {
            self.value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            self.value = array
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.value = dictionary
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable cannot decode value")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case is NSNull:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyCodable cannot encode value"))
        }
    }
}