//
//  SwissGridUIScreenshots.swift
//  SwissGridUIScreenshots
//
//  Created by Martin Schilliger on 24.10.17.
//  Copyright © 2017 Martin Apps. All rights reserved.
//

import XCTest

class SwissGridUIScreenshots: XCTestCase {

    override func setUp() {
        super.setUp()

        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
//        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    //    func test(){
    //        let app = XCUIApplication()
    //        app.alerts.element.collectionViews.buttons["Allow"].tap()
    //    }

    func testScreenshotting() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let app = XCUIApplication()
        snapshot("0Launch")

        // Type coordinates into field
        let xx00000Xx00000TextField = app.textFields["XX00000/XX00000"]
        xx00000Xx00000TextField.typeText("2600000,1200000")
        snapshot("1Coordinates")

        // Open Settings to show available map providers
        app/*@START_MENU_TOKEN@*/.buttons["buttonOpenSettings"]/*[[".buttons[\"iconSettings\"]",".buttons[\"buttonOpenSettings\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Apple Maps"]/*[[".cells.staticTexts[\"Apple Maps\"]",".staticTexts[\"Apple Maps\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        snapshot("2Settings")
//        app.buttons["buttonCloseSettings"].tap()

        // Open maps application
//        app.buttons["buttonOpenMaps"].tap()
//        snapshot("2MapsOpen")
    }
    
}
