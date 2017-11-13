///
//  ViewController.swift
//  SwiftWeekView
//
//  Created by Evan Cooper on 2017-08-18.
//  Copyright © 2017 Evan Cooper. All rights reserved.
//

import UIKit
import SwiftDate

class ViewController: UIViewController, WeekViewDataSource, WeekViewStyler {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let bump: CGFloat = 10
        let frame: CGRect = CGRect(x: 0, y: bump, width: self.view.frame.width, height: self.view.frame.height - bump)
        let weekView: WeekView = WeekView(frame: frame, visibleDays: 3, startHour: 9, endHour: 17)
        weekView.dataSource = self
        weekView.styler = self
        self.view.addSubview(weekView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func weekViewGenerateEvents(_ weekView: WeekView, date: DateInRegion) -> [WeekViewEvent] {
        let start1 = date.atTime(hour: (date.day % 5) + 9, minute: 0, second: 0)!
        let end1 = date.atTime(hour: start1.hour + (date.day % 3) + 1, minute: 30 * (date.day % 2), second: 0)!
        let event1: WeekViewEvent = WeekViewEvent(title: "Event \(date.day)", start: start1, end: end1)
        
        let start2 = date.atTime(hour: (date.day % 5) + 9, minute: 0, second: 0)!
        let end2 = date.atTime(hour: start1.hour + (date.day % 3) + 1, minute: 30 * (date.day % 2), second: 0)!
        let event2: WeekViewEvent = WeekViewEvent(title: "Event \(date.day)", start: start2, end: end2, color: UIColor.red)
        
        return [event1, event2]
    }
    
    func weekViewStylerEventView(_ weekView: WeekView, eventContainer: CGRect, event: WeekViewEvent) -> UIView {
        let eventView: UIView = UIView(frame: eventContainer)
        eventView.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.6)
        
        let eventLeftBorder: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: eventContainer.size.height))
        eventLeftBorder.backgroundColor = UIColor.blue
        
        let eventText: UITextView = UITextView(frame: CGRect(x: 3, y: 0, width: eventContainer.size.width - 3, height: eventContainer.size.height))
        eventText.text = event.description
        eventText.backgroundColor = .clear
        eventText.font = weekView.getFont()
        eventText.textColor = weekView.getColorTheme().eventTextColor
        eventText.isEditable = false
        eventText.isSelectable = false
        
        eventView.addSubview(eventLeftBorder)
        eventView.addSubview(eventText)
        
        return eventView
    }
}
