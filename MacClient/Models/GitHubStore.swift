import Foundation
import Combine

/// Store for managing GitHub state
class GitHubStore: ObservableObject {
    private let gitHubService: GitHubService
    
    @Published var repositories: [GitHubRepository] = []
    @Published var searchResults: [GitHubRepository] = []
    @Published var selectedRepository: GitHubRepository?
    @Published var branches: [GitHubBranch] = []
    @Published var selectedBranch: GitHubBranch?
    @Published var contents: [GitHubContent] = []
    @Published var currentPath: String = ""
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(gitHubService: GitHubService) {
        self.gitHubService = gitHubService
        
        // Subscribe to authentication changes
        gitHubService.$isAuthenticated
            .sink { [weak self] isAuthenticated in
                if isAuthenticated {
                    self?.loadRepositories()
                } else {
                    self?.repositories = []
                    self?.selectedRepository = nil
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Repository Actions
    
    /// Load repositories for the authenticated user
    func loadRepositories() {
        isLoading = true
        error = nil
        
        gitHubService.listRepositories()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            }, receiveValue: { [weak self] repositories in
                self?.repositories = repositories
            })
            .store(in: &cancellables)
    }
    
    /// Search repositories
    func searchRepositories(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        error = nil
        
        gitHubService.searchRepositories(query: query)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            }, receiveValue: { [weak self] repositories in
                self?.searchResults = repositories
            })
            .store(in: &cancellables)
    }
    
    /// Select a repository
    func selectRepository(_ repository: GitHubRepository) {
        selectedRepository = repository
        loadBranches(owner: repository.owner.login, repo: repository.name)
        currentPath = ""
    }
    
    // MARK: - Branch Actions
    
    /// Load branches for a repository
    func loadBranches(owner: String, repo: String) {
        isLoading = true
        error = nil
        
        gitHubService.listBranches(owner: owner, repo: repo)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            }, receiveValue: { [weak self] branches in
                self?.branches = branches
                // Select default branch
                if let defaultBranch = self?.selectedRepository?.defaultBranch,
                   let branch = branches.first(where: { $0.name == defaultBranch }) {
                    self?.selectBranch(branch)
                } else if let firstBranch = branches.first {
                    self?.selectBranch(firstBranch)
                }
            })
            .store(in: &cancellables)
    }
    
    /// Select a branch
    func selectBranch(_ branch: GitHubBranch) {
        selectedBranch = branch
        if let repository = selectedRepository {
            loadContents(owner: repository.owner.login, repo: repository.name, path: currentPath, ref: branch.name)
        }
    }
    
    // MARK: - Content Actions
    
    /// Load contents of a repository
    func loadContents(owner: String, repo: String, path: String, ref: String) {
        isLoading = true
        error = nil
        currentPath = path
        
        gitHubService.getContents(owner: owner, repo: repo, path: path, ref: ref)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.error = error
                }
            }, receiveValue: { [weak self] contents in
                self?.contents = contents
            })
            .store(in: &cancellables)
    }
    
    /// Navigate to a directory
    func navigateToDirectory(_ content: GitHubContent) {
        guard content.type == .dir,
              let repository = selectedRepository,
              let branch = selectedBranch else {
            return
        }
        
        loadContents(owner: repository.owner.login, repo: repository.name, path: content.path, ref: branch.name)
    }
    
    /// Navigate up one directory
    func navigateUp() {
        guard !currentPath.isEmpty,
              let repository = selectedRepository,
              let branch = selectedBranch else {
            return
        }
        
        let newPath = currentPath.split(separator: "/").dropLast().joined(separator: "/")
        loadContents(owner: repository.owner.login, repo: repository.name, path: newPath, ref: branch.name)
    }
    
    /// Get file content
    func getFileContent(_ content: GitHubContent) -> AnyPublisher<String, Error> {
        guard content.type == .file,
              let repository = selectedRepository,
              let branch = selectedBranch else {
            return Fail(error: NSError(domain: "GitHubStore", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid content or repository not selected"]))
                .eraseToAnyPublisher()
        }
        
        return gitHubService.getFileContent(owner: repository.owner.login, repo: repository.name, path: content.path, ref: branch.name)
            .compactMap { content in
                guard let encodedContent = content.content, let encoding = content.encoding, encoding == "base64" else {
                    return nil
                }
                
                // Remove line breaks from base64 string
                let cleanedBase64 = encodedContent.replacingOccurrences(of: "\n", with: "")
                
                // Decode base64 content
                guard let data = Data(base64Encoded: cleanedBase64) else {
                    return nil
                }
                
                return String(data: data, encoding: .utf8)
            }
            .eraseToAnyPublisher()
    }
}