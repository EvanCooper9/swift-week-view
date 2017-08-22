//
//  ViewController.swift
//  SwiftWeekView
//
//  Created by Evan Cooper on 2017-08-18.
//  Copyright © 2017 Evan Cooper. All rights reserved.
//

import UIKit
import SwiftDate

class EG: WeekView.WeekViewDataSource {
    override func generateEvents(date: DateInRegion, completion: (([WeekViewEvent]) -> Void)?) -> [WeekViewEvent] {
        var events: [WeekViewEvent] = []
        
        if (completion != nil) {
            // perform asynchronous tasks
            completion!(events)
        }
        
        // create a WeekViewEvent for the day of date
        let start = date.atTime(hour: 12, minute: 0, second: 0)!
        let end = date.atTime(hour: 13, minute: 30, second: 0)!
        let event: WeekViewEvent = WeekViewEvent(title: "Lunch \(date.day)", startDate: start, endDate: end)
        events.append(event)
        return events
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let bump: CGFloat = 10
        let frame: CGRect = CGRect(x: 0, y: bump, width: self.view.frame.width, height: self.view.frame.height - bump)
        let weekView: WeekView = WeekView(frame: frame, dataSource: EG(), visibleDays: 5)
        self.view.addSubview(weekView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
