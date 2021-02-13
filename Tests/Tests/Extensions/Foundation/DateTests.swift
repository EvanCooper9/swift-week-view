import XCTest

@testable import ECWeekView

final class DateTests: XCTestCase {
    func testThatIsTodayIsCorrect() {
        XCTAssertTrue(Date().isToday)
        XCTAssertFalse(Date(timeIntervalSince1970: 0).isToday)
        XCTAssertFalse(Date(timeIntervalSinceNow: 1.days).isToday)
        XCTAssertFalse(Date(timeIntervalSinceNow: -1.days).isToday)
    }
}
