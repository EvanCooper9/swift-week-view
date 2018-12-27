///
//  ViewController.swift
//  SwiftWeekView
//
//  Created by Evan Cooper on 2017-08-18.
//  Copyright © 2017 Evan Cooper. All rights reserved.
//

import UIKit
import SwiftDate

class ViewController: UIViewController {
    
    let eventDetailLauncher = EventDetailLauncher()
    lazy var weekView: WeekView = {
        let bump: CGFloat = 20
        let frame: CGRect = CGRect(x: 0, y: bump, width: view.frame.width, height: view.frame.height - bump)
        let weekView = WeekView(frame: frame, visibleDays: 3)
        weekView.dataSource = self
        weekView.delegate = self
        weekView.backgroundColor = .white
        return weekView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(weekView)
    }
}

// MARK: - WeekViewDataSource

extension ViewController: WeekViewDataSource {
    func weekViewGenerateEvents(_ weekView: WeekView, date: DateInRegion, eventCompletion: @escaping ([WeekViewEvent]?) -> Void) -> [WeekViewEvent]? {
        let start1 = date.dateBySet(hour: (date.day % 5) + 9, min: 0, secs: 0)!
        let end1 = date.dateBySet(hour: start1.hour + (date.day % 3) + 1, min: 30 * (date.day % 2), secs: 0)!
        let event = WeekViewEvent(title: "Title \(date.day)", subtitle: "Subtitle \(date.day)", start: start1, end: end1)

        let lunchStart = date.dateBySet(hour: 12, min: 0, secs: 0)!
        let lunchEnd = date.dateBySet(hour: 13, min: 0, secs: 0)!
        let lunch = WeekViewEvent(title: "Lunch", subtitle: "lunch", start: lunchStart, end: lunchEnd)

        eventCompletion([event, lunch])
        return nil
    }
}

// MARK: - WeekViewDelegate

extension ViewController: WeekViewDelegate {
    func weekViewDidClickOnEvent(_ weekView: WeekView, event: WeekViewEvent, view: UIView) {
        eventDetailLauncher.event = event
        eventDetailLauncher.present()
    }

    func weekViewDidClickOnFreeTime(_ weekView: WeekView, date: DateInRegion) {
        print(#function, "date:", date.toString())
    }
}
