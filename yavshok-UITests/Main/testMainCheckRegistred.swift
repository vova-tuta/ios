import XCTest

// проверка того, что проверка зарегистрированного пользователя проходит успешно


class testMainCheckRegistred: XCTestCase {
    
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }

    func testMainCheckRegistred() throws {
        
        let emailTextField = app.textFields["Email"]
        XCTAssertTrue(emailTextField.exists, "Поле для ввода Email не найдено.")
        
        emailTextField.tap()
        emailTextField.typeText("autotests.vova_tuta.ios@ya.ru")
        
        let button = app.buttons["Я в шоке?"]
        
        button.tap()
        
        let label = app.staticTexts["successText"]

        XCTAssertTrue(label.exists, "Текст 'Ты еще не в ШОКе' не отображается на экране.")
    }
}
