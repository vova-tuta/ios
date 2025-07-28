import XCTest

// проверка неактивности кнопки, если не ввести креды при регистрации

class testRegistrationErrorWithoutCreds: XCTestCase {
    
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }

    func testRegistrationErrorWithoutCreds() throws {
        
        let loginButton = app.buttons["В шок"]
        let registrationOpenButton = app.buttons["Регистрация"]
        let registrationButton = app.buttons["Зарегистрироваться"]

        loginButton.tap()
        registrationOpenButton.tap()
    
        XCTAssertFalse(registrationButton.isEnabled, "Кнопка регистрации активна, хотя данные не введены.")

    }
}
