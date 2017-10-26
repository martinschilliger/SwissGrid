//
//  SwissGridUITests.swift
//  SwissGridUITests
//
//  Created by Martin Schilliger on 14.09.17.
//  Copyright © 2017 Martin Apps. All rights reserved.
//

import XCTest

class SwissGridUITests: XCTestCase {

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        XCUIDevice.shared.orientation = .portrait
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    //    func testExample() {
    //        // Use recording to get started writing UI tests.
    //        // Use XCTAssert and related functions to verify your tests produce the correct results.
    //    }

    func testChangeMapProvider() {
        let app = XCUIApplication()
        app.buttons["iconSettings"].tap()
        app.tables.cells.staticTexts["Google Maps"].tap()
        app.buttons["buttonCloseSettings"].tap()
    }

    func testLV03Input() {
        let app = XCUIApplication()

        app.textFields["XX00000/XX00000"].typeText("551'750.0, 182'000.0")
        XCTAssertTrue(app.buttons["buttonOpenMaps"].isEnabled)
    }

    func testLV95Input() {
        let app = XCUIApplication()

        app.textFields["XX00000/XX00000"].typeText("2730250, 1222999")
        XCTAssertTrue(app.buttons["buttonOpenMaps"].isEnabled)
    }
}
