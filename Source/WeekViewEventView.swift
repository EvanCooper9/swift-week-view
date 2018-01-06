//
//  WeekViewEventView.swift
//  SwiftWeekView
//
//  Created by Evan Cooper on 2017-12-04.
//  Copyright © 2017 Evan Cooper. All rights reserved.
//

import Foundation
import UIKit

class WeekViewEventView: UIView, NSCopying {
    
    var eventID: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(eventID, forKey: "eventID")
//        aCoder.encode(gestureRecognizers, forKey: "gestureRecognizers")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        eventID = aDecoder.decodeObject(forKey: "eventID") as? String
//        gestureRecognizers = aDecoder.decodeObject(forKey: "gestureRecognizers") as? [UIGestureRecognizer]
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = WeekViewEventView(frame: frame)
        copy.gestureRecognizers = gestureRecognizers
        return copy
    }
}
