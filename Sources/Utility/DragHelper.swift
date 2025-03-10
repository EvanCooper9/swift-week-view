//
//  File.swift
//  ECWeekView
//
//  Created by Evan Cooper on 2025-03-10.
//

import Foundation

final class DragHelper: Observable, ObservableObject {

    struct DraggedEventData {
        let eventIdentifier: String
        var location: CGPoint?
        var date: Date
    }

    @Published private(set) var draggedEventData: DraggedEventData?

    func begin(_ draggedEventData: DraggedEventData) {
        print(#function, draggedEventData)
        self.draggedEventData = draggedEventData
    }

    func update(_ location: CGPoint) {
        draggedEventData?.location = location
    }

    func update(_ date: Date) {
        print(#function, date)
        draggedEventData?.date = date
    }

    func end() {
        draggedEventData = nil
    }
}
