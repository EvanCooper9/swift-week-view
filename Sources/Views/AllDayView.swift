import EventKit
import SwiftUI

struct AllDayEventView: View {

    let event: EKEvent
    let eventStore: EKEventStore

    @State private var presentEditEvent = false

    private var color: Color { Color(event.calendar.cgColor) }

    var body: some View {
        Text(event.title)
            .font(.caption)
            .padding(5)
            .foregroundColor(color)
            .cornerRadius(2)
            .frame(maxWidth: .infinity)
            .background(color.opacity(0.2))
            .onTapGesture { presentEditEvent.toggle() }
            .sheet(isPresented: $presentEditEvent) {
                EventEditView(event: event, eventStore: eventStore)
            }
    }
}

struct AllDayView: View {

    let events: [EKEvent]
    let eventStore: EKEventStore

    @State private var show = false

    var body: some View {
        VStack {
            if show {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(events) { AllDayEventView(event: $0, eventStore: eventStore) }
                }
                .padding(2)
                .background(Color.white)
                .shadow(color: Color(.lightGray).opacity(0.5), radius: 5, x: 0, y: 0)
            }

            HStack {
                Spacer()

                HStack {
                    if show {
                        Text("All day events")
                            .font(.caption)
                    }
                    Image(systemName: "chevron.\(show ? "up" : "down")")
                        .font(.caption)
                }
                .padding([.top, .bottom], 6)
                .padding([.leading, .trailing], 8)
                .background(Color.white)
                .clipShape(Capsule())
                .shadow(color: Color(.lightGray).opacity(0.5), radius: 5, x: 0, y: 0)
                .onTapGesture { show.toggle() }
            }

            Spacer()
        }
    }
}

struct AllDayView_Previews: PreviewProvider {
    private static let eventStore = EKEventStore()

    private static var calendar: EKCalendar {
        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.cgColor = Color(.red).cgColor
        return calendar
    }

    private static var event: EKEvent {
        let event = EKEvent(eventStore: eventStore)
        event.title = "Preview event"
        event.location = "Hintonburg"
        event.startDate = Date()
        event.endDate = Date().addingTimeInterval(1.hours)
        event.isAllDay = true
        event.calendar = calendar
        return event
    }

    static var previews: some View {
        AllDayView(events: [event, event, event], eventStore: eventStore)
            .previewLayout(.fixed(width: 500, height: 300))
            .previewDevice(nil)
    }
}
