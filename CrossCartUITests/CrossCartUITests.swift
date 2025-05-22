//
//  CrossCartUITests.swift
//  CrossCartUITests
//
//  Created by shruti's macbook on 24/04/25.
//

import XCTest

final class CrossCartUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    @MainActor
    func testLogin() throws {
        let app = XCUIApplication()
        app.launch()
        
        let loginText = app.staticTexts["loginText"]
        XCTAssertTrue(loginText.exists)
        XCTAssertEqual(loginText.label, "Login")
        
        let userName = app.textFields["usernameField"]
        XCTAssertTrue(userName.exists)
        userName.tap()
        userName.typeText("Shrutisoni20.ss@gmail.com")
        
        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.exists)
        loginButton.tap()
       
        let passwordText = app.textFields["passwordField"]
        XCTAssertTrue(passwordText.exists)
        passwordText.tap()
        
        let forgotPassword = app.buttons["forgotPasswordButton"]
        XCTAssertTrue(forgotPassword.exists)
        forgotPassword.tap()
    }
}
