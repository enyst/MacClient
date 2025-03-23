import SwiftUI

struct FileExplorerView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedFile: FileItem?
    @State private var fileContent: String = ""
    
    // Sample file structure for preview
    private let sampleFiles: [FileItem] = [
        FileItem(
            path: "/workspace",
            name: "workspace",
            isDirectory: true,
            size: 0,
            modifiedAt: Date(),
            children: [
                FileItem(
                    path: "/workspace/project",
                    name: "project",
                    isDirectory: true,
                    size: 0,
                    modifiedAt: Date(),
                    children: [
                        FileItem(
                            path: "/workspace/project/main.swift",
                            name: "main.swift",
                            isDirectory: false,
                            size: 1024,
                            modifiedAt: Date()
                        ),
                        FileItem(
                            path: "/workspace/project/README.md",
                            name: "README.md",
                            isDirectory: false,
                            size: 512,
                            modifiedAt: Date()
                        )
                    ]
                ),
                FileItem(
                    path: "/workspace/notes.txt",
                    name: "notes.txt",
                    isDirectory: false,
                    size: 256,
                    modifiedAt: Date()
                )
            ]
        )
    ]
    
    var body: some View {
        NavigationSplitView {
            List(sampleFiles, children: \.children) { file in
                FileRowView(file: file)
                    .onTapGesture {
                        if !file.isDirectory {
                            selectedFile = file
                            loadFileContent(file)
                        }
                    }
            }
            .listStyle(.sidebar)
        } detail: {
            if let selectedFile = selectedFile {
                FileContentView(file: selectedFile, content: fileContent)
            } else {
                Text("Select a file to view its contents")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func loadFileContent(_ file: FileItem) {
        // In a real app, this would load the actual file content
        // For now, we'll simulate content based on file extension
        
        let fileExtension = file.name.components(separatedBy: ".").last?.lowercased() ?? ""
        
        switch fileExtension {
        case "swift":
            fileContent = """
            import Foundation
            
            func greet(name: String) -> String {
                return "Hello, \\(name)!"
            }
            
            print(greet(name: "World"))
            """
        case "md":
            fileContent = """
            # Project README
            
            This is a sample README file for the project.
            
            ## Features
            
            - Feature 1
            - Feature 2
            - Feature 3
            
            ## Installation
            
            ```bash
            git clone https://github.com/example/project.git
            cd project
            swift build
            ```
            """
        default:
            fileContent = "This is sample content for \(file.name)"
        }
    }
}

struct FileRowView: View {
    let file: FileItem
    
    var body: some View {
        HStack {
            Image(systemName: file.isDirectory ? "folder.fill" : fileIcon(for: file.name))
                .foregroundColor(file.isDirectory ? .blue : .gray)
            Text(file.name)
        }
    }
    
    private func fileIcon(for fileName: String) -> String {
        let fileExtension = fileName.components(separatedBy: ".").last?.lowercased() ?? ""
        
        switch fileExtension {
        case "swift", "kt", "java":
            return "doc.plaintext.fill"
        case "md", "txt", "rtf":
            return "doc.text.fill"
        case "json", "xml", "yaml", "yml":
            return "curlybraces"
        case "png", "jpg", "jpeg", "gif":
            return "photo.fill"
        case "pdf":
            return "doc.fill"
        case "zip", "tar", "gz":
            return "archivebox.fill"
        default:
            return "doc.fill"
        }
    }
}

struct FileContentView: View {
    let file: FileItem
    let content: String
    
    var body: some View {
        VStack {
            HStack {
                Text(file.name)
                    .font(.headline)
                Spacer()
                Text("\(formatFileSize(file.size))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            Divider()
            
            ScrollView {
                Text(content)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private func formatFileSize(_ size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}

#Preview {
    FileExplorerView()
        .environmentObject(AppState())
}