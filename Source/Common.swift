//
//  Common.swift
//  CalendarWeekView
//
//  Created by Evan Cooper on 2017-08-17.
//  Copyright © 2017 Evan Cooper. All rights reserved.
//

import Foundation
import UIKit

enum ScrollDirection: Int {
    case horizontal
    case vertical
}

enum Theme {
    case light, dark
    
    var baseColor: UIColor {
        switch self {
        case .light:
            return UIColor(rgb: 0xffffff)
        case .dark:
            return UIColor(rgb: 0x373737)
        }
    }
    
    var hourLineColor: UIColor {
        switch self {
        case .light:
            return UIColor(rgb: 0xe6e5e6)
        case .dark:
            return UIColor(rgb: 0x252525)
        }
    }
    
    var hourTextColor: UIColor {
        switch self {
        case .light:
            return UIColor(rgb: 0x373737)
        case .dark:
            return UIColor(rgb: 0xc0c0c0)
        }
    }
    
    var eventTextColor: UIColor {
        switch self {
        case .light:
            return UIColor(rgb: 0xfafafa)
        case .dark:
            return UIColor(rgb: 0xc0c0c0)
        }
    }
    
    var weekendColor: UIColor {
        switch self {
        case .light:
            return UIColor(rgb: 0xf4f4f4)
        case .dark:
            return UIColor(rgb: 0x414141)
        }
    }
}
