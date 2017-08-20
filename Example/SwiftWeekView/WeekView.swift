//
//  WeekView.swift
//  WeekView
//
//  Created by Evan Cooper on 2017-08-10.
//  Copyright © 2017 Evan Cooper. All rights reserved.
//

import Foundation
import UIKit
import SwiftDate

class WeekView: UIView {
    private var initDate: DateInRegion!
    private var visibleDays : Int!
    private var scrollView: UIInfiniteScrollView!
    private var viewCreator: UIInfiniteScrollView.ViewCreator!
    
    private var startHour: Int!
    private var endHour: Int!
    
    private var colorTheme: Theme!
    var font: UIFont!
    
    var headerHeight: CGFloat!
    
    func getScrollView() -> UIInfiniteScrollView { return self.scrollView }
    
    // Interface class meant to be subclassed for the generateEvents funtion
    class EventGenerator {
        /*
         generateEvents(date: DateInRegion) -> [WeekViewEvent]
         
         Description:
         creat a collection of WeekViewEvents for the given unique date. Must be overridden or it will fail
         
         Params:
         - date: tshe date for which to create WeekViewEvents
         
         Returns: a collection of WeekViewEvents for the given unique date
        */
        func generateEvents(date: DateInRegion) -> [WeekViewEvent] {
            fatalError("Error, did not override funciton \(#function)\n")
        }
    }
    
    // Custom implementation of the UIInfiniteScrollView.ViewCreator interface class
    private class VC: UIInfiniteScrollView.ViewCreator {
        var weekView: WeekView!
        var eventGenerator: EventGenerator!
        
        init(weekView: WeekView, eventGenerator: EventGenerator) {
            self.weekView = weekView
            self.eventGenerator = eventGenerator
        }
        
        override func createViewSet(viewCoordinate: CGPoint, viewPosition: Int, viewWidth: CGFloat, viewHeight: CGFloat) -> [UIView] {
            var result: [UIView] = []
            
            let viewDate: DateInRegion = weekView.initDate + viewPosition.days
            let header: UITextViewFixed = UITextViewFixed(frame: CGRect(x: viewCoordinate.x, y: 0, width: viewWidth, height: weekView.headerHeight))
            let view: UIView = UIView(frame: CGRect(x: viewCoordinate.x, y: header.frame.height, width: viewWidth, height: viewHeight - header.frame.height))
            if (viewDate.isInWeekend) {
                let color : UIColor = weekView.colorTheme.weekendColor
                view.backgroundColor = UIColor(red: color.components.red, green: color.components.green, blue: color.components.blue, alpha: 0.5)
            }
            
            header.text = String("\(viewDate.weekdayShortName) \(viewDate.day)".uppercased())
            header.centerTextVertically()
            header.textAlignment = .center
            header.centerTextVertically()
            header.font = weekView.font
            header.isEditable = false
            header.isSelectable = false
            header.backgroundColor = .clear
            
            var eventViews: [UIView] = []
            let events = self.eventGenerator.generateEvents(date: viewDate)
            for event in events {
                let eventStartHour = event.getStart().hour
                let eventStartMinute = event.getStart().minute
                let eventEndHour = event.getEnd().hour
                let eventEndMinute = event.getEnd().minute
                
                let hourHeight = (weekView.frame.height - (weekView.headerHeight * 2)) / CGFloat(weekView.endHour - weekView.startHour)
                let minuteHeight = hourHeight / 60
                
                var eventX = viewCoordinate.x
                let eventY = header.frame.height + (hourHeight * CGFloat(eventStartHour - self.weekView.startHour)) + (minuteHeight * CGFloat(eventStartMinute))
                var eventWidth = viewWidth
                let eventHeight = (hourHeight * CGFloat(eventEndHour - eventStartHour)) + (minuteHeight * CGFloat(eventEndMinute - eventStartMinute))
                
                if (events.count > 1) {
                    var overlappingViews: [WeekViewEvent] = []
                    for e in events {
                        if (event != e && event.overlaps(withEvent: e)) {
                            overlappingViews.append(e)
                        } else if (event == e) {
                            overlappingViews.append(event)
                        }
                    }
                    
                    if (overlappingViews.count >= 2) {
                        eventWidth = viewWidth / CGFloat(overlappingViews.count)
                        eventX = viewCoordinate.x + (CGFloat(overlappingViews.index(of: event)!) * eventWidth)
                    }
                }
                
                let eventView: UIView = UIView(frame: CGRect(x: eventX, y: eventY, width: eventWidth, height: eventHeight))
                eventView.backgroundColor = UIColor(red: event.getColor().components.red, green: event.getColor().components.green, blue: event.getColor().components.blue, alpha: 0.65)
                
                let eventLeftBorder: UIView = UIView(frame: CGRect(x: eventX, y: eventY, width: 3, height: eventHeight))
                eventLeftBorder.backgroundColor = event.getColor()
                
                let eventText: UITextView = UITextView(frame: eventView.frame)
                eventText.text = "\(event.getTitle())\n\(event.getStart().string(format: .custom("HH:mm"))) - \(event.getEnd().string(format: .custom("HH:mm")))"
                eventText.backgroundColor = .clear
                eventText.font = weekView.font
                eventText.textColor = weekView.colorTheme.eventTextColor
                eventText.isEditable = false
                eventText.isSelectable = false
                
                eventViews.append(eventView)
                eventViews.append(eventLeftBorder)
                eventViews.append(eventText)
            }
            
            result.append(header)
            result.append(view)
            for eventView in eventViews {
                result.append(eventView)
            }

            return result
        }
    }
    
    init(frame: CGRect, eventGenerator: EventGenerator, visibleDays: Int) {
        super.init(frame: frame)
        self.commonInit(frame: frame, eventGenerator: eventGenerator, visibleDays: visibleDays)
    }
    
    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        self.commonInit(frame: frame, eventGenerator: EventGenerator(), visibleDays: 5)
    }
    
    /*
     commonInit(frame: CGRect, eventGenerator: EventGenerator, visibleDays: Int)
     
     Description:
     Function used by all the other init functions, to centrialized initialization
     
     Params:
     - frame: the frame of the calendar view
     - eventGenerator: an instance of an EventGenerator that overrides the generateEvents function
     - visibleDays: an instance of a ViewCreator subclass that overrides the createViewSet method
     */
    func commonInit(frame: CGRect, eventGenerator: EventGenerator, visibleDays: Int, startHour: Int = 9, endHour: Int = 17) {
        self.colorTheme = LightTheme()
        self.font = UIFont.init(descriptor: UIFontDescriptor(), size: 10)
        
        self.headerHeight = 30
        self.initDate = DateInRegion()
        self.initDate = self.initDate - visibleDays.days
        self.visibleDays = visibleDays
        self.startHour = startHour
        self.endHour = endHour
        
        let monthAndYearText: UITextView = UITextView(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: self.headerHeight))
        monthAndYearText.text = "\(self.initDate.monthName) \(self.initDate.year)"
        monthAndYearText.isEditable = false
        monthAndYearText.isSelectable = false
        
        let timeView: UIView = UIView(frame: CGRect(x: frame.origin.x, y: frame.origin.y + monthAndYearText.frame.height, width: 40, height: frame.height - monthAndYearText.frame.height))
        let hourHeight: CGFloat = (timeView.frame.height - self.headerHeight) / CGFloat(self.endHour - self.startHour)
        var hourLines: [CAShapeLayer] = []
        for hour in self.startHour...self.endHour {
            let hourText: UITextViewFixed = UITextViewFixed(frame: CGRect(x: timeView.frame.origin.x, y: hourHeight * CGFloat(hour - startHour) + self.headerHeight - self.font.pointSize / 2, width: timeView.frame.width, height: hourHeight))
            hourText.text = "\(hour):00"
            hourText.textAlignment = .right
            hourText.backgroundColor = .clear
            hourText.font = self.font
            hourText.textColor = self.colorTheme.hourTextColor
            hourText.pushTextToTop()
            
            let linePath = UIBezierPath(rect: CGRect(x: timeView.frame.width, y: hourHeight * CGFloat(hour - startHour) + self.headerHeight, width: frame.width, height: 0.1))
            let layer = CAShapeLayer()
            layer.path = linePath.cgPath
            layer.strokeColor = self.colorTheme.hourLineColor.cgColor
            layer.fillColor = self.colorTheme.hourLineColor.cgColor
            hourLines.append(layer)
            
            timeView.addSubview(hourText)
        }

        self.viewCreator = VC(weekView: self, eventGenerator: eventGenerator)
        self.scrollView = UIInfiniteScrollView(frame: CGRect(x: timeView.frame.width, y: timeView.frame.origin.y, width: frame.width - timeView.frame.width, height: frame.height), viewsInPageCount: visibleDays, spacerSize: 2, viewCreator: self.viewCreator, direction: .horizontal)
        self.scrollView.backgroundColor = .clear
        
        self.addSubview(monthAndYearText)
        self.addSubview(timeView)
        self.addSubview(self.scrollView)
        
        for line in hourLines {
            timeView.layer.addSublayer(line)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        tap.numberOfTapsRequired = 2
        self.addGestureRecognizer(tap)
    }
    
    func doubleTap() {
//        self.scrollView.jumpToView(viewPosition: nil, viewCoordinate: CGPoint(x: 0, y: 0))
    }
}
