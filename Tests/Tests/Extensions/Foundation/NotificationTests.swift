import Foundation
import XCTest

@testable import ECWeekView

final class NotificationTests: XCTestCase {
    func testThatIsCalendarDataChangedIsCorrect() {
        let n1 = Notification(name: .EKEventStoreChanged)
        XCTAssertFalse(n1.isCalendarDataChanged)

        let n2 = Notification(
            name: .EKEventStoreChanged,
            userInfo: ["EKEventStoreCalendarDataChangedUserInfoKey": false]
        )
        XCTAssertFalse(n2.isCalendarDataChanged)

        let n3 = Notification(
            name: .EKEventStoreChanged,
            userInfo: ["EKEventStoreCalendarDataChangedUserInfoKey": true]
        )
        XCTAssertTrue(n3.isCalendarDataChanged)
    }
}
