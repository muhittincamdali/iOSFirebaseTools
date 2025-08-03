# Contributing to iOSFirebaseTools

🎉 **Thank you for your interest in contributing to iOSFirebaseTools!** 

This document provides guidelines and information for contributors who want to help improve this project.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Documentation Standards](#documentation-standards)
- [Pull Request Process](#pull-request-process)
- [Release Process](#release-process)
- [Community Guidelines](#community-guidelines)

## 🤝 Code of Conduct

This project and its participants are governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

### Our Standards

- **Respectful Communication**: Be respectful and inclusive in all interactions
- **Professional Behavior**: Maintain professional standards in all contributions
- **Constructive Feedback**: Provide constructive and helpful feedback
- **Inclusive Environment**: Create an inclusive environment for all contributors

## 🚀 Getting Started

### Prerequisites

- **Xcode 15.0+** with iOS 15.0+ SDK
- **Swift 5.9+** 
- **Firebase SDK 10.18.0+**
- **Git** for version control
- **SwiftLint** for code style enforcement

### Required Tools

```bash
# Install SwiftLint
brew install swiftlint

# Install Firebase CLI
npm install -g firebase-tools

# Install Xcode Command Line Tools
xcode-select --install
```

## 🛠️ Development Setup

### 1. Fork and Clone

```bash
# Fork the repository on GitHub
# Then clone your fork
git clone https://github.com/your-username/iOSFirebaseTools.git
cd iOSFirebaseTools

# Add upstream remote
git remote add upstream https://github.com/muhittincamdali/iOSFirebaseTools.git
```

### 2. Setup Development Environment

```bash
# Install dependencies
swift package resolve

# Setup Firebase project
firebase init

# Configure Firebase
cp Firebase/GoogleService-Info-Example.plist Firebase/GoogleService-Info.plist
# Edit GoogleService-Info.plist with your Firebase project details
```

### 3. Build and Test

```bash
# Build the project
swift build

# Run tests
swift test

# Run SwiftLint
swiftlint lint

# Build documentation
swift package generate-documentation
```

## 📝 Coding Standards

### Swift Style Guide

We follow the [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/) and use SwiftLint for enforcement.

#### Naming Conventions

```swift
// ✅ Correct
class FirebaseAuthManager {
    func signInUser(email: String, password: String) async throws -> User
}

// ❌ Incorrect
class firebaseAuthManager {
    func signinuser(email: String, password: String) async throws -> User
}
```

#### Code Organization

```swift
// MARK: - Imports
import Foundation
import FirebaseAuth

// MARK: - Protocols
protocol AuthServiceProtocol {
    func signIn(email: String, password: String) async throws -> User
}

// MARK: - Main Class
public class FirebaseAuthManager: ObservableObject {
    
    // MARK: - Singleton
    public static let shared = FirebaseAuthManager()
    
    // MARK: - Published Properties
    @Published public var currentUser: User?
    
    // MARK: - Private Properties
    private let auth = Auth.auth()
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Public Methods
    public func signIn(email: String, password: String) async throws -> User {
        // Implementation
    }
    
    // MARK: - Private Methods
    private func setupAuthStateListener() {
        // Implementation
    }
}
```

#### Documentation Standards

```swift
/// Manages Firebase Authentication operations with advanced features.
///
/// This class provides a comprehensive wrapper around Firebase Auth,
/// including social authentication, biometric authentication, and
/// real-time state management.
///
/// ## Usage Example
/// ```swift
/// let authManager = FirebaseAuthManager.shared
/// do {
///     let user = try await authManager.signIn(email: "user@example.com", password: "password")
///     print("Signed in: \(user.displayName)")
/// } catch {
///     print("Sign in failed: \(error)")
/// }
/// ```
///
/// ## Features
/// - Email/password authentication
/// - Social authentication (Apple, Google, Facebook)
/// - Biometric authentication
/// - Real-time auth state monitoring
/// - Profile management
///
/// - Author: Muhittin Camdali
/// - Since: 1.0.0
/// - Version: 2.1.0
public class FirebaseAuthManager: ObservableObject {
    // Implementation
}
```

### Architecture Guidelines

#### Clean Architecture

```swift
// Domain Layer
protocol UserRepositoryProtocol {
    func getUser(id: String) async throws -> User
    func saveUser(_ user: User) async throws
}

// Data Layer
class FirebaseUserRepository: UserRepositoryProtocol {
    func getUser(id: String) async throws -> User {
        // Implementation
    }
}

// Presentation Layer
class UserViewModel: ObservableObject {
    @Published var user: User?
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
}
```

#### SOLID Principles

```swift
// Single Responsibility Principle
class AuthService {
    func authenticate(email: String, password: String) async throws -> User
}

class UserService {
    func getUserProfile(id: String) async throws -> UserProfile
}

// Open/Closed Principle
protocol AuthProvider {
    func authenticate() async throws -> User
}

class EmailAuthProvider: AuthProvider {
    func authenticate() async throws -> User
}

class AppleAuthProvider: AuthProvider {
    func authenticate() async throws -> User
}
```

## 🧪 Testing Guidelines

### Test Structure

```swift
import XCTest
@testable import iOSFirebaseTools

final class FirebaseAuthManagerTests: XCTestCase {
    
    // MARK: - Properties
    var authManager: FirebaseAuthManager!
    var mockAuth: MockFirebaseAuth!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        mockAuth = MockFirebaseAuth()
        authManager = FirebaseAuthManager(auth: mockAuth)
    }
    
    override func tearDown() {
        authManager = nil
        mockAuth = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    func testSignInSuccess() async throws {
        // Given
        let email = "test@example.com"
        let password = "password123"
        mockAuth.shouldSucceed = true
        
        // When
        let user = try await authManager.signIn(email: email, password: password)
        
        // Then
        XCTAssertNotNil(user)
        XCTAssertEqual(user.email, email)
    }
    
    func testSignInFailure() async {
        // Given
        let email = "test@example.com"
        let password = "wrongpassword"
        mockAuth.shouldSucceed = false
        
        // When & Then
        do {
            _ = try await authManager.signIn(email: email, password: password)
            XCTFail("Should throw error")
        } catch {
            XCTAssertTrue(error is FirebaseAuthError)
        }
    }
}
```

### Test Coverage Requirements

- **Unit Tests**: 100% coverage for all public methods
- **Integration Tests**: All Firebase service integrations
- **UI Tests**: All user interactions and flows
- **Performance Tests**: Memory usage and response times

### Running Tests

```bash
# Run all tests
swift test

# Run specific test
swift test --filter FirebaseAuthManagerTests

# Run with coverage
swift test --enable-code-coverage

# Generate coverage report
xcrun llvm-cov show -format=html .build/debug/iOSFirebaseToolsPackageTests.xctest/Contents/MacOS/iOSFirebaseToolsPackageTests > coverage.html
```

## 📚 Documentation Standards

### README Requirements

- ✅ Project description and features
- ✅ Installation instructions
- ✅ Quick start guide
- ✅ Usage examples
- ✅ API documentation links
- ✅ Contributing guidelines
- ✅ License information

### API Documentation

```swift
/// Signs in a user with email and password.
///
/// This method authenticates a user using Firebase Authentication.
/// It supports both new and existing users.
///
/// - Parameters:
///   - email: The user's email address
///   - password: The user's password (minimum 6 characters)
///
/// - Returns: A `User` object representing the authenticated user
///
/// - Throws: `FirebaseAuthError.signInFailed` if authentication fails
///
/// ## Example
/// ```swift
/// do {
///     let user = try await authManager.signIn(
///         email: "user@example.com",
///         password: "securepassword123"
///     )
///     print("Welcome, \(user.displayName ?? "User")!")
/// } catch {
///     print("Sign in failed: \(error.localizedDescription)")
/// }
/// ```
///
/// ## Security Notes
/// - Passwords are encrypted in transit
/// - Failed attempts are rate-limited
/// - Account lockout after multiple failures
///
/// - Since: 1.0.0
/// - Version: 2.1.0
public func signIn(email: String, password: String) async throws -> User
```

## 🔄 Pull Request Process

### 1. Create Feature Branch

```bash
git checkout -b feature/awesome-feature
```

### 2. Make Changes

- Write clean, documented code
- Add comprehensive tests
- Update documentation
- Follow coding standards

### 3. Commit Guidelines

```bash
# Use conventional commits
git commit -m "feat: add biometric authentication support"
git commit -m "fix: resolve memory leak in analytics tracking"
git commit -m "docs: update API documentation"
git commit -m "test: add unit tests for auth manager"
git commit -m "refactor: improve error handling in storage tools"
```

### 4. Push and Create PR

```bash
git push origin feature/awesome-feature
# Create PR on GitHub
```

### 5. PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update
- [ ] Performance improvement

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] UI tests added/updated
- [ ] All tests pass

## Documentation
- [ ] README updated
- [ ] API documentation updated
- [ ] Examples updated
- [ ] Migration guide updated

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Code is well documented
- [ ] Tests are comprehensive
- [ ] No breaking changes (or documented)
```

## 🚀 Release Process

### Version Bumping

```bash
# Update version in Package.swift
# Update CHANGELOG.md
# Create release branch
git checkout -b release/2.1.1

# Commit changes
git commit -m "chore: bump version to 2.1.1"

# Create tag
git tag -a v2.1.1 -m "Release version 2.1.1"
git push origin v2.1.1
```

### Release Checklist

- [ ] All tests pass
- [ ] Documentation is up to date
- [ ] CHANGELOG.md is updated
- [ ] Version is bumped
- [ ] Release notes are written
- [ ] GitHub release is created
- [ ] CocoaPods spec is updated (if applicable)

## 👥 Community Guidelines

### Communication

- **Be Respectful**: Treat all contributors with respect
- **Be Helpful**: Provide constructive feedback and assistance
- **Be Patient**: Understand that contributors have different skill levels
- **Be Inclusive**: Welcome contributors from all backgrounds

### Recognition

- Contributors will be listed in the README
- Significant contributions will be highlighted in releases
- Community members will be recognized for their work

### Getting Help

- **Issues**: Use GitHub Issues for bug reports and feature requests
- **Discussions**: Use GitHub Discussions for questions and ideas
- **Documentation**: Check the documentation first
- **Examples**: Review the example projects

## 🏆 Recognition

### Contributors Hall of Fame

We recognize and appreciate all contributors to this project. Your contributions help make iOSFirebaseTools better for the entire iOS development community.

### Contribution Levels

- **Bronze**: 1-5 contributions
- **Silver**: 6-15 contributions  
- **Gold**: 16-30 contributions
- **Platinum**: 31+ contributions

## 📞 Contact

- **Issues**: [GitHub Issues](https://github.com/muhittincamdali/iOSFirebaseTools/issues)
- **Discussions**: [GitHub Discussions](https://github.com/muhittincamdali/iOSFirebaseTools/discussions)
- **Email**: muhittincamdali@example.com
- **Twitter**: [@muhittincamdali](https://twitter.com/muhittincamdali)

---

**Thank you for contributing to iOSFirebaseTools! 🚀**

Together, we're building the future of iOS Firebase development. 