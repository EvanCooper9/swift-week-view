import EventKit
import XCTest

@testable import ECWeekView

final class EKEventTests: XCTestCase {

    private var eventStore: MockEKEventStore!

    override func setUp() {
        super.setUp()
        eventStore = MockEKEventStore()
    }

    func testThatStartHourIsCorrect() {
        let event = EKEvent(eventStore: eventStore)
        event.startDate = Calendar.current.date(bySetting: .hour, value: 1, of: Date())
        XCTAssertEqual(event.startHour, 1)
    }

    func testThatStartMinuteIsCorrect() {
        let event = EKEvent(eventStore: eventStore)
        event.startDate = Calendar.current.date(bySetting: .minute, value: 1, of: Date())
        XCTAssertEqual(event.startMinute, 1)
    }

    func testThatEndHourIsCorrect() {
        let event = EKEvent(eventStore: eventStore)
        event.endDate = Calendar.current.date(bySetting: .hour, value: 1, of: Date())
        XCTAssertEqual(event.endHour, 1)
    }

    func testThatEndMinuteIsCorrect() {
        let event = EKEvent(eventStore: eventStore)
        event.endDate = Calendar.current.date(bySetting: .minute, value: 1, of: Date())
        XCTAssertEqual(event.endMinute, 1)
    }
}
