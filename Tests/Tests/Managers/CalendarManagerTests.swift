import EventKit
import XCTest

@testable import ECWeekView

final class CalendarManagerTests: XCTestCase {

    private var eventStore: MockEKEventStore!
    private var calendarManager: CalendarManager!

    override func setUp() {
        super.setUp()
        eventStore = MockEKEventStore()
        calendarManager = CalendarManager(eventStore: eventStore)
    }

    func testThatEventStoreIsCorrect() {
        XCTAssertEqual(calendarManager.eventStore, eventStore)
    }

    func testThatItRequestsAuthorization() {
        calendarManager.eventsFor(day: Date())
        XCTAssertTrue(eventStore.didRequestAuthorization)
    }

    func testThatItDoesNotRequestAuthorizationIfAlreadyDetermined() {
        eventStore.authorizationStatus = .denied
        calendarManager.eventsFor(day: Date())
        XCTAssertFalse(eventStore.didRequestAuthorization)
    }

    func testThatItReturnsNoEventsWhenNotAuthorized() throws {
        eventStore.authorizationStatus = .denied

        let testEvent = EKEvent(eventStore: eventStore)
        testEvent.title = #function
        testEvent.calendar = EKCalendar(for: .event, eventStore: eventStore)
        testEvent.startDate = Date()
        testEvent.endDate = Date().advanced(by: 1.hours)
        try eventStore.save(testEvent, span: .thisEvent)

        calendarManager.eventsFor(day: Date()) {
            XCTAssertTrue($0.isEmpty)
        }
    }

    func testThatEventsAreCorrect() throws {
        eventStore.authorizationStatus = .authorized

        calendarManager.eventsFor(day: Date()) {
            XCTAssertTrue($0.isEmpty)
        }

        let testEvent = EKEvent(eventStore: eventStore)
        testEvent.title = #function
        testEvent.calendar = EKCalendar(for: .event, eventStore: eventStore)
        testEvent.startDate = Date()
        testEvent.endDate = Date().advanced(by: 1.hours)
        try eventStore.save(testEvent, span: .thisEvent)

        calendarManager.eventsFor(day: Date()) {
            XCTAssertEqual($0, [testEvent])
        }
    }
}
