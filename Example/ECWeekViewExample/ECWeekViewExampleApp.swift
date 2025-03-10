import ECWeekView
import SwiftUI

@main
struct ECWeekViewExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ECWeekView(visibleDays: 2, visibleHours: 8, startHour: 9) { event in
                ECEventView(event: event)
            } header: { date in
                Text(date.formatted(date: .abbreviated, time: .omitted))
            }
        }
    }
}
