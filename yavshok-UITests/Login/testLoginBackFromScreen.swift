import XCTest

// проверка возврата с экрана логина

class testLoginBackFromScreen: XCTestCase {
    
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }

    func testLoginBackFromScreen() throws {
        
        let loginButton = app.buttons["В шок"]
        let backButton = app.buttons["Назад"]
        let label = app.staticTexts["mainTitle"]

        loginButton.tap()
        
        backButton.tap()

        XCTAssertTrue(label.exists, "Переход на главную не произошел")
    }
}
