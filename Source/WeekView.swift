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
    internal var initDate: DateInRegion!
    internal var visibleDays : Int!
    internal var timeView: UIView!
    internal var scrollView: UIInfiniteScrollView!
    internal var viewCreator: UIInfiniteScrollView.ViewCreator!
    internal var startHour: Int!
    internal var endHour: Int!
    internal var colorTheme: Theme!
    internal var font: UIFont!
    internal var headerHeight: CGFloat!
    internal var monthAndYearText: UITextView!
    internal var nowLineEnabled: Bool!
    internal var nowLine: CAShapeLayer!
    internal var nowCircle: UIView!
    internal var nowLineColor: UIColor!
    
    func getScrollView() -> UIInfiniteScrollView { return self.scrollView }
    
    // Interface class meant to be subclassed for the generateEvents funtion
    class WeekViewDataSource {
        /*
         generateEvents(date: DateInRegion) -> [WeekViewEvent]
         
         Description:
         creat a collection of WeekViewEvents for the given unique date. Must be overridden or it will fail
         
         Params:
         - date: the date for which to create WeekViewEvents
         - completion: a callback function for asynchronous calls within this function
         
         Returns: a collection of WeekViewEvents for the given unique date
        */
        func generateEvents(date: DateInRegion, completion: (([WeekViewEvent]) -> Void)?) -> [WeekViewEvent] {
            fatalError("Error, did not override funciton \(#function)\n")
        }
    }
    
    // Custom implementation of the UIInfiniteScrollView.ViewCreator interface class
    internal class VC: UIInfiniteScrollView.ViewCreator {
        private var weekView: WeekView!
        private var weekViewDelegate: WeekViewDataSource!
        
        init(weekView: WeekView, weekViewDelegate: WeekViewDataSource) {
            self.weekView = weekView
            self.weekViewDelegate = weekViewDelegate
        }
        
        override func createViewSet(viewCoordinate: CGPoint, viewPosition: Int, viewWidth: CGFloat, viewHeight: CGFloat, views: [[UIView]], completion: @escaping ([UIView], Int) -> Void) -> [UIView] {
            let viewDate: DateInRegion = weekView.initDate + viewPosition.days
            
            if (viewDate.day == 8 || viewDate.day == 23) {
                self.weekView.monthAndYearText.text = "\(viewDate.monthName) \(viewDate.year)"
            }
            
            let header: UITextViewFixed = UITextViewFixed(frame: CGRect(x: viewCoordinate.x, y: 0, width: viewWidth, height: weekView.headerHeight))
            let view: UIView = UIView(frame: CGRect(x: viewCoordinate.x, y: header.frame.height, width: viewWidth, height: viewHeight - header.frame.height))
            
            if (viewDate.isInWeekend) {
                let color : UIColor = weekView.colorTheme.weekendColor
                view.backgroundColor = UIColor(red: color.components.red, green: color.components.green, blue: color.components.blue, alpha: 0.5)
            }
            
            header.text = String("\(viewDate.weekdayShortName) \(viewDate.day)".uppercased())
            header.textAlignment = .center
            header.centerTextVertically()
            header.font = weekView.font
            header.textColor = weekView.colorTheme.hourTextColor
            header.isEditable = false
            header.isSelectable = false
            header.backgroundColor = .clear
            
            DispatchQueue.global(qos: .background).async {
                let events = self.weekViewDelegate.generateEvents(date: viewDate, completion: nil)
                DispatchQueue.main.async {
                    var eventViews: [UIView] = []
                    for event in events {
                        let hourHeight = (self.weekView.frame.height - (self.weekView.headerHeight * 2)) / CGFloat(self.weekView.endHour - self.weekView.startHour)
                        let minuteHeight = hourHeight / 60
                        let eventStartHour = event.getStart().hour
                        let eventStartMinute = event.getStart().minute
                        let eventEndHour = event.getEnd().hour
                        let eventEndMinute = event.getEnd().minute
                        var eventX = viewCoordinate.x
                        let eventY = header.frame.height + (hourHeight * CGFloat(eventStartHour - self.weekView.startHour)) + (minuteHeight * CGFloat(eventStartMinute))
                        var eventWidth = viewWidth
                        let eventHeight = (hourHeight * CGFloat(eventEndHour - eventStartHour)) + (minuteHeight * CGFloat(eventEndMinute - eventStartMinute))
                        
                        // For events that overlap
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
                        eventView.backgroundColor = UIColor(red: event.getColor().components.red, green: event.getColor().components.green, blue: event.getColor().components.blue, alpha: 0.6)
                        
                        let eventLeftBorder: UIView = UIView(frame: CGRect(x: eventX, y: eventY, width: 5, height: eventHeight))
                        eventLeftBorder.backgroundColor = event.getColor()
                        
                        let eventText: UITextView = UITextView(frame: CGRect(x: eventView.frame.origin.x + 3, y: eventView.frame.origin.y, width: eventView.frame.width, height: eventView.frame.height))
                        eventText.text = "\(event.getTitle())\n\(event.getStart().string(format: .custom("HH:mm"))) - \(event.getEnd().string(format: .custom("HH:mm")))"
                        eventText.backgroundColor = .clear
                        eventText.font = self.weekView.font
                        eventText.textColor = self.weekView.colorTheme.eventTextColor
                        eventText.isEditable = false
                        eventText.isSelectable = false
                        
                        eventViews.append(contentsOf: [eventView, eventLeftBorder, eventText])
                    }
                    completion(eventViews, viewPosition)
                }
            }
            
            return [header, view]
        }
    }
    
    init(frame: CGRect, dataSource: WeekViewDataSource, visibleDays: Int, date: DateInRegion = DateInRegion(), startHour: Int = 9, endHour: Int = 17, colorTheme: Theme? = LightTheme(), nowLineEnabled: Bool? = true) {
        super.init(frame: frame)
        self.commonInit(
            frame: frame,
            delegate: dataSource,
            visibleDays: visibleDays,
            date: date,
            startHour: startHour,
            endHour: endHour,
            colorTheme: colorTheme,
            nowLineEnabled: nowLineEnabled
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Storyboard initialization not suppoted.")
    }
    
    /*
     commonInit(frame: CGRect, eventGenerator: EventGenerator, visibleDays: Int)
     
     Description:
     Function used by all the other init functions, to centrialized initialization
     
     Params:
     - frame: the frame of the calendar view
     - eventGenerator: an instance of an EventGenerator that overrides the generateEvents function
     - visibleDays: an instance of a ViewCreator subclass that overrides the createViewSet method
     - date: (Optional) the day `WeekView` will initially load. Defaults to the current day.
     - startHour: (Optional) the earliest hour that will be displayed. Defaults to 09:00.
     - endHour: (Optional) the latest hour that will be displayed. Defalts to 17:00.
     */
    internal func commonInit(frame: CGRect, delegate: WeekViewDataSource, visibleDays: Int, date: DateInRegion = DateInRegion(), startHour: Int = 9, endHour: Int = 17, colorTheme: Theme? = LightTheme(), nowLineEnabled: Bool? = true, nowLineColor: UIColor? = .red) {
        self.colorTheme = colorTheme
        self.font = UIFont.init(descriptor: UIFontDescriptor(), size: 10)
        self.headerHeight = 30
        self.initDate = date - visibleDays.days
        self.visibleDays = visibleDays
        self.startHour = startHour
        self.endHour = endHour
        
        self.monthAndYearText = UITextView(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: self.headerHeight))
        monthAndYearText.text = "\(self.initDate.monthName) \(self.initDate.year)"
        monthAndYearText.textColor = self.colorTheme.hourTextColor
        monthAndYearText.backgroundColor = self.colorTheme.baseColor
        monthAndYearText.isEditable = false
        monthAndYearText.isSelectable = false
        
        self.timeView = UIView(frame: CGRect(x: frame.origin.x, y: frame.origin.y + monthAndYearText.frame.height, width: 40, height: frame.height - monthAndYearText.frame.height))
        self.timeView.backgroundColor = self.colorTheme.baseColor
        
        self.viewCreator = VC(weekView: self, weekViewDelegate: delegate)
        self.scrollView = UIInfiniteScrollView(frame: CGRect(x: timeView.frame.width, y: timeView.frame.origin.y, width: frame.width - timeView.frame.width, height: frame.height), viewsInPageCount: visibleDays, spacerSize: 2, viewCreator: self.viewCreator, direction: .horizontal)
        self.scrollView.backgroundColor = self.colorTheme.baseColor
        
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
            hourText.isEditable = false
            hourText.isSelectable = false
            
            let linePath = UIBezierPath(rect: CGRect(x: 0, y: hourHeight * CGFloat(hour - startHour) + self.headerHeight, width: scrollView.contentSize.width, height: 0.1))
            let layer = CAShapeLayer()
            layer.path = linePath.cgPath
            layer.strokeColor = self.colorTheme.hourLineColor.cgColor
            layer.fillColor = self.colorTheme.hourLineColor.cgColor
            hourLines.append(layer)
            
            self.timeView.addSubview(hourText)
        }
        
        self.addSubview(monthAndYearText)
        self.addSubview(self.scrollView)
        self.addSubview(timeView)
        
        for line in hourLines {
            scrollView.layer.addSublayer(line)
        }
        
        self.nowLineEnabled = nowLineEnabled
        self.nowLineColor = nowLineColor
        self.nowLine = CAShapeLayer()
        self.nowCircle = UIView()
        
        if (self.nowLineEnabled) {
            DispatchQueue.global(qos: .background).async {
                while true {
                    if (self.nowLineEnabled) {
                        DispatchQueue.main.async {
                            self.refreshNowLine(xPos: self.timeView.frame.width, yPos: self.timeView.frame.origin.y + self.headerHeight, hourHeight: hourHeight)
                        }
                        sleep(60)
                    } else {
                        self.nowLine.removeFromSuperlayer()
                        self.nowCircle.removeFromSuperview()
                        break
                    }
                }
            }
        }
        
        self.scrollView.snap()
    }
    
    /*
     refreshNowLine(xPos: CGFloat, yPos: CGFloat, hourHeight: CGFloat)
     
     Description:
     Will re-position the 'now' line, for internal use only.
    */
    private func refreshNowLine(xPos: CGFloat, yPos: CGFloat, hourHeight: CGFloat) {
        self.nowLine.removeFromSuperlayer()
        self.nowCircle.removeFromSuperview()
        
        let now: DateInRegion = DateInRegion()
        let linePath = UIBezierPath(rect: CGRect(x: xPos, y: yPos + (hourHeight * CGFloat(now.hour - startHour)) + ((hourHeight/60) * CGFloat(now.minute)), width: scrollView.contentSize.width, height: 0.1))
        self.nowLine.path = linePath.cgPath
        self.nowLine.strokeColor = self.nowLineColor.cgColor
        self.nowLine.fillColor = self.nowLineColor.cgColor
        self.layer.addSublayer(self.nowLine)
        
        self.nowCircle = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 6))
        self.nowCircle.center = CGPoint(x: xPos, y: yPos + (hourHeight * CGFloat(now.hour - startHour)) + ((hourHeight/60) * CGFloat(now.minute)))
        self.nowCircle.layer.cornerRadius = 3
        self.nowCircle.backgroundColor = self.nowLineColor
        self.nowCircle.clipsToBounds = true
        self.addSubview(self.nowCircle)
    }
    
    /*
     jumpToDay(date: DateInRegion)
     
     Description:
     A hacky way of jumping the view to a specific day. Re-initializing the view is costly but it works for now
     
     Params:
     - date: the date to jump the view to.
    */
    func jumpToDay(date: DateInRegion) {
        self.initDate = date - self.visibleDays.days
        self.scrollView.removeFromSuperview()
        self.scrollView = UIInfiniteScrollView(frame: self.scrollView.frame, viewsInPageCount: self.visibleDays, spacerSize: 2, viewCreator: self.scrollView.viewCreator, direction: self.scrollView.scrollDirection)
        self.addSubview(self.scrollView)
    }
}
