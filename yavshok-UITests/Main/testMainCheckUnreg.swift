import XCTest

// проверка того, что проверка незарегестрированного пользователя проходит успешно

class testMainCheckUnreg: XCTestCase {
    
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }

    func testMainCheckUnreg() throws {
        
        let emailTextField = app.textFields["Email"]
        XCTAssertTrue(emailTextField.exists, "Поле для ввода Email не найдено.")
        
        emailTextField.tap()
        emailTextField.typeText("unreg.test.q2834mdnf3uni2gn4ol14k@email.ru")
        
        let button = app.buttons["Я в шоке?"]
        
        button.tap()
        
        let label = app.staticTexts["failureText"]

        XCTAssertTrue(label.exists, "Текст 'Ты еще не в ШОКе' не отображается на экране.")
    }
}
