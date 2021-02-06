import EventKit
import SwiftUI

struct EventView: View {

    let event: EKEvent
    let eventStore: EKEventStore

    @State private var presentEdit = false

    private var color: Color { Color(event.calendar.cgColor) }

    var body: some View {
        HStack(spacing: 0) {
            color
                .frame(width: 8)
                .opacity(0.9)
            ZStack {
                color.opacity(0.2)
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(event.title)
                            .font(.caption)
                            .foregroundColor(color)
                            .fontWeight(.semibold)
                            .frame(alignment: .leading)
                            .padding([.top, .leading, .trailing], 8)
                            .padding([.bottom], 1)
                            .multilineTextAlignment(.leading)
                        if let location = event.location {
                            Text(location)
                                .font(.caption2)
                                .foregroundColor(color)
                                .frame(alignment: .leading)
                                .padding([.leading], 8)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .cornerRadius(3)
        .onTapGesture { presentEdit.toggle() }
        .sheet(isPresented: $presentEdit) { EventEditView(event: event, eventStore: eventStore) }
    }
}

struct EventView_Preview: PreviewProvider {

    private static let eventStore = EKEventStore()

    private static var calendar: EKCalendar {
        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.cgColor = Color(.red).cgColor
        return calendar
    }

    private static var event: EKEvent {
        let event = EKEvent(eventStore: eventStore)
        event.title = "Preview Content"
        event.location = "Hintonburg"
        event.startDate = Date()
        event.endDate = Date().addingTimeInterval(1.hours)
        event.calendar = calendar
        return event
    }

    static var previews: some View {
        EventView(event: event, eventStore: eventStore)
            .previewLayout(.fixed(width: 200, height: 200))
    }
}
