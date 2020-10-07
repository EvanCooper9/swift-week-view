import Foundation
import SwiftDate

public class WeekViewEvent: NSObject {
    let id: String
    let title: String
    let subtitle: String
    let start: DateInRegion
    let end: DateInRegion
    
    init(title: String, subtitle: String, start: DateInRegion, end: DateInRegion) {
        self.id = UUID().uuidString
        self.title = title
        self.subtitle = subtitle
        self.start = start
        self.end = end
    }
    
    func overlaps(with event: WeekViewEvent) -> Bool {
        return (start == event.start && end == event.end) ||
            (start > event.start && start < event.end) ||
            (end > event.start && end < event.end) ||
            (start < event.end && end > event.end)
    }
}

// MARK: - Comparable

extension WeekViewEvent: Comparable {
    public static func < (lhs: WeekViewEvent, rhs: WeekViewEvent) -> Bool {
        return lhs.start < rhs.start
    }

    public static func == (lhs: WeekViewEvent, rhs: WeekViewEvent) -> Bool {
        return lhs.title == rhs.title &&
            lhs.subtitle == rhs.subtitle &&
            lhs.start == rhs.start &&
            lhs.end == rhs.end
    }
}
