//
//  Extensions.swift
//  CalendarWeekView
//
//  Created by Evan Cooper on 2017-08-17.
//  Copyright © 2017 Evan Cooper. All rights reserved.
//

import Foundation
import UIKit

// Allow for creation of UIColor with hex value eg : 0xffffff
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let coreImageColor = self.coreImageColor
        return (coreImageColor.red, coreImageColor.green, coreImageColor.blue, coreImageColor.alpha)
    }
}

// Self implementation of the NSCopying protocol
extension UIView {
    func copyView() -> UIView {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self))! as! UIView
    }
}

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
}

// Remove text insets from UITextVIew
@IBDesignable class UITextViewFixed: UITextView {
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    
    func setup() {
        textContainerInset = UIEdgeInsetsMake(0, 5, 0, 5)
        textContainer.lineFragmentPadding = 0
    }
}
