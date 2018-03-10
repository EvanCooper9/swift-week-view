//
//  WeekViewDataSource.swift
//  SwiftWeekView
//
//  Created by Evan Cooper on 2017-12-05.
//  Copyright © 2017 Evan Cooper. All rights reserved.
//

import Foundation
import UIKit
import SwiftDate

/**
 Used to delegate the creation of events for the WeekView
 */
protocol WeekViewDataSource {
    /**
     Generate and return a set of events for a specific day. Events can be returned synchronously or asynchronously
     
     - Returns:
     A collection of WeekViewEvents specific to the day of the provided date
     
     - Parameters:
        - weekView: the WeekView that is calling this function
        - date: the date for which to create events for
     */
    func weekViewGenerateEvents(_ weekView: WeekView, date: DateInRegion, eventCompletion: @escaping ([WeekViewEvent]) -> Void) -> [WeekViewEvent]
}
