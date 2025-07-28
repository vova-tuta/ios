import XCTest

// проверка экрана логина 

class testLoginScreen: XCTestCase {
    
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }

    func testLoginScreen() throws {
        
        let loginButton = app.buttons["В шок"]
        let backButton = app.buttons["Назад"]
        let registrationButton = app.buttons["Регистрация"]
        
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Пароль"]

        loginButton.tap()
        
        XCTAssertTrue(loginButton.exists, "Кнопка 'В шок' не найдена")
        XCTAssertTrue(backButton.exists, "Кнопка 'Назад' не найдена")
        XCTAssertTrue(registrationButton.exists, "Кнопка 'Регистрация' не найдена")

        XCTAssertTrue(emailField.exists, "Поле 'Email' не найдено")
        XCTAssertTrue(passwordField.exists, "Поле 'Пароль' не найдено")
    }
}
