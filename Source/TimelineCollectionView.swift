//
//  TimelineCollectionView.swift
//  test
//
//  Created by Evan Cooper on 2018-02-09.
//  Copyright © 2018 Evan Cooper. All rights reserved.
//

import UIKit

protocol TimelineCellDataSource {
    func setupCell(_ cell: UICollectionViewCell, indexPath: IndexPath, relativeIndex: Int, data: Any)
    func timelineCollectionView(dataFor index: Int) -> Any
}

protocol TimelineCollectionViewDelegate {
    func timelineCollectionView(didSelectItemAt indexPath: IndexPath, with relativeIndex: Int, cell: UICollectionViewCell)
}

class TimelineCollectionView<T: UICollectionViewCell>: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, TimelineCellDataSource, TimelineCollectionViewDelegate {
    
    func setupCell(_ cell: UICollectionViewCell, indexPath: IndexPath, relativeIndex: Int, data: Any) {
        guard let cell = cell as? TimelineCell else { return }
        cell.setupViews()
        cell.label.text = "\(data as! Int)"
        cell.label.textColor = .white
        cell.backgroundColor = ((indexPath.row + relativeIndex) % 2 == 0) ? .blue : .red
    }
    
    func timelineCollectionView(dataFor index: Int) -> Any {
        return index
    }
    
    let cellID: String = "cell"
    let numberOfCells: Int = 15
    let numberOfVisibleCells: Int = 5
    var relativeIndex: Int = 0
    var data: [Int:Any] = [Int:Any]()
    var flowLayout: UICollectionViewFlowLayout!
    var timelineCellDataSource: TimelineCellDataSource!
    var timelineCollectionViewDelegate: TimelineCollectionViewDelegate!
    
    enum DataDirection {
        case positive
        case negative
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        guard let layout = layout as? UICollectionViewFlowLayout else {
            fatalError("layout must be of type UICollectionViewFlowLayout")
        }
        
        dataSource = self
        delegate = self
        timelineCellDataSource = self
        timelineCollectionViewDelegate = self
        self.frame = frame
        register(T.self, forCellWithReuseIdentifier: self.cellID)
        flowLayout = layout
        backgroundColor = .lightGray
        
        Array(0...numberOfCells - 1).forEach { (i) in
            data[i] = i
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfCells
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(withReuseIdentifier: self.cellID, for: indexPath) as! T
        timelineCellDataSource.setupCell(cell, indexPath: indexPath, relativeIndex: relativeIndex, data: data[indexPath.row + relativeIndex]!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (flowLayout.scrollDirection == .horizontal) {
            return CGSize(width: collectionView.frame.width / CGFloat(numberOfVisibleCells), height: collectionView.frame.height)
        }
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height / CGFloat(numberOfVisibleCells))
    }
    
    var onceOnly = false
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !onceOnly {
            let scrollIndex = IndexPath(row: 5, section: 0)
            
            if (flowLayout.scrollDirection == .horizontal) {
                scrollToItem(at: scrollIndex, at: .left, animated: false)
            } else {
                scrollToItem(at: scrollIndex, at: .top, animated: false)
            }
            
            onceOnly = true
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if onceOnly {
            let topEdge = contentOffset.y
            let bottomEdge = contentOffset.y + frame.size.height
            let leftEdge = contentOffset.x
            let rightEdge = contentOffset.x + frame.size.width
            
            let cellHeight = frame.height / CGFloat(numberOfVisibleCells) - (flowLayout.minimumLineSpacing * CGFloat(numberOfVisibleCells - 1))
            let cellWidth = frame.width / CGFloat(numberOfVisibleCells) - (flowLayout.minimumLineSpacing * CGFloat(numberOfVisibleCells - 1))
            
            if (bottomEdge >= contentSize.height - cellHeight && flowLayout.scrollDirection == .vertical) {
                // scrolled to the bottom
                print("bottom")
                addRequiredData(dataDirection: .positive)
            } else if (topEdge <= cellHeight && flowLayout.scrollDirection == .vertical) {
                // scrolled to the top
                print("top")
                addRequiredData(dataDirection: .negative)
            } else if (leftEdge <= cellWidth && flowLayout.scrollDirection == .horizontal) {
                // scrolled to left edge
                print("left")
                addRequiredData(dataDirection: .negative)
            } else if (rightEdge >= contentSize.width - cellWidth && flowLayout.scrollDirection == .horizontal) {
                // scrolled to right edge
                print("right")
                addRequiredData(dataDirection: .positive)
            }
        }
    }
    
    func addRequiredData(dataDirection: DataDirection) {
        (2...numberOfVisibleCells).forEach { (i) in
            relativeIndex += (dataDirection == .positive) ? 1 : -1
            let checkIndex = (dataDirection == .positive) ? !data.keys.contains(relativeIndex + numberOfCells) : !data.keys.contains(relativeIndex)
            if checkIndex {
                let newIndex = (dataDirection == .positive) ? Array(data.keys).max()! + 1 : Array(data.keys).min()! - 1
                print("creating new entry in data: \(newIndex)")
                data[newIndex] = timelineCellDataSource.timelineCollectionView(dataFor: newIndex)
                print("min: \(Array(data.keys).min()!), max: \(Array(data.keys).max()!)")
            }
        }
        
        reloadData()
        
        let scrollIndex = IndexPath(row: numberOfVisibleCells, section: 0)
        if (flowLayout.scrollDirection == .horizontal) {
            scrollToItem(at: scrollIndex, at: .left, animated: false)
        } else {
            scrollToItem(at: scrollIndex, at: .top, animated: false)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        timelineCollectionViewDelegate.timelineCollectionView(didSelectItemAt: indexPath, with: relativeIndex, cell: collectionView.cellForItem(at: indexPath)!)
    }
    
    func timelineCollectionView(didSelectItemAt indexPath: IndexPath, with relativeIndex: Int, cell: UICollectionViewCell) {
        if (cell.backgroundColor == .blue || cell.backgroundColor == .red) {
            cell.backgroundColor = .black
        } else {
            cell.backgroundColor = ((indexPath.row + relativeIndex) % 2 == 0) ? .blue : .red
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
