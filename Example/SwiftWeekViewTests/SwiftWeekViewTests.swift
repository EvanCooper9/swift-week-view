//
//  SwiftWeekViewTests.swift
//  SwiftWeekViewTests
//
//  Created by Evan Cooper on 2017-08-18.
//  Copyright © 2017 Evan Cooper. All rights reserved.
//

import XCTest
@testable import SwiftWeekView
@testable import SwiftDate

class SwiftWeekViewTests: XCTestCase {
    
    var testFrame: CGRect!
    var scrollViewHorizontal: UIInfiniteScrollView!
    var scrollViewVertical: UIInfiniteScrollView!
    var weekView: WeekView!
    
    class VC: UIInfiniteScrollView.ViewCreator {
        override func createViewSet(viewCoordinate: CGPoint, viewPosition: Int, viewWidth: CGFloat, viewHeight: CGFloat) -> [UIView] {
            let view: UIView = UIView(frame: CGRect(x: viewCoordinate.x, y: viewCoordinate.y, width: viewWidth, height: viewHeight))
            return [view]
        }
    }
    
    class EG: WeekView.EventGenerator {
        override func generateEvents(date: DateInRegion) -> [WeekViewEvent] {
            // create a WeekViewEvent for the day of date
            let start = date.atTime(hour: 12, minute: 0, second: 0)!
            let end = date.atTime(hour: 13, minute: 0, second: 0)!
            let event: WeekViewEvent = WeekViewEvent(title: "Lunch", startDate: start, endDate: end)
            return [event]
        }
    }
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        testFrame = CGRect(x: 0, y: 0, width: 500, height: 500)
        scrollViewHorizontal = UIInfiniteScrollView(frame: testFrame, viewsInPageCount: 5, spacerSize: 2, viewCreator: VC(), direction: .horizontal)
        scrollViewVertical = UIInfiniteScrollView(frame: testFrame, viewsInPageCount: 5, spacerSize: 2, viewCreator: VC(), direction: .vertical)
        weekView = WeekView(frame: testFrame, eventGenerator: EG(), visibleDays: 5)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        testFrame = nil
        scrollViewHorizontal = nil
        scrollViewVertical = nil
        weekView = nil
    }
    
    func testScrollViewSetup() {
        XCTAssert(scrollViewHorizontal.frame.height == testFrame.height)
        XCTAssert(scrollViewHorizontal.contentSize.height == testFrame.height)
        
        XCTAssert(scrollViewVertical.frame.width == testFrame.width)
        XCTAssert(scrollViewVertical.contentSize.width == testFrame.width)
    }
    
    func testWeekViewSetup() {
        XCTAssert(weekView.getScrollView().contentSize.height == testFrame.height)
        XCTAssert(weekView.frame.height == testFrame.height)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
