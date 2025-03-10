import EventKit
import SwiftUI

public struct ECEventView: View {

    let event: EKEvent

    public init(event: EKEvent) {
        self.event = event
    }

    @State private var presentEdit = false
    @Environment(\.eventStore) private var eventStore
    private var color: Color { Color(event.calendar.cgColor) }

    public var body: some View {
        color
            .opacity(0.2)
            .overlay(alignment: .topLeading) {
                HStack(alignment: .top) {
                    Capsule()
                        .foregroundStyle(color)
                        .width(4)
                    VStack(alignment: .leading) {
                        Text(event.title)
                            .font(.caption)
                            .foregroundColor(color)
                            .fontWeight(.semibold)
                        if let location = event.location {
                            Label(location, systemImage: .locationCircle)
                                .font(.caption2)
                                .foregroundColor(color)
                        } else {
                            Label {
                                Text(event.startDate ... event.endDate)
                            } icon: {
                                Image(systemName: .clock)
                            }
                            .font(.caption2)
                            .foregroundColor(color)
                        }
                    }
                }
                .padding(4)
            }
            .cornerRadius(3)
            .onTapGesture { presentEdit.toggle() }
            .sheet(isPresented: $presentEdit) { EventEditView(event: event, eventStore: eventStore) }
    }
}

struct EventView_Preview: PreviewProvider {

    private static var event: EKEvent {
        let eventStore = EKEventStore()
        let calendar = EKCalendar(for: .event, eventStore: eventStore)
        calendar.cgColor = Color(.red).cgColor

        let event = EKEvent(eventStore: eventStore)
        event.title = "Interview @Apple"
        event.location = "Cupertino, CA"
        event.startDate = Date()
        event.endDate = Date().addingTimeInterval(1.hours)
        event.calendar = calendar
        return event
    }

    static var previews: some View {
        ECEventView(event: event)
            .frame(width: 300, height: 150)
    }
}
