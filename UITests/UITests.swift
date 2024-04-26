//
//  Electricity_Prices_UI_Tests.swift
//  Electricity Prices UI Tests
//
//  Created by Jonas Bromö on 2024-04-20.
//

import XCTest

final class ElectricityPricesUITests: XCTestCase {

    @MainActor
    override func setUpWithError() throws {
        continueAfterFailure = false

        UserDefaults.standard.setValue(true, forKey: "FASTLANE_SNAPSHOT")
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    override func tearDownWithError() throws {
        UserDefaults.standard.setValue(false, forKey: "FASTLANE_SNAPSHOT")
    }

    @MainActor
    // swiftlint:disable:next function_body_length
    func testExample() throws {
        let app = XCUIApplication()
        snapshot("0MainView")

#if os(iOS)
        app.buttons["settings"].tap()
        app.buttons["viewMode"].tap()
        app.buttons["todayAndTomorrow"].tap()
        app.buttons["done"].tap()
        snapshot("1TodayAndTomorrow")

        app.buttons["settings"].tap()
        app.buttons["chart"].tap()
        app.buttons["line"].tap()
        app.buttons["unit"].tap()
        app.buttons["subdivided"].tap()
        app.buttons["done"].tap()
        snapshot("2LineChart")

        app.buttons["settings"].tap()
        app.buttons["chart"].tap()
        app.buttons["bar"].tap()
        app.buttons["unit"].tap()
        app.buttons["automatic"].tap()
        app.buttons["done"].tap()
        XCUIDevice.shared.press(.home)
        sleep(1)
        snapshot("3Homescreen")

        XCUIDevice.shared.perform(NSSelectorFromString("pressLockButton"))
        sleep(1)
        snapshot("4LockScreen")
#elseif os(watchOS)
        app.swipeLeft()
        app.swipeLeft()
        app.buttons["viewMode"].tap()
        app.buttons["todayAndTomorrow"].tap()
        app.swipeRight()
        snapshot("1TodayAndTomorrow")

        app.swipeLeft()
        app.buttons["chart"].tap()
        app.buttons["line"].tap()
        app.buttons["unit"].tap()
        app.buttons["subdivided"].tap()
        app.swipeRight()
        snapshot("2LineChart")

        app.swipeLeft()
        app.buttons["chart"].tap()
        app.buttons["bar"].tap()
        app.buttons["unit"].tap()
        app.buttons["automatic"].tap()
        app.swipeRight()
        snapshot("3UnitAutomatic")

        XCUIDevice.shared.press(.home)
        sleep(1)
        snapshot("2Homescreen")
#endif
    }

}