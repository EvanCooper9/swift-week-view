import Foundation

extension Notification {
    var isCalendarDataChanged: Bool {
        userInfo?["EKEventStoreCalendarDataChangedUserInfoKey"] as? Bool ?? false
    }
}
