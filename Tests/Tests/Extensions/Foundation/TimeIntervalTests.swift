import XCTest

@testable import ECWeekView

final class TimeIntervalTests: XCTestCase {

    func testThatSecondIsCorrect() {
        XCTAssertEqual(TimeInterval.second, 1)
    }

    func testThatMinuteIsCorrect() {
        XCTAssertEqual(TimeInterval.minute, 60)
    }

    func testThatHourIsCorrect() {
        XCTAssertEqual(TimeInterval.hour, 3600)
    }

    func testThatDayIsCorrect() {
        XCTAssertEqual(TimeInterval.day, 86400)
    }

    func testThatWeekIsCorrect() {
        XCTAssertEqual(TimeInterval.week, 604800)
    }

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

    func testThatWeeksIsCorrect() {
        XCTAssertEqual(1.weeks, 604800)
        XCTAssertEqual(10.weeks, 6048000)
        XCTAssertEqual(100.weeks, 60480000)
    }
}
