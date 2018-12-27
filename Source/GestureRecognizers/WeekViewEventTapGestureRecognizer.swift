//
//  WeekViewEventGuestureRecognizer.swift
//  SwiftWeekView
//
//  Created by Evan Cooper on 2018-12-27.
//  Copyright © 2018 Evan Cooper. All rights reserved.
//

import UIKit

final class WeekViewEventTapGestureRecognizer: UITapGestureRecognizer {
    let event: WeekViewEvent
    let eventView: UIView

    init(target: Any?, action: Selector?, event: WeekViewEvent, eventView: UIView) {
        self.event = event
        self.eventView = eventView
        super.init(target: target, action: action)
    }
}
