import ECKit
import EventKit
import EventKitUI
import SwiftUI

struct DayView<Event: View>: View {

    private let date: Date
    @State private var events = [EKEvent]()

    @Environment(\.eventStore) private var eventStore
    @Environment(\.calendarQueue) private var calendarQueue
    @EnvironmentObject private var dragHelper: DragHelper

    private let eventViewBuilder: (EKEvent) -> Event

    init(
        day: Date,
        @ViewBuilder eventViewBuilder: @escaping (EKEvent) -> Event
    ) {
        self.date = day
        self.eventViewBuilder = eventViewBuilder
    }

    var body: some View {
        ZStack(alignment: .leading) {
            VStack {
                ForEach(0..<25) { hour in
                    VStack {
                        LinearGradient(
                            gradient: .init(colors: [Color(.lightGray), .clear]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(height: 1)
                        .opacity(0.2)
                        Spacer()
                    }
                }
            }

            GeometryReader { proxy in
                ZStack {
                    events(with: proxy)
                    if let draggedEventData = dragHelper.draggedEventData,
                       draggedEventData.date == date,
                       let location = draggedEventData.location,
                       let rawEvent = eventStore.event(withIdentifier: draggedEventData.eventIdentifier) {
                        let event = edited(event: rawEvent, for: location, in: proxy)
                        ECEventView(event: event)
                            .frame(width: proxy.size.width, height: height(for: event, with: proxy, ignoreDay: true))
                            .offset(x: 0, y: startHourOffset(for: event, with: proxy))
                    }
                }
            }
            .contentShape(Rectangle())
            .clipped()
            .onDrop(of: [.data], delegate: self)
        }
        .onAppearOnce {
            subscribeToEvents()
        }
    }

    @ViewBuilder
    private func events(with geometry: GeometryProxy) -> some View {
        let eventsWithIdentifiers = events
            .filterNot(\.isAllDay)
            .compactMap { event -> (eventIdentifier: String, event: EKEvent)? in
                guard let eventIdentifier = event.eventIdentifier else { return nil }
                return (eventIdentifier, event)
            }

        ForEach(eventsWithIdentifiers, id: \.eventIdentifier) { eventIdentifier, event in
            eventViewBuilder(event)
                .onDrag {
                    dragHelper.begin(.init(
                        eventIdentifier: eventIdentifier,
                        location: nil,
                        date: date
                    ))
                    return NSItemProvider(object: DropData(dropAreaSize: geometry.size, eventIdentifier: eventIdentifier))
                } preview: {
                    eventViewBuilder(event)
                        .frame(
                            width: width(for: event, with: geometry),
                            height: height(for: event, with: geometry)
                        )
                }
                .frame(
                    width: width(for: event, with: geometry),
                    height: height(for: event, with: geometry)
                )
                .offset(
                    x: xOffset(for: event, with: geometry),
                    y: startHourOffset(for: event, with: geometry)
                )
        }
    }

    private func edited(event: EKEvent, for location: CGPoint, in proxy: GeometryProxy) -> EKEvent {
        let newStartTime = location.y / secondHeight(for: proxy.size.height)
        let roundedNewStartTime = newStartTime.roundToNearest(CGFloat(15.minutes))
        let dateComponent = Calendar.current.dateComponents([.year, .month, .day, .timeZone], from: date)
        let date = Calendar.current.date(from: dateComponent)!
        let duration = event.endDate.timeIntervalSince1970 - event.startDate.timeIntervalSince1970

        event.startDate = date.addingTimeInterval(TimeInterval(roundedNewStartTime))
        event.endDate = event.startDate.addingTimeInterval(duration)

        return event
    }

    private func height(for event: EKEvent, with geometry: GeometryProxy, ignoreDay: Bool = false) -> CGFloat {
        let isFromPreviousDay = ignoreDay ? false : !event.startDate.isSameDay(as: date)
        let isToNextDay = ignoreDay ? false : !event.endDate.isSameDay(as: date)
        let start = isFromPreviousDay ? 0 : event.startHour.hours + event.startMinute.minutes
        let end = isToNextDay ? 2.days : event.endHour.hours + event.endMinute.minutes
        return CGFloat(end - start) * secondHeight(for: geometry)
    }

    private func width(for event: EKEvent, with geometry: GeometryProxy) -> CGFloat {
        let overlappingEvents = events.overlappingEvents(against: event)
        return geometry.size.width / CGFloat(overlappingEvents.count + 1)
    }

    private func xOffset(for event: EKEvent, with geometry: GeometryProxy) -> CGFloat {
        let events = events
            .overlappingEvents(against: event)
            .appending(event)
            .sorted()

        let index = events.firstIndex(of: event) ?? 0

        return CGFloat(index) * width(for: event, with: geometry)
    }

    private func startHourOffset(for event: EKEvent, with geometry: GeometryProxy) -> CGFloat {
        guard event.startDate.isSameDay(as: date) else {
            return 0
        }

        let start = event.startHour.hours + event.startMinute.minutes
        return CGFloat(start) * secondHeight(for: geometry)
    }

    private func secondHeight(for geometry: GeometryProxy) -> CGFloat {
        secondHeight(for: geometry.size.height)
    }

    private func secondHeight(for height: CGFloat) -> CGFloat {
        let hourHeight = height / 25
        let minuteHeight = hourHeight / 60
        return minuteHeight / 60
    }

    private func subscribeToEvents() {
        NotificationCenter.default.addObserver(forName: .EKEventStoreChanged, object: nil, queue: .main) { notification in
            guard notification.isCalendarDataChanged else { return }
            Task {
                await MainActor.run {
                    fetchEvents()
                }
            }
        }
        fetchEvents()
    }

    private func fetchEvents() {
        calendarQueue.sync { [eventStore] in
            guard let start = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: date),
                  let end = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: date)
            else {
                self.events = []
                return
            }
            let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: nil)
            let events = eventStore.events(matching: predicate)
            self.events = events
        }
    }
}

extension DayView: DropDelegate {
    func performDrop(info: DropInfo) -> Bool {
        for item in info.itemProviders(for: [.data]) {
            item.loadObject(ofClass: DropData.self) { dropData, error in
                guard let dropData = dropData as? DropData else { return }
                let location = info.location

                Task { [location] in
                    await MainActor.run { [location] in
                        guard let event = eventStore.event(withIdentifier: dropData.eventIdentifier) else { return }

                        let newStartTime = location.y / secondHeight(for: dropData.dropAreaSize.height)
                        let roundedNewStartTime = newStartTime.roundToNearest(CGFloat(15.minutes))
                        let dateComponent = Calendar.current.dateComponents([.year, .month, .day, .timeZone], from: date)
                        let date = Calendar.current.date(from: dateComponent)!
                        let duration = event.endDate.timeIntervalSince1970 - event.startDate.timeIntervalSince1970

                        event.startDate = date.addingTimeInterval(TimeInterval(roundedNewStartTime))
                        event.endDate = event.startDate.addingTimeInterval(duration)

                        try? eventStore.save(event, span: .thisEvent)
                    }
                }
            }
        }
        dragHelper.end()
        return true
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        dragHelper.update(info.location)
        return .init(operation: .move)
    }

    func dropEntered(info: DropInfo) {
        dragHelper.update(date)
    }
}

struct DayView_Preview: PreviewProvider {
    static var previews: some View {
        HStack {
            TimeView(visibleHours: 24)
            DayView(day: .now) { event in
                ECEventView(event: event)
            }
        }
        .background(.white)
        .padding()
        .background(.red)
    }
}
