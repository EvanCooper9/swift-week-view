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

protocol WeekViewDataSource {
    func generateEvents(date: DateInRegion, completion: (([WeekViewEvent]) -> Void)?) -> [WeekViewEvent]
}

@IBDesignable class WeekView: UIView, WeekViewDataSource, UIInfiniteScrollViewDataSource {
    private var initDate: DateInRegion!
    private var visibleDays : Int! = 5
    private var timeView: UIView!
    private var scrollView: UIInfiniteScrollView!
    
    private var startHour: Int! = 9
    private var endHour: Int! = 17
    private var colorTheme: Theme!
    private var font: UIFont!
    private var headerHeight: CGFloat!
    private var monthAndYearText: UITextView!
    
    private var nowLineEnabled: Bool!
    private var nowLineColor: UIColor!
    private var nowLine: CAShapeLayer!
    private var nowCircle: UIView!
    
    public var dataSource: WeekViewDataSource! {
        didSet {
            if (oldValue != nil) {
                self.scrollView.reloadView()
            }
        }
    }
    
    init(frame: CGRect, visibleDays: Int, date: DateInRegion = DateInRegion(), startHour: Int = 9, endHour: Int = 17, colorTheme: Theme? = LightTheme(), nowLineEnabled: Bool? = true) {
        super.init(frame: frame)
        self.commonInit(
            frame: frame,
            visibleDays: visibleDays,
            date: date,
            startHour: startHour,
            endHour: endHour,
            colorTheme: colorTheme,
            nowLineEnabled: nowLineEnabled
        )
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit(
            frame: frame,
            visibleDays: 5,
            date: DateInRegion(),
            startHour: 9,
            endHour: 17,
            colorTheme: LightTheme(),
            nowLineEnabled: true
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit(
            frame: self.bounds,
            visibleDays: 5,
            date: DateInRegion(),
            startHour: 9,
            endHour: 17,
            colorTheme: LightTheme(),
            nowLineEnabled: true
        )
    }
    
    override func prepareForInterfaceBuilder() {
        self.commonInit(
            frame: self.bounds,
            visibleDays: 5,
            date: DateInRegion(),
            startHour: 9,
            endHour: 17,
            colorTheme: LightTheme(),
            nowLineEnabled: true
        )
    }
    
    /*
     commonInit(frame: CGRect, eventGenerator: EventGenerator, visibleDays: Int)
     
     Description:
     Function used by all the other init functions, to centrialized initialization
     
     Params:
     - frame: the frame of the calendar view
     - visibleDays: an instance of a ViewCreator subclass that overrides the createViewSet method
     - date: (Optional) the day `WeekView` will initially load. Defaults to the current day.
     - startHour: (Optional) the earliest hour that will be displayed. Defaults to 09:00.
     - endHour: (Optional) the latest hour that will be displayed. Defalts to 17:00.
     */
    private func commonInit(frame: CGRect, visibleDays: Int, date: DateInRegion = DateInRegion(), startHour: Int = 9, endHour: Int = 17, colorTheme: Theme? = LightTheme(), nowLineEnabled: Bool? = true, nowLineColor: UIColor? = .red) {
        self.dataSource = self
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
        
        self.timeView = UIView(frame: CGRect(x: frame.origin.x, y: frame.origin.y + self.monthAndYearText.frame.height, width: 40, height: frame.height - self.monthAndYearText.frame.height))
        self.timeView.backgroundColor = self.colorTheme.baseColor
        
        self.scrollView = UIInfiniteScrollView(frame: CGRect(x: timeView.frame.width, y: timeView.frame.origin.y, width: frame.width - timeView.frame.width, height: self.timeView.frame.height), viewsInPageCount: visibleDays, spacerSize: 2, scrollDirection: .horizontal)
        self.scrollView.dataSource = self
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
        
        self.addSubview(self.monthAndYearText)
        self.addSubview(self.scrollView)
        self.addSubview(self.timeView)
        
        for line in hourLines {
            scrollView.layer.addSublayer(line)
        }
        
        self.nowLineEnabled = nowLineEnabled
        self.nowLineColor = nowLineColor
        self.nowLine = CAShapeLayer()
        self.nowCircle = UIView()
        
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
        
        self.scrollView.snap()
    }
    
    internal func createViewSet(viewCoordinate: CGPoint, viewPosition: Int, viewWidth: CGFloat, viewHeight: CGFloat, views: [[UIView]], completion: @escaping ([UIView]) -> Void) -> [UIView] {
        let viewDate: DateInRegion = self.initDate + viewPosition.days
        if (viewDate.day == 8 || viewDate.day == 23) {
            self.monthAndYearText.text = "\(viewDate.monthName) \(viewDate.year)"
        }
        
        let header: UITextViewFixed = UITextViewFixed(frame: CGRect(x: viewCoordinate.x, y: 0, width: viewWidth, height: self.headerHeight))
        let view: UIView = UIView(frame: CGRect(x: viewCoordinate.x, y: header.frame.height, width: viewWidth, height: viewHeight - header.frame.height))
        
        if (viewDate.isInWeekend) {
            let color : UIColor = self.colorTheme.weekendColor
            view.backgroundColor = UIColor(red: color.components.red, green: color.components.green, blue: color.components.blue, alpha: 0.5)
        }
        
        header.text = String("\(viewDate.weekdayShortName) \(viewDate.day)".uppercased())
        header.textAlignment = .center
        header.centerTextVertically()
        header.font = self.font
        header.textColor = self.colorTheme.hourTextColor
        header.isEditable = false
        header.isSelectable = false
        header.backgroundColor = .clear
        
        DispatchQueue.global(qos: .background).async {
            let events = self.dataSource.generateEvents(date: viewDate, completion: nil)
            
            if (events.count == 0) {
                completion ([UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))])
            } else {
                DispatchQueue.main.async {
                    var eventViews: [UIView] = []
                    for event in events {
                        let hourHeight = (self.frame.height - (self.headerHeight * 2)) / CGFloat(self.endHour - self.startHour)
                        let minuteHeight = hourHeight / 60
                        let eventStartHour = event.getStart().hour
                        let eventStartMinute = event.getStart().minute
                        let eventEndHour = event.getEnd().hour
                        let eventEndMinute = event.getEnd().minute
                        var eventX = viewCoordinate.x
                        let eventY = header.frame.height + (hourHeight * CGFloat(eventStartHour - self.startHour)) + (minuteHeight * CGFloat(eventStartMinute))
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
                        eventText.font = self.font
                        eventText.textColor = self.colorTheme.eventTextColor
                        eventText.isEditable = false
                        eventText.isSelectable = false
                        
                        eventViews.append(contentsOf: [eventView, eventLeftBorder, eventText])
                    }
                    completion(eventViews)
                }
            }
        }
        
        return [header, view]
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
        
        if (yPos + (hourHeight * CGFloat(now.hour - startHour)) + ((hourHeight/60) * CGFloat(now.minute)) < self.timeView.frame.origin.y + self.headerHeight) {
            self.nowLine.removeFromSuperlayer()
            self.nowCircle.removeFromSuperview()
        }
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
        self.scrollView = UIInfiniteScrollView(frame: self.scrollView.frame, viewsInPageCount: self.visibleDays, spacerSize: 2, scrollDirection: .horizontal)
        self.scrollView.dataSource = self
        self.addSubview(self.scrollView)
    }
    
    internal func generateEvents(date: DateInRegion, completion: (([WeekViewEvent]) -> Void)?) -> [WeekViewEvent] {
        return []
    }
}
