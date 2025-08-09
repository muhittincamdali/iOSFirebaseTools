# Firestore API

<!-- TOC START -->
## Table of Contents
- [Firestore API](#firestore-api)
- [Overview](#overview)
- [Core Features](#core-features)
- [Usage](#usage)
- [Features](#features)
<!-- TOC END -->


## Overview

The Firestore API provides comprehensive Firestore database operations for iOS applications.

## Core Features

- **CRUD Operations**: Create, Read, Update, Delete operations
- **Real-time Updates**: Listen to real-time data changes
- **Offline Support**: Work offline with automatic sync
- **Queries**: Complex query operations
- **Transactions**: Atomic database operations

## Usage

```swift
import iOSFirebaseTools

let firestoreManager = FirestoreManager()

// Add document
firestoreManager.addDocument(
    collection: "users",
    data: ["name": "John", "email": "john@example.com"]
) { result in
    // Handle result
}

// Get document
firestoreManager.getDocument(
    collection: "users",
    documentId: "user123"
) { result in
    // Handle result
}

// Real-time listener
firestoreManager.listenToCollection("users") { documents in
    // Handle real-time updates
}
```

## Features

- **CRUD Operations**: Full database operations
- **Real-time**: Live data synchronization
- **Offline**: Work without internet
- **Queries**: Complex data queries
- **Transactions**: Atomic operations
