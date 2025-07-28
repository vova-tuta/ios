import XCTest

// проверка выхода из профиля

class testProfileLogout: XCTestCase {
    
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }

    func testProfileLogout() throws {
        
        let loginButton = app.buttons["В шок"]
        let editButton = app.buttons["editProfileButton"]
        let logoutButton = app.buttons["logoutButton"]
        let emailField = app.textFields["emailField"]
        let passwordField = app.secureTextFields["passwordField"]
        let mainTitle = app.staticTexts["mainTitle"]
        
        loginButton.tap()
        emailField.tap()
        emailField.typeText("autotests.vova_tuta.ios@ya.ru")
        passwordField.tap()
        passwordField.typeText("12345")
        loginButton.tap()
        
        let existsPredicate = NSPredicate(format: "exists == true")
        expectation(for: existsPredicate, evaluatedWith: editButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertTrue(editButton.exists, "Переход на экран профиля не произошел: кнопка 'Редактировать' не найдена")
        logoutButton.tap()
        XCTAssertTrue(mainTitle.exists, "Переход на главную не произошел: заголовок 'Я в ШОКе' не найден")
        
    }
}

