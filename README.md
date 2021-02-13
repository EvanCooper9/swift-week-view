# ECWeekView

An iOS calendar library for displaying calendar events in a week view.

## Features
- See calendar events in a week view
- Pull events from EventKit
- Drag & drop
- Event editing
- Infinite horizontal scrolling

## Installation
### Swift Package Manager
```
.package(url: "https://github.com/EvanCooper9/swift-week-view", branch: "swiftui")
```

## Usage

```swift
import ECWeekView

struct ContentView: View {
    var body: some View {
        ECWeekView()
    }
}
```

>You should add `NSCalendarsUsageDescription` to your app's `Info.plist`
