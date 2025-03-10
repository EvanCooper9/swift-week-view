import Combine
import EventKit
import ECScrollView
import SwiftUI
import SwiftUIX

public struct ECWeekView<Event: View, Header: View>: View {

    @StateObject private var viewModel: ECWeekViewModel
    @State private var loaded = false

    private var eventViewBuilder: (EKEvent) -> Event
    private var headerViewBuilder: (Date) -> Header

    private let startHour: Int

    public init(
        visibleDays: Int = 3,
        visibleHours: Int = 8,
        startHour: Int = 9,
        @ViewBuilder event: @escaping (EKEvent) -> Event,
        @ViewBuilder header: @escaping (Date) -> Header
    ) {
        _viewModel = .init(wrappedValue: .init(
            visibleDays: visibleDays,
            visibleHours: visibleHours
        ))
        eventViewBuilder = event
        headerViewBuilder = header
        self.startHour = startHour
    }

    // MARK: - Public Properties

    public var body: some View {
        ScrollViewReader { scrollViewReader in
            ScrollView(showsIndicators: false) {
                HStack(spacing: 0) {
                    TimeView(visibleHours: viewModel.visibleHours)
                        .frame(width: 45)
                        .padding(.leading, 3)
                    ECScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 0) {
                            ForEach(viewModel.days) { day in
                                DayView(day: day, eventViewBuilder: eventViewBuilder)
                                    .containerRelativeFrame(.horizontal) { containerWidth, _ in
                                        containerWidth / CGFloat(viewModel.visibleDays)
                                    }
                                    .id(day)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .didEndDecelerating { offset, proxy in
                        viewModel.didEndDecelerating(offset, scrollViewProxy: proxy)
                    }
                    .onContentOffsetChanged { offset, size, proxy in
                        if !loaded {
                            proxy.scrollTo(
                                viewModel.days[2],
                                anchor: .leading
                            )
                            loaded.toggle()
                        }

                        viewModel.contentOffsetChanged(offset, with: size, scrollViewSize: size, scrollViewProxy: proxy)
                    }
                    .scrollTargetBehavior(.viewAligned)
                }
                .containerRelativeFrame(.vertical) { containerHeight, _ in
                    let hourHeight = containerHeight / CGFloat(viewModel.visibleHours)
                    return hourHeight * 24.0
                }
                .onAppearOnce {
                    scrollViewReader.scrollTo((startHour - 1).hours, anchor: .top)
                }
            }
        }
        .environmentObject(DragHelper())
    }
}

public extension ECWeekView where Event == AnyView {
    init(
        visibleDays: Int = 3,
        visibleHours: Int = 8,
        startHour: Int = 9,
        @ViewBuilder header: @escaping (Date) -> Header
    ) {
        _viewModel = .init(wrappedValue: .init(
            visibleDays: visibleDays,
            visibleHours: visibleHours
        ))
        eventViewBuilder = { event in
            AnyView(ECEventView(event: event))
        }
        headerViewBuilder = header
        self.startHour = startHour
    }
}

public extension ECWeekView where Header == AnyView {
    init(
        visibleDays: Int = 3,
        visibleHours: Int = 8,
        startHour: Int = 9,
        @ViewBuilder event: @escaping (EKEvent) -> Event
    ) {
        _viewModel = .init(wrappedValue: .init(
            visibleDays: visibleDays,
            visibleHours: visibleHours
        ))
        eventViewBuilder = event
        headerViewBuilder = { date in
            AnyView(Text(date.formatted(date: .abbreviated, time: .omitted)))
        }
        self.startHour = startHour
    }
}

public extension ECWeekView where Event == AnyView, Header == AnyView {
    init(
        visibleDays: Int = 3,
        visibleHours: Int = 8,
        startHour: Int = 9
    ) {
        _viewModel = .init(wrappedValue: .init(
            visibleDays: visibleDays,
            visibleHours: visibleHours
        ))
        eventViewBuilder = { event in
            AnyView(ECEventView(event: event))
        }
        headerViewBuilder = { date in
            AnyView(Text(date.formatted(date: .abbreviated, time: .omitted)))
        }
        self.startHour = startHour
    }
}

extension Date: @retroactive Identifiable {
    public var id: String {
        formatted(date: .complete, time: .complete)
    }
}

struct ECWeekView_Previews: PreviewProvider {
    static var previews: some View {
        ECWeekView()
    }
}
