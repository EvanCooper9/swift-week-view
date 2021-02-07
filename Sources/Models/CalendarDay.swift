import EventKit

public struct CalendarDay: Comparable, Identifiable, Hashable {

    public let id = UUID()
    public let date: Date
    public var events: [EKEvent]
    public let eventStore: EKEventStore

    public init(date: Date, events: [EKEvent], eventStore: EKEventStore) {
        self.date = date
        self.events = events
        self.eventStore = eventStore
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.date < rhs.date
    }
}
