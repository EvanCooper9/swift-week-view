//
//  WeekViewDelegate.swift
//  SwiftWeekView
//
//  Created by Evan Cooper on 2017-12-05.
//  Copyright © 2017 Evan Cooper. All rights reserved.
//

import Foundation
import UIKit

/**
 Used to delegate events and actions that occur.
 */
@objc protocol WeekViewDelegate {
    /**
     Fires when a calendar event is touched on
     
     - Parameters:
        - weekView: the WeekView that is calling this function
        - event: the event that was clicked
        - view: the view that was clicked
     */
    @objc func weekViewDidClickOnEvent(_ weekView: WeekView, event: WeekViewEvent, view: WeekViewEventView)
    
    /**
     For determining a gesture that will be used to interact with events
     
     - Important:
     Make sure to set the target of the gesture to the included weekView parameter.
     
     - Parameters:
        - weekView: the WeekView that will use the returned guesture
     */
    @objc optional func weekViewGestureForInteraction(_ weekView: WeekView) -> UIGestureRecognizer
}
