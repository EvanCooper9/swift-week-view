import Foundation

public extension Date {
    var isToday: Bool {
        isSameDay(as: Date())
    }

    func isSameDay(as date: Date) -> Bool {
        Calendar.current.compare(self, to: date, toGranularity: .day) == .orderedSame
    }

    mutating func addTimeInterval(_ timeInterval: Int) {
        addTimeInterval(TimeInterval(timeInterval))
    }
}
