import EventKit
import ECScrollView
import SwiftUI

public struct WeekView: View {

    @ObservedObject private var viewModel: ViewModel

    @State private var offset: CGPoint = .init(x: 1000, y: 110)
    
    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack {
                    Spacer()
                    HStack(spacing: 0) {
                        TimeView(visibleHours: viewModel.visibleHours)
                            .frame(width: 45)
                            .padding(.leading, 3)
                        GeometryReader { geometry in
                            ECScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 0) {
                                    ForEach(viewModel.days.sorted()) { day in
                                        DayView(day: day).frame(width: geometry.size.width / CGFloat(viewModel.visibleDays))
                                    }
                                }
                            }
                            .didEndDecelerating { offset, proxy in
                                viewModel.didEndDecelerating(offset, scrollViewProxy: proxy)
                            }
                            .onContentOffsetChanged { offset, size, proxy in
                                viewModel.contentOffsetChanged(offset, with: size, scrollViewSize: geometry.size, scrollViewProxy: proxy)
                            }
                        }
                    }
                    .frame(height: contentHeight(for: geometry))
                }
            }
        }
    }

    private func contentHeight(for geometry: GeometryProxy) -> CGFloat {
        let secondHeight = geometry.size.height / CGFloat(viewModel.visibleHours) / 60 / 60
        return secondHeight * CGFloat(24.hours)
    }
}

extension WeekView {

    public final class ViewModel: ObservableObject {

        private enum LoadDirection {
            case positive, negative

            var positive: Bool { self == .positive }
            var negative: Bool { self == .negative }
        }

        // MARK: - Public Properties

        @Published public var visibleDays: Int
        @Published public var visibleHours: Int
        @Published public var days = [CalendarDay]()

        // MARK: - Private Properties

        private let calendarManager: CalendarManaging

        private lazy var initialReferenceDate = Date().addingTimeInterval(TimeInterval(-visibleDays.days))
        private lazy var positiveReferenceDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 1, of: initialReferenceDate)!
        private lazy var negativeRefrenceDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 1, of: initialReferenceDate)!
        private lazy var loadedDays = visibleDays * 3

        private var contentOffset = CGPoint.zero
        private var contentSize = CGSize.zero
        private var scrollViewSize = CGSize.zero

        private var initialContentLoaded = false

        // MARK: - Lifecycle

        public init(calendarManager: CalendarManaging, visibleDays: Int, visibleHours: Int) {
            self.calendarManager = calendarManager
            self.visibleDays = visibleDays
            self.visibleHours = visibleHours

            NotificationCenter.default.addObserver(forName: .EKEventStoreChanged, object: nil, queue: .main) { notification in
                guard let calendarDataChanged = notification.userInfo?["EKEventStoreCalendarDataChangedUserInfoKey"] as? Bool, calendarDataChanged else { return }
                print(notification)
                self.fetchEvents()
            }

            fetchEvents()
        }

        // MARK: - Public Methods

        func contentOffsetChanged(_ contentOffset: CGPoint, with contentSize: CGSize, scrollViewSize: CGSize, scrollViewProxy: ScrollViewProxy) {
            self.contentOffset = contentOffset
            self.contentSize = contentSize
            self.scrollViewSize = scrollViewSize

            if !initialContentLoaded {
                initialContentLoaded.toggle()
                let middleDay = days[visibleDays]
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    scrollViewProxy.scrollTo(middleDay.id, anchor: .leading)
                }
            }
        }

        func didEndDecelerating(_ contentOffset: CGPoint, scrollViewProxy: ScrollViewProxy) {

//            let dayWidth = scrollViewSize.width / CGFloat(visibleDays)
//            if contentOffset.x.truncatingRemainder(dividingBy: dayWidth) != 0 {
//                // pagination
//                days.enumerated()
//                    .first { CGFloat($0.offset) * dayWidth == contentOffset.x.roundToNearest(dayWidth) }
//                    .map { _, day in
//                        withAnimation { scrollViewProxy.scrollTo(day.id, anchor: .leading) }
//                    }
//            }

            if contentOffset.x == 0 {
                let oldReferenceDate = negativeRefrenceDate
                negativeRefrenceDate.addTimeInterval(-loadedDays.days)
                fetchEvents(loadDirection: .negative)

                guard let day = days.first(where: { $0.date == oldReferenceDate }) else { return }
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    scrollViewProxy.scrollTo(day.id, anchor: .leading)
                }
            } else if contentOffset.x >= contentSize.width - scrollViewSize.width {
                positiveReferenceDate.addTimeInterval(loadedDays.days)
                fetchEvents(loadDirection: .positive)
            }
        }

        // MARK: - Private Methods

        private func fetchEvents(loadDirection: LoadDirection = .positive) {
            (0..<loadedDays).forEach { day in

                let referenceDate = (loadDirection.positive ? positiveReferenceDate : negativeRefrenceDate)
                    .advanced(by: TimeInterval(day.days))

                calendarManager.eventsFor(day: referenceDate) { events in
                    let newDay = CalendarDay(date: referenceDate, events: events, eventStore: self.calendarManager.eventStore)
                    guard !self.days.contains(where: { $0.date.isSameDay(as: referenceDate) }) else {
                        self.days = self.days.map { day in
                            guard day.date.isSameDay(as: referenceDate) else { return day }
                            return newDay
                        }
                        return
                    }

                    loadDirection.positive ? self.days.append(newDay) : self.days.insert(newDay, at: 0)
                }
            }
        }
    }
}

struct WeekView_Previews: PreviewProvider {

    private struct PreviewCalendarManager: CalendarManaging {
        var eventStore: EKEventStore

        func eventsFor(day date: Date, completion: (([EKEvent]) -> Void)?) {
            var events = [EKEvent]()
            events.append(WeekView_Previews.event(with: "Event A", location: "Ottawa", for: date))
//            events.append(WeekView_Previews.event(with: "Event B", location: "Ottawa", for: date))
            events.append(WeekView_Previews.event(with: "My Birthday", for: date, isAllDay: true))
            completion?(events)
        }
    }

    private static let calendarManager = PreviewCalendarManager(eventStore: eventStore)

    private static var viewModel: WeekView.ViewModel {
        .init(calendarManager: calendarManager, visibleDays: 2, visibleHours: 12)
    }

    static var previews: some View {
        WeekView(viewModel: viewModel)
    }
}
