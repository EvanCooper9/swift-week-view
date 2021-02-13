import XCTest

@testable import ECWeekView

final class CalendarDayTests: XCTestCase {

    private var eventStore: MockEKEventStore!

    override func setUp() {
        super.setUp()
        self.eventStore = MockEKEventStore()
    }

    func testThatComparableIsCorrect() {
        let now = Date()
        let earlier = now.addingTimeInterval(-1.minutes)
        let later = now.addingTimeInterval(1.minutes)

        let yesterday = CalendarDay(date: earlier, events: [], eventStore: eventStore)
        let today = CalendarDay(date: now, events: [], eventStore: eventStore)
        let tomorrow = CalendarDay(date: later, events: [], eventStore: eventStore)

        XCTAssertTrue(yesterday < today)
        XCTAssertTrue(today < tomorrow)
    }
}
