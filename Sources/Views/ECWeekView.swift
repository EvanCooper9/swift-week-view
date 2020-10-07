import Foundation
import UIKit
import SwiftDate
import ECTimelineView

@IBDesignable public final class ECWeekView: UIView {

    // MARK: - Private properties

    private lazy var timeView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = colorTheme.baseColor
        return view
    }()

    private typealias DataType = [ECWeekViewEvent]
    private typealias CellType = ECDayCell
    private lazy var timelineView: ECTimelineView<DataType, CellType> = {
        let config = ECTimelineViewConfig(visibleCells: visibleDays, scrollDirection: .horizontal)
        let timelineView = ECTimelineView<DataType, CellType>(frame: .zero, config: config)
        timelineView.translatesAutoresizingMaskIntoConstraints = false
        timelineView.timelineCellDelegate = self
        timelineView.backgroundColor = .clear
        return timelineView
    }()

    private var nowLine: CAShapeLayer!
    private var nowLinePath: CGPath {
        let linePath = UIBezierPath(rect: CGRect(x: nowLineCenter.x, y: nowLineCenter.y, width: timelineView.contentSize.width, height: 0.1))
        return linePath.cgPath
    }
    
    private var nowCircle: UIView!
    private var nowLineCenter: CGPoint {
        let now = DateInRegion()
        return CGPoint(x: timeView.frame.width, y: timeView.frame.origin.y + (hourHeight * CGFloat(now.hour - startHour)) + ((hourHeight/60) * CGFloat(now.minute)))
    }

    private var hourHeight: CGFloat {
        return (frame.height - dateHeaderHeight) / CGFloat(endHour - startHour)
    }

    private var minuteHeight: CGFloat {
        return hourHeight / 60
    }

    // MARK: - Public properties
    
    public weak var dataSource: ECWeekViewDataSource? {
        didSet {
            timelineView.timelineDataSource = self
        }
    }

    public weak var delegate: ECWeekViewDelegate?

    public weak var styler: ECWeekViewStyler? {
        didSet {
            if oldValue != nil {
                timelineView.reloadData()
            }
        }
    }

    @IBInspectable public var visibleDays : Int = 5
    
    public var initDate: DateInRegion = DateInRegion()
    public var startHour: Int = 9
    public var endHour: Int = 17
    public var nowLineEnabled: Bool = true
    public var colorTheme: Theme = .light
    public var nowLineColor: UIColor = .red

    // MARK: - Public functions
    
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
    public init(frame: CGRect, visibleDays: Int, date: DateInRegion = DateInRegion()) {
        super.init(frame: frame)
        commonInit(frame: frame, visibleDays: visibleDays, date: date)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit(frame: frame, visibleDays: 5, date: DateInRegion())
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit(frame: frame, visibleDays: 5, date: DateInRegion())
    }

    public override func prepareForInterfaceBuilder() {
        commonInit(frame: frame, visibleDays: 5, date: DateInRegion())
    }

    // MARK: - Private functions
    
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
    private func commonInit(frame: CGRect, visibleDays: Int, date: DateInRegion) {
        self.frame = frame
        self.visibleDays = visibleDays
        initDate = date - visibleDays.days

        styler = self

        addHourInfo()
        addSubview(timeView)
        addSubview(timelineView)
        insertNowLine()
        
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
    }

    private func framesMatch(frame1: CGRect, frame2: CGRect) -> Bool {
        return frame1.origin.x.isEqual(to: frame2.origin.x) && frame1.origin.y.isEqual(to: frame2.origin.y) && frame1.size.width.isEqual(to: frame2.size.width) && frame1.size.height.isEqual(to: frame2.size.height)
    }

    private func insertNowLine() {
        let now: DateInRegion = DateInRegion()
        let linePath = UIBezierPath(rect: CGRect(x: timeView.frame.width, y: timeView.frame.origin.y + (hourHeight * CGFloat(now.hour - startHour)) + ((hourHeight/60) * CGFloat(now.minute)), width: timelineView.contentSize.width, height: 0.1))
        nowLine = CAShapeLayer()
        nowLine.path = linePath.cgPath
        nowLine.strokeColor = nowLineColor.cgColor
        nowLine.fillColor = nowLineColor.cgColor

        nowCircle = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 6))
        nowCircle.layer.cornerRadius = 3
        nowCircle.backgroundColor = nowLineColor
        nowCircle.clipsToBounds = true

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
                    sleep(60)
                } else {
                    self.nowLine.removeFromSuperlayer()
                    self.nowCircle.removeFromSuperview()
                    break
                }
            }
        }
    }
    
    /**
     Add the hour text and horizontal line for each hour that's visible in the scrollView
     */
    private func addHourInfo() {
        for hour in startHour...endHour {
            let hourText = UILabel(frame: .zero)
            hourText.translatesAutoresizingMaskIntoConstraints = false
//            hourText.removeTextInsets()
            hourText.text = "\(hour):00"
            hourText.textAlignment = .right
            hourText.backgroundColor = .clear
            hourText.font = styler?.font ?? UIFont.init(descriptor: UIFontDescriptor(), size: 12)
            hourText.textColor = colorTheme.hourTextColor
//            hourText.pushTextToTop()
//            hourText.isEditable = false
//            hourText.isSelectable = false
            timeView.addSubview(hourText)
            NSLayoutConstraint.activate([
                hourText.leftAnchor.constraint(equalTo: timeView.leftAnchor),
                hourText.rightAnchor.constraint(equalTo: timeView.rightAnchor),
                hourText.topAnchor.constraint(equalTo: timeView.topAnchor, constant: dateHeaderHeight + hourHeight * CGFloat(hour - startHour) - font.pointSize / 2)
            ])

            let hourLayer = CAShapeLayer()
            hourLayer.strokeColor = colorTheme.hourLineColor.cgColor
            hourLayer.fillColor = colorTheme.hourLineColor.cgColor
            let linePath = UIBezierPath(rect: CGRect(x: frame.origin.x + timeView.frame.width, y: dateHeaderHeight + hourHeight * CGFloat(hour - startHour) + frame.origin.y, width: timelineView.contentSize.width, height: 0.1))
            hourLayer.path = linePath.cgPath
            layer.addSublayer(hourLayer)
        }
    }
}

// MARK: - Placing events graphically

extension ECWeekView {
    private func placeEvents(_ events: [ECWeekViewEvent], in cell: UICollectionViewCell) -> [ECWeekViewEvent:CGRect] {
        let threshold = 20

        var mutableEvents = events.sorted()
        var placedEvents = [ECWeekViewEvent]()
        var placedEventRects = [ECWeekViewEvent:CGRect]()

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
        get {
            return UIFont.init(descriptor: UIFontDescriptor(), size: 11)
        }
    }

    public var showsDateHeader: Bool {
        get {
            return true
        }
    }

    public var dateHeaderHeight: CGFloat {
        get {
            return showsDateHeader ? 20 : 0
        }
    }

    public func weekViewStylerECEventView(_ weekView: ECWeekView, eventContainer: CGRect, event: ECWeekViewEvent) -> UIView {
        let weekViewECEventView: ECEventView = .fromNib()
        weekViewECEventView.frame = eventContainer
        weekViewECEventView.event = event
        return weekViewECEventView
    }

    public func weekViewStylerHeaderView(_ weekView: ECWeekView, with date: DateInRegion, in cell: UICollectionViewCell) -> UIView {
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
    public func timelineCollectionView<T, U>(_ timelineCollectionView: ECTimelineView<T, U>, dataFor index: Int, asyncClosure: @escaping (T?) -> Void) -> T? where U : UICollectionViewCell {
        let viewDate: DateInRegion = initDate + index.days
        let events = dataSource?.weekViewGenerateEvents(self, date: viewDate, eventCompletion: { asyncEvents in
            if let asyncEvents = asyncEvents as? T {
                asyncClosure(asyncEvents)
            }
        })
        return events as? T
    }
}

// MARK: - ECTimelineViewCellDelegate

extension ECWeekView: ECTimelineViewCellDelegate {
    public func configure<T, U>(_ cell: U, withData data: T?) where U : UICollectionViewCell {
        guard let data = data as? DataType else { return }
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
