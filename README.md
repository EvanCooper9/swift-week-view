# Swift-Week-View
An iOS calendar library for displaying calendar events in a week view.

<p align="center">
	<img src="Media/screen2.gif" width="30%" height="auto">
</p> 

## Features
- See calendar events in a week view
- Infinite horizontal scrolling
- Snaps to closest day after scrolling

## Usage
1. Download source & install dependencies

2. Create some subclass of `CalendarWeekView`'s delegate for creating events, `EventGenerator`. Override the `generateEvents(date: DateInRegion) -> [WeekViewEvent]` function. This function should return a list of `WeekViewEvent`s specific to the day of `date`. See [here](malcommac.github.io/SwiftDate/manipulate_dates.html#dateatunit) for [SwiftDate](https://github.com/malcommac/SwiftDate) documentation on creating date objects at specific times. Currently, events rely on a [24-hour clock](https://en.wikipedia.org/wiki/24-hour_clock).

   ```Swift
   class EG: CalendarWeekView.EventGenerator {
       override func generateEvents(date: DateInRegion) -> [WeekViewEvent] {
       	   // create a WeekViewEvent for the day of date
           let start = date.atTime(hour: 12, minute: 0, second: 0)!
           let end = date.atTime(hour: 13, minute: 0, second: 0)!
           let event: WeekViewEvent = WeekViewEvent(title: "Lunch", startDate: start, endDate: end)
           return [event]
       }
   }
   ```

3. Create an instance of `CalendarWeekView`, then add it as a subview.
   
   ```Swift
   let weekView: CalendarWeekView = CalendarWeekView(frame: frame, eventGenerator: EG(), visibleDays: 5)
   view.addSubview(weekView)
   ```

## Dependencies
- [SwiftDate](https://github.com/malcommac/SwiftDate)
- [UIInfiniteScrollView](https://github.com/EvanCooper9/swift-infinite-uiscrollview) - already included in source

## Example
See the included example for basic implementation. Make sure to open `CalendarWeekView.xcworkspace` for it to work properly with CocoaPods.