import SwiftUI

struct TimeView: View {

    let visibleHours: Int

    @State private var time: TimeInterval = 0

    public var body: some View {
        VStack(alignment: .trailing) {
            ForEach(0..<25) { hour in
                Text(stringForHour(hour))
                    .font(.footnote)
                    .foregroundColor(Color(.gray))
                    .id(hour.hours)
                Spacer()
            }
        }
    }

    private func secondHeight(for geometry: GeometryProxy) -> CGFloat {
        geometry.size.height / 25 / 60 / 60
    }

    private func stringForHour(_ hour: Int) -> String {
        let midnightToday = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        let currentTime = Date().timeIntervalSince(midnightToday)
        guard abs(hour.hours - Int(currentTime)) > 10.minutes else { return "" }
        guard hour > 0 else { return "12 AM" }
        guard hour < 24 else { return "12 AM" }
        return "\(hour <= 12 ? hour : hour - 12) \(hour < 12 ? "AM" : "PM")"
    }

    private func stringForCurrentTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm"
        return dateFormatter.string(from: Date())
    }
}

struct TimeView_Preivews: PreviewProvider {
    static var previews: some View {
        TimeView(visibleHours: 14)
    }
}
