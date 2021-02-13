import SwiftUI

struct TimeView: View {

    let visibleHours: Int

    @State private var time: TimeInterval = 0

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(alignment: .trailing) {
                    ForEach(0..<25) { hour in
                        VStack {
                            Text(stringForHour(hour))
                                .font(.footnote)
                                .foregroundColor(Color(.gray))
                            if hour < 25 {
                                Spacer()
                            }
                        }
                        .offset(y: -5)
                    }
                }
                VStack(alignment: .trailing) {
                    HStack(spacing: 2) {
                        Text(stringForCurrentTime())
                            .font(.caption)
                        Circle()
                            .frame(width: 8, height: 8)
                            .zIndex(.infinity)
                    }
                    .foregroundColor(.red)
                    .offset(y: CGFloat(time) * secondHeight(for: geometry))
                    .offset(y: -6.5) // not sure why but this aligns it properly

                    Spacer()
                }
            }
            .padding(0)
            .onAppear { startTimer() }
        }
    }

    private func secondHeight(for geometry: GeometryProxy) -> CGFloat {
        geometry.size.height / 25 / 60 / 60
    }

    private func startTimer() {
        let midnightToday = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        time = Date().timeIntervalSince(midnightToday)
        let interval: TimeInterval = 1.minutes
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            time += interval
        }
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
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 40, height: 1000))
    }
}
