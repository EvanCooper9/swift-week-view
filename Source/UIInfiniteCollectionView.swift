//
//  UIInfiniteCollectionView.swift
//  test
//
//  Created by Evan Cooper on 2018-01-13.
//  Copyright © 2018 Evan Cooper. All rights reserved.
//

import UIKit

class UIInfiniteCollectionViewCell: UICollectionViewCell {
    
    var label: UILabel = {
        var label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    func setupViews() {
        addSubview(label)
        addConstraintsWithFormat(format: "V:|-8-[v0]-8-|", views: label)
        addConstraintsWithFormat(format: "H:|-8-[v0]-8-|", views: label)
    }
}

class UIInfiniteCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var totalData = Array(1...9)
    var data = Array(1...9)
    var flowLayout: UICollectionViewFlowLayout!
    var cellWidth: CGFloat = 200
    var cellHeight: CGFloat = 200
    
    init(frame: CGRect, layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        dataSource = self
        delegate = self
        self.flowLayout = layout as! UICollectionViewFlowLayout
        backgroundColor = UIColor.white
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: String(describing: type(of: UIInfiniteCollectionViewCell.self)), for: indexPath) as! UIInfiniteCollectionViewCell
        cell.setupViews()
        cell.label.text = "\(data[indexPath.item])"
        cell.backgroundColor = (data[indexPath.item] % 2 == 0) ? .blue : .red
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (flowLayout.scrollDirection == .horizontal) {
            cellWidth = frame.width / 5
            cellHeight = frame.height
            return CGSize(width: frame.width / 5, height: frame.height)
        }
        cellWidth = frame.width
        cellHeight = frame.height / 5
        return CGSize(width: frame.width, height: frame.height / 5)
    }
    
    var onceOnly = false
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !onceOnly {
            let scrollIndex = IndexPath(row: 3, section: 0)
            if (flowLayout.scrollDirection == .horizontal) {
                scrollToItem(at: scrollIndex, at: .left, animated: false)
            } else {
                scrollToItem(at: scrollIndex, at: .top, animated: false)
            }
            onceOnly = true
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let leftEdge = contentOffset.x + frame.width
        let rightEdge = contentOffset.x
        let topEdge = contentOffset.y
        let bottomEdge = contentOffset.y + frame.size.height
        
        if onceOnly {
            if (rightEdge <= cellWidth && flowLayout.scrollDirection == .horizontal) {
                // scrolled to the right
                data.removeLast()
                data.insert(data.first! - 1, at: 0)
                totalData.insert(data.first! - 1, at: 0)
                self.reloadData()
                let scrollIndex = IndexPath(row: 2, section: 0)
                scrollToItem(at: scrollIndex, at: .left, animated: false)
            } else if (leftEdge >= scrollView.contentSize.width - cellWidth && flowLayout.scrollDirection == .horizontal) {
                // scrolled to the left
                data.removeFirst()
                data.append(data.last! + 1)
                totalData.append(data.last! + 1)
                self.reloadData()
                let scrollIndex = IndexPath(row: data.count - 3, section: 0)
                scrollToItem(at: scrollIndex, at: .right, animated: false)
            } else if (bottomEdge >= contentSize.height - cellHeight && flowLayout.scrollDirection == .vertical) {
                // scrolled to the bottom
                data.removeFirst()
                data.append(data.last! + 1)
                totalData.append(data.last! + 1)
                self.reloadData()
                let scrollIndex = IndexPath(row: data.count - 3, section: 0)
                scrollToItem(at: scrollIndex, at: .bottom, animated: false)
            } else if (topEdge <= cellHeight && flowLayout.scrollDirection == .vertical) {
                // scrolled to the top
                data.removeLast()
                data.insert(data.first! - 1, at: 0)
                totalData.insert(data.first! - 1, at: 0)
                self.reloadData()
                let scrollIndex = IndexPath(row: 2, section: 0)
                scrollToItem(at: scrollIndex, at: .top, animated: false)
            }
        }
    }
}
