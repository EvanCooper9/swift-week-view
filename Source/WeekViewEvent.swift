//
//  WeekViewEvent.swift
//  CalendarWeekView
//
//  Created by Evan Cooper on 2017-08-10.
//  Copyright © 2017 Evan Cooper. All rights reserved.
//

import Foundation
import SwiftDate

class WeekViewEvent: NSObject, Comparable {
    private var title: String
    private var start: DateInRegion
    private var end: DateInRegion
    private var color: UIColor
    
    override var description: String {
        return "\(getTitle())\n\(getStart().string(format: .custom("HH:mm"))) - \(getEnd().string(format: .custom("HH:mm")))"
    }
    
    func getTitle() -> String { return self.title }
    func getStart() -> DateInRegion { return self.start }
    func getEnd() -> DateInRegion { return self.end }
    func getColor() -> UIColor { return self.color }
    
    init(title: String, start: DateInRegion, end: DateInRegion, color: UIColor = UIColor.purple) {
        self.title = title
        self.start = start
        self.end = end
        self.color = color
    }
    
    static func < (lhs: WeekViewEvent, rhs: WeekViewEvent) -> Bool {
        // returns the event with the earliest start date
        return lhs.start < rhs.start
    }
    
    static func == (lhs: WeekViewEvent, rhs: WeekViewEvent) -> Bool {
        return lhs.title == rhs.title &&
            lhs.start == rhs.start &&
            lhs.end == rhs.end &&
            lhs.color == rhs.color
    }
    
    func overlaps(withEvent: WeekViewEvent) -> Bool {
        return (self.start == withEvent.start && self.end == withEvent.end) ||
            (self.start >= withEvent.start && self.start <= withEvent.end) ||
            (self.end >= withEvent.start && self.end <= withEvent.end) ||
            (self.start <= withEvent.end && self.end >= withEvent.end)
    }
}
