//
//  ViewController.swift
//  SwiftWeekView
//
//  Created by Evan Cooper on 2017-08-18.
//  Copyright © 2017 Evan Cooper. All rights reserved.
//

import UIKit
import SwiftDate

class EG: CalendarWeekView.EventGenerator {
    override func generateEvents(date: DateInRegion) -> [WeekViewEvent] {
        let start = date.atTime(hour: (date.day % 5) + 9, minute: 15, second: 0)!
        let end = date.atTime(hour: start.hour + (date.day % 3) + 1, minute: 30, second: 0)!

        let eventA: WeekViewEvent = WeekViewEvent(title: "Event \(date.day)A", startDate: start, endDate: end, color: UIColor.red)
        let eventB: WeekViewEvent = WeekViewEvent(title: "Event \(date.day)B", startDate: start + 30.minutes, endDate: end + 45.minutes, color: UIColor.purple)
        let eventC: WeekViewEvent = WeekViewEvent(title: "Event \(date.day)C", startDate: eventA.getEnd() + 30.minutes, endDate: eventA.getEnd() + 1.hour, color: UIColor.orange)
        
        if (date.day % 3 == 0) {
            return [eventA, eventB]
        } else if (date.day % 3 == 1) {
            return [eventA, eventC]
        }
        
        return [eventA]
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let bump: CGFloat = 10
        let frame: CGRect = CGRect(x: 0, y: bump, width: self.view.frame.width, height: self.view.frame.height - bump)
        let weekView: CalendarWeekView = CalendarWeekView(frame: frame, eventGenerator: EG(), visibleDays: 5)
        self.view.addSubview(weekView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
