import EventKit
import SwiftUI

extension EnvironmentValues {
    @Entry var eventStore = EKEventStore()
    @Entry var calendarQueue = DispatchQueue(label: "com.evancooper.calendarqueue")
    @Entry var dragHelper = DragHelper()
}
