//
//  UIInfiniteScrollViewDataSource.swift
//  SwiftWeekView
//
//  Created by Evan Cooper on 2017-12-15.
//  Copyright © 2017 Evan Cooper. All rights reserved.
//

import Foundation
import UIKit

/*
 Protocol: UIInfiniteScrollViewDataSource
 
 Description:
 Used to delegate the creation of views for the scrollView
 */
protocol UIInfiniteScrollViewDataSource {
    /*
     scrollViewFillContainer(containerCoordinate: CGPoint, containerPosition: Int, containerSize: CGSize, completion: @escaping ([UIView]) -> Void) -> [UIView]
     
     Description:
     Creates a set of views for the cell in the scroll view. The cell will add the contents of the returned array as sub-views.
     
     Params:
     - containerCoordinate: the coordinate of the container to be filled (top left)
     - containerPosition: the left-to-right position of the container, relative to the other containers that have been created
     - containerSize: the size, in width and height, of the container to be filled
     - completion: a completion handler that will add asynchronous container contents once they are ready
     */
    func scrollViewFillContainer(containerCoordinate: CGPoint, containerPosition: Int, containerSize: CGSize, completion: @escaping ([UIView]) -> Void) -> [UIView]
}

