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

/*
 Protocol: WeekViewDataSource
 
 Description: Used to delegate the creation of events for the WeekView
 */
protocol WeekViewDataSource {
    /*
     weekViewGenerateEvents(_ weekView: WeekView, date: DateInRegion) -> [WeekViewEvent]
     
     Description:
     Generate and return a set of events for a specific day. Events can be returned synchronously or asynchronously
     
     Params:
     - weekView: the WeekView that is calling this function
     - date: the date for which to create events for
     */
    func weekViewGenerateEvents(_ weekView: WeekView, date: DateInRegion) -> [WeekViewEvent]
}

/*
 Protocol WeekViewDelegate
 
 Description:
 Used to delegate events and actions that occur.
 */
@objc protocol WeekViewDelegate {
    /*
     weekViewDidClickOnEvent(_ weekView: WeekView, event: WeekViewEvent)
     
     Description:
     Fires when a calendar event is touched on
     
     Params:
     - weekView: the WeekView that is calling this function
     - event: the event that was clicked
     */
    @objc func weekViewDidClickOnEvent(_ weekView: WeekView, event: WeekViewEvent)
}

/*
 Protocol: WeekViewStyler
 
 Description:
 Used to delegate the creation of different view types within the WeekView.
 */
@objc protocol WeekViewStyler {
    /*
     weekViewStylerEventView(_ weekView: WeekView, eventContainer: CGRect, event: WeekViewEvent) -> WeekViewEventView
     
     Description:
     Create the view for an event
     
     Params:
     - weekView: the WeekView that the view will be added to
     - eventContainer: the container of which the eventView needs to conform to
     - event: the event it's self
     */
    @objc optional func weekViewStylerEventView(_ weekView: WeekView, eventContainer: CGRect, event: WeekViewEvent) -> WeekViewEventView
    
    /*
     weekViewStylerHeaderView(_ weekView: WeekView, containerPosition: Int, container: CGRect) -> UIView
     
     Description:
     Create the header view for the day in the calendar. This would normally contain information about the date
     
     Params:
     - weekView: the WeekView that the header will be added to
     - containerPosition: the left-to-right position of the container that the header will be added to, relative to the other containers that have been created
     - container: the container of which the header needs to conform to
     */
    @objc optional func weekViewStylerHeaderView(_ weekView: WeekView, containerPosition: Int, container: CGRect) -> UIView
    
    /*
     weekViewStylerDayView(_ weekView: WeekView, containerPosition: Int, containerCoordinate: CGPoint, containerSize: CGSize, header: UIView) -> UIView
     
     Description:
     Create the main view that will contain the events. This normally appears directly under the header created in weekViewUIEventView (above)
     
     Params:
     - weekView: the WeekView that the header will be added to
     - containerPosition: the left-to-right position of the container that the view will be added to, relative to the other containers that have been created
     - container: the container of which the timeView needs to conform to
     - header: the header of the weekView. The time view should start under the header
     */
    @objc optional func weekViewStylerDayView(_ weekView: WeekView, containerPosition: Int, container: CGRect, header: UIView) -> UIView
}

@IBDesignable class WeekView: UIView, WeekViewDataSource, WeekViewDelegate, WeekViewStyler, UIInfiniteScrollViewDataSource {
    // Main UI elements
    private var monthAndYearText: UITextView!
    private var timeView: UIView!
    private var scrollView: UIInfiniteScrollView!
    
    // Primary properties
    private var events: [WeekViewEvent]!
    private var initDate: DateInRegion!
    private var visibleDays : Int!
    private var startHour: Int!
    private var endHour: Int!
    private var headerHeight: CGFloat!
    private var respondsToInteraction: Bool!
    
    // Secondary properties
    private var nowLineEnabled: Bool!
    
    // Style properties
    private var colorTheme: Theme!
    private var font: UIFont!
    private var nowLineColor: UIColor!
    private var nowLine: CAShapeLayer!
    private var nowCircle: UIView!
    
    public var dataSource: WeekViewDataSource! {
        didSet {
            if (oldValue != nil) {
                self.events = []
                self.reloadScrollView()
                self.reloadTimeView()
            }
        }
    }
    
    public var delegate: WeekViewDelegate!
    
    public var styler: WeekViewStyler! {
        didSet {
            if (oldValue != nil) {
                self.reloadScrollView()
                self.reloadTimeView()
            }
        }
    }
    
    // getters
    func getInitDate() -> DateInRegion { return self.initDate }
    func getFont() -> UIFont { return self.font }
    func getColorTheme() -> Theme { return self.colorTheme }
    
    /*
     init(frame: CGRect, visibleDays: Int, date: DateInRegion = DateInRegion(), startHour: Int = 9, endHour: Int = 17, colorTheme: Theme = .light, nowLineEnabled: Bool = true, nowLineColor: UIColor = .red)
     
     Description:
     Function used by all the other init functions, to centrialized initialization
     
     Params:
     - frame: the frame of the calendar view
     - visibleDays: an instance of a ViewCreator subclass that overrides the createViewSet method
     - date: (Optional) the day `WeekView` will initially load. Defaults to the current day
     - startHour: (Optional) the earliest hour that will be displayed. Defaults to 09:00
     - endHour: (Optional) the latest hour that will be displayed. Defalts to 17:00
     - nowLineEnabled: (Optional) specify if the "now line" will be visible. Defaults to true
     - nowLineColor: (Optional) the color of the "now line". Defaults to red
     */
    init(frame: CGRect, visibleDays: Int, date: DateInRegion = DateInRegion(), startHour: Int = 9, endHour: Int = 17, colorTheme: Theme = .light, nowLineEnabled: Bool = true, nowLineColor: UIColor = .red, respondsToInteraction: Bool = false) {
        super.init(frame: frame)
        self.commonInit(frame: frame, visibleDays: visibleDays, date: date, startHour: startHour, endHour: endHour, colorTheme: colorTheme, nowLineEnabled: nowLineEnabled, nowLineColor: nowLineColor, respondsToInteraction: respondsToInteraction)
    }
    
    /*
     init(frame: CGRect)
     
     NOTE: Only to be used internally for storyboard initialization
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit(frame: frame, visibleDays: 5, date: DateInRegion(), startHour: 9, endHour: 17, colorTheme: .light, nowLineEnabled: true, nowLineColor: .red, respondsToInteraction: false)
    }
    
    /*
     init?(coder aDecoder: NSCoder)
     
     For storyboard initialization
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit(frame: frame, visibleDays: 5, date: DateInRegion(), startHour: 9, endHour: 17, colorTheme: .light, nowLineEnabled: true, nowLineColor: .red, respondsToInteraction: false)
    }
    
    /*
     prepareForInterfaceBuilder()
     
     Description:
     Called when a designable object is created in Interface Builder
     
     From: https://developer.apple.com/documentation/objectivec/nsobject/1402908-prepareforinterfacebuilder
     */
    override func prepareForInterfaceBuilder() {
        self.commonInit(frame: frame, visibleDays: 5, date: DateInRegion(), startHour: 9, endHour: 17, colorTheme: .light, nowLineEnabled: true, nowLineColor: .red, respondsToInteraction: false)
    }
    
    private func framesMatch(frame1: CGRect, frame2: CGRect) -> Bool {
        return frame1.origin.x.isEqual(to: frame2.origin.x) && frame1.origin.y.isEqual(to: frame2.origin.y) && frame1.size.width.isEqual(to: frame2.size.width) && frame1.size.height.isEqual(to: frame2.size.height)
    }
    
    /*
     commonInit(frame: CGRect, visibleDays: Int, date: DateInRegion, startHour: Int, endHour: Int, colorTheme: Theme, nowLineEnabled: Bool, nowLineColor: UIColor)
     
     Description:
     Function used by all the other init functions, to centrialize initialization
     
     Params:
     - frame: the frame of the calendar view
     - visibleDays: an instance of a ViewCreator subclass that overrides the createViewSet method
     - date: the day `WeekView` will initially load
     - startHour: the earliest hour that will be displayed
     - endHour: the latest hour that will be displayed
     - nowLineEnabled: specify if the "now line" will be visible
     - nowLineColor: the color of the "now line"
     */
    private func commonInit(frame: CGRect, visibleDays: Int, date: DateInRegion, startHour: Int, endHour: Int, colorTheme: Theme, nowLineEnabled: Bool, nowLineColor: UIColor, respondsToInteraction: Bool) {
        self.dataSource = self
        self.delegate = self
        self.styler = self
        self.events = []
        self.colorTheme = colorTheme
        self.font = UIFont.init(descriptor: UIFontDescriptor(), size: 10)
        self.headerHeight = 30
        self.initDate = date - visibleDays.days
        self.visibleDays = visibleDays
        self.startHour = startHour
        self.endHour = endHour
        self.respondsToInteraction = respondsToInteraction
        
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
        self.scrollView.weekView = self
        
        let hourHeight: CGFloat = (timeView.frame.height - self.headerHeight) / CGFloat(self.endHour - self.startHour)
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
            
            self.timeView.addSubview(hourText)
        }
        
        self.addSubview(self.monthAndYearText)
        self.addSubview(self.scrollView)
        self.addSubview(self.timeView)
        
        self.addHourInfo()
        
        self.nowLineEnabled = nowLineEnabled
        self.nowLineColor = nowLineColor
        self.nowLine = CAShapeLayer()
        self.nowCircle = UIView()
        
        DispatchQueue.global(qos: .userInteractive).async {
            while true {
                if (self.nowLineEnabled) {
                    DispatchQueue.main.async {
                        self.refreshNowLine(xPos: self.timeView.frame.width, yPos: self.timeView.frame.origin.y + self.headerHeight, hourHeight: hourHeight)
                    }
                    sleep(1)
                } else {
                    self.nowLine.removeFromSuperlayer()
                    self.nowCircle.removeFromSuperview()
                    break
                }
            }
        }
        
        self.scrollView.snap()
    }
    
    /*
     scrollViewFillContainer(containerCoordinate: CGPoint, containerPosition: Int, containerSize: CGSize, completion: @escaping ([UIView]) -> Void) -> [UIView]
     
     Description:
     Implementation of UIInfiniteScrollViewDataSource protocol.
     */
    internal func scrollViewFillContainer(containerCoordinate: CGPoint, containerPosition: Int, containerSize: CGSize, completion: @escaping ([UIView]) -> Void) -> [UIView] {
        let viewDate: DateInRegion = self.initDate + containerPosition.days
        if (viewDate.day == 8 || viewDate.day == 23) {
            self.monthAndYearText.text = "\(viewDate.monthName) \(viewDate.year)"
        }
        
        let container: CGRect = CGRect(origin: containerCoordinate, size: containerSize)
        
        let styler = self.styler as AnyObject
        let header: UIView = (styler.responds(to: #selector(weekViewStylerHeaderView(_:containerPosition:container:)))) ? self.styler.weekViewStylerHeaderView!(self, containerPosition: containerPosition, container: container) : self.weekViewStylerHeaderView(self, containerPosition: containerPosition, container: container)
        self.headerHeight = header.frame.height
        
        let view: UIView = (styler.responds(to: #selector(weekViewStylerDayView(_:containerPosition:container:header:)))) ? self.styler.weekViewStylerDayView!(self, containerPosition: containerPosition, container: container, header: header) : self.weekViewStylerDayView(self, containerPosition: containerPosition, container: container, header: header)
        
        let linePath = UIBezierPath(rect: CGRect(x: containerCoordinate.x - (self.scrollView.getSpacerSize() / 2), y: containerCoordinate.y + self.headerHeight/2, width: 0.1, height: containerSize.height - self.headerHeight/2))
        let layer: CAShapeLayer = CAShapeLayer()
        layer.path = linePath.cgPath
        layer.strokeColor = self.colorTheme.hourLineColor.cgColor
        layer.fillColor = self.colorTheme.hourLineColor.cgColor
        self.scrollView.layer.addSublayer(layer)
        
        DispatchQueue.global(qos: .background).async {
            let events = self.dataSource.weekViewGenerateEvents(self, date: viewDate)
            DispatchQueue.main.async {
                var eventViews: [UIView] = []
                for event in events {
                    let hourHeight = (self.frame.height - self.monthAndYearText.frame.height - header.frame.height) / CGFloat(self.endHour - self.startHour)
                    let minuteHeight = hourHeight / 60
                    let eventStartHour = event.getStart().hour
                    let eventStartMinute = event.getStart().minute
                    let eventEndHour = event.getEnd().hour
                    let eventEndMinute = event.getEnd().minute
                    var eventX = containerCoordinate.x
                    let eventY = self.headerHeight + (hourHeight * CGFloat(eventStartHour - self.startHour)) + (minuteHeight * CGFloat(eventStartMinute))
                    var eventWidth = containerSize.width
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
                            eventWidth = containerSize.width / CGFloat(overlappingViews.count)
                            eventX = containerCoordinate.x + (CGFloat(overlappingViews.index(of: event)!) * eventWidth)
                        }
                    }
                    
                    let eventContainer: CGRect = CGRect(x: eventX, y: eventY, width: eventWidth, height: eventHeight)
                    guard let eventView = self.styler.weekViewStylerEventView?(self, eventContainer: eventContainer, event: event) else {
                        let eventView = self.weekViewStylerEventView(self, eventContainer: eventContainer, event: event)
                        eventViews.append(eventView)
                        break
                    }
                    
                    eventView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didClickOnEvent(_:))))
                    eventViews.append(eventView)
                    self.events.append(event)
                }
                
                if (eventViews.count == 0) {
                    let ghostView: UIView = UIView(frame: CGRect(x: containerCoordinate.x, y: 0, width: containerSize.width, height: 1))
                    ghostView.backgroundColor = .clear
                    eventViews.append(ghostView)
                }
                
                completion(eventViews)
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
        
        if (now.hour < self.startHour || now.hour > self.endHour) {
            self.nowLine.removeFromSuperlayer()
            self.nowCircle.removeFromSuperview()
        }
    }
    
    /*
     addHourInfo()
     
     Description:
     Add the hour text and horizontal line for each hour that's visible in the scrollView
     */
    private func addHourInfo() {
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
        
        for line in hourLines {
            self.scrollView.layer.addSublayer(line)
        }
    }
    
    /*
     reloadScrollView()
     
     Description:
     Internal utility function to refresh the contents of the scrollView
     */
    private func reloadScrollView() {
        self.scrollView.removeFromSuperview()
        self.scrollView = UIInfiniteScrollView(frame: self.scrollView.frame, viewsInPageCount: self.visibleDays, spacerSize: 2, scrollDirection: .horizontal)
        self.scrollView.dataSource = self
        self.scrollView.weekView = self
        self.scrollView.backgroundColor = self.colorTheme.baseColor
        self.addSubview(self.scrollView)
        self.addHourInfo()
    }
    
    /*
     reloadTimeView()
     
     Description:
     Internal utility function to refresh the contents of the timeView
     */
    private func reloadTimeView() {
        self.timeView.removeFromSuperview()
        self.timeView = UIView(frame: CGRect(x: self.frame.origin.x, y: self.frame.origin.y + self.monthAndYearText.frame.height, width: 40, height: self.frame.height - self.monthAndYearText.frame.height))
        self.timeView.backgroundColor = self.colorTheme.baseColor
        let hourHeight: CGFloat = (timeView.frame.height - self.headerHeight) / CGFloat(self.endHour - self.startHour)
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
            
            self.timeView.addSubview(hourText)
        }
        self.addSubview(self.timeView)
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
    
    /*
     weekViewGenerateEvents(_ weekView: WeekView, date: DateInRegion) -> [WeekViewEvent]
     
     Description:
     Default implementation of the WeekViewDataSource protocol
     */
    internal func weekViewGenerateEvents(_ weekView: WeekView, date: DateInRegion) -> [WeekViewEvent] {
        let start: DateInRegion = date.atTime(hour: 12, minute: 0, second: 0)!
        let end: DateInRegion = date.atTime(hour: 13, minute: 30, second: 0)!
        let event: WeekViewEvent = WeekViewEvent(title: "Lunch " + String(date.day), start: start, end: end)
        return [event]
    }
    
    func weekViewDidClickOnEvent(_ weekView: WeekView, event: WeekViewEvent) {
        print(#function)
        print(event)
    }
    
    /*
     weekViewStylerEventView(_ weekView: WeekView, eventContainer: CGRect, event: WeekViewEvent) -> UIView
     
     Description:
     Default implementation of the WeekViewStyler protocol
     */
    internal func weekViewStylerEventView(_ weekView: WeekView, eventContainer: CGRect, event: WeekViewEvent) -> WeekViewEventView {
        let eventView: WeekViewEventView = WeekViewEventView(frame: eventContainer)
        eventView.backgroundColor = UIColor(red: event.getColor().components.red, green: event.getColor().components.green, blue: event.getColor().components.blue, alpha: 0.6)
        
        let eventLeftBorder: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: eventView.frame.height))
        eventLeftBorder.backgroundColor = event.getColor()
        
        let eventText: UITextView = UITextView(frame: CGRect(x: 3, y: 0, width: eventView.frame.width - 3, height: eventView.frame.height))
        eventText.text = event.description
        eventText.backgroundColor = .clear
        eventText.font = weekView.font
        eventText.textColor = weekView.colorTheme.eventTextColor
        eventText.isEditable = false
        eventText.isSelectable = false
        
        eventView.addSubview(eventLeftBorder)
        eventView.addSubview(eventText)
        eventView.eventID = event.getID()
        return eventView
    }
    
    /*
     weekViewStylerHeaderView(_ weekView: WeekView, containerPosition: Int, container: CGRect) -> UIView
     
     Description:
     Default implementation of the WeekViewStyler Protocol
     */
    internal func weekViewStylerHeaderView(_ weekView: WeekView, containerPosition: Int, container: CGRect) -> UIView {
        let viewDate: DateInRegion = self.initDate + containerPosition.days
        let header: UITextViewFixed = UITextViewFixed(frame: CGRect(x: container.origin.x, y: 0, width: container.size.width, height: self.headerHeight))
        
        header.text = String("\(viewDate.weekdayShortName) \(viewDate.day)".uppercased())
        header.textAlignment = .center
        header.centerTextVertically()
        header.font = self.font
        header.textColor = self.colorTheme.hourTextColor
        header.isEditable = false
        header.isSelectable = false
        header.backgroundColor = .clear
        
        return header
    }
    
    /*
     weekViewStylerDayView(_ weekView: WeekView, containerPosition: Int, container: CGRect, header: UIView) -> UIView
     
     Description:
     Default implementation of the WeekViewStyler Protocol
     */
    internal func weekViewStylerDayView(_ weekView: WeekView, containerPosition: Int, container: CGRect, header: UIView) -> UIView {
        let viewDate: DateInRegion = self.initDate + containerPosition.days
        let view: UIView = UIView(frame: CGRect(x: container.origin.x, y: header.frame.height, width: container.size.width, height: container.size.height - header.frame.height))
        if (viewDate.isInWeekend) {
            view.backgroundColor = UIColor(red: self.colorTheme.weekendColor.components.red, green: self.colorTheme.weekendColor.components.green, blue: self.colorTheme.weekendColor.components.blue, alpha: 0.5)
        }
        
        return view
    }
    
    @objc func didClickOnEvent(_ touch: UITapGestureRecognizer) {
        if (self.respondsToInteraction) {
            guard let weekViewEventView = touch.view as? WeekViewEventView else {
                return
            }
            
            for event in self.events {
                if (event.getID() == weekViewEventView.eventID!) {
                    self.delegate.weekViewDidClickOnEvent(self, event: event)
                    return
                }
            }
        }
    }
}
