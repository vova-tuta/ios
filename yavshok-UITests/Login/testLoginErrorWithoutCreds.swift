import XCTest

// проверка неактивности кнопки, если не ввести креды при логине

class testLoginErrorWithoutCreds: XCTestCase {
    
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }

    func testLoginErrorWithoutCreds() throws {
        
        let loginButton = app.buttons["В шок"]

        loginButton.tap()
        
        XCTAssertFalse(loginButton.isEnabled, "Кнопка логина активна, хотя данные не введены.")

    }
}
