//
//  UIInfiniteScrollView.swift
//  UIInfiniteScrollView
//
//  Created by Evan Cooper on 2017-08-10.
//  Copyright © 2017 Evan Cooper. All rights reserved.
//

import Foundation
import UIKit

class UIInfiniteScrollView: UIScrollView, UIScrollViewDelegate {
    internal var views: [[UIView]]!
    internal var viewRangeStart: Int!
    internal var viewsInPageCount: Int!
    internal var loadPageCount: Int!
    internal var viewWidth: CGFloat!
    internal var viewHeight: CGFloat!
    internal var spacerSize: CGFloat!
    internal var viewCreator: ViewCreator!
    internal var scrollDirection: Direction!
    internal var isSnapEnabled: Bool = true
    
    // Interface class meant to be subclassed for the use of the createViewSet function
    class ViewCreator {
        var scrollView: UIInfiniteScrollView!
        /*
         createViewSet(xPosition: CGFloat, viewPosition: Int, viewWidth: CGFloat, viewHeight: CGFloat, spacerSize: CGFloat) -> [UIView]
         
         Description:
         Create a set of views for a given space. Must be overriden by the subclass, or it will fail
         
         Params:
         - viewCoordinate: the origin point of the view being created
         - viewPosition: the position of the space, relative to the other spaces that have already been created
         - viewWidth: the width of the space
         - spacerSize: the width of the spacer that is placed on the right side of the space
         
         Returns: a collection of views that make up the space being initialized
         */
        
        init(scrollView: UIInfiniteScrollView? = nil) {
            self.scrollView = scrollView
        }
        
        func createViewSet(viewCoordinate: CGPoint, viewPosition: Int, viewWidth: CGFloat, viewHeight: CGFloat, views: [[UIView]], completion: @escaping ([UIView], Int) -> Void) -> [UIView] {
            fatalError("Error, did not override funciton \(#function)\nPlease use init method that defines viewCreator\n")
        }
        
        func addAsyncCreatedViewSets(events: [WeekViewEvent]) {
            fatalError("Error, did not override funciton \(#function)")
        }
    }
    
    // Enum to differentiate the scroll direction of UIInfiniteScrollView
    enum Direction {
        case horizontal
        case vertical
    }
    
    /*
     init(frame: CGRect, viewsInPageCount: Int, spacerSize: CGFloat, viewCreator: ViewCreator)
     
     Params:
     - frame: the frame that UIInfiniteScrollView sits in
     - viewsInPageCount: amount of views that are visible on screen at any given moment
     - spacerSize: width of the space between each view, in pixels
     - viewCreator: an instance of a ViewCreator subclass that overrides the createViewSet method
     - direction: the direction that the scrollView will scroll, .horizontal or .vertical
     */
    init(frame: CGRect, viewsInPageCount: Int, spacerSize: CGFloat, viewCreator: ViewCreator, direction: Direction) {
        super.init(frame: frame)
        self.commonInit(viewsInPageCount: viewsInPageCount, spacerSize: spacerSize, viewCreator: viewCreator, direction: direction)
    }
    
    /*
     Required init function, designed to fail, forcing the class-specific init function to be used
     It will fail because the viewCreator passed to the commonInit method does not override the function within
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit(viewsInPageCount: 5, spacerSize: 3, viewCreator: ViewCreator(scrollView: self), direction: Direction.horizontal)
    }
    
    /*
     commonInit(viewsInPageCount: Int, spacerSize: CGFloat, viewCreator: ViewCreator)
     
     Description:
     Function used by all the other init functions, to centrialized initialization
     
     Params:
     - viewsInPageCount: amount of views that are visible on screen at any given moment
     - spacerSize: width of the space between each view, in pixels
     - viewCreator: an instance of a ViewCreator subclass that overrides the createViewSet method
     - direction: the direction that the scrollView will scroll, .horizontal or .vertical
     */
    internal func commonInit(viewsInPageCount: Int, spacerSize: CGFloat, viewCreator: ViewCreator, direction: Direction) {
        self.delegate = self
        self.views = []
        self.viewRangeStart = 0
        self.viewsInPageCount = viewsInPageCount
        self.loadPageCount = self.viewsInPageCount * 3
        self.spacerSize = spacerSize
        self.viewCreator = viewCreator
        self.viewCreator.scrollView = self
        self.scrollDirection = direction
        
        if (self.scrollDirection == .horizontal) {
            self.viewWidth = (self.frame.width - (CGFloat(self.spacerSize) * CGFloat(self.viewsInPageCount - 1))) / CGFloat(self.viewsInPageCount)
            self.viewHeight = 0
            self.contentSize = CGSize(width: (self.viewWidth + self.spacerSize) * CGFloat(self.viewsInPageCount * 3) - self.spacerSize, height: self.frame.height)
            self.contentOffset = CGPoint(x: Int(self.viewWidth + self.spacerSize) * self.viewsInPageCount, y: 0)
        } else {
            self.viewWidth = 0
            self.viewHeight = (self.frame.height - (CGFloat(self.spacerSize) * CGFloat(self.viewsInPageCount - 1))) / CGFloat(self.viewsInPageCount)
            self.contentSize = CGSize(width: self.frame.width, height: (self.viewHeight + self.spacerSize) * CGFloat(self.viewsInPageCount * 3))
            self.contentOffset = CGPoint(x: 0, y: Int(self.viewHeight + self.spacerSize) * self.viewsInPageCount)
        }
        
        self.createViews(fromPosition: 0, toPosition: (self.viewsInPageCount * 3) - 1)
        self.loadActiveViews(startIndex: 0)
    }
    
    /*
     calculateXPosition(index: Int) -> Int ... calculateYPosition(index: Int) -> CGFloat
     
     Description:
     Commonly used calculation put into function for ease
     
     Params:
     - index: the index of the view that's being loaded
     
     Returns: the required value for the view's frame.origin.x OR frame.origin.y, in order to properly position the view
     
     NOTE:
     At any given moment, one of these functions will return 0
     When the scrollView scroll horizontally, calculateYPosition returns 0
     When the scrollView scroll vertically, calculateXPosition returns 0
     */
    internal func calculateXPosition(index: Int) -> CGFloat { return (self.scrollDirection == .horizontal) ? CGFloat(index) * (self.viewWidth + self.spacerSize) : 0 }
    internal func calculateYPosition(index: Int) -> CGFloat { return (self.scrollDirection == .vertical) ? CGFloat(index) * (self.viewHeight + self.spacerSize) : 0 }
    
    /*
     scrollViewDidScroll(_ scrollView: UIScrollView)
     
     Description:
     Tells the delegate when the user scrolls the content view within the receiver
     In this case, it's used to notify the delegate when the visible part of the scrollView is reaching the bounds of the scrollView's content
     
     From: https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619392-scrollviewdidscroll
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.scrollDirection == .horizontal) {
            let loadThreshold: CGFloat = (self.viewWidth + self.spacerSize) * 2
            let leftEdge = scrollView.contentOffset.x
            let rightEdge = scrollView.contentOffset.x + scrollView.frame.size.width
            
            if (rightEdge >= scrollView.contentSize.width - loadThreshold) {
                createViews(fromPosition: self.views.count, toPosition: self.views.count + self.viewsInPageCount)
                
                self.viewRangeStart = self.viewRangeStart + self.viewsInPageCount
                self.loadActiveViews(startIndex: self.viewRangeStart)
                self.setContentOffset(CGPoint(x: self.contentOffset.x - (self.viewWidth + self.spacerSize) * CGFloat(self.viewsInPageCount), y: 0), animated: false)
            } else if (leftEdge <= loadThreshold) {
                let lowestI = Int(self.views[0][0].frame.origin.x / self.viewWidth)
                createViews(fromPosition: lowestI - self.viewsInPageCount, toPosition: lowestI - 1)
                
                self.loadActiveViews(startIndex: self.viewRangeStart)
                self.setContentOffset(CGPoint(x: self.contentOffset.x + (self.viewWidth + self.spacerSize) * CGFloat(self.viewsInPageCount), y: 0), animated: false)
            }
        } else {
            let loadThreshold: CGFloat = (self.viewHeight + self.spacerSize) * 2
            let topEdge = scrollView.contentOffset.y
            let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
            
            if (bottomEdge >= scrollView.contentSize.height - loadThreshold) {
                createViews(fromPosition: self.views.count, toPosition: self.views.count + self.viewsInPageCount)
                
                self.viewRangeStart = self.viewRangeStart + self.viewsInPageCount
                self.loadActiveViews(startIndex: self.viewRangeStart)
                self.setContentOffset(CGPoint(x: 0, y: Int(self.viewHeight + self.spacerSize) * self.viewsInPageCount), animated: false)
            } else if (topEdge <= loadThreshold) {
                let lowestI = Int(self.views[0][0].frame.origin.y / self.viewHeight)
                createViews(fromPosition: lowestI - self.viewsInPageCount, toPosition: lowestI - 1)
                
                self.loadActiveViews(startIndex: self.viewRangeStart)
                self.setContentOffset(CGPoint(x: 0, y: Int(self.viewHeight + self.spacerSize) * self.viewsInPageCount), animated: false)
            }
        }
    }
    
    /*
     scrollViewWillBeginDecelerating(_ scrollView: UIScrollView)
     
     Description:
     Tells the delegate that the scroll view is starting to decelerate the scrolling movement
     In this case, it's used to call the snap() functoin to keep the UI clean
     
     From: https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619386-scrollviewwillbegindecelerating
     */
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if (self.isSnapEnabled) { self.snap() }
    }
    
    /*
     scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
     
     Description:
     Tells the delegate when dragging ended in the scroll view
     In this case, it's used to call the snap() functoin to keep the UI clean
     
     From: https://developer.apple.com/documentation/uikit/uiscrollviewdelegate/1619436-scrollviewdidenddragging
     */
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (self.isSnapEnabled) { self.snap() }
    }
    
    /*
     snap()
     
     Description:
     Snap the content view edges to the closest edges
     */
    private func snap() {
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
    
    /*
     loadActiveViews(startIndex: Int)
     
     Description:
     To load the necessary views into the content box of UIInfiniteScrollView
     These views are the ones that are visible to the user and represent the current horizontal position of UIInfiniteScrollView
     
     Params:
     - startIndex: The index to start loading views from the class' views parameter
     */
    internal func loadActiveViews(startIndex: Int) {
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        for i in startIndex..<startIndex + self.viewsInPageCount * 3 {
            var index = i
            if (index >= self.views.count) { index -= startIndex }
            for view in self.views[index] {
                let placeholderView: UIView = view.copyView()
                if (self.scrollDirection == .horizontal) {
                    var viewCalculatedXPosition = self.calculateXPosition(index: index - startIndex)
                    viewCalculatedXPosition += view.frame.origin.x - self.views[index][0].frame.origin.x
                    placeholderView.frame.origin.x = viewCalculatedXPosition
                } else {
                    var viewCalculatedYPosition = self.calculateYPosition(index: index - startIndex)
                    viewCalculatedYPosition += view.frame.origin.y - self.views[index][0].frame.origin.y
                    placeholderView.frame.origin.y = viewCalculatedYPosition
                }
                self.addSubview(placeholderView)
            }
        }
    }
    
    /*
     addAsyncLoadedViews(views: [UIView], viewPosition: Int)
     
     Description:
     To load in the views that were created asynchronously
     
     Params:
     - views: the views that were create asynchronously
     - viewPosition: the position of the views relative to the others
    */
    internal func addAsyncLoadedViews(views: [UIView], viewPosition: Int) {
        let newViewPosition = (viewPosition <= 0) ? abs(self.viewRangeStart - viewPosition) : viewPosition
        
        var index: Int = 0
        for viewSet in self.views {
            if (viewSet[0].frame.origin.x == views[0].frame.origin.x) {
                self.views[index].append(contentsOf: views)
                for view in views {
                    let placeholderView: UIView = view.copyView()
                    if (self.scrollDirection == .horizontal) {
                        var viewCalculatedXPosition = self.calculateXPosition(index: newViewPosition)
                        viewCalculatedXPosition += view.frame.origin.x - self.views[newViewPosition][0].frame.origin.x
                        placeholderView.frame.origin.x = viewCalculatedXPosition
                    } else {
                        var viewCalculatedYPosition = self.calculateYPosition(index: newViewPosition)
                        viewCalculatedYPosition += view.frame.origin.y - self.views[newViewPosition][0].frame.origin.y
                        placeholderView.frame.origin.y = viewCalculatedYPosition
                    }
                    self.addSubview(placeholderView)
                }
                break
            }
            index += 1
        }
    }
    
    /*
     createViews(fromPosition: Int, toPosition: Int)
     
     Description:
     Create brand new views and add them to UIInfiniteScrollView's array of views
     Keep UIInfiniteScrollView's views sorted by the x orgin of each index
     
     Params:
     - fromPosition: start creating views from this position
     - toPosition: stop creating views at this position (inclusive)
     */
    internal func createViews(fromPosition: Int, toPosition: Int) {
        for i in fromPosition...toPosition {
            let viewCoordinate: CGPoint = CGPoint(x: calculateXPosition(index: i), y: calculateYPosition(index: i))
            
            if (self.scrollDirection == .horizontal) {
                let viewSet = self.viewCreator.createViewSet(viewCoordinate: viewCoordinate, viewPosition: i, viewWidth: self.viewWidth, viewHeight: self.frame.height, views: self.views, completion: self.addAsyncLoadedViews)
                self.views.append(viewSet)
                self.views.sort(by: {$0[0].frame.origin.x < $1[0].frame.origin.x})
            } else {
                let viewSet = self.viewCreator.createViewSet(viewCoordinate: viewCoordinate, viewPosition: i, viewWidth: self.frame.width, viewHeight: self.viewHeight, views: self.views, completion: self.addAsyncLoadedViews)
                self.views.append(viewSet)
                self.views.sort(by: {$0[0].frame.origin.y < $1[0].frame.origin.y})
            }
        }
    }
    
    /*
     jumpToView(viewPosition: Int?, viewXPosition: CGFloat?)
     
     Description:
     Jump to the visible area to the specified view position
     The defined view position will the the first view from the left in the visible area
     
     Params (one is required):
     - viewPosition (optional): The position of the view relative to the other views that have been created (default use if both parameters are provided)
     - viewCoordinate (optional): The coordinate of the view's frame's origin
     */
    public func jumpToView(viewPosition: Int?, viewCoordinate: CGPoint?) {
        if let viewPosition = viewPosition {
            self.loadActiveViews(startIndex: viewPosition - self.viewsInPageCount)
        } else if let viewCoordinate = viewCoordinate {
            if (self.scrollDirection == .horizontal) {
                self.loadActiveViews(startIndex: Int(viewCoordinate.x / (self.viewWidth + self.spacerSize)) - self.viewsInPageCount)
            } else {
                self.loadActiveViews(startIndex: Int(viewCoordinate.y / (self.viewHeight + self.spacerSize)) - self.viewsInPageCount)
            }
        } else {
            fatalError("Please give one of: viewPosition: Int, viewXPosition: CGFloat.\nIf both are provided, default is viewPosition")
        }
    }
}
