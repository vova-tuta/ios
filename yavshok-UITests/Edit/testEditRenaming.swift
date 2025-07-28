import XCTest

// проверка переименования профиля

class testEditRename: XCTestCase {
    
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }

    func testEditRename() throws {
        
        let loginButton = app.buttons["В шок"]
        let editButton = app.buttons["editProfileButton"]
        let logoutButton = app.buttons["logoutButton"]
        let saveButton = app.buttons["saveButton"]
        
        let emailField = app.textFields["emailField"]
        let passwordField = app.secureTextFields["passwordField"]
        let nameField = app.textFields["nameField"]
        
        let userNameLabel = app.staticTexts["userName"]
        
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
        
        editButton.tap()
        
        nameField.tap()
        
        nameField.typeText("\u{8}")
        nameField.typeText("\u{8}")
        nameField.typeText("\u{8}")
        nameField.typeText("\u{8}")  // 4 раза сносим, дада, не лучшая практика, но работает не трош
        nameField.typeText("Test")

        saveButton.tap()
        
        XCTAssertEqual(userNameLabel.label, "Test", "Текст в элементе 'userName' не равен 'Test'")
        
        editButton.tap()
        
        nameField.tap() // меняем имя для будущих прогонов
        
        nameField.typeText("\u{8}")
        nameField.typeText("\u{8}")
        nameField.typeText("\u{8}")
        nameField.typeText("\u{8}")  // 4 раза сносим, дада, не лучшая практика, но работает не трош
        nameField.typeText("Neko")

        saveButton.tap()

        logoutButton.tap()
    }
}
