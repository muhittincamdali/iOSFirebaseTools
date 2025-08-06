import Foundation
import FirebaseStorage

/// Firebase Storage Manager for handling file uploads, downloads, and management
public class FirebaseStorageManager {
    
    // MARK: - Singleton
    public static let shared = FirebaseStorageManager()
    private init() {}
    
    // MARK: - Properties
    private let storage = Storage.storage()
    private var storageRef: StorageReference?
    
    // MARK: - Configuration
    public struct StorageConfiguration {
        public var enableCaching: Bool = true
        public var enableCompression: Bool = true
        public var maxUploadSize: Int64 = 100 * 1024 * 1024 // 100MB
        public var cacheExpiration: TimeInterval = 3600 // 1 hour
        public var enableMetadata: Bool = true
        public var enableSecurityRules: Bool = true
        
        public init() {}
    }
    
    // MARK: - Error Types
    public enum StorageError: Error, LocalizedError {
        case uploadFailed(Error)
        case downloadFailed(Error)
        case deleteFailed(Error)
        case invalidPath
        case fileTooLarge
        case networkError
        case permissionDenied
        case quotaExceeded
        
        public var errorDescription: String? {
            switch self {
            case .uploadFailed(let error):
                return "Upload failed: \(error.localizedDescription)"
            case .downloadFailed(let error):
                return "Download failed: \(error.localizedDescription)"
            case .deleteFailed(let error):
                return "Delete failed: \(error.localizedDescription)"
            case .invalidPath:
                return "Invalid storage path"
            case .fileTooLarge:
                return "File size exceeds maximum allowed size"
            case .networkError:
                return "Network connection error"
            case .permissionDenied:
                return "Permission denied for storage operation"
            case .quotaExceeded:
                return "Storage quota exceeded"
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Configure the storage manager
    /// - Parameter config: Storage configuration
    /// - Parameter completion: Completion handler
    public func configure(_ config: StorageConfiguration, completion: @escaping (Result<Void, StorageError>) -> Void) {
        storageRef = storage.reference()
        
        // Configure caching
        if config.enableCaching {
            let settings = StorageSettings()
            settings.cacheMaxBytes = 100 * 1024 * 1024 // 100MB cache
            storage.useEmulator(withHost: "localhost", port: 9199)
        }
        
        completion(.success(()))
    }
    
    /// Upload file to Firebase Storage
    /// - Parameters:
    ///   - data: File data to upload
    ///   - path: Storage path
    ///   - metadata: Optional metadata
    ///   - completion: Completion handler
    public func uploadFile(
        data: Data,
        path: String,
        metadata: StorageMetadata? = nil,
        completion: @escaping (Result<StorageReference, StorageError>) -> Void
    ) {
        guard let storageRef = storageRef else {
            completion(.failure(.invalidPath))
            return
        }
        
        let fileRef = storageRef.child(path)
        
        // Check file size
        if data.count > 100 * 1024 * 1024 { // 100MB limit
            completion(.failure(.fileTooLarge))
            return
        }
        
        let uploadTask = fileRef.putData(data, metadata: metadata) { metadata, error in
            if let error = error {
                completion(.failure(.uploadFailed(error)))
                return
            }
            
            completion(.success(fileRef))
        }
        
        // Monitor upload progress
        uploadTask.observe(.progress) { snapshot in
            let progress = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print("Upload progress: \(Int(progress * 100))%")
        }
    }
    
    /// Upload file from URL
    /// - Parameters:
    ///   - url: Local file URL
    ///   - path: Storage path
    ///   - metadata: Optional metadata
    ///   - completion: Completion handler
    public func uploadFile(
        from url: URL,
        path: String,
        metadata: StorageMetadata? = nil,
        completion: @escaping (Result<StorageReference, StorageError>) -> Void
    ) {
        guard let storageRef = storageRef else {
            completion(.failure(.invalidPath))
            return
        }
        
        let fileRef = storageRef.child(path)
        
        let uploadTask = fileRef.putFile(from: url, metadata: metadata) { metadata, error in
            if let error = error {
                completion(.failure(.uploadFailed(error)))
                return
            }
            
            completion(.success(fileRef))
        }
        
        // Monitor upload progress
        uploadTask.observe(.progress) { snapshot in
            let progress = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print("Upload progress: \(Int(progress * 100))%")
        }
    }
    
    /// Download file from Firebase Storage
    /// - Parameters:
    ///   - path: Storage path
    ///   - completion: Completion handler
    public func downloadFile(
        path: String,
        completion: @escaping (Result<Data, StorageError>) -> Void
    ) {
        guard let storageRef = storageRef else {
            completion(.failure(.invalidPath))
            return
        }
        
        let fileRef = storageRef.child(path)
        
        fileRef.getData(maxSize: 100 * 1024 * 1024) { data, error in
            if let error = error {
                completion(.failure(.downloadFailed(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.downloadFailed(NSError(domain: "Storage", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"]))))
                return
            }
            
            completion(.success(data))
        }
    }
    
    /// Download file to local URL
    /// - Parameters:
    ///   - path: Storage path
    ///   - localURL: Local URL to save file
    ///   - completion: Completion handler
    public func downloadFile(
        path: String,
        to localURL: URL,
        completion: @escaping (Result<URL, StorageError>) -> Void
    ) {
        guard let storageRef = storageRef else {
            completion(.failure(.invalidPath))
            return
        }
        
        let fileRef = storageRef.child(path)
        
        let downloadTask = fileRef.write(toFile: localURL) { url, error in
            if let error = error {
                completion(.failure(.downloadFailed(error)))
                return
            }
            
            guard let url = url else {
                completion(.failure(.downloadFailed(NSError(domain: "Storage", code: -1, userInfo: [NSLocalizedDescriptionKey: "No URL received"]))))
                return
            }
            
            completion(.success(url))
        }
        
        // Monitor download progress
        downloadTask.observe(.progress) { snapshot in
            let progress = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            print("Download progress: \(Int(progress * 100))%")
        }
    }
    
    /// Get download URL for file
    /// - Parameters:
    ///   - path: Storage path
    ///   - completion: Completion handler
    public func getDownloadURL(
        path: String,
        completion: @escaping (Result<URL, StorageError>) -> Void
    ) {
        guard let storageRef = storageRef else {
            completion(.failure(.invalidPath))
            return
        }
        
        let fileRef = storageRef.child(path)
        
        fileRef.downloadURL { url, error in
            if let error = error {
                completion(.failure(.downloadFailed(error)))
                return
            }
            
            guard let url = url else {
                completion(.failure(.downloadFailed(NSError(domain: "Storage", code: -1, userInfo: [NSLocalizedDescriptionKey: "No URL received"]))))
                return
            }
            
            completion(.success(url))
        }
    }
    
    /// Delete file from Firebase Storage
    /// - Parameters:
    ///   - path: Storage path
    ///   - completion: Completion handler
    public func deleteFile(
        path: String,
        completion: @escaping (Result<Void, StorageError>) -> Void
    ) {
        guard let storageRef = storageRef else {
            completion(.failure(.invalidPath))
            return
        }
        
        let fileRef = storageRef.child(path)
        
        fileRef.delete { error in
            if let error = error {
                completion(.failure(.deleteFailed(error)))
                return
            }
            
            completion(.success(()))
        }
    }
    
    /// List files in directory
    /// - Parameters:
    ///   - path: Directory path
    ///   - completion: Completion handler
    public func listFiles(
        path: String,
        completion: @escaping (Result<[StorageReference], StorageError>) -> Void
    ) {
        guard let storageRef = storageRef else {
            completion(.failure(.invalidPath))
            return
        }
        
        let directoryRef = storageRef.child(path)
        
        directoryRef.listAll { result, error in
            if let error = error {
                completion(.failure(.downloadFailed(error)))
                return
            }
            
            guard let result = result else {
                completion(.failure(.downloadFailed(NSError(domain: "Storage", code: -1, userInfo: [NSLocalizedDescriptionKey: "No result received"]))))
                return
            }
            
            completion(.success(result.items))
        }
    }
    
    /// Get file metadata
    /// - Parameters:
    ///   - path: Storage path
    ///   - completion: Completion handler
    public func getMetadata(
        path: String,
        completion: @escaping (Result<StorageMetadata, StorageError>) -> Void
    ) {
        guard let storageRef = storageRef else {
            completion(.failure(.invalidPath))
            return
        }
        
        let fileRef = storageRef.child(path)
        
        fileRef.getMetadata { metadata, error in
            if let error = error {
                completion(.failure(.downloadFailed(error)))
                return
            }
            
            guard let metadata = metadata else {
                completion(.failure(.downloadFailed(NSError(domain: "Storage", code: -1, userInfo: [NSLocalizedDescriptionKey: "No metadata received"]))))
                return
            }
            
            completion(.success(metadata))
        }
    }
    
    /// Update file metadata
    /// - Parameters:
    ///   - path: Storage path
    ///   - metadata: New metadata
    ///   - completion: Completion handler
    public func updateMetadata(
        path: String,
        metadata: StorageMetadata,
        completion: @escaping (Result<StorageMetadata, StorageError>) -> Void
    ) {
        guard let storageRef = storageRef else {
            completion(.failure(.invalidPath))
            return
        }
        
        let fileRef = storageRef.child(path)
        
        fileRef.updateMetadata(metadata) { metadata, error in
            if let error = error {
                completion(.failure(.uploadFailed(error)))
                return
            }
            
            guard let metadata = metadata else {
                completion(.failure(.uploadFailed(NSError(domain: "Storage", code: -1, userInfo: [NSLocalizedDescriptionKey: "No metadata received"]))))
                return
            }
            
            completion(.success(metadata))
        }
    }
    
    /// Upload image with compression
    /// - Parameters:
    ///   - image: UIImage to upload
    ///   - path: Storage path
    ///   - quality: JPEG quality (0.0 to 1.0)
    ///   - completion: Completion handler
    public func uploadImage(
        _ image: UIImage,
        path: String,
        quality: CGFloat = 0.8,
        completion: @escaping (Result<StorageReference, StorageError>) -> Void
    ) {
        guard let imageData = image.jpegData(compressionQuality: quality) else {
            completion(.failure(.uploadFailed(NSError(domain: "Storage", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"]))))
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        uploadFile(data: imageData, path: path, metadata: metadata, completion: completion)
    }
    
    /// Upload video file
    /// - Parameters:
    ///   - videoURL: Local video URL
    ///   - path: Storage path
    ///   - completion: Completion handler
    public func uploadVideo(
        from videoURL: URL,
        path: String,
        completion: @escaping (Result<StorageReference, StorageError>) -> Void
    ) {
        let metadata = StorageMetadata()
        metadata.contentType = "video/mp4"
        
        uploadFile(from: videoURL, path: path, metadata: metadata, completion: completion)
    }
    
    /// Upload document file
    /// - Parameters:
    ///   - documentURL: Local document URL
    ///   - path: Storage path
    ///   - completion: Completion handler
    public func uploadDocument(
        from documentURL: URL,
        path: String,
        completion: @escaping (Result<StorageReference, StorageError>) -> Void
    ) {
        let metadata = StorageMetadata()
        metadata.contentType = "application/pdf"
        
        uploadFile(from: documentURL, path: path, metadata: metadata, completion: completion)
    }
    
    /// Cancel upload task
    /// - Parameter task: Upload task to cancel
    public func cancelUpload(_ task: StorageUploadTask) {
        task.cancel()
    }
    
    /// Cancel download task
    /// - Parameter task: Download task to cancel
    public func cancelDownload(_ task: StorageDownloadTask) {
        task.cancel()
    }
    
    /// Pause upload task
    /// - Parameter task: Upload task to pause
    public func pauseUpload(_ task: StorageUploadTask) {
        task.pause()
    }
    
    /// Resume upload task
    /// - Parameter task: Upload task to resume
    public func resumeUpload(_ task: StorageUploadTask) {
        task.resume()
    }
    
    /// Pause download task
    /// - Parameter task: Download task to pause
    public func pauseDownload(_ task: StorageDownloadTask) {
        task.pause()
    }
    
    /// Resume download task
    /// - Parameter task: Download task to resume
    public func resumeDownload(_ task: StorageDownloadTask) {
        task.resume()
    }
}

// MARK: - Extensions

extension FirebaseStorageManager {
    
    /// Create storage reference for path
    /// - Parameter path: Storage path
    /// - Returns: Storage reference
    public func reference(for path: String) -> StorageReference? {
        return storageRef?.child(path)
    }
    
    /// Get root storage reference
    /// - Returns: Root storage reference
    public func rootReference() -> StorageReference? {
        return storageRef
    }
    
    /// Check if file exists
    /// - Parameters:
    ///   - path: Storage path
    ///   - completion: Completion handler
    public func fileExists(
        path: String,
        completion: @escaping (Result<Bool, StorageError>) -> Void
    ) {
        getMetadata(path: path) { result in
            switch result {
            case .success:
                completion(.success(true))
            case .failure:
                completion(.success(false))
            }
        }
    }
    
    /// Get file size
    /// - Parameters:
    ///   - path: Storage path
    ///   - completion: Completion handler
    public func getFileSize(
        path: String,
        completion: @escaping (Result<Int64, StorageError>) -> Void
    ) {
        getMetadata(path: path) { result in
            switch result {
            case .success(let metadata):
                completion(.success(metadata.size))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
