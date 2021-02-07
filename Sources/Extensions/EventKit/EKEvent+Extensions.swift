import EventKit

extension EKEvent: Identifiable {}

public extension EKEvent {
    private var cal: Calendar { .current }
    var startHour: Int { cal.component(.hour, from: startDate) }
    var startMinute: Int { cal.component(.minute, from: startDate) }
    var endHour: Int { cal.component(.hour, from: endDate) }
    var endMinute: Int { cal.component(.minute, from: endDate) }

    func collides(with event: EKEvent) -> Bool {
        let startComparison = event.startDate.compare(startDate)
        let startsBeforeStart = startComparison == .orderedAscending
        let startsAfterStart = startComparison == .orderedDescending
        let startsSameStart = startComparison == .orderedSame

        let startEndComparison = event.startDate.compare(endDate)
        let startsBeforeEnd = startEndComparison == .orderedAscending
//        let startsAfterEnd = startEndComparison == .orderedDescending
//        let startsSameEnd = startEndComparison == .orderedSame

        let endStartComparison = event.endDate.compare(startDate)
//        let endsBeforeStart = endStartComparison == .orderedAscending
        let endsAfterStart = endStartComparison == .orderedDescending
//        let endSameStart = endStartComparison == .orderedSame

        let endComparison = event.endDate.compare(endDate)
        let endsBeforeEnd = endComparison == .orderedAscending
        let endsAfterEnd = endComparison == .orderedDescending
        let endsSameEnd = endComparison == .orderedSame

        let cases: [Bool] = [
            (startsBeforeStart && endsAfterStart),
            (startsBeforeEnd && endsAfterEnd),
            (startsAfterStart && endsBeforeEnd),
            (startsSameStart || endsSameEnd)
        ]

        return cases.contains { $0 }
    }
}

extension EKEvent: Comparable {
    public static func < (lhs: EKEvent, rhs: EKEvent) -> Bool {
        let comparison = lhs.compareStartDate(with: rhs)
        guard comparison != .orderedSame else { return lhs.title < rhs.title }
        return comparison == .orderedAscending
    }
}


public extension Array where Element: EKEvent {
    func overlappingEvents(against event: EKEvent) -> Self {
        self
            .filter { !$0.isAllDay }
            .filter { someEvent in
                guard !someEvent.isAllDay, someEvent.id != event.id else { return false }
                return event.collides(with: someEvent)
            }
    }
}
