import EventKit

@objc
public protocol EventStoreAuthorization {
    func authorizationStatus(for entityType: EKEntityType) -> EKAuthorizationStatus
}

extension EKEventStore: EventStoreAuthorization {
    open func authorizationStatus(for entityType: EKEntityType) -> EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: entityType)
    }
}
