///
//  ViewController.swift
//  SwiftWeekView
//
//  Created by Evan Cooper on 2017-08-18.
//  Copyright © 2017 Evan Cooper. All rights reserved.
//

import UIKit
import SwiftDate

class ViewController: UIViewController, WeekViewDataSource, WeekViewDelegate, WeekViewStyler {
    
    let eventDetailLauncher = EventDetailLauncher()
    lazy var weekView: WeekView = {
        let bump: CGFloat = 10
        let frame: CGRect = CGRect(x: 0, y: bump, width: self.view.frame.width, height: self.view.frame.height - bump)
        let weekView = WeekView(frame: frame, visibleDays: 5)
        weekView.dataSource = self
        weekView.delegate = self
        weekView.styler = self
        return weekView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(weekView)
//        weekView.setGestureRecognizer(gestureRecognizerType: UITapGestureRecognizer())
    }
    
    func weekViewGenerateEvents(_ weekView: WeekView, date: DateInRegion) -> [WeekViewEvent] {
        let start1 = date.atTime(hour: (date.day % 5) + 9, minute: 0, second: 0)!
        let end1 = date.atTime(hour: start1.hour + (date.day % 3) + 1, minute: 30 * (date.day % 2), second: 0)!
        let event1: WeekViewEvent = WeekViewEvent(title: "Event \(date.day)", start: start1, end: end1)
        return [event1]
    }
    
    func weekViewGestureForInteraction(_ weekView: WeekView) -> UIGestureRecognizer {
        return UITapGestureRecognizer(target: self, action: #selector(clickedWeekView))
    }
    
    func weekViewDidClickOnEvent(_ weekView: WeekView, event: WeekViewEvent, view: WeekViewEventView) {
        eventDetailLauncher.event = event
        eventDetailLauncher.present()
    }
    
    @objc func clickedWeekView() {
        print("Custom target for clicking on event")
    }
    
    func weekViewStylerEventView(_ weekView: WeekView, eventContainer: CGRect, event: WeekViewEvent) -> WeekViewEventView {
        let eventLeftBorder: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: eventContainer.size.height))
        eventLeftBorder.backgroundColor = UIColor.blue
        
        let eventText: UITextView = UITextView(frame: CGRect(x: 3, y: 0, width: eventContainer.size.width - 3, height: eventContainer.size.height))
        eventText.text = event.description
        eventText.backgroundColor = .clear
        eventText.font = weekView.getFont()
        eventText.textColor = weekView.getColorTheme().eventTextColor
        eventText.isEditable = false
        eventText.isSelectable = false
        
        let eventView = WeekViewEventView(frame: eventContainer)
        eventView.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.6)
        eventView.addSubview(eventLeftBorder)
        eventView.addSubview(eventText)
        return eventView
    }
}

