import Foundation
import Alamofire
import Combine
import KeychainAccess

/// Service for interacting with the GitHub API
class GitHubService: ObservableObject {
    private let baseURL = "https://api.github.com"
    private let oauthURL = "https://github.com/login/oauth/authorize"
    private let tokenURL = "https://github.com/login/oauth/access_token"
    private let keychain = Keychain(service: "com.openhands.MacClient")
    private let clientId: String
    private let clientSecret: String
    private let redirectURI: String
    
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: GitHubUser?
    
    private var token: String? {
        get {
            try? keychain.get("github_token")
        }
        set {
            if let newValue = newValue {
                try? keychain.set(newValue, key: "github_token")
                isAuthenticated = true
            } else {
                try? keychain.remove("github_token")
                isAuthenticated = false
                currentUser = nil
            }
        }
    }
    
    init(clientId: String, clientSecret: String, redirectURI: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirectURI = redirectURI
        
        // Check if token exists and validate it
        if let _ = token {
            validateToken()
        }
    }
    
    // MARK: - Authentication
    
    /// Generate the GitHub OAuth URL
    func getAuthURL() -> URL {
        var components = URLComponents(string: oauthURL)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "scope", value: "repo user")
        ]
        return components.url!
    }
    
    /// Exchange the code for an access token
    func exchangeCodeForToken(code: String) -> AnyPublisher<Void, Error> {
        let parameters: [String: String] = [
            "client_id": clientId,
            "client_secret": clientSecret,
            "code": code,
            "redirect_uri": redirectURI
        ]
        
        let headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        
        return AF.request(tokenURL, method: .post, parameters: parameters, headers: headers)
            .validate()
            .publishDecodable(type: GitHubOAuthTokenResponse.self)
            .value()
            .map { [weak self] response in
                self?.token = response.accessToken
                return
            }
            .eraseToAnyPublisher()
    }
    
    /// Validate the current token
    private func validateToken() {
        guard let token = token else {
            isAuthenticated = false
            return
        }
        
        getCurrentUser()
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure = completion {
                    self?.token = nil
                }
            }, receiveValue: { [weak self] user in
                self?.currentUser = user
                self?.isAuthenticated = true
            })
            .store(in: &cancellables)
    }
    
    /// Sign out and clear the token
    func signOut() {
        token = nil
    }
    
    // MARK: - User
    
    /// Get the current authenticated user
    func getCurrentUser() -> AnyPublisher<GitHubUser, Error> {
        return request(path: "/user")
            .decode(type: GitHubUser.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    // MARK: - Repositories
    
    /// List repositories for the authenticated user
    func listRepositories() -> AnyPublisher<[GitHubRepository], Error> {
        return request(path: "/user/repos", parameters: ["sort": "updated"])
            .decode(type: [GitHubRepository].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    /// Search repositories
    func searchRepositories(query: String) -> AnyPublisher<[GitHubRepository], Error> {
        let parameters: [String: String] = [
            "q": query,
            "sort": "updated",
            "per_page": "10"
        ]
        
        return request(path: "/search/repositories", parameters: parameters)
            .decode(type: GitHubSearchResult<GitHubRepository>.self, decoder: JSONDecoder())
            .map { $0.items }
            .eraseToAnyPublisher()
    }
    
    /// Get repository details
    func getRepository(owner: String, repo: String) -> AnyPublisher<GitHubRepository, Error> {
        return request(path: "/repos/\(owner)/\(repo)")
            .decode(type: GitHubRepository.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    /// List branches for a repository
    func listBranches(owner: String, repo: String) -> AnyPublisher<[GitHubBranch], Error> {
        return request(path: "/repos/\(owner)/\(repo)/branches")
            .decode(type: [GitHubBranch].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    /// Get contents of a repository
    func getContents(owner: String, repo: String, path: String, ref: String? = nil) -> AnyPublisher<[GitHubContent], Error> {
        var parameters: [String: String] = [:]
        if let ref = ref {
            parameters["ref"] = ref
        }
        
        return request(path: "/repos/\(owner)/\(repo)/contents/\(path)", parameters: parameters)
            .decode(type: [GitHubContent].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    /// Get a single file content
    func getFileContent(owner: String, repo: String, path: String, ref: String? = nil) -> AnyPublisher<GitHubContent, Error> {
        var parameters: [String: String] = [:]
        if let ref = ref {
            parameters["ref"] = ref
        }
        
        return request(path: "/repos/\(owner)/\(repo)/contents/\(path)", parameters: parameters)
            .decode(type: GitHubContent.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    // MARK: - Helper Methods
    
    private var cancellables = Set<AnyCancellable>()
    
    private func request(path: String, method: HTTPMethod = .get, parameters: [String: String] = [:]) -> AnyPublisher<Data, Error> {
        guard let token = token else {
            return Fail(error: NSError(domain: "GitHubService", code: 401, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"]))
                .eraseToAnyPublisher()
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "token \(token)",
            "Accept": "application/vnd.github.v3+json"
        ]
        
        let url = baseURL + path
        
        return AF.request(url, method: method, parameters: parameters, headers: headers)
            .validate()
            .publishData()
            .value()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}