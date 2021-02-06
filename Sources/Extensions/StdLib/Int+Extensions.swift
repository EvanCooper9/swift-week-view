import Foundation

public extension Int {
    var seconds: Self { self }
    var minutes: Self { self * 60 }
    var hours: Self { self.minutes * 60 }
    var days: Self { self.hours * 24 }
}
