import XCTest

// проверка того, что кнопка "Я в шоке?" стала активной после ввода емайла

class testMainInputEnablesButton: XCTestCase {
    
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app.launch()
    }


    func testMainInputEnablesButton() throws {
        let emailTextField = app.textFields["Email"]
        XCTAssertTrue(emailTextField.exists, "Поле для ввода Email не найдено.")
        
        emailTextField.tap()
        emailTextField.typeText("test@email.ru")
        
        let button = app.buttons["Я в шоке?"]
        
        XCTAssertTrue(button.isEnabled, "Кнопка 'Я в шоке?' не активна.")
    }
}
