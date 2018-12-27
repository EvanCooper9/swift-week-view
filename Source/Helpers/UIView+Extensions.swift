//
//  UIView+Extensions.swift
//  SwiftWeekView
//
//  Created by Evan Cooper on 2018-12-29.
//  Copyright © 2018 Evan Cooper. All rights reserved.
//

import UIKit


extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}
