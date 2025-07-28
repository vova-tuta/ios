import XCTest

// проверка возврата с экрана реги

class testRegistrationBackFromScreen: XCTestCase {
    
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }

    func testBackFromRegistrationScreen() throws {
        
        let loginButton = app.buttons["В шок"]
        let backButton = app.buttons["Назад"]
        let registrationButton = app.buttons["Регистрация"]
        let label = app.staticTexts["loginTitle"]

        loginButton.tap()
        registrationButton.tap()
        backButton.tap()

        XCTAssertTrue(label.exists, "Переход на экран логина не произошел")
    }
}
