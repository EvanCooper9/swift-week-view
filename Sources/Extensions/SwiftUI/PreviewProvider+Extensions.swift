import EventKit
import SwiftUI

public extension PreviewProvider {
    static var eventStore: EKEventStore { .init() }

    static var calendar: EKCalendar {
        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.cgColor = Color(.red).cgColor
        return calendar
    }

    static func event(with title: String, location: String? = nil, for date: Date = Date(), isAllDay: Bool = false) -> EKEvent {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.location = location
        event.startDate = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: date)!
        event.endDate = event.startDate.addingTimeInterval(2.hours)
        event.calendar = calendar
        event.isAllDay = isAllDay
        return event
    }
}
