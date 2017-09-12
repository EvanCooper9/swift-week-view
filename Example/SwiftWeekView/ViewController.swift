//
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
        // Do any additional setup after loading the view, typically from a nib.
        let bump: CGFloat = 10
        let frame: CGRect = CGRect(x: 0, y: bump, width: self.view.frame.width, height: self.view.frame.height - bump)
        let weekView: WeekView = WeekView(frame: frame, visibleDays: 5, startHour: 9, endHour: 17)
        weekView.dataSource = self
//        weekView.styler = self
        self.view.addSubview(weekView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func weekViewGenerateEvents(_ weekView: WeekView, date: DateInRegion) -> [WeekViewEvent] {
        let start = date.atTime(hour: (date.day % 5) + 9, minute: 0, second: 0)!
        let end = date.atTime(hour: start.hour + (date.day % 3) + 1, minute: 30 * (date.day % 2), second: 0)!
        let event: WeekViewEvent = WeekViewEvent(title: "Event \(date.day)", start: start, end: end)
        return [event]
    }
    
    func weekViewStylerEventView(_ weekView: WeekView, eventCoordinate: CGPoint, eventSize: CGSize, event: WeekViewEvent) -> UIView {
        let eventView: UIView = UIView(frame: CGRect(x: eventCoordinate.x, y: eventCoordinate.y, width: eventSize.width, height: eventSize.height))
        eventView.backgroundColor = UIColor(red: event.getColor().components.red, green: event.getColor().components.green, blue: event.getColor().components.blue, alpha: 0.6)
        
        let eventLeftBorder: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: eventSize.height))
        eventLeftBorder.backgroundColor = event.getColor()
        
        let eventText: UITextView = UITextView(frame: CGRect(x: 3, y: 0, width: eventView.frame.width - 3, height: eventView.frame.height))
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
    
    func weekViewStylerHeaderView(_ weekView: WeekView, containerPosition: Int, containerCoordinate: CGPoint, containerSize: CGSize) -> UIView {
        return UIView(frame: CGRect(x: containerCoordinate.x, y: containerCoordinate.y, width: containerSize.width, height: 0))
    }
    
    func weekViewStylerDayView(_ weekView: WeekView, containerPosition: Int, containerCoordinate: CGPoint, containerSize: CGSize, header: UIView) -> UIView {
        let view: UIView = UIView(frame: CGRect(x: containerCoordinate.x, y: containerCoordinate.y + header.frame.height, width: containerSize.width, height: containerSize.height - header.frame.height))
        view.backgroundColor = UIColor.cyan
        return view
    }
}
