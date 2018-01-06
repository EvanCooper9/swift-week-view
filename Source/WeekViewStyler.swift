//
//  WeekViewStyler.swift
//  SwiftWeekView
//
//  Created by Evan Cooper on 2017-12-05.
//  Copyright © 2017 Evan Cooper. All rights reserved.
//

import Foundation
import UIKit

/**
 Used to delegate the creation of different view types within the WeekView.
 */
@objc protocol WeekViewStyler {
    /**
     Create the view for an event
     
     - Parameters:
        - weekView: the WeekView that the view will be added to
        - eventContainer: the container of which the eventView needs to conform to
        - event: the event it's self
     */
    @objc optional func weekViewStylerEventView(_ weekView: WeekView, eventContainer: CGRect, event: WeekViewEvent) -> WeekViewEventView
    
    /**
     Create the header view for the day in the calendar. This would normally contain information about the date
     
     - Parameters:
        - weekView: the WeekView that the header will be added to
        - containerPosition: the left-to-right position of the container that the header will be added to, relative to the other containers that have been created
        - container: the container of which the header needs to conform to
     */
    @objc optional func weekViewStylerHeaderView(_ weekView: WeekView, containerPosition: Int, container: CGRect) -> UIView
    
    /**
     Create the main view that will contain the events. This normally appears directly under the header created in weekViewUIEventView (above)
     
     - Parameters:
        - weekView: the WeekView that the header will be added to
        - containerPosition: the left-to-right position of the container that the view will be added to, relative to the other containers that have been created
        - container: the container of which the timeView needs to conform to
        - header: the header of the weekView. The time view should start under the header
     */
    @objc optional func weekViewStylerDayView(_ weekView: WeekView, containerPosition: Int, container: CGRect, header: UIView) -> UIView
}

