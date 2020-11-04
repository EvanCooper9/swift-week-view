import Foundation
import UIKit
import SwiftDate
import ECTimelineView

@IBDesignable
public final class ECWeekView: UIView {

    // MARK: - Private properties

    private lazy var timeView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = colorTheme.baseColor
        return view
    }()

    private lazy var timelineView: ECTimelineView<[ECWeekViewEvent], ECDayCell> = {
        let timelineView = ECTimelineView<[ECWeekViewEvent], ECDayCell>()
        timelineView.translatesAutoresizingMaskIntoConstraints = false
        timelineView.backgroundColor = .clear
        timelineView.scrollDirection = .horizontal
        timelineView.timelineDataSource = self
        return timelineView
    }()

    private lazy var nowLine: CAShapeLayer = {
        let now: DateInRegion = DateInRegion()
        let linePath = UIBezierPath(rect: CGRect(x: timeView.frame.width, y: timeView.frame.origin.y + (hourHeight * CGFloat(now.hour - startHour)) + ((hourHeight/60) * CGFloat(now.minute)), width: timelineView.bounds.width, height: 0.1))
        let nowLine = CAShapeLayer()
        nowLine.path = linePath.cgPath
        nowLine.strokeColor = nowLineColor.cgColor
        nowLine.fillColor = nowLineColor.cgColor
        return nowLine
    }()
    
    private var nowLinePath: CGPath {
        UIBezierPath(rect: CGRect(x: nowLineCenter.x, y: nowLineCenter.y, width: timelineView.contentSize.width, height: 0.1)).cgPath
    }
    
    private lazy var nowCircle: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 6))
        view.layer.cornerRadius = 3
        view.backgroundColor = nowLineColor
        view.clipsToBounds = true
        return view
    }()
    
    private var nowLineCenter: CGPoint {
        let now = DateInRegion()
        return CGPoint(x: timeView.frame.width, y: timeView.frame.origin.y + (hourHeight * CGFloat(now.hour - startHour)) + ((hourHeight/60) * CGFloat(now.minute)))
    }

    private var hourHeight: CGFloat {
        (frame.height - dateHeaderHeight) / CGFloat(endHour - startHour)
    }

    private var minuteHeight: CGFloat {
        hourHeight / 60
    }

    // MARK: - Public properties
    
    public weak var dataSource: ECWeekViewDataSource? {
        didSet { timelineView.timelineDataSource = self }
    }

    public weak var delegate: ECWeekViewDelegate? {
        didSet { timelineView.reloadData() }
    }

    public weak var styler: ECWeekViewStyler? {
        didSet { timelineView.reloadData() }
    }

    @IBInspectable public var visibleDays: Int = 5 {
        didSet { timelineView.visibleCellCount = visibleDays }
    }
    
    public var initDate: DateInRegion = DateInRegion()
    public var startHour: Int = 9
    public var endHour: Int = 17
    public var nowLineEnabled: Bool = true
    public var colorTheme: Theme = .light
    public var nowLineColor: UIColor = .red

    // MARK: - Lifecycle
    
    public init(visibleDays: Int, date: DateInRegion = DateInRegion()) {
        self.visibleDays = visibleDays
        super.init(frame: .zero)
        commonInit(frame: .zero, visibleDays: visibleDays, date: date)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(frame: frame, visibleDays: visibleDays, date: DateInRegion())
    }

    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonInit(frame: frame, visibleDays: visibleDays, date: DateInRegion())
    }

    // MARK: - Private Methods
    
    private func commonInit(frame: CGRect, visibleDays: Int, date: DateInRegion) {
        self.frame = frame
        self.visibleDays = visibleDays
        initDate = date - visibleDays.days
        styler = self

        addSubview(timeView)
        addSubview(timelineView)
        
        NSLayoutConstraint.activate([
            timeView.widthAnchor.constraint(equalToConstant: 40),
            timeView.topAnchor.constraint(equalTo: topAnchor),
            timeView.bottomAnchor.constraint(equalTo: bottomAnchor),
            timeView.leftAnchor.constraint(equalTo: leftAnchor),
            timeView.rightAnchor.constraint(equalTo: timelineView.leftAnchor),
            timelineView.rightAnchor.constraint(equalTo: rightAnchor),
            timelineView.topAnchor.constraint(equalTo: topAnchor),
            timelineView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        addHourInfo()
        insertNowLine()
    }

    private func insertNowLine() {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            while true {
                if (self.nowLineEnabled) {
                    DispatchQueue.main.async {
                        self.nowLine.removeFromSuperlayer()
                        self.nowCircle.removeFromSuperview()

                        let now = DateInRegion()
                        if (now.hour > self.startHour && now.hour < self.endHour) {
                            self.nowCircle.center = self.nowLineCenter
                            self.nowLine.path = self.nowLinePath
                            self.layer.addSublayer(self.nowLine)
                            self.addSubview(self.nowCircle)
                        }
                    }
                    sleep(15)
                } else {
                    self.nowLine.removeFromSuperlayer()
                    self.nowCircle.removeFromSuperview()
                    break
                }
            }
        }
    }
    
    private func addHourInfo() {
        for hour in startHour...endHour {
            let label = UILabel(frame: .zero)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "\(hour):00"
            label.textAlignment = .right
            label.backgroundColor = .clear
            label.font = styler?.font ?? UIFont.init(descriptor: UIFontDescriptor(), size: 12)
            label.textColor = colorTheme.hourTextColor
            
            let verticalOffset = dateHeaderHeight + hourHeight * CGFloat(hour - startHour)

            timeView.addSubview(label)
            NSLayoutConstraint.activate([
                label.leftAnchor.constraint(equalTo: timeView.leftAnchor),
                label.rightAnchor.constraint(equalTo: timeView.rightAnchor),
                label.topAnchor.constraint(equalTo: timeView.topAnchor, constant: verticalOffset - (font.pointSize / 2))
            ])

            let hourLayer = CAShapeLayer()
            hourLayer.strokeColor = colorTheme.hourLineColor.cgColor
            hourLayer.fillColor = colorTheme.hourLineColor.cgColor
            let linePath = UIBezierPath(rect: CGRect(x: timeView.bounds.maxX, y: verticalOffset, width: bounds.width - timeView.bounds.maxX, height: 0.1))
            hourLayer.path = linePath.cgPath
            layer.addSublayer(hourLayer)
        }
    }
}

// MARK: - Placing events graphically

extension ECWeekView {
    private func placeEvents(_ events: [ECWeekViewEvent], in cell: UICollectionViewCell) -> [ECWeekViewEvent: CGRect] {
        let threshold = 20

        var mutableEvents = events.sorted()
        var placedEvents = [ECWeekViewEvent]()
        var placedEventRects = [ECWeekViewEvent: CGRect]()

        while !mutableEvents.isEmpty {
            let eventsToPlace = mutableEvents.compactMap { event -> ECWeekViewEvent? in
                return (event.start > mutableEvents.first!.start + threshold.minutes) ? nil : event
            }

            var eventGroupRect = CGRect(x: 0, y: dateHeaderHeight, width: cell.bounds.width, height: cell.bounds.height - dateHeaderHeight)
            placedEvents.reversed().forEach { placedEvent in
                if let firstEventToPlace = eventsToPlace.first, let placedEventRect = placedEventRects[placedEvent], firstEventToPlace.overlaps(with: placedEvent) {
                    let groupRectHeight = cell.bounds.height - placedEventRect.minY
                    let overlapOffset: CGFloat = 5
                    eventGroupRect = CGRect(x: placedEventRect.minX + overlapOffset, y: placedEventRect.minY, width: placedEventRect.width - overlapOffset, height: groupRectHeight)
                }
            }

            for (index, event) in eventsToPlace.enumerated() {
                placedEventRects[event] = rect(for: event, in: eventGroupRect, overlapingEvents: eventsToPlace, widthIndex: index)
            }

            mutableEvents.removeFirst(eventsToPlace.count)
            placedEvents.append(contentsOf: eventsToPlace)
        }

        return placedEventRects
    }

    private func rect(for event: ECWeekViewEvent, in rect: CGRect, overlapingEvents: [ECWeekViewEvent], widthIndex: Int) -> CGRect {
        let eventStartHour =  event.start.hour
        let eventStartMinute = event.start.minute
        let eventEndHour = event.end.hour
        let eventEndMinute = event.end.minute
        let eventY = (hourHeight * CGFloat(eventStartHour - startHour)) + (minuteHeight * CGFloat(eventStartMinute)) + dateHeaderHeight
        let eventHeight = (hourHeight * CGFloat(eventEndHour - eventStartHour)) + (minuteHeight * CGFloat(eventEndMinute - eventStartMinute))

        let eventWidth = rect.width / CGFloat(overlapingEvents.count)
        let eventX: CGFloat = rect.minX + (eventWidth * CGFloat(widthIndex))

        let rectInset: CGFloat = 0.5
        return CGRect(x: eventX + rectInset, y: eventY + rectInset, width: eventWidth - (2 * rectInset), height: eventHeight - (2 * rectInset))
    }
}

// MARK: - Gesture recognizer selectors

extension ECWeekView {
    @objc private func handle(tap: UITapGestureRecognizer) {
        if let tap = tap as? ECWeekViewEventTapGestureRecognizer {
            delegate?.weekViewDidClickOnEvent(self, event: tap.event, view: tap.eventView)
        } else if let tap = tap as? ECWeekViewFreeTimeTapGestureRecognizer {
            let location = tap.location(in: tap.view).y - dateHeaderHeight
            let hour = Int(floor(location / hourHeight)) + startHour
            let minute = Int(floor((location - (CGFloat(hour - startHour) * hourHeight)) / minuteHeight))
            guard let date = tap.date?.dateBySet(hour: hour, min: minute, secs: 0) else { return }
            delegate?.weekViewDidClickOnFreeTime(self, date: date)
        }
    }
}

// MARK: - Default WeekViewStyler implementation

extension ECWeekView: ECWeekViewStyler {
    public var font: UIFont {
        get { .init(descriptor: .init(), size: 11) }
    }

    public var showsDateHeader: Bool {
        get { true }
    }

    public var dateHeaderHeight: CGFloat {
        get { 20 }
    }

    public func weekViewStylerECEventView(_ weekView: ECWeekView, eventContainer: CGRect, event: ECWeekViewEvent) -> UIView {
        let weekViewECEventView: ECEventView = .fromNib()
        weekViewECEventView.frame = eventContainer
        weekViewECEventView.event = event
        return weekViewECEventView
    }

    public func weekViewStylerHeaderView(_ weekView: ECWeekView, with date: DateInRegion, in cell: UICollectionViewCell) -> UIView? {
        guard showsDateHeader else { return nil }
        let labelFrame = CGRect(x: 0, y: 0, width: cell.frame.width, height: dateHeaderHeight)
        let label = UILabel(frame: labelFrame)
        label.font = font
        label.text = date.toFormat("EEE d")
        label.textColor = .black
        label.textAlignment = .center
        return label
    }
}


// MARK: - ECTimelineViewDataSource

extension ECWeekView: ECTimelineViewDataSource {
    public func timelineView<T, U>(_ timelineView: ECTimelineView<T, U>, dataFor index: Int, asyncClosure: @escaping (T?) -> Void) -> T? where U : UICollectionViewCell {
        let viewDate = initDate + index.days
        let events = dataSource?.weekViewGenerateEvents(self, date: viewDate, eventCompletion: { asyncEvents in
            if let asyncEvents = asyncEvents as? T {
                asyncClosure(asyncEvents)
            }
        })
        return events as? T
    }

    public func configure<T, U>(_ cell: U, withData data: T?) where U : UICollectionViewCell {
        guard let data = data as? [ECWeekViewEvent] else { return }
        let weekViewFreeTimeTapGestureRecognizer = ECWeekViewFreeTimeTapGestureRecognizer(target: self, action: #selector(handle(tap:)), date: data.first?.start)
        cell.addGestureRecognizer(weekViewFreeTimeTapGestureRecognizer)
        cell.backgroundColor = .clear

        if let date = data.first?.start, let cellHeader = styler?.weekViewStylerHeaderView(self, with: date, in: cell) {
            cell.addSubview(cellHeader)
        }

        let eventRects = placeEvents(data.sorted(), in: cell)
        data.forEach { event in
            if let eventRect = eventRects[event], let eventView = styler?.weekViewStylerECEventView(self, eventContainer: eventRect, event: event) {
                let weekViewEventTapGestureRecognizer = ECWeekViewEventTapGestureRecognizer(target: self, action: #selector(handle(tap:)), event: event, eventView: eventView)
                eventView.addGestureRecognizer(weekViewEventTapGestureRecognizer)
                cell.addSubview(eventView)
            }
        }
    }
}
