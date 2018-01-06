//
//  UIInfiniteScrollView.swift
//  UIInfiniteScrollView
//
//  Created by Evan Cooper on 2017-08-10.
//  Copyright © 2017 Evan Cooper. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class UIInfiniteScrollView: UIScrollView, UIScrollViewDelegate, UIInfiniteScrollViewDataSource {
    private var views = [[UIView]]()
    private var viewRangeStart: Int! = 0
    private var loadPageCount: Int!
    private var viewSize: CGSize!
    private var spacerSize: CGFloat! = 2
    private var viewsInPageCount: Int! = 5
    private var scrollDirection: ScrollDirection! = .horizontal
    
    private var isSnapEnabled: Bool = true
    
    var weekView: WeekView?
    
    var dataSource: UIInfiniteScrollViewDataSource! {
        didSet {
            if (oldValue != nil) {
                for subView in self.subviews {
                    for subView2 in subView.subviews {
                        subView2.removeFromSuperview()
                    }
                    subView.removeFromSuperview()
                }
                self.views = []
                self.createViews(fromPosition: 0, toPosition: (self.viewsInPageCount * 3) - 1)
                self.loadActiveViews(startIndex: 0)
            }
        }
    }
    
    // getter(s)
    func getViewRangeStart() -> Int { return self.viewRangeStart }
    func getSpacerSize() -> CGFloat { return self.spacerSize }
    func getViews() -> [[UIView]] { return self.views }
    func getViewSize() -> CGSize { return self.viewSize }
    
    /*
     init(frame: CGRect, viewsInPageCount: Int, spacerSize: CGFloat, ScrollDirection: ScrollDirection) {
     
     Params:
     - frame: the frame that UIInfiniteScrollView sits in
     - viewsInPageCount: amount of views that are visible on screen at any given moment
     - spacerSize: width of the space between each view, in pixels
     - scrollDirection: the scrollDirection that the scrollView will scroll, .horizontal or .vertical
     */
    init(frame: CGRect, viewsInPageCount: Int, spacerSize: CGFloat, scrollDirection: ScrollDirection) {
        super.init(frame: frame)
        self.commonInit(viewsInPageCount: viewsInPageCount, spacerSize: spacerSize, scrollDirection: scrollDirection)
    }
    
    /*
     init(frame: CGRect)
     
     NOTE: Only to be used internally for storyboard initialization
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit(viewsInPageCount: 5, spacerSize: 2, scrollDirection: .horizontal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit(viewsInPageCount: 5, spacerSize: 2, scrollDirection: .horizontal)
    }
    
    /*
     prepareForInterfaceBuilder()
     
     Description:
     Called when a designable object is created in Interface Builder
     
     From: https://developer.apple.com/documentation/objectivec/nsobject/1402908-prepareforinterfacebuilder
    */
    override func prepareForInterfaceBuilder() {
        self.commonInit(viewsInPageCount: 5, spacerSize: 2, scrollDirection: .horizontal)
    }
    
    /*
     commonInit(viewsInPageCount: Int, spacerSize: CGFloat, scrollDirection: ScrollDirection)
     
     Description:
     Function used by all the other init functions, to centrialized initialization
     
     Params:
     - viewsInPageCount: amount of views that are visible on screen at any given moment
     - spacerSize: width of the space between each view, in pixels
     - scrollDirection: the direction that the scrollView will scroll, .horizontal or .vertical
     */
    private func commonInit(viewsInPageCount: Int, spacerSize: CGFloat, scrollDirection: ScrollDirection) {
        delegate = self
        dataSource = self
        self.viewsInPageCount = viewsInPageCount
        loadPageCount = self.viewsInPageCount * 3
        self.spacerSize = spacerSize
        self.scrollDirection = scrollDirection
        
        if (scrollDirection == .horizontal) {
            viewSize = CGSize(width: (self.frame.width - (CGFloat(self.spacerSize) * CGFloat(self.viewsInPageCount - 1))) / CGFloat(self.viewsInPageCount), height: self.frame.height)
            contentSize = CGSize(width: (self.viewSize.width + self.spacerSize) * CGFloat(self.viewsInPageCount * 3) - self.spacerSize, height: self.frame.height)
            contentOffset = CGPoint(x: Int(self.viewSize.width + self.spacerSize) * self.viewsInPageCount, y: 0)
        } else {
            viewSize = CGSize(width: self.frame.width, height: (self.frame.height - (CGFloat(self.spacerSize) * CGFloat(self.viewsInPageCount - 1))) / CGFloat(self.viewsInPageCount))
            contentSize = CGSize(width: self.frame.width, height: (self.viewSize.height + self.spacerSize) * CGFloat(self.viewsInPageCount * 3))
            contentOffset = CGPoint(x: 0, y: Int(self.viewSize.height + self.spacerSize) * self.viewsInPageCount)
        }
        
        createViews(fromPosition: 0, toPosition: (self.viewsInPageCount * 3) - 1)
        loadActiveViews(startIndex: 0)
    }
    
    /*
     calculateXPosition(index: Int) -> CGFloat ... calculateYPosition(index: Int) -> CGFloat
     
     
     Commonly used calculation put into function for ease
     
     Params:
     - index: the index of the view that's being loaded
     
     Returns: the required value for the view's frame.origin.x OR frame.origin.y, in order to properly position the view
     
     NOTE:
     When the scrollView scroll horizontally, calculateYPosition returns 0
     When the scrollView scroll vertically, calculateXPosition returns 0
     */
    private func calculateXPosition(index: Int) -> CGFloat { return (scrollDirection == .horizontal) ? CGFloat(index) * (viewSize.width + spacerSize) : 0 }
    private func calculateYPosition(index: Int) -> CGFloat { return (scrollDirection == .vertical) ? CGFloat(index) * (viewSize.height + spacerSize) : 0 }
    
    /**
     Calculate the realtive position of a view within UIInfiniteScrollView's content based on the view's index.based
     
     - Parameters:
        - index: the index of the view that's being added to the content view of UIInfinteScrollView
     */
    private func calculatePosition(index: Int) -> CGPoint {
        var point = CGPoint()
        point.x = (scrollDirection == .horizontal) ? CGFloat(index) * (viewSize.width + spacerSize) : 0
        point.y = (scrollDirection == .vertical) ? CGFloat(index) * (viewSize.height + spacerSize) : 0
        return point
    }
    
    /*
     Implementation of the UIScrollViewDelegate protocol method.
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.views.count > 0) {
            if (self.scrollDirection == .horizontal) {
                let loadThreshold: CGFloat = self.viewSize.width / 2 // (self.viewSize.width + self.spacerSize) * 2
                let leftEdge = scrollView.contentOffset.x
                let rightEdge = scrollView.contentOffset.x + scrollView.frame.size.width
                
                if (rightEdge >= scrollView.contentSize.width - loadThreshold) {
                    createViews(fromPosition: self.views.count, toPosition: self.views.count + self.viewsInPageCount)
                    
                    self.viewRangeStart = self.viewRangeStart + self.viewsInPageCount
                    self.loadActiveViews(startIndex: self.viewRangeStart)
                    self.setContentOffset(CGPoint(x: self.contentOffset.x - (self.viewSize.width + self.spacerSize) * CGFloat(self.viewsInPageCount), y: 0), animated: false)
                } else if (leftEdge <= loadThreshold) {
                    let lowestI = Int(self.views[0][0].frame.origin.x / self.viewSize.width)
                    createViews(fromPosition: lowestI - self.viewsInPageCount, toPosition: lowestI - 1)
                    
                    self.loadActiveViews(startIndex: self.viewRangeStart)
                    self.setContentOffset(CGPoint(x: self.contentOffset.x + (self.viewSize.width + self.spacerSize) * CGFloat(self.viewsInPageCount), y: 0), animated: false)
                }
            } else {
                let loadThreshold: CGFloat = self.viewSize.height / 2 // (self.viewSize.height + self.spacerSize) * 2
                let topEdge = scrollView.contentOffset.y
                let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
                
                if (bottomEdge >= scrollView.contentSize.height - loadThreshold) {
                    createViews(fromPosition: self.views.count, toPosition: self.views.count + self.viewsInPageCount)
                    
                    self.viewRangeStart = self.viewRangeStart + self.viewsInPageCount
                    self.loadActiveViews(startIndex: self.viewRangeStart)
                    self.setContentOffset(CGPoint(x: 0, y: Int(self.viewSize.height + self.spacerSize) * self.viewsInPageCount), animated: false)
                } else if (topEdge <= loadThreshold) {
                    let lowestI = Int(self.views[0][0].frame.origin.y / self.viewSize.height)
                    createViews(fromPosition: lowestI - self.viewsInPageCount, toPosition: lowestI - 1)
                    
                    self.loadActiveViews(startIndex: self.viewRangeStart)
                    self.setContentOffset(CGPoint(x: 0, y: Int(self.viewSize.height + self.spacerSize) * self.viewsInPageCount), animated: false)
                }
            }
        }
    }
    
    /*
     Implementation of the UIScrollViewDelegate protocol method.
     */
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if (self.isSnapEnabled) { self.snap() }
    }
    
    /*
     Implementation of the UIScrollViewDelegate protocol method.
     */
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (self.isSnapEnabled) { self.snap() }
    }
    
    /**
     Snap the content view edges to the closest edges
     */
    public func snap() {
        var closestAnchor: CGFloat = (self.scrollDirection == .horizontal) ? self.contentSize.width : self.contentSize.height
        var closestViewSet: [UIView] = self.views[0]
        for viewSet in self.views {
            let delta = (self.scrollDirection == .horizontal) ? abs(self.contentOffset.x - viewSet[0].frame.origin.x) : abs(self.contentOffset.x - viewSet[0].frame.origin.y)
            if (delta < closestAnchor) {
                closestAnchor = delta
                closestViewSet = viewSet
            }
        }
        
        self.setContentOffset(CGPoint(x: closestViewSet[0].frame.origin.x, y: 0), animated: true)
    }
    
    /**
     Create brand new views and add them to UIInfiniteScrollView's array of views
     Keep UIInfiniteScrollView's views sorted by the x orgin of each index
     
     - Parameters:
        - fromPosition: start creating views from this position
        - toPosition: stop creating views at this position (inclusive)
     */
    private func createViews(fromPosition: Int, toPosition: Int) {
        for i in fromPosition...toPosition {
            let viewCoordinate: CGPoint = calculatePosition(index: i) //CGPoint(x: calculateXPosition(index: i), y: calculateYPosition(index: i))
            let viewSet = self.dataSource.scrollViewFillContainer(containerCoordinate: viewCoordinate, containerPosition: i, containerSize: self.viewSize, completion: self.addAsyncLoadedViews)
            self.views.append(viewSet)
            
            if (viewSet.count >= 2) {
                print(viewSet[1].gestureRecognizers)
            }
            
            if (self.scrollDirection == .horizontal) {
                self.views.sort(by: {$0[0].frame.origin.x < $1[0].frame.origin.x})
            } else {
                self.views.sort(by: {$0[0].frame.origin.y < $1[0].frame.origin.y})
            }
        }
    }
    
    /**
     To load the necessary views into the content box of UIInfiniteScrollView
     These views are the ones that are visible to the user and represent the current horizontal position of UIInfiniteScrollView
     
     - Parameters:
        - startIndex: The index to start loading views from the class' views parameter
     */
    private func loadActiveViews(startIndex: Int) {
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        for i in startIndex..<startIndex + self.viewsInPageCount * 3 {
            var index = i
            if (index >= self.views.count) { index -= startIndex }
            for view in self.views[index] {
                let placeholderView = view.copyView()
                var placeholderViewPosition = calculatePosition(index: index - startIndex)
                if (scrollDirection == .horizontal) {
                    placeholderViewPosition.x += view.frame.origin.x - self.views[index][0].frame.origin.x
                    placeholderView.frame.origin.x = placeholderViewPosition.x
                } else {
                    placeholderViewPosition.y += view.frame.origin.y - self.views[index][0].frame.origin.y
                    placeholderView.frame.origin.y = placeholderViewPosition.y
                }
                
                if (view.gestureRecognizers != nil) {
                    for gestureRecognizer in view.gestureRecognizers! {
                        placeholderView.addGestureRecognizer(gestureRecognizer)
                    }
                }
                
                if (type(of: view) == WeekViewEventView.self && self.weekView != nil) {
                    let gestureRecognizer = UITapGestureRecognizer(target: self.weekView!, action: #selector(self.weekView?.didClickOnEvent(_:)))
                    placeholderView.addGestureRecognizer(gestureRecognizer)
                }
                
                addSubview(placeholderView)
            }
        }
    }
    
    /**
     To load in the views that were created asynchronously. Used as a completion handler when generating the views
     
     - Parameters:
        - views: the views that were create asynchronously
    */
    private func addAsyncLoadedViews(views: [UIView]) {
        var index: Int = 0
        for viewSet in self.views {
            if (viewSet[0].frame.origin.x == views[0].frame.origin.x) {
                self.views[index].append(contentsOf: views)
                for view in views {
                    let placeholderView = view.copyView()
                    var placeholderViewPosition = calculatePosition(index: index - self.viewRangeStart)
                    if (scrollDirection == .horizontal) {
                        placeholderViewPosition.x += view.frame.origin.x - self.views[index][0].frame.origin.x
                        placeholderView.frame.origin.x = placeholderViewPosition.x
                    } else {
                        placeholderViewPosition.y += view.frame.origin.y - self.views[index][0].frame.origin.y
                        placeholderView.frame.origin.y = placeholderViewPosition.y
                    }
                    
                    if (view.gestureRecognizers != nil) {
                        for gestureRecognizer in view.gestureRecognizers! {
                            placeholderView.addGestureRecognizer(gestureRecognizer)
                        }
                    }
                    
                    if (type(of: view) == WeekViewEventView.self && self.weekView != nil) {
//                        print(view)
                        let gestureRecognizer = UITapGestureRecognizer(target: self.weekView!, action: #selector(self.weekView?.didClickOnEvent(_:)))
                        placeholderView.addGestureRecognizer(gestureRecognizer)
                    }
                
                    addSubview(placeholderView)
                }
                break
            }
            index += 1
        }
    }
    
    /**
     Jump to the visible area to the specified view position
     The defined view position will the the first view from the left in the visible area
     
     - Important:
     At least one of the parameters is required.
     
     - Parameters:
        - viewPosition: (optional) The position of the view relative to the other views that have been created (default use if both parameters are provided)
        - viewCoordinate: (optional) The coordinate of the view's frame's origin
     */
     func jumpToView(viewPosition: Int?, viewCoordinate: CGPoint?) {
        if let viewPosition = viewPosition {
            self.loadActiveViews(startIndex: viewPosition - self.viewsInPageCount)
        } else if let viewCoordinate = viewCoordinate {
            if (self.scrollDirection == .horizontal) {
                self.loadActiveViews(startIndex: Int(viewCoordinate.x / (self.viewSize.width + self.spacerSize)) - self.viewsInPageCount)
            } else {
                self.loadActiveViews(startIndex: Int(viewCoordinate.y / (self.viewSize.height + self.spacerSize)) - self.viewsInPageCount)
            }
        } else {
            fatalError("Please give one of: viewPosition: Int, viewXPosition: CGFloat.\nIf both are provided, default is viewPosition")
        }
    }
    
    /*
     Default implementation of the UIInfiniteScrollViewDataSource protocol method.
    */
    internal func scrollViewFillContainer(containerCoordinate: CGPoint, containerPosition: Int, containerSize: CGSize, completion: @escaping ([UIView]) -> Void) -> [UIView] {
        let view: UIView = UIView(frame: CGRect(x: containerCoordinate.x, y: containerCoordinate.y, width: containerSize.width, height: containerSize.height))
        view.backgroundColor = (containerPosition % 2 == 0) ? UIColor.lightGray : UIColor.gray
        return [view]
    }
}
