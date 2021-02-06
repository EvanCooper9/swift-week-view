import EventKit
import Foundation

public protocol CalendarManaging {
    var eventStore: EKEventStore { get }
    func eventsFor(day date: Date, completion: (([EKEvent]) -> Void)?)
    func requestCalendarAccess(completion: ((Bool) -> Void)?)
}

public extension CalendarManaging {
    func eventsFor(day date: Date, completion: (([EKEvent]) -> Void)? = nil) {
        eventsFor(day: date, completion: completion)
    }
    func requestCalendarAccess(completion: ((Bool) -> Void)? = nil) {
        requestCalendarAccess(completion: completion)
    }
}

public struct CalendarManager: CalendarManaging {

    // MARK: - Public Properties

    public var authorizationStatus: EKAuthorizationStatus { eventStore.authorizationStatus(for: .event) }
    public let eventStore: EKEventStore

    // MARK: - Lifecycle

    public init(eventStore: EKEventStore = .init()) {
        self.eventStore = eventStore
    }

    // MARK: - Public Methods

    public func eventsFor(day date: Date, completion: (([EKEvent]) -> Void)?) {
        guard authorizationStatus == .authorized else {
            requestCalendarAccess { granted in
                guard granted else {
                    completion?([])
                    return
                }

                completion?(eventsFor(day: date))
            }
            return
        }

        completion?(eventsFor(day: date))
    }

    public func requestCalendarAccess(completion: ((Bool) -> Void)?) {
        guard authorizationStatus == .notDetermined else {
            completion?(authorizationStatus == .authorized)
            return
        }

        eventStore.requestAccess(to: .event) { granted, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }

            completion?(granted)
        }
    }

    // MARK: - Private Methods

    private func eventsFor(day date: Date) -> [EKEvent] {
        guard authorizationStatus == .authorized else { return [] }

        let start = Calendar.current.nextDate(
            after: date,
            matching: .init(hour: 0),
            matchingPolicy: .nextTime,
            direction: .backward
        ) ?? date

        let predicate = eventStore.predicateForEvents(
            withStart: start,
            end: start.advanced(by: 1.days),
            calendars: nil
        )

        return eventStore.events(matching: predicate)
    }
}
