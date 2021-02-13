import EventKit
import ECWeekView

@objc
class MockEKEventStore: EKEventStore {

    var authorizationStatus = EKAuthorizationStatus.notDetermined
    var authorized = false

    private(set) var didRequestAuthorization = false
    private(set) var events = [EKEvent]()

    override func authorizationStatus(for entityType: EKEntityType) -> EKAuthorizationStatus {
        return authorizationStatus
    }

    override func requestAccess(to entityType: EKEntityType, completion: @escaping EKEventStoreRequestAccessCompletionHandler) {
        didRequestAuthorization = true
        completion(authorized, nil)
    }

    override func events(matching predicate: NSPredicate) -> [EKEvent] {
        events
    }

    override func save(_ event: EKEvent, span: EKSpan) throws {
        events.append(event)
    }
}
