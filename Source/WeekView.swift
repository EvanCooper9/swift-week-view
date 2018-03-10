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
    
    // Secondary properties
    private var nowLineEnabled: Bool!
    
    // Style properties
    private var colorTheme: Theme!
    private var font: UIFont!
    private var nowLineColor: UIColor!
    private var nowLine: CAShapeLayer!
    private var nowCircle: UIView!
    
    public var dataSource: WeekViewDataSource! {
        willSet {
            self.events = []
            print("changing dataSource \(self.events)")
        }
        didSet {
            if (oldValue != nil) {
                self.reloadScrollView()
                self.reloadTimeView()
            }
        }
    }
    
    private lazy var gestureRecognizer: UIGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didClickOnEvent(_:)))
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
    
    // setter
    func setGesture(gestureRecognizer: UIGestureRecognizer) {
        gestureRecognizer.addTarget(self, action: #selector(didClickOnEvent(_:)))
        self.gestureRecognizer = gestureRecognizer
        self.events = []
        self.reloadScrollView()
        self.reloadTimeView()
    }
    
    func setGestureRecognizer<T: UIGestureRecognizer>(gestureRecognizerType: T) {
        self.gestureRecognizer = T(target: self, action: #selector(didClickOnEvent(_:)))
        print(T.self)
        self.events = []
        self.reloadScrollView()
        self.reloadTimeView()
    }
    
    /**
     Initialization function
     
     - Parameters:
        - frame: the frame of the calendar view
        - visibleDays: an instance of a ViewCreator subclass that overrides the createViewSet method
        - date: (Optional) the day `WeekView` will initially load. Defaults to the current day
        - startHour: (Optional) the earliest hour that will be displayed. Defaults to 09:00
        - endHour: (Optional) the latest hour that will be displayed. Defalts to 17:00
        - nowLineEnabled: (Optional) specify if the "now line" will be visible. Defaults to true
        - nowLineColor: (Optional) the color of the "now line". Defaults to red
     */
    init(frame: CGRect, visibleDays: Int, date: DateInRegion = DateInRegion(), startHour: Int = 9, endHour: Int = 17, colorTheme: Theme = .light, nowLineEnabled: Bool = true, nowLineColor: UIColor = .red) {
        super.init(frame: frame)
        self.commonInit(frame: frame, visibleDays: visibleDays, date: date, startHour: startHour, endHour: endHour, colorTheme: colorTheme, nowLineEnabled: nowLineEnabled, nowLineColor: nowLineColor)
    }
    
    /*
     init(frame: CGRect)
     
     NOTE: Only to be used internally for storyboard initialization
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit(frame: frame, visibleDays: 5, date: DateInRegion(), startHour: 9, endHour: 17, colorTheme: .light, nowLineEnabled: true, nowLineColor: .red)
    }
    
    /**
     For storyboard initialization
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit(frame: frame, visibleDays: 5, date: DateInRegion(), startHour: 9, endHour: 17, colorTheme: .light, nowLineEnabled: true, nowLineColor: .red)
    }
    
    /*
     prepareForInterfaceBuilder()
     
     Description:
     Called when a designable object is created in Interface Builder
     
     From: https://developer.apple.com/documentation/objectivec/nsobject/1402908-prepareforinterfacebuilder
     */
    override func prepareForInterfaceBuilder() {
        self.commonInit(frame: frame, visibleDays: 5, date: DateInRegion(), startHour: 9, endHour: 17, colorTheme: .light, nowLineEnabled: true, nowLineColor: .red)
    }
    
    private func framesMatch(frame1: CGRect, frame2: CGRect) -> Bool {
        return frame1.origin.x.isEqual(to: frame2.origin.x) && frame1.origin.y.isEqual(to: frame2.origin.y) && frame1.size.width.isEqual(to: frame2.size.width) && frame1.size.height.isEqual(to: frame2.size.height)
    }
    
    /**
     Initialization function used by all the other init functions, to centrialize initialization
     
     - Parameters:
        - frame: the frame of the calendar view
        - visibleDays: an instance of a ViewCreator subclass that overrides the createViewSet method
        - date: the day `WeekView` will initially load
        - startHour: the earliest hour that will be displayed
        - endHour: the latest hour that will be displayed
        - nowLineEnabled: specify if the "now line" will be visible
        - nowLineColor: the color of the "now line"
     */
    private func commonInit(frame: CGRect, visibleDays: Int, date: DateInRegion, startHour: Int, endHour: Int, colorTheme: Theme, nowLineEnabled: Bool, nowLineColor: UIColor) {
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
    
    /**
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
        let viewGestureRecognizer = UIGestureRecognizer(target: self, action: #selector(didClickTesting(_:)))
        view.addGestureRecognizer(viewGestureRecognizer)
        
        // adding the vertical line spacing between each day
        let linePath = UIBezierPath(rect: CGRect(x: containerCoordinate.x - (self.scrollView.getSpacerSize() / 2), y: containerCoordinate.y + self.headerHeight/2, width: 0.1, height: containerSize.height - self.headerHeight/2))
        let layer: CAShapeLayer = CAShapeLayer()
        layer.path = linePath.cgPath
        layer.strokeColor = self.colorTheme.hourLineColor.cgColor
        layer.fillColor = self.colorTheme.hourLineColor.cgColor
        self.scrollView.layer.addSublayer(layer)
        
        let events = self.dataSource.weekViewGenerateEvents(self, date: viewDate, eventCompletion: { (asyncEvents) in
            DispatchQueue.main.async {
                let eventViews = self.eventsToViews(events: asyncEvents, header: header, containerCoordinate: containerCoordinate, containerSize: containerSize)
                completion(eventViews)
            }
        })
        
        let eventViews = self.eventsToViews(events: events, header: header, containerCoordinate: containerCoordinate, containerSize: containerSize)
        DispatchQueue.main.async {
            completion(eventViews)
        }
        
        return [header, view]
    }
    
    private func eventsToViews(events: [WeekViewEvent], header: UIView, containerCoordinate: CGPoint, containerSize: CGSize) -> [UIView] {
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
            if (self.events.count > 1) {
                var overlappingViews: [WeekViewEvent] = []
                overlappingViews.append(event)
                for e in self.events {
                    if (event.getID() != e.getID() && event.overlaps(withEvent: e)) {
                        overlappingViews.append(e)
                    }
                }
                
                if (overlappingViews.count >= 2) {
                    eventWidth = containerSize.width / CGFloat(overlappingViews.count / 2)
                    eventX = containerCoordinate.x + (CGFloat(overlappingViews.index(of: event)!) * eventWidth)
                }
            }
            
            let eventContainer: CGRect = CGRect(x: eventX, y: eventY, width: eventWidth, height: eventHeight)
            guard let eventView = self.styler.weekViewStylerEventView?(self, eventContainer: eventContainer, event: event) else {
                let eventView = self.weekViewStylerEventView(self, eventContainer: eventContainer, event: event)
                eventViews.append(eventView)
                break
            }
            
            var eventViewGuesture = self.weekViewGestureForInteraction(self)
            let delegate = self.delegate as AnyObject
            if (delegate.responds(to: #selector(delegate.weekViewGestureForInteraction(_:)))) {
                eventViewGuesture = delegate.weekViewGestureForInteraction!(self)
                eventViewGuesture.addTarget(self, action: #selector(self.didClickOnEvent(_:)))
            }
            
            eventView.addGestureRecognizer(eventViewGuesture)
            eventView.eventID = event.getID()
            eventViews.append(eventView)
            self.events.append(event)
        }
        
        if (eventViews.count == 0) {
            let ghostView: UIView = UIView(frame: CGRect(x: containerCoordinate.x, y: 0, width: containerSize.width, height: 1))
            ghostView.backgroundColor = .clear
            eventViews.append(ghostView)
        }
        return eventViews
    }
    
    /**
     Will re-position the 'now' line.
     
     - Parameters:
        - xPos: the new x-coordinate of the line
        - yPos: the new y-coordinate of the line
        - hourHeight: the height of each hour in the timeView
     
     - Important:
     For internal use only.
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
    
    /**
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
     Utility function to refresh the contents of the scrollView
     
     - Important:
     For internal use only.
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
    
    /**
     Utility function to refresh the contents of the timeView
     
     - Important:
     For internal use only.
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
    
    /**
     Jump the view to a specific day
     
     - Parameters:
        - date: the date to jump the view to.
     
     - Important:
     This will re-initialize the entire scrollView within. Not an optimal solution.
     */
    func jumpToDay(date: DateInRegion) {
        self.initDate = date - self.visibleDays.days
        self.scrollView.removeFromSuperview()
        self.scrollView = UIInfiniteScrollView(frame: self.scrollView.frame, viewsInPageCount: self.visibleDays, spacerSize: 2, scrollDirection: .horizontal)
        self.scrollView.dataSource = self
        self.addSubview(self.scrollView)
    }
    
    /*
     Default implementation of the WeekViewDataSource protocol method.
     */
    internal func weekViewGenerateEvents(_ weekView: WeekView, date: DateInRegion, eventCompletion: @escaping ([WeekViewEvent]) -> Void) -> [WeekViewEvent] {
        let start: DateInRegion = date.atTime(hour: 12, minute: 0, second: 0)!
        let end: DateInRegion = date.atTime(hour: 13, minute: 30, second: 0)!
        let event: WeekViewEvent = WeekViewEvent(title: "Lunch " + String(date.day), start: start, end: end)
        return [event]
    }
    
    /*
     Default implemenation of the WeekViewDelegate protocol method.
     */
    func weekViewDidClickOnEvent(_ weekView: WeekView, event: WeekViewEvent, view: WeekViewEventView) {
        print(#function, "event:", event.getID())
    }
    
    /*
 
     */
    func weekViewDidClickOnFreeTime(_ weekView: WeekViewEvent, date: DateInRegion) {
        print(#function, "date:", date)
    }
    
    /*
     Default implementation of the WeekViewDelegate protocol method.
     */
    @objc func weekViewGestureForInteraction(_ weekView: WeekView) -> UIGestureRecognizer {
        return UIGestureRecognizer(target: self, action: #selector(didClickOnEvent(_:)))
    }
    
    /*
     Default implementation of the WeekViewStyler protocol method.
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
        return eventView
    }
    
    /*
     Default implementation of the WeekViewStyler protocol method.
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
     Default implementation of the WeekViewStyler protocol method.
     */
    internal func weekViewStylerDayView(_ weekView: WeekView, containerPosition: Int, container: CGRect, header: UIView) -> UIView {
        let viewDate: DateInRegion = self.initDate + containerPosition.days
        let view: UIView = UIView(frame: CGRect(x: container.origin.x, y: header.frame.height, width: container.size.width, height: container.size.height - header.frame.height))
        if (viewDate.isInWeekend) {
            view.backgroundColor = UIColor(red: self.colorTheme.weekendColor.components.red, green: self.colorTheme.weekendColor.components.green, blue: self.colorTheme.weekendColor.components.blue, alpha: 0.5)
        }
        
        return view
    }
    
    @objc func didClickTesting(_ gesture: UIGestureRecognizer) {
        print("something happened yay")
    }
    
    /**
     Fires when a view is interacted with within the WeekView. Fires the WeekViewDelegate protocol method if an event was interacted with.
     
     - Parameters:
        - gesture: the gesture that performed the interaction.
     */
    @objc func didClickOnEvent(_ gesture: UIGestureRecognizer) {
        print("some sort of click")
        guard let weekViewEventView = gesture.view as? WeekViewEventView else {
            print("empty click")
            return
        }
        
        for event in self.events {
            if (event.getID() == weekViewEventView.eventID!) {
                self.delegate.weekViewDidClickOnEvent(self, event: event, view: weekViewEventView)
                return
            }
        }
    }
}

