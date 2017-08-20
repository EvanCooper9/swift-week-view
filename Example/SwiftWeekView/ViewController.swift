//
//  ViewController.swift
//  SwiftWeekView
//
//  Created by Evan Cooper on 2017-08-18.
//  Copyright © 2017 Evan Cooper. All rights reserved.
//

import UIKit
import SwiftDate

class EG: WeekView.EventGenerator {
    override func generateEvents(date: DateInRegion) -> [WeekViewEvent] {
        // create a WeekViewEvent for the day of date
        let start = date.atTime(hour: 12, minute: 0, second: 0)!
        let end = date.atTime(hour: 13, minute: 0, second: 0)!
        let event: WeekViewEvent = WeekViewEvent(title: "Lunch", startDate: start, endDate: end)
        return [event]
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let bump: CGFloat = 10
        let frame: CGRect = CGRect(x: 0, y: bump, width: self.view.frame.width, height: self.view.frame.height - bump)
        let weekView: WeekView = WeekView(frame: frame, eventGenerator: EG(), visibleDays: 5)
        self.view.addSubview(weekView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
