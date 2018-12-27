//
//  TimelineCollectionViewCell.swift
//  SwiftWeekView
//
//  Created by Evan Cooper on 2018-12-27.
//  Copyright © 2018 Evan Cooper. All rights reserved.
//

import UIKit

final class WeekViewDayCell: UICollectionViewCell {
    override func prepareForReuse() {
        subviews.forEach { subview in
            subview.removeFromSuperview()
        }
    }
}
