import Foundation
import Combine

/// Service for handling file operations
class FileService {
    // Singleton instance
    static let shared = FileService()
    
    // API service
    private let apiService = APIService.shared
    
    // App state
    private let appState = AppState.shared
    
    // Private initializer for singleton
    private init() {}
    
    /// List files in a directory
    /// - Parameter path: The directory path
    /// - Returns: A publisher that emits an array of file items or an error
    func listFiles(path: String) -> AnyPublisher<[FileItem], Error> {
        appState.fileStore.isLoadingFiles = true
        
        let parameters: [String: Any] = [
            "path": path
        ]
        
        return apiService.get(endpoint: "files/list", parameters: parameters)
            .map { (response: FileListResponse) -> [FileItem] in
                // Update the app state
                self.appState.fileStore.currentDirectory = path
                self.appState.fileStore.isLoadingFiles = false
                
                // Update the file store
                let fileDict = Dictionary(uniqueKeysWithValues: response.files.map { ($0.path, $0) })
                self.appState.fileStore.files = fileDict
                
                return response.files
            }
            .handleEvents(receiveCompletion: { completion in
                if case .failure = completion {
                    self.appState.fileStore.isLoadingFiles = false
                }
            })
            .eraseToAnyPublisher()
    }
    
    /// Get the content of a file
    /// - Parameter path: The file path
    /// - Returns: A publisher that emits the file content or an error
    func getFileContent(path: String) -> AnyPublisher<String, Error> {
        let parameters: [String: Any] = [
            "path": path
        ]
        
        return apiService.get(endpoint: "files/content", parameters: parameters)
            .map { (response: FileContentResponse) -> String in
                return response.content
            }
            .eraseToAnyPublisher()
    }
    
    /// Save the content of a file
    /// - Parameters:
    ///   - path: The file path
    ///   - content: The file content
    /// - Returns: A publisher that emits a success boolean or an error
    func saveFileContent(path: String, content: String) -> AnyPublisher<Bool, Error> {
        let parameters: [String: Any] = [
            "path": path,
            "content": content
        ]
        
        return apiService.post(endpoint: "files/save", parameters: parameters)
            .map { (_: FileOperationResponse) -> Bool in
                return true
            }
            .eraseToAnyPublisher()
    }
    
    /// Create a new file
    /// - Parameters:
    ///   - path: The file path
    ///   - content: The file content
    /// - Returns: A publisher that emits a success boolean or an error
    func createFile(path: String, content: String = "") -> AnyPublisher<Bool, Error> {
        let parameters: [String: Any] = [
            "path": path,
            "content": content
        ]
        
        return apiService.post(endpoint: "files/create", parameters: parameters)
            .map { (_: FileOperationResponse) -> Bool in
                return true
            }
            .eraseToAnyPublisher()
    }
    
    /// Create a new directory
    /// - Parameter path: The directory path
    /// - Returns: A publisher that emits a success boolean or an error
    func createDirectory(path: String) -> AnyPublisher<Bool, Error> {
        let parameters: [String: Any] = [
            "path": path
        ]
        
        return apiService.post(endpoint: "files/mkdir", parameters: parameters)
            .map { (_: FileOperationResponse) -> Bool in
                return true
            }
            .eraseToAnyPublisher()
    }
    
    /// Delete a file or directory
    /// - Parameter path: The path to delete
    /// - Returns: A publisher that emits a success boolean or an error
    func delete(path: String) -> AnyPublisher<Bool, Error> {
        let parameters: [String: Any] = [
            "path": path
        ]
        
        return apiService.delete(endpoint: "files/delete", parameters: parameters)
            .map { (_: FileOperationResponse) -> Bool in
                return true
            }
            .eraseToAnyPublisher()
    }
    
    /// Rename a file or directory
    /// - Parameters:
    ///   - oldPath: The old path
    ///   - newPath: The new path
    /// - Returns: A publisher that emits a success boolean or an error
    func rename(oldPath: String, newPath: String) -> AnyPublisher<Bool, Error> {
        let parameters: [String: Any] = [
            "oldPath": oldPath,
            "newPath": newPath
        ]
        
        return apiService.post(endpoint: "files/rename", parameters: parameters)
            .map { (_: FileOperationResponse) -> Bool in
                return true
            }
            .eraseToAnyPublisher()
    }
}

/// Response model for file list
struct FileListResponse: Decodable {
    let files: [FileItem]
}

/// Response model for file content
struct FileContentResponse: Decodable {
    let content: String
}

/// Response model for file operations
struct FileOperationResponse: Decodable {
    let success: Bool
    let message: String?
}