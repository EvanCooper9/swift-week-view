import Foundation

public extension TimeInterval {
    static var second: Self { 1.seconds }
    static var minute: Self { 1.minutes  }
    static var hour: Self { 1.hours }
    static var day: Self { 1.days }
    static var week: Self { 1.days * 7 }
    static var year: Self { 1.weeks * 52 }

    var seconds: Self { self }
    var minutes: Self { self * 60 }
    var hours: Self { self.minutes * 60 }
    var days: Self { self.hours * 24 }
    var weeks: Self { self.days * 7 }
    var years: Self { self.weeks * 52 }
}
