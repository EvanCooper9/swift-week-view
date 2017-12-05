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
    private var id: String
    private var title: String
    private var start: DateInRegion
    private var end: DateInRegion
    private var color: UIColor
    
    var view: UIView?
    
    override var description: String {
        return "\(getTitle())\n\(getStart().string(format: .custom("HH:mm"))) - \(getEnd().string(format: .custom("HH:mm")))"
    }
    
    func getID() -> String { return self.id }
    func getTitle() -> String { return self.title }
    func getStart() -> DateInRegion { return self.start }
    func getEnd() -> DateInRegion { return self.end }
    func getColor() -> UIColor { return self.color }
    
    init(title: String, start: DateInRegion, end: DateInRegion, color: UIColor = UIColor.red) {
        self.id = UUID().uuidString
        self.title = title
        self.start = start
        self.end = end
        self.color = color
    }
    
    static func < (lhs: WeekViewEvent, rhs: WeekViewEvent) -> Bool {
        print(#function)
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
            (start >= withEvent.start && start <= withEvent.end) ||
            (end >= withEvent.start && end <= withEvent.end) ||
            (start <= withEvent.end && end >= withEvent.end)
    }
}
