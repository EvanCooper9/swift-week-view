//
//  Common.swift
//  CalendarWeekView
//
//  Created by Evan Cooper on 2017-08-17.
//  Copyright © 2017 Evan Cooper. All rights reserved.
//

import Foundation
import UIKit

protocol Theme {
    var baseColor: UIColor {get}
    var hourLineColor: UIColor {get}
    var hourTextColor: UIColor {get}
    var eventTextColor: UIColor {get}
    var weekendColor: UIColor {get}
}

class LightTheme: Theme {
    var baseColor: UIColor = UIColor(rgb: 0xfafafa)
    var hourLineColor: UIColor = UIColor(rgb: 0xe6e5e6)
    var hourTextColor: UIColor = UIColor(rgb: 0xc0c0c0)
    var eventTextColor: UIColor = UIColor(rgb: 0xffffff)
    var weekendColor: UIColor = UIColor(rgb: 0xf5f5f5)
}

class DarkTheme: Theme {
    var baseColor: UIColor = UIColor(rgb: 0x414141)
    var hourLineColor: UIColor = UIColor(rgb: 0xffffff)
    var hourTextColor: UIColor = UIColor(rgb: 0xffffff)
    var eventTextColor: UIColor = UIColor(rgb: 0xffffff)
    var weekendColor: UIColor = UIColor(rgb: 0x414141)
}
