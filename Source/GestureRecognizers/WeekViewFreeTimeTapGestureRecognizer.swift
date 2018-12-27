//
//  WeekViewFreeTimeTapGuestureRecognizer.swift
//  SwiftWeekView
//
//  Created by Evan Cooper on 2018-12-27.
//  Copyright © 2018 Evan Cooper. All rights reserved.
//

import UIKit
import SwiftDate

final class WeekViewFreeTimeTapGestureRecognizer: UITapGestureRecognizer {
    let date: DateInRegion?
    
    init(target: Any?, action: Selector?, date: DateInRegion?) {
        self.date = date
        super.init(target: target, action: action)
    }
}
