//
//  WeekViewDelegate.swift
//  SwiftWeekView
//
//  Created by Evan Cooper on 2017-12-05.
//  Copyright © 2017 Evan Cooper. All rights reserved.
//

import Foundation
import UIKit

/*
 Protocol WeekViewDelegate
 
 Description:
 Used to delegate events and actions that occur.
 */
@objc protocol WeekViewDelegate {
    /*
     weekViewDidClickOnEvent(_ weekView: WeekView, event: WeekViewEvent)
     
     Description:
     Fires when a calendar event is touched on
     
     Params:
     - weekView: the WeekView that is calling this function
     - event: the event that was clicked
     */
    @objc func weekViewDidClickOnEvent(_ weekView: WeekView, event: WeekViewEvent, view: WeekViewEventView)
}
