//
//  UITextView+Extensions.swift
//  SwiftWeekView
//
//  Created by Evan Cooper on 2018-12-29.
//  Copyright © 2018 Evan Cooper. All rights reserved.
//

import UIKit

// Center a UITextView's text verically
extension UITextView {
    func centerTextVertically() {
        var topCorrect = (self.bounds.size.height - self.contentSize.height * self.zoomScale) / 2
        topCorrect = (topCorrect < 0.0) ? 0.0 : topCorrect
        self.contentInset.top = topCorrect
    }

    func pushTextToTop() {
        self.contentInset.top = 0.0
    }

    func removeTextInsets() {
        textContainerInset = UIEdgeInsetsMake(0, 5, 0, 5)
        textContainer.lineFragmentPadding = 0
    }
}

