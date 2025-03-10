//
//  File.swift
//  ECWeekView
//
//  Created by Evan Cooper on 2025-02-23.
//

import Combine
import Foundation
import SwiftUI

public final class ECWeekViewModel: ObservableObject {

    private enum LoadDirection {
        case all, positive, negative

        var all: Bool { self == .all }
        var positive: Bool { self == .positive }
        var negative: Bool { self == .negative }
    }

    // MARK: - Public Properties

    @Published public var visibleDays: Int
    @Published public var visibleHours: Int
    @Published public var days = [Date]()

    // MARK: - Private Properties

    private var negativeRefrenceDate: Date {
        didSet {
            setDays()
        }
    }
    
    private var positiveReferenceDate: Date {
        didSet {
            setDays()
        }
    }

    private var contentSize = CGSize.zero
    private var scrollViewSize = CGSize.zero

    private var initialContentLoaded = false

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Lifecycle

    public init(visibleDays: Int, visibleHours: Int) {

        self.visibleDays = visibleDays
        self.visibleHours = visibleHours

        let initialReferenceDate = Date.now
        positiveReferenceDate = initialReferenceDate.addingTimeInterval(TimeInterval(visibleDays.days * 2))
        negativeRefrenceDate = initialReferenceDate.addingTimeInterval(TimeInterval(-visibleDays.days))
        setDays()
    }

    // MARK: - Public Methods

    @MainActor
    func contentOffsetChanged(_ contentOffset: CGPoint, with contentSize: CGSize, scrollViewSize: CGSize, scrollViewProxy: ScrollViewProxy) {
        self.contentSize = contentSize
        self.scrollViewSize = scrollViewSize

        if !initialContentLoaded {
            initialContentLoaded.toggle()

            let middleDay = days[visibleDays]
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                scrollViewProxy.scrollTo(middleDay, anchor: .leading)
            }
        }
    }

    @MainActor
    func didEndDecelerating(_ contentOffset: CGPoint, scrollViewProxy: ScrollViewProxy) {
        guard !days.isEmpty else { return }

        if contentOffset.x <= 0 {
            negativeRefrenceDate.addTimeInterval(-loadCount(for: .negative).days)
        } else if contentOffset.x >= contentSize.width - scrollViewSize.width {
            positiveReferenceDate.addTimeInterval(loadCount(for: .positive).days)
        }
    }

    // MARK: - Private Methods

    private func loadCount(for loadDirection: LoadDirection) -> Int {
        switch loadDirection {
        case .all:
            return Int(negativeRefrenceDate.distance(to: positiveReferenceDate) / 1.days)
        case .positive, .negative:
            return visibleDays * 3
        }
    }

    private func setDays() {
        let start = negativeRefrenceDate.formatted(date: .abbreviated, time: .omitted)
        let end = positiveReferenceDate.formatted(date: .abbreviated, time: .omitted)
        print("date range \(start) - \(end)")

        self.days = stride(
            from: negativeRefrenceDate.timeIntervalSince1970,
            through: positiveReferenceDate.timeIntervalSince1970,
            by: 1.days
        )
        .map(Date.init(timeIntervalSince1970:))
    }
}
