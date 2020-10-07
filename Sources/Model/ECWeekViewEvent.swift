import Foundation
import SwiftDate

public class ECWeekViewEvent: NSObject {
    public let id: String
    public let title: String
    public let subtitle: String
    public let start: DateInRegion
    public let end: DateInRegion
    
    public init(title: String, subtitle: String, start: DateInRegion, end: DateInRegion) {
        self.id = UUID().uuidString
        self.title = title
        self.subtitle = subtitle
        self.start = start
        self.end = end
    }
    
    func overlaps(with event: ECWeekViewEvent) -> Bool {
        return (start == event.start && end == event.end) ||
            (start > event.start && start < event.end) ||
            (end > event.start && end < event.end) ||
            (start < event.end && end > event.end)
    }
}

// MARK: - Comparable

extension ECWeekViewEvent: Comparable {
    public static func < (lhs: ECWeekViewEvent, rhs: ECWeekViewEvent) -> Bool {
        return lhs.start < rhs.start
    }

    public static func == (lhs: ECWeekViewEvent, rhs: ECWeekViewEvent) -> Bool {
        return lhs.title == rhs.title &&
            lhs.subtitle == rhs.subtitle &&
            lhs.start == rhs.start &&
            lhs.end == rhs.end
    }
}
