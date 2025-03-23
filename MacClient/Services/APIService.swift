import Foundation
import Alamofire
import Combine

/// Service for handling API requests
class APIService {
    // Singleton instance
    static let shared = APIService()
    
    // Base URL for API requests
    private let baseURL = "https://api.all-hands.dev"
    
    // Session manager for handling requests
    private let session: Session
    
    // Private initializer for singleton
    private init() {
        // Configure session with interceptors for auth tokens, etc.
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0
        configuration.timeoutIntervalForResource = 60.0
        
        let interceptor = APIRequestInterceptor()
        session = Session(configuration: configuration, interceptor: interceptor)
    }
    
    /// Make a GET request to the API
    /// - Parameters:
    ///   - endpoint: The API endpoint
    ///   - parameters: Query parameters
    /// - Returns: A publisher that emits the decoded response or an error
    func get<T: Decodable>(endpoint: String, parameters: [String: Any]? = nil) -> AnyPublisher<T, Error> {
        let url = "\(baseURL)/\(endpoint)"
        
        return session.request(url, method: .get, parameters: parameters)
            .validate()
            .publishDecodable(type: T.self)
            .value()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    /// Make a POST request to the API
    /// - Parameters:
    ///   - endpoint: The API endpoint
    ///   - parameters: Body parameters
    /// - Returns: A publisher that emits the decoded response or an error
    func post<T: Decodable>(endpoint: String, parameters: [String: Any]? = nil) -> AnyPublisher<T, Error> {
        let url = "\(baseURL)/\(endpoint)"
        
        return session.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .publishDecodable(type: T.self)
            .value()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    /// Make a PUT request to the API
    /// - Parameters:
    ///   - endpoint: The API endpoint
    ///   - parameters: Body parameters
    /// - Returns: A publisher that emits the decoded response or an error
    func put<T: Decodable>(endpoint: String, parameters: [String: Any]? = nil) -> AnyPublisher<T, Error> {
        let url = "\(baseURL)/\(endpoint)"
        
        return session.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .publishDecodable(type: T.self)
            .value()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    /// Make a DELETE request to the API
    /// - Parameters:
    ///   - endpoint: The API endpoint
    ///   - parameters: Query parameters
    /// - Returns: A publisher that emits the decoded response or an error
    func delete<T: Decodable>(endpoint: String, parameters: [String: Any]? = nil) -> AnyPublisher<T, Error> {
        let url = "\(baseURL)/\(endpoint)"
        
        return session.request(url, method: .delete, parameters: parameters, encoding: URLEncoding.queryString)
            .validate()
            .publishDecodable(type: T.self)
            .value()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}

/// Interceptor for handling authentication tokens
class APIRequestInterceptor: RequestInterceptor {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        
        // Add auth token if available
        if let token = AppState.shared.authStore.token {
            urlRequest.headers.add(.authorization(bearerToken: token))
        }
        
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        // Handle token refresh logic here if needed
        completion(.doNotRetry)
    }
}