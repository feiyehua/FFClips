//
    /*******************************************************************************
            
            File name:     FFClipsUITestsLaunchTests.swift
            Author:        FeiYehua
            
            Description:   Created for FFClips in 2025
            
            History:
                    2025/4/18: File created.
            
    ********************************************************************************/
    

import XCTest

final class FFClipsUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
