//
//  TimelineCell.swift
//  test
//
//  Created by Evan Cooper on 2018-02-09.
//  Copyright © 2018 Evan Cooper. All rights reserved.
//

import UIKit

class TimelineCell: UICollectionViewCell {
    
    var id: Int
    var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        self.id = 0
        super.init(frame: frame)
        self.frame = frame
    }
    
    init(frame: CGRect, id: Int) {
        self.id = id
        super.init(frame: frame)
        self.frame = frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var description: String {
        return "\(id)"
    }
    
    func setupViews() {
        addSubview(label)
        addConstraintsWithFormat(format: "V:|-16-[v0]-16-|", views: label)
        addConstraintsWithFormat(format: "H:|-16-[v0]-16-|", views: label)
    }
}
