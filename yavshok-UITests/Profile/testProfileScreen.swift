import XCTest

// проверка экрана профиля

class testProfileScreen: XCTestCase {
    
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }

    func testProfileScreen() throws {
        
        let loginButton = app.buttons["В шок"]
        
        let editButton = app.buttons["editProfileButton"]
        let logoutButton = app.buttons["logoutButton"]
        
        let emailField = app.textFields["emailField"]
        let passwordField = app.secureTextFields["passwordField"]
        
        let postsCountLabel = app.staticTexts["postsCount"]
        let followersCountLabel = app.staticTexts["followersCount"]
        let likesCountLabel = app.staticTexts["likesCount"]
        
        let profileImage = app.images["profileImage"]

        loginButton.tap()
        emailField.tap()
        emailField.typeText("autotests.vova_tuta.ios@ya.ru")
        passwordField.tap()
        passwordField.typeText("12345")
        loginButton.tap()
        
        let existsPredicate = NSPredicate(format: "exists == true")
        expectation(for: existsPredicate, evaluatedWith: editButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertTrue(editButton.exists, "Кнопка 'Редактировать' не найдена")
        XCTAssertTrue(postsCountLabel.exists, "Лейбл постов не найден")
        XCTAssertTrue(followersCountLabel.exists, "Лейбл подписчиков не найден")
        XCTAssertTrue(likesCountLabel.exists, "Лейбл лайков не найден")
        XCTAssertTrue(profileImage.exists, "Изображение профиля не найдено.")

        logoutButton.tap()
    }
}

