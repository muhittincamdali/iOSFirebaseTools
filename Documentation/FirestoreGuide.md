# Firestore Guide

<!-- TOC START -->
## Table of Contents
- [Firestore Guide](#firestore-guide)
- [🗄️ Firebase Firestore Integration Guide](#-firebase-firestore-integration-guide)
- [🚀 Quick Start](#-quick-start)
  - [1. Installation](#1-installation)
  - [2. Basic Setup](#2-basic-setup)
  - [3. First Database Operation](#3-first-database-operation)
- [📝 Basic Operations](#-basic-operations)
  - [Add Documents](#add-documents)
  - [Get Documents](#get-documents)
  - [Update Documents](#update-documents)
  - [Delete Documents](#delete-documents)
- [🔄 Real-Time Listeners](#-real-time-listeners)
  - [Listen to Document Changes](#listen-to-document-changes)
  - [Remove Listeners](#remove-listeners)
- [🔍 Queries](#-queries)
  - [Simple Queries](#simple-queries)
  - [Advanced Queries](#advanced-queries)
- [📊 Batch Operations](#-batch-operations)
  - [Batch Writes](#batch-writes)
  - [Transaction Operations](#transaction-operations)
- [🔐 Security Rules](#-security-rules)
  - [Basic Security Rules](#basic-security-rules)
  - [Role-Based Access](#role-based-access)
- [📱 Offline Support](#-offline-support)
  - [Enable Offline Persistence](#enable-offline-persistence)
  - [Offline Data Handling](#offline-data-handling)
- [🔄 Data Synchronization](#-data-synchronization)
  - [Sync Data](#sync-data)
- [📊 Performance Optimization](#-performance-optimization)
  - [Indexing](#indexing)
  - [Query Optimization](#query-optimization)
- [🚨 Error Handling](#-error-handling)
  - [Common Errors](#common-errors)
  - [Retry Logic](#retry-logic)
- [📱 Best Practices](#-best-practices)
  - [Data Modeling](#data-modeling)
  - [Query Optimization](#query-optimization)
  - [Security](#security)
- [🔗 Related Documentation](#-related-documentation)
- [📞 Support](#-support)
<!-- TOC END -->


## 🗄️ Firebase Firestore Integration Guide

Complete guide for integrating Firebase Firestore into your iOS application.

---

## 🚀 Quick Start

### 1. Installation

Add Firebase Firestore to your project:

```swift
// Swift Package Manager
dependencies: [
    .package(url: "https://github.com/muhittincamdali/iOSFirebaseTools.git", from: "1.0.0")
]

// Import the module
import iOSFirebaseTools
```

### 2. Basic Setup

```swift
import iOSFirebaseTools

// Initialize Firestore manager
let firestoreManager = FirestoreManager.shared

// Configure Firestore
let config = FirestoreConfiguration()
config.enableOfflineSupport = true
config.enableCaching = true
config.enableSecurityRules = true
config.enableRealTimeUpdates = true

firestoreManager.configure(config) { result in
    switch result {
    case .success:
        print("✅ Firestore configured successfully")
    case .failure(let error):
        print("❌ Firestore configuration failed: \(error)")
    }
}
```

### 3. First Database Operation

```swift
// Add document to Firestore
let userData = [
    "name": "John Doe",
    "email": "john@example.com",
    "age": 30,
    "createdAt": FieldValue.serverTimestamp()
]

firestoreManager.addDocument(
    collection: "users",
    data: userData
) { result in
    switch result {
    case .success(let documentID):
        print("✅ Document added: \(documentID)")
    case .failure(let error):
        print("❌ Document addition failed: \(error)")
    }
}
```

---

## 📝 Basic Operations

### Add Documents

```swift
// Add single document
let userData = [
    "name": "John Doe",
    "email": "john@example.com",
    "age": 30,
    "createdAt": FieldValue.serverTimestamp()
]

firestoreManager.addDocument(
    collection: "users",
    data: userData
) { result in
    switch result {
    case .success(let documentID):
        print("✅ Document added: \(documentID)")
    case .failure(let error):
        print("❌ Document addition failed: \(error)")
    }
}

// Add document with custom ID
firestoreManager.addDocument(
    collection: "users",
    documentID: "user123",
    data: userData
) { result in
    switch result {
    case .success(let documentID):
        print("✅ Document added with custom ID: \(documentID)")
    case .failure(let error):
        print("❌ Document addition failed: \(error)")
    }
}
```

### Get Documents

```swift
// Get single document
firestoreManager.getDocument(
    collection: "users",
    documentID: "user123"
) { result in
    switch result {
    case .success(let document):
        print("✅ Document retrieved: \(document.data())")
    case .failure(let error):
        print("❌ Document retrieval failed: \(error)")
    }
}

// Get multiple documents
firestoreManager.getDocuments(
    collection: "users",
    query: Query.whereField("age", isGreaterThan: 25)
) { result in
    switch result {
    case .success(let documents):
        print("✅ Retrieved \(documents.count) documents")
        for document in documents {
            print("Document: \(document.data())")
        }
    case .failure(let error):
        print("❌ Document retrieval failed: \(error)")
    }
}
```

### Update Documents

```swift
// Update document
let updateData = [
    "age": 31,
    "updatedAt": FieldValue.serverTimestamp()
]

firestoreManager.updateDocument(
    collection: "users",
    documentID: "user123",
    data: updateData
) { result in
    switch result {
    case .success:
        print("✅ Document updated successfully")
    case .failure(let error):
        print("❌ Document update failed: \(error)")
    }
}

// Update specific fields
firestoreManager.updateDocument(
    collection: "users",
    documentID: "user123",
    data: updateData,
    merge: true
) { result in
    switch result {
    case .success:
        print("✅ Document fields updated")
    case .failure(let error):
        print("❌ Field update failed: \(error)")
    }
}
```

### Delete Documents

```swift
// Delete document
firestoreManager.deleteDocument(
    collection: "users",
    documentID: "user123"
) { result in
    switch result {
    case .success:
        print("✅ Document deleted successfully")
    case .failure(let error):
        print("❌ Document deletion failed: \(error)")
    }
}
```

---

## 🔄 Real-Time Listeners

### Listen to Document Changes

```swift
// Listen to single document
firestoreManager.listenToDocument(
    collection: "users",
    documentID: "user123"
) { result in
    switch result {
    case .success(let document):
        print("📡 Document updated: \(document.data())")
    case .failure(let error):
        print("❌ Document listener failed: \(error)")
    }
}

// Listen to collection changes
firestoreManager.listenToCollection(
    collection: "users",
    query: Query.whereField("age", isGreaterThan: 25)
) { result in
    switch result {
    case .success(let documents):
        print("📡 Collection updated: \(documents.count) documents")
        for document in documents {
            print("Document: \(document.data())")
        }
    case .failure(let error):
        print("❌ Collection listener failed: \(error)")
    }
}
```

### Remove Listeners

```swift
// Remove document listener
firestoreManager.removeDocumentListener(
    collection: "users",
    documentID: "user123"
)

// Remove collection listener
firestoreManager.removeCollectionListener(
    collection: "users"
)
```

---

## 🔍 Queries

### Simple Queries

```swift
// Query by field
let query = Query.whereField("age", isGreaterThan: 25)

firestoreManager.getDocuments(
    collection: "users",
    query: query
) { result in
    switch result {
    case .success(let documents):
        print("✅ Found \(documents.count) users over 25")
    case .failure(let error):
        print("❌ Query failed: \(error)")
    }
}

// Query with multiple conditions
let complexQuery = Query
    .whereField("age", isGreaterThan: 25)
    .whereField("city", isEqualTo: "New York")
    .order(by: "createdAt", descending: true)
    .limit(to: 10)

firestoreManager.getDocuments(
    collection: "users",
    query: complexQuery
) { result in
    switch result {
    case .success(let documents):
        print("✅ Found \(documents.count) matching users")
    case .failure(let error):
        print("❌ Complex query failed: \(error)")
    }
}
```

### Advanced Queries

```swift
// Array queries
let arrayQuery = Query.whereField("tags", arrayContains: "swift")

// Array contains any
let arrayAnyQuery = Query.whereField("tags", arrayContainsAny: ["swift", "ios", "firebase"])

// In queries
let inQuery = Query.whereField("status", in: ["active", "pending"])

// Range queries
let rangeQuery = Query
    .whereField("price", isGreaterThanOrEqualTo: 10)
    .whereField("price", isLessThanOrEqualTo: 100)

// Full-text search (using array fields)
let searchQuery = Query.whereField("searchTerms", arrayContains: "firebase")
```

---

## 📊 Batch Operations

### Batch Writes

```swift
// Batch write operations
let batch = firestoreManager.createBatch()

// Add document
batch.addDocument(
    collection: "users",
    data: ["name": "John", "email": "john@example.com"]
)

// Update document
batch.updateDocument(
    collection: "users",
    documentID: "user123",
    data: ["age": 31]
)

// Delete document
batch.deleteDocument(
    collection: "users",
    documentID: "oldUser"
)

// Commit batch
batch.commit { result in
    switch result {
    case .success:
        print("✅ Batch write completed")
    case .failure(let error):
        print("❌ Batch write failed: \(error)")
    }
}
```

### Transaction Operations

```swift
// Transaction operations
firestoreManager.runTransaction { transaction in
    // Read document
    let userDoc = transaction.getDocument(
        collection: "users",
        documentID: "user123"
    )
    
    // Update based on current value
    if let userData = userDoc?.data(),
       let currentBalance = userData["balance"] as? Double {
        let newBalance = currentBalance - 50.0
        
        transaction.updateDocument(
            collection: "users",
            documentID: "user123",
            data: ["balance": newBalance]
        )
        
        transaction.addDocument(
            collection: "transactions",
            data: [
                "userId": "user123",
                "amount": -50.0,
                "type": "withdrawal",
                "timestamp": FieldValue.serverTimestamp()
            ]
        )
    }
    
    return nil
} { result in
    switch result {
    case .success:
        print("✅ Transaction completed")
    case .failure(let error):
        print("❌ Transaction failed: \(error)")
    }
}
```

---

## 🔐 Security Rules

### Basic Security Rules

```javascript
// Firestore security rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read/write for authenticated users
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Allow read for public data
    match /public/{document=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Allow admin access
    match /admin/{document=**} {
      allow read, write: if request.auth != null && 
        request.auth.token.admin == true;
    }
  }
}
```

### Role-Based Access

```javascript
// Role-based security rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User profiles
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Posts with role-based access
    match /posts/{postId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        (request.auth.uid == resource.data.authorId || 
         request.auth.token.role == 'admin');
    }
  }
}
```

---

## 📱 Offline Support

### Enable Offline Persistence

```swift
// Configure offline support
let config = FirestoreConfiguration()
config.enableOfflineSupport = true
config.cacheSizeBytes = 100 * 1024 * 1024 // 100MB

firestoreManager.configure(config) { result in
    switch result {
    case .success:
        print("✅ Offline support enabled")
    case .failure(let error):
        print("❌ Offline configuration failed: \(error)")
    }
}
```

### Offline Data Handling

```swift
// Check network status
firestoreManager.isNetworkAvailable { isAvailable in
    if isAvailable {
        print("✅ Network available")
    } else {
        print("📱 Working offline")
    }
}

// Enable offline persistence
firestoreManager.enableOfflinePersistence { result in
    switch result {
    case .success:
        print("✅ Offline persistence enabled")
    case .failure(let error):
        print("❌ Offline persistence failed: \(error)")
    }
}
```

---

## 🔄 Data Synchronization

### Sync Data

```swift
// Sync local changes when online
firestoreManager.syncOfflineChanges { result in
    switch result {
    case .success(let syncedCount):
        print("✅ Synced \(syncedCount) offline changes")
    case .failure(let error):
        print("❌ Sync failed: \(error)")
    }
}

// Check pending writes
firestoreManager.getPendingWrites { writes in
    print("📝 Pending writes: \(writes.count)")
}
```

---

## 📊 Performance Optimization

### Indexing

```swift
// Create composite index
firestoreManager.createIndex(
    collection: "users",
    fields: ["age", "city", "createdAt"]
) { result in
    switch result {
    case .success:
        print("✅ Index created")
    case .failure(let error):
        print("❌ Index creation failed: \(error)")
    }
}
```

### Query Optimization

```swift
// Optimize queries with proper indexing
let optimizedQuery = Query
    .whereField("age", isGreaterThan: 25)
    .whereField("city", isEqualTo: "New York")
    .order(by: "createdAt", descending: true)
    .limit(to: 10)

// Use pagination
firestoreManager.getDocumentsWithPagination(
    collection: "users",
    query: optimizedQuery,
    pageSize: 20
) { result in
    switch result {
    case .success(let paginatedResult):
        print("✅ Retrieved \(paginatedResult.documents.count) documents")
        print("Has more: \(paginatedResult.hasMore)")
    case .failure(let error):
        print("❌ Paginated query failed: \(error)")
    }
}
```

---

## 🚨 Error Handling

### Common Errors

```swift
// Handle common Firestore errors
firestoreManager.addDocument(
    collection: "users",
    data: userData
) { result in
    switch result {
    case .success(let documentID):
        print("✅ Document added: \(documentID)")
    case .failure(let error):
        switch error {
        case .permissionDenied:
            print("❌ Permission denied")
            // Handle permission error
            
        case .notFound:
            print("❌ Document not found")
            // Handle not found error
            
        case .alreadyExists:
            print("❌ Document already exists")
            // Handle duplicate error
            
        case .resourceExhausted:
            print("❌ Resource exhausted")
            // Handle quota exceeded
            
        case .unavailable:
            print("❌ Service unavailable")
            // Retry operation
            
        default:
            print("❌ Unknown error: \(error)")
        }
    }
}
```

### Retry Logic

```swift
// Implement retry logic for failed operations
func retryOperation<T>(
    operation: @escaping (@escaping (Result<T, FirestoreError>) -> Void) -> Void,
    maxAttempts: Int = 3
) {
    var attempts = 0
    
    func attemptOperation() {
        attempts += 1
        
        operation { result in
            switch result {
            case .success(let value):
                print("✅ Operation successful on attempt \(attempts)")
                // Handle success
                
            case .failure(let error):
                if attempts < maxAttempts && error.isRetryable {
                    print("❌ Attempt \(attempts) failed, retrying...")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        attemptOperation()
                    }
                } else {
                    print("❌ All \(maxAttempts) attempts failed")
                    // Handle final failure
                }
            }
        }
    }
    
    attemptOperation()
}
```

---

## 📱 Best Practices

### Data Modeling

- Design your data structure for efficient queries
- Use subcollections for related data
- Avoid deeply nested objects
- Use arrays for simple lists
- Consider denormalization for performance

### Query Optimization

- Create appropriate indexes
- Use compound queries efficiently
- Limit query results with pagination
- Cache frequently accessed data
- Use offline persistence for better UX

### Security

- Implement proper security rules
- Validate data on both client and server
- Use authentication for sensitive operations
- Implement role-based access control
- Regularly audit your security rules

---

## 🔗 Related Documentation

- [Firestore API](FirestoreAPI.md)
- [Getting Started Guide](GettingStarted.md)
- [Authentication Guide](AuthenticationGuide.md)
- [Security Guide](SecurityGuide.md)
- [Configuration API](ConfigurationAPI.md)

---

## 📞 Support

For questions and support:

- **GitHub Issues**: [Create an issue](https://github.com/muhittincamdali/iOSFirebaseTools/issues)
- **Documentation**: [Full documentation](https://github.com/muhittincamdali/iOSFirebaseTools/tree/master/Documentation)
- **Examples**: [Code examples](https://github.com/muhittincamdali/iOSFirebaseTools/tree/master/Examples)
