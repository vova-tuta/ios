import XCTest

// проверка экрана регистрции

class testRegistrationScreen: XCTestCase {
    
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }

    func testRegistrationScreen() throws {
        
        let loginButton = app.buttons["В шок"]
        let registrationOpenButton = app.buttons["Регистрация"]
        
        let backButton = app.buttons["Назад"]
        let registrationButton = app.buttons["Зарегистрироваться"]
        
        let emailField = app.textFields["Введите email"]
        let passwordField = app.secureTextFields["Пароль"]
        let ageField = app.textFields["Возраст"]

        loginButton.tap()
        registrationOpenButton.tap()
        
        XCTAssertTrue(backButton.exists, "Кнопка 'Назад' не найдена")
        XCTAssertTrue(registrationButton.exists, "Кнопка 'Зарегистироваться' не найдена")

        XCTAssertTrue(emailField.exists, "Поле 'Введите email' не найдено")
        XCTAssertTrue(passwordField.exists, "Поле 'Пароль' не найдено")
        XCTAssertTrue(ageField.exists, "Поле 'Возраст' не найдено")

    }
}

