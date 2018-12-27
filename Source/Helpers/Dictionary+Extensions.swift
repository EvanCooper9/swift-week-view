//
//  Dictionary+Extensions.swift
//  SwiftWeekView
//
//  Created by Evan Cooper on 2019-01-01.
//  Copyright © 2019 Evan Cooper. All rights reserved.
//

import Foundation

extension Dictionary {
    static func += <K, V> (left: inout [K: V], right: [K: V]) {
        right.forEach { (key: K, value: V) in
            left[key] = value
        }
    }
}
