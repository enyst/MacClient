import SwiftUI

struct GitHubView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText: String = ""
    
    // Sample repositories for preview
    private let sampleRepositories: [GitHubRepository] = [
        GitHubRepository(
            id: 1,
            name: "swift-algorithms",
            fullName: "apple/swift-algorithms",
            description: "Swift Algorithms is an open-source package of sequence and collection algorithms, along with their related types.",
            owner: GitHubUser(id: 10639145, login: "apple", avatarUrl: nil, htmlUrl: "https://github.com/apple"),
            isPrivate: false,
            htmlUrl: "https://github.com/apple/swift-algorithms",
            updatedAt: Date()
        ),
        GitHubRepository(
            id: 2,
            name: "swift-collections",
            fullName: "apple/swift-collections",
            description: "A package of production grade Swift data structures.",
            owner: GitHubUser(id: 10639145, login: "apple", avatarUrl: nil, htmlUrl: "https://github.com/apple"),
            isPrivate: false,
            htmlUrl: "https://github.com/apple/swift-collections",
            updatedAt: Date()
        ),
        GitHubRepository(
            id: 3,
            name: "MacClient",
            fullName: "enyst/MacClient",
            description: "A macOS client for OpenHands",
            owner: GitHubUser(id: 12345, login: "enyst", avatarUrl: nil, htmlUrl: "https://github.com/enyst"),
            isPrivate: true,
            htmlUrl: "https://github.com/enyst/MacClient",
            updatedAt: Date()
        )
    ]
    
    var body: some View {
        VStack {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search repositories", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            .padding()
            
            // Repository list
            List {
                ForEach(filteredRepositories) { repo in
                    RepositoryRowView(repository: repo)
                }
            }
            .listStyle(.inset)
        }
    }
    
    private var filteredRepositories: [GitHubRepository] {
        if searchText.isEmpty {
            return sampleRepositories
        } else {
            return sampleRepositories.filter { repo in
                repo.name.localizedCaseInsensitiveContains(searchText) ||
                repo.fullName.localizedCaseInsensitiveContains(searchText) ||
                (repo.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }
}

struct RepositoryRowView: View {
    let repository: GitHubRepository
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: repository.isPrivate ? "lock.fill" : "book.fill")
                    .foregroundColor(repository.isPrivate ? .orange : .blue)
                
                Text(repository.fullName)
                    .font(.headline)
                
                Spacer()
                
                Text(formatDate(repository.updatedAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let description = repository.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                Label("View on GitHub", systemImage: "arrow.up.right.square")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Spacer()
                
                Button(action: {
                    // Clone repository action
                }) {
                    Label("Clone", systemImage: "arrow.down.doc.fill")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    GitHubView()
        .environmentObject(AppState())
}