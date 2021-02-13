import Combine
import EventKit
import ECScrollView
import SwiftUI

public struct WeekView: View {

    @ObservedObject private var viewModel: ViewModel

    @State private var offset: CGPoint = .init(x: 1000, y: 110)
    
    public init(viewModel: ViewModel = .init()) {
        self.viewModel = viewModel
    }

    // MARK: - Public Properties

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
                                HStack(spacing: 0) {
                                    ForEach(viewModel.days, id: \.id) { day in
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

    // MARK: - Private Methods

    private func contentHeight(for geometry: GeometryProxy) -> CGFloat {
        let secondHeight = geometry.size.height / CGFloat(viewModel.visibleHours) / 60 / 60
        return secondHeight * CGFloat(24.hours)
    }
}

extension WeekView {

    public final class ViewModel: ObservableObject {

        private enum LoadDirection {
            case all, positive, negative

            var all: Bool { self == .all }
            var positive: Bool { self == .positive }
            var negative: Bool { self == .negative }
        }

        // MARK: - Public Properties

        @Published public var visibleDays: Int
        @Published public var visibleHours: Int
        @Published public var days = [CalendarDay]()

        // MARK: - Private Properties

        private let calendarManager: CalendarManaging

        private var negativeRefrenceDate: Date
        private var positiveReferenceDate: Date

        private var contentSize = CGSize.zero
        private var scrollViewSize = CGSize.zero

        private var initialContentLoaded = false

        private var cancellables = Set<AnyCancellable>()

        // MARK: - Lifecycle

        public init(calendarManager: CalendarManaging = CalendarManager(), visibleDays: Int = 1, visibleHours: Int = 12) {

            self.calendarManager = calendarManager
            self.visibleDays = visibleDays
            self.visibleHours = visibleHours

            let initialReferenceDate = Calendar.current.date(bySettingHour: 0, minute: 0, second: 1, of: Date())!
            positiveReferenceDate = initialReferenceDate.addingTimeInterval(TimeInterval(visibleDays.days))
            negativeRefrenceDate = initialReferenceDate.addingTimeInterval(TimeInterval(-visibleDays.days))

            NotificationCenter.default.addObserver(forName: .EKEventStoreChanged, object: nil, queue: .main) { [weak self] notification in
                guard let self = self, notification.isCalendarDataChanged else { return }
                self.fetchEvents(loadDirection: .all)
                    .sink { self.days = $0 }
                    .store(in: &self.cancellables)
            }

            // put some initial data to display an empty calendar
            days = (0..<loadCount(for: .all)).map { day in
                let date = negativeRefrenceDate.advanced(by: TimeInterval(day.days))
                return CalendarDay(date: date, events: [], eventStore: calendarManager.eventStore)
            }

            fetchEvents(loadDirection: .all)
                .sink { self.days = $0 }
                .store(in: &cancellables)
        }

        // MARK: - Public Methods

        func contentOffsetChanged(_ contentOffset: CGPoint, with contentSize: CGSize, scrollViewSize: CGSize, scrollViewProxy: ScrollViewProxy) {
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
            guard !days.isEmpty else { return }

            if contentOffset.x <= 0 {
                let oldReferenceDate = negativeRefrenceDate
                negativeRefrenceDate.addTimeInterval(-loadCount(for: .negative).days)
                fetchEvents(loadDirection: .negative)
                    .sink { [weak self] days in
                        guard let self = self else { return }
                        self.days.insert(contentsOf: days, at: 0)
                        guard let day = self.days.first(where: { $0.date.isSameDay(as: oldReferenceDate) }) else { return }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0001) {
                            scrollViewProxy.scrollTo(day.id, anchor: .leading)
                        }
                    }
                    .store(in: &cancellables)
            } else if contentOffset.x >= contentSize.width - scrollViewSize.width {
                positiveReferenceDate.addTimeInterval(loadCount(for: .positive).days)
                fetchEvents(loadDirection: .positive)
                    .sink { [weak self] days in
                        guard let self = self else { return }
                        var days = days
                        self.days = self.days.map { day in
                            guard let sameDay = days.first(where: { $0.date == day.date }) else { return day }
                            if let index = days.firstIndex(of: sameDay) { days.remove(at: index) }
                            return sameDay
                        }
                        self.days.append(contentsOf: days)
                    }
                    .store(in: &cancellables)
            }
        }

        // MARK: - Private Methods

        private func fetchEvents(loadDirection: LoadDirection) -> AnyPublisher<[CalendarDay], Never> {

            let days = (0..<loadCount(for: loadDirection))
                .map { day -> Date in
                    (loadDirection.positive ? positiveReferenceDate : negativeRefrenceDate)
                        .addingTimeInterval(TimeInterval(day.days))
                }
                .map { day(for: $0) }

            return Publishers
                .MergeMany(days)
                .receive(on: RunLoop.main)
                .collect()
                .map { $0.sorted() }
                .eraseToAnyPublisher()
        }

        private func day(for date: Date) -> Future<CalendarDay, Never> {
            Future() { [weak self] result in
                guard let self = self else { return }
                self.calendarManager.eventsFor(day: date) { events in
                    let day = CalendarDay(date: date, events: events, eventStore: self.calendarManager.eventStore)
                    result(.success(day))
                }
            }
        }

        private func loadCount(for loadDirection: LoadDirection) -> Int {
            switch loadDirection {
            case .all:
                return Int(negativeRefrenceDate.distance(to: positiveReferenceDate) / 1.days)
            case .positive, .negative:
                return visibleDays * 3
            }
        }
    }
}

struct WeekView_Previews: PreviewProvider {

    private struct PreviewCalendarManager: CalendarManaging {
        var authorizationStatus: EKAuthorizationStatus { .authorized }

        var eventStore: EKEventStore

        func eventsFor(day date: Date, completion: (([EKEvent]) -> Void)?) {
            var events = [EKEvent]()
            events.append(WeekView_Previews.event(with: "Interview @Apple", location: "Ottawa", for: date))
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
            .preferredColorScheme(.dark)
    }
}
