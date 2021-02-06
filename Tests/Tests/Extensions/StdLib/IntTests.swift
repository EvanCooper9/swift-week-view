import XCTest

@testable import ECWeekView

final class IntTests: XCTestCase {

    func testThatSecondsIsCorrect() {
        XCTAssertEqual(1.seconds, 1)
        XCTAssertEqual(10.seconds, 10)
        XCTAssertEqual(100.seconds, 100)
    }

    func testThatMinutesIsCorrect() {
        XCTAssertEqual(1.minutes, 60)
        XCTAssertEqual(10.minutes, 600)
        XCTAssertEqual(100.minutes, 6000)
    }

    func testThatHoursIsCorrect() {
        XCTAssertEqual(1.hours, 3600)
        XCTAssertEqual(10.hours, 36000)
        XCTAssertEqual(100.hours, 360000)
    }

    func testThatDaysIsCorrect() {
        XCTAssertEqual(1.days, 86400)
        XCTAssertEqual(10.days, 864000)
        XCTAssertEqual(100.days, 8640000)
    }
}
