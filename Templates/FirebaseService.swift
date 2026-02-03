// MARK: - Firebase Service Template
// Use this template to create new Firebase service integrations

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

/// Template for creating a domain-specific Firebase service.
/// Replace __COLLECTION__ with your Firestore collection name (e.g., users, products)
/// Replace __MODEL__ with your data model name (e.g., User, Product)
@MainActor
public final class __MODEL__FirebaseService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published public private(set) var items: [__MODEL__] = []
    @Published public private(set) var isLoading = false
    @Published public private(set) var error: FirebaseServiceError?
    
    // MARK: - Private Properties
    
    private let db = Firestore.firestore()
    private let collectionName = "__COLLECTION__"
    private var listener: ListenerRegistration?
    
    // MARK: - Initialization
    
    public init() {}
    
    deinit {
        listener?.remove()
    }
    
    // MARK: - CRUD Operations
    
    /// Fetch all documents from the collection
    public func fetchAll() async throws -> [__MODEL__] {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let snapshot = try await db.collection(collectionName).getDocuments()
            let items = snapshot.documents.compactMap { doc -> __MODEL__? in
                try? doc.data(as: __MODEL__.self)
            }
            self.items = items
            return items
        } catch {
            self.error = .fetchFailed(error)
            throw error
        }
    }
    
    /// Fetch a single document by ID
    public func fetch(id: String) async throws -> __MODEL__? {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let document = try await db.collection(collectionName).document(id).getDocument()
            return try document.data(as: __MODEL__.self)
        } catch {
            self.error = .fetchFailed(error)
            throw error
        }
    }
    
    /// Create a new document
    @discardableResult
    public func create(_ item: __MODEL__) async throws -> String {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let docRef = try db.collection(collectionName).addDocument(from: item)
            return docRef.documentID
        } catch {
            self.error = .createFailed(error)
            throw error
        }
    }
    
    /// Create a document with a specific ID
    public func create(_ item: __MODEL__, withId id: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try db.collection(collectionName).document(id).setData(from: item)
        } catch {
            self.error = .createFailed(error)
            throw error
        }
    }
    
    /// Update an existing document
    public func update(_ item: __MODEL__, id: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try db.collection(collectionName).document(id).setData(from: item, merge: true)
        } catch {
            self.error = .updateFailed(error)
            throw error
        }
    }
    
    /// Delete a document
    public func delete(id: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await db.collection(collectionName).document(id).delete()
            items.removeAll { $0.id == id }
        } catch {
            self.error = .deleteFailed(error)
            throw error
        }
    }
    
    // MARK: - Real-time Listeners
    
    /// Start listening for real-time updates
    public func startListening() {
        listener = db.collection(collectionName)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.error = .listenerFailed(error)
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.items = documents.compactMap { doc -> __MODEL__? in
                    try? doc.data(as: __MODEL__.self)
                }
            }
    }
    
    /// Stop listening for updates
    public func stopListening() {
        listener?.remove()
        listener = nil
    }
    
    // MARK: - Query Operations
    
    /// Query documents with a filter
    public func query(
        field: String,
        isEqualTo value: Any
    ) async throws -> [__MODEL__] {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let snapshot = try await db.collection(collectionName)
                .whereField(field, isEqualTo: value)
                .getDocuments()
            
            return snapshot.documents.compactMap { doc -> __MODEL__? in
                try? doc.data(as: __MODEL__.self)
            }
        } catch {
            self.error = .queryFailed(error)
            throw error
        }
    }
    
    /// Query with pagination
    public func queryPaginated(
        limit: Int,
        startAfter lastDocument: DocumentSnapshot? = nil
    ) async throws -> (items: [__MODEL__], lastDoc: DocumentSnapshot?) {
        isLoading = true
        defer { isLoading = false }
        
        do {
            var query = db.collection(collectionName)
                .order(by: "createdAt", descending: true)
                .limit(to: limit)
            
            if let lastDoc = lastDocument {
                query = query.start(afterDocument: lastDoc)
            }
            
            let snapshot = try await query.getDocuments()
            let items = snapshot.documents.compactMap { doc -> __MODEL__? in
                try? doc.data(as: __MODEL__.self)
            }
            
            return (items, snapshot.documents.last)
        } catch {
            self.error = .queryFailed(error)
            throw error
        }
    }
    
    // MARK: - Batch Operations
    
    /// Perform batch write operations
    public func batchCreate(_ items: [__MODEL__]) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let batch = db.batch()
        
        for item in items {
            let docRef = db.collection(collectionName).document()
            try batch.setData(from: item, forDocument: docRef)
        }
        
        try await batch.commit()
    }
    
    /// Perform batch delete
    public func batchDelete(ids: [String]) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let batch = db.batch()
        
        for id in ids {
            let docRef = db.collection(collectionName).document(id)
            batch.deleteDocument(docRef)
        }
        
        try await batch.commit()
        items.removeAll { ids.contains($0.id ?? "") }
    }
}

// MARK: - Error Types

public enum FirebaseServiceError: LocalizedError {
    case fetchFailed(Error)
    case createFailed(Error)
    case updateFailed(Error)
    case deleteFailed(Error)
    case queryFailed(Error)
    case listenerFailed(Error)
    
    public var errorDescription: String? {
        switch self {
        case .fetchFailed(let error):
            return "Failed to fetch: \(error.localizedDescription)"
        case .createFailed(let error):
            return "Failed to create: \(error.localizedDescription)"
        case .updateFailed(let error):
            return "Failed to update: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete: \(error.localizedDescription)"
        case .queryFailed(let error):
            return "Failed to query: \(error.localizedDescription)"
        case .listenerFailed(let error):
            return "Listener failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - Model Protocol

/// Your model must conform to this protocol
public protocol __MODEL__: Codable, Identifiable {
    var id: String? { get set }
    var createdAt: Date { get }
    var updatedAt: Date { get }
}

// MARK: - Usage Example
/*
 
 // 1. Define your model
 struct Product: __MODEL__ {
     @DocumentID var id: String?
     let name: String
     let price: Double
     let createdAt: Date
     var updatedAt: Date
 }
 
 // 2. Create the service
 let productService = ProductFirebaseService()
 
 // 3. Fetch all products
 let products = try await productService.fetchAll()
 
 // 4. Create a new product
 let product = Product(name: "iPhone", price: 999, createdAt: Date(), updatedAt: Date())
 let id = try await productService.create(product)
 
 // 5. Listen for real-time updates
 productService.startListening()
 
 // 6. In SwiftUI
 struct ProductListView: View {
     @StateObject private var service = ProductFirebaseService()
     
     var body: some View {
         List(service.items) { product in
             Text(product.name)
         }
         .task {
             try? await service.fetchAll()
         }
     }
 }
 
 */
