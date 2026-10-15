import XCTest

/// End-to-end tests on a simulator: the app talks to the Firebase Local Emulator Suite, which
/// must be running with `Emulators/firebase.json` (scripts/start-emulators.sh, or
/// `firebase emulators:exec` as in scripts/capture-screenshots.sh and CI).
///
/// With `SCREENSHOT_DIR` set, the tests also save the README screenshots there.
@MainActor
final class FirebaseLabUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-reset"]
        app.launch()
    }

    func testSignUpWriteAndPinNotes() throws {
        let email = Self.newEmail()
        fill(email: email, password: "correct horse")
        save("sign-in")
        submit("sign-up")
        XCTAssertTrue(app.navigationBars["Notes"].waitForExistence(timeout: 15), "Sign-up did not open the notes")

        for text in ["Book the venue for Saturday", "Buy oat milk", "Call the dentist"] {
            addNote(text)
        }
        dismissKeyboard()
        let venue = noteCell("Book the venue for Saturday")
        venue.swipeRight()
        app.buttons["Pin"].tap()
        XCTAssertTrue(app.images["Pinned"].waitForExistence(timeout: 10), "The note was not pinned")
        let firstNote = app.cells.element(boundBy: 0).staticTexts.element(boundBy: 0).label
        XCTAssertTrue(firstNote.hasPrefix("Book the venue"), "Pinned notes come first, found \(firstNote)")
        save("notes")

        app.buttons["account"].tap()
        let shownEmail = app.staticTexts["user-email"]
        XCTAssertTrue(shownEmail.waitForExistence(timeout: 5))
        XCTAssertTrue(shownEmail.label.contains(email), shownEmail.label)
        let token = app.descendants(matching: .any)["id-token"]
        XCTAssertTrue(token.label.contains("redacted"), "The ID token must not be shown: \(token.label)")
        save("account")
        app.buttons["done"].tap()
    }

    func testNotesBelongToTheirOwnerAcrossSignIns() throws {
        let email = Self.newEmail()
        fill(email: email, password: "correct horse")
        submit("sign-up")
        XCTAssertTrue(app.navigationBars["Notes"].waitForExistence(timeout: 15))
        addNote("Only mine")
        signOut()

        // A second user sees none of the first user's notes.
        fill(email: Self.newEmail(), password: "correct horse")
        submit("sign-up")
        XCTAssertTrue(app.staticTexts["No Notes Yet"].waitForExistence(timeout: 15))
        signOut()

        fill(email: email, password: "correct horse")
        submit("sign-in")
        XCTAssertTrue(noteCell("Only mine").waitForExistence(timeout: 15), "The note did not survive signing out and in")
        dismissKeyboard()
        noteCell("Only mine").swipeLeft()
        // A long swipe deletes at once; a short one shows the Delete button.
        let delete = app.buttons["Delete"]
        if delete.waitForExistence(timeout: 2) { delete.tap() }
        XCTAssertTrue(app.staticTexts["No Notes Yet"].waitForExistence(timeout: 10))
    }

    func testWrongPasswordShowsAnError() throws {
        let email = Self.newEmail()
        fill(email: email, password: "correct horse")
        submit("sign-up")
        XCTAssertTrue(app.navigationBars["Notes"].waitForExistence(timeout: 15))
        signOut()

        fill(email: email, password: "not the password")
        submit("sign-in")
        let message = app.descendants(matching: .any).matching(identifier: "message").firstMatch
        XCTAssertTrue(message.waitForExistence(timeout: 10))
        XCTAssertTrue(message.label.contains("Wrong e-mail or password"), message.label)
    }

    func testContinueWithoutAnAccount() throws {
        app.buttons["anonymous"].tap()
        XCTAssertTrue(app.navigationBars["Notes"].waitForExistence(timeout: 15))
        addNote("Written anonymously")
        app.buttons["account"].tap()
        let shownEmail = app.staticTexts["user-email"]
        XCTAssertTrue(shownEmail.waitForExistence(timeout: 5))
        XCTAssertTrue(shownEmail.label.contains("Anonymous"), shownEmail.label)
        // The sign-in provider is read from the ID token's claims.
        XCTAssertTrue(app.staticTexts["provider"].label.contains("anonymous"), app.staticTexts["provider"].label)
    }

    // MARK: - Helpers

    private static func newEmail() -> String {
        "lab-\(UUID().uuidString.prefix(8).lowercased())@example.com"
    }

    private func fill(email: String, password: String) {
        let emailField = app.textFields["email"]
        XCTAssertTrue(emailField.waitForExistence(timeout: 10))
        emailField.tap()
        emailField.typeText(email)
        let passwordField = app.secureTextFields["password"]
        passwordField.tap()
        passwordField.typeText(password)
    }

    /// Taps a sign-in button and answers the system's "Save Password?" sheet, which iOS shows
    /// after a password field is submitted.
    private func submit(_ button: String) {
        app.buttons[button].tap()
        dismissSavePassword(timeout: 4)
    }

    private func dismissSavePassword(timeout: TimeInterval) {
        let notNow = app.buttons["Not Now"]
        if notNow.waitForExistence(timeout: timeout) { notNow.tap() }
    }

    private func addNote(_ text: String) {
        let field = app.textFields["new-note"]
        field.tap()
        field.typeText(text)
        app.buttons["add-note"].tap()
        XCTAssertTrue(noteCell(text).waitForExistence(timeout: 10), "\(text) was not added")
    }

    /// Swipes on list rows are unreliable while the keyboard is up.
    private func dismissKeyboard() {
        let done = app.keyboards.buttons["Done"]
        if done.exists { done.tap() }
    }

    private func noteCell(_ text: String) -> XCUIElement {
        app.cells.containing(NSPredicate(format: "label BEGINSWITH %@", text)).firstMatch
    }

    private func signOut() {
        dismissSavePassword(timeout: 0)
        app.buttons["account"].tap()
        if !app.buttons["sign-out"].waitForExistence(timeout: 5) {
            // A late "Save Password?" sheet can take the first tap.
            dismissSavePassword(timeout: 2)
            app.buttons["account"].tap()
        }
        app.buttons["sign-out"].tap()
        XCTAssertTrue(app.textFields["email"].waitForExistence(timeout: 10))
    }

    /// Saves a screenshot for the README when SCREENSHOT_DIR is set, and attaches it to the
    /// test result either way.
    private func save(_ name: String) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
        let environment = ProcessInfo.processInfo.environment
        guard let directory = environment["SCREENSHOT_DIR"] else { return }
        let appearance = environment["APPEARANCE"] ?? "light"
        let url = URL(fileURLWithPath: directory).appendingPathComponent("\(name)-\(appearance).png")
        try? screenshot.pngRepresentation.write(to: url)
    }
}
