import ECWeekView
import SwiftUI

@main
struct ECWeekViewExampleApp: App {
    var body: some Scene {
        WindowGroup {
            WeekView(viewModel: .init(calendarManager: CalendarManager(), visibleDays: 2, visibleHours: 12))
        }
    }
}
