//
//  WeekViewStyler.swift
//  SwiftWeekView
//
//  Created by Evan Cooper on 2017-12-05.
//  Copyright © 2017 Evan Cooper. All rights reserved.
//

import Foundation
import UIKit
import SwiftDate

/**
 Used to delegate the creation of different view types within the WeekView.
 */
protocol WeekViewStyler: class {
    /**
     The font used by WeekView
     */
    var font: UIFont { get }

    /**
     Bool indicating if each cell should have a header
     */
    var showsDateHeader: Bool { get }

    /**
     The height for a cell's header, if it's being shown
     */
    var dateHeaderHeight: CGFloat { get }

    /**
     Create the view for an event
     
     - Parameters:
        - weekView: the WeekView that the view will be added to
        - eventContainer: the container of which the eventView needs to conform to
        - event: the event it's self
     */
    func weekViewStylerEventView(_ weekView: WeekView, eventContainer: CGRect, event: WeekViewEvent) -> UIView
    
    /**
     Create the header view for the day in the calendar. This would normally contain information about the date
     
     - Parameters:
        - weekView: the WeekView that the header will be added to
        - date: the date to create the header view for
        - cell: the cell that will have the header added to it
     */
    func weekViewStylerHeaderView(_ weekView: WeekView, with date: DateInRegion, in cell: UICollectionViewCell) -> UIView
}

