import XCTest\n@testable import iOSFirebaseTools\n\nfinal class iOSFirebaseToolsTests: XCTestCase {\n    func testMigration() {\n        FirebaseMigrator.performMigration()\n    }\n}
