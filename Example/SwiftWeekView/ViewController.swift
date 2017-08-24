//
//  ViewController.swift
//  SwiftWeekView
//
//  Created by Evan Cooper on 2017-08-18.
//  Copyright © 2017 Evan Cooper. All rights reserved.
//

import UIKit
import SwiftDate

class DS: WeekView.WeekViewDataSource {
    override func generateEvents(date: DateInRegion, completion: (([WeekViewEvent]) -> Void)?) -> [WeekViewEvent] {
        // create a WeekViewEvent for the day of date
        let start = date.atTime(hour: (date.day % 5) + 9, minute: 0, second: 0)!
        let end = date.atTime(hour: start.hour + (date.day % 3) + 1, minute: 30 * (date.day % 2), second: 0)!
        let event: WeekViewEvent = WeekViewEvent(title: "Event \(date.day)", startDate: start, endDate: end)
        return [event]
    }
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let bump: CGFloat = 10
        let frame: CGRect = CGRect(x: 0, y: bump, width: self.view.frame.width, height: self.view.frame.height - bump)
        let weekView: WeekView = WeekView(frame: frame, dataSource: DS(), visibleDays: 5, startHour: 9, endHour: 17)
        self.view.addSubview(weekView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
