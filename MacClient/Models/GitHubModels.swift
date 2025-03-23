import Foundation

/// GitHub repository model
struct GitHubRepository: Identifiable, Codable {
    var id: Int
    var name: String
    var fullName: String
    var owner: GitHubUser
    var description: String?
    var isPrivate: Bool
    var htmlUrl: URL
    var updatedAt: Date
    var stargazersCount: Int
    var forksCount: Int
    var language: String?
    var defaultBranch: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case fullName = "full_name"
        case owner
        case description
        case isPrivate = "private"
        case htmlUrl = "html_url"
        case updatedAt = "updated_at"
        case stargazersCount = "stargazers_count"
        case forksCount = "forks_count"
        case language
        case defaultBranch = "default_branch"
    }
}

/// GitHub user model
struct GitHubUser: Identifiable, Codable {
    var id: Int
    var login: String
    var avatarUrl: URL
    var htmlUrl: URL
    var name: String?
    var email: String?
    var bio: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case login
        case avatarUrl = "avatar_url"
        case htmlUrl = "html_url"
        case name
        case email
        case bio
    }
}

/// GitHub branch model
struct GitHubBranch: Identifiable, Codable {
    var id: String { name }
    var name: String
    var commit: GitHubCommit
    var protected: Bool
}

/// GitHub commit model
struct GitHubCommit: Codable {
    var sha: String
    var url: URL
}

/// GitHub content model
struct GitHubContent: Identifiable, Codable {
    var id: String { path }
    var name: String
    var path: String
    var sha: String
    var size: Int
    var url: URL
    var htmlUrl: URL
    var downloadUrl: URL?
    var type: GitHubContentType
    var content: String?
    var encoding: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case path
        case sha
        case size
        case url
        case htmlUrl = "html_url"
        case downloadUrl = "download_url"
        case type
        case content
        case encoding
    }
}

/// GitHub content type
enum GitHubContentType: String, Codable {
    case file
    case dir
    case symlink
    case submodule
}

/// GitHub search result model
struct GitHubSearchResult<T: Codable>: Codable {
    var totalCount: Int
    var incompleteResults: Bool
    var items: [T]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
        case items
    }
}

/// GitHub error model
struct GitHubError: Codable, Error {
    var message: String
    var documentation_url: String?
}

/// GitHub OAuth token response
struct GitHubOAuthTokenResponse: Codable {
    var accessToken: String
    var tokenType: String
    var scope: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
    }
}