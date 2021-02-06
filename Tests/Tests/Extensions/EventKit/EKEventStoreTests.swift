import EventKit
import XCTest

@testable import ECWeekView

final class EKEventStoreTests: XCTestCase {
    func testThatAuthorizationStatusIsCorrect() {
        let eventAuthorization = EKEventStore().authorizationStatus(for: .event)
        let reminderAuthorization = EKEventStore().authorizationStatus(for: .reminder)

        XCTAssertEqual(eventAuthorization, EKEventStore.authorizationStatus(for: .event))
        XCTAssertEqual(reminderAuthorization, EKEventStore.authorizationStatus(for: .reminder))
    }
}
