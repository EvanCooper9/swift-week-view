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

protocol Theme {
    var baseColor: UIColor {get}
    var hourLineColor: UIColor {get}
    var hourTextColor: UIColor {get}
    var eventTextColor: UIColor {get}
    var weekendColor: UIColor {get}
}

class LightTheme: Theme {
    var baseColor: UIColor = UIColor(rgb: 0xffffff)
    var hourLineColor: UIColor = UIColor(rgb: 0xe6e5e6)
    var hourTextColor: UIColor = UIColor(rgb: 0x373737)
    var eventTextColor: UIColor = UIColor(rgb: 0xfafafa)
    var weekendColor: UIColor = UIColor(rgb: 0xf4f4f4)
}

class DarkTheme: Theme {
    var baseColor: UIColor = UIColor(rgb: 0x373737)
    var hourLineColor: UIColor = UIColor(rgb: 0x252525)
    var hourTextColor: UIColor = UIColor(rgb: 0xc0c0c0)
    var eventTextColor: UIColor = UIColor(rgb: 0xc0c0c0)
    var weekendColor: UIColor = UIColor(rgb: 0x414141)
}
