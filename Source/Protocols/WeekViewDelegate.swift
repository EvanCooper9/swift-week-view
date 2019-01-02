//
//  WeekViewDelegate.swift
//  SwiftWeekView
//
//  Created by Evan Cooper on 2017-12-05.
//  Copyright © 2017 Evan Cooper. All rights reserved.
//

import UIKit
import SwiftDate

/**
 Used to delegate events and actions that occur.
 */
protocol WeekViewDelegate: class {
    /**
     Fires when a calendar event is touched on
     
     - parameters:
        - weekView: the WeekView that is calling this function
        - event: the event that was clicked
        - view: the view that was clicked
     */
    func weekViewDidClickOnEvent(_ weekView: WeekView, event: WeekViewEvent, view: UIView)

    /**
     Fires when a space without an event is tapped

     - parameters:
        - weekView: the WeekView that was tapped
        - date: the date that was clicked. Accurate down to the minute.
     */
    func weekViewDidClickOnFreeTime(_ weekView: WeekView, date: DateInRegion)
}
