import Foundation
import Combine
import KeychainAccess

/// Service for handling authentication
class AuthService {
    // Singleton instance
    static let shared = AuthService()
    
    // Keychain for secure storage
    private let keychain = Keychain(service: "dev.all-hands.MacClient")
    
    // API service
    private let apiService = APIService.shared
    
    // App state
    private let appState = AppState.shared
    
    // Cancellables for managing subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // Private initializer for singleton
    private init() {
        // Try to load saved token on initialization
        loadSavedToken()
    }
    
    /// Sign in with username and password
    /// - Parameters:
    ///   - username: The username
    ///   - password: The password
    /// - Returns: A publisher that emits a success boolean or an error
    func signIn(username: String, password: String) -> AnyPublisher<Bool, Error> {
        appState.authStore.isAuthenticating = true
        
        let parameters: [String: Any] = [
            "username": username,
            "password": password
        ]
        
        return apiService.post(endpoint: "auth/login", parameters: parameters)
            .map { (response: AuthResponse) -> Bool in
                // Save the token
                self.saveToken(response.token)
                
                // Update the app state
                self.appState.authStore.token = response.token
                self.appState.authStore.user = response.user
                self.appState.isAuthenticated = true
                self.appState.authStore.isAuthenticating = false
                
                return true
            }
            .handleEvents(receiveCompletion: { completion in
                if case .failure = completion {
                    self.appState.authStore.isAuthenticating = false
                }
            })
            .eraseToAnyPublisher()
    }
    
    /// Sign out the current user
    /// - Returns: A publisher that emits a success boolean or an error
    func signOut() -> AnyPublisher<Bool, Error> {
        // Clear the token
        clearToken()
        
        // Reset the app state
        appState.reset()
        
        return Just(true)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    /// Save the authentication token to the keychain
    /// - Parameter token: The token to save
    private func saveToken(_ token: String) {
        do {
            try keychain.set(token, key: "authToken")
        } catch {
            print("Failed to save token: \(error)")
        }
    }
    
    /// Load the saved authentication token from the keychain
    private func loadSavedToken() {
        do {
            if let token = try keychain.get("authToken") {
                appState.authStore.token = token
                appState.isAuthenticated = true
                
                // Fetch user profile with the token
                fetchUserProfile()
            }
        } catch {
            print("Failed to load token: \(error)")
        }
    }
    
    /// Clear the authentication token from the keychain
    private func clearToken() {
        do {
            try keychain.remove("authToken")
        } catch {
            print("Failed to clear token: \(error)")
        }
    }
    
    /// Fetch the user profile
    private func fetchUserProfile() {
        apiService.get(endpoint: "auth/profile")
            .map { (response: UserProfileResponse) -> User in
                return response.user
            }
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed to fetch user profile: \(error)")
                    
                    // If unauthorized, sign out
                    if let afError = error as? AFError, afError.responseCode == 401 {
                        self.signOut().sink(receiveCompletion: { _ in }, receiveValue: { _ in }).store(in: &self.cancellables)
                    }
                }
            }, receiveValue: { user in
                self.appState.authStore.user = user
            })
            .store(in: &cancellables)
    }
}

/// Response model for authentication
struct AuthResponse: Decodable {
    let token: String
    let user: User
}

/// Response model for user profile
struct UserProfileResponse: Decodable {
    let user: User
}

// Placeholder for AFError
struct AFError: Error {
    let responseCode: Int?
}