//
//  WeekViewEvent.swift
//  CalendarWeekView
//
//  Created by Evan Cooper on 2017-08-10.
//  Copyright © 2017 Evan Cooper. All rights reserved.
//

import Foundation
import SwiftDate

class WeekViewEvent: Comparable, Equatable {
    private var title: String
    private var startDate: DateInRegion
    private var endDate: DateInRegion
    private var color: UIColor
    
    func getTitle() -> String { return self.title }
    func getStart() -> DateInRegion { return self.startDate }
    func getEnd() -> DateInRegion { return self.endDate }
    func getColor() -> UIColor { return self.color }
    
    init(title: String, startDate: DateInRegion, endDate: DateInRegion, color: UIColor = UIColor.blue) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.color = color
    }
    
    static func < (lhs: WeekViewEvent, rhs: WeekViewEvent) -> Bool {
        // returns the event with the earliest start date
        return lhs.startDate < rhs.startDate
    }
    
    static func == (lhs: WeekViewEvent, rhs: WeekViewEvent) -> Bool {
        return lhs.title == rhs.title &&
            lhs.startDate == rhs.startDate &&
            lhs.endDate == rhs.endDate &&
            lhs.color == rhs.color
    }
    
    func overlaps(withEvent: WeekViewEvent) -> Bool {
        return (self.startDate == withEvent.startDate && self.endDate == withEvent.endDate) ||
            (self.startDate >= withEvent.startDate && self.startDate <= withEvent.endDate) ||
            (self.endDate >= withEvent.startDate && self.endDate <= withEvent.endDate) ||
            (self.startDate <= withEvent.endDate && self.endDate >= withEvent.endDate)
    }
}
