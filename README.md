# Swift-Week-View
An iOS calendar library for displaying calendar events in a week view.

<p align="center">
	<img src="Media/screen1.png" width="30%" height="auto">
	<img src="Media/screen2.gif" width="30%" height="auto">
</p> 

## Features
- See calendar events in a week view
- Asynchronously load calendar events
- Infinite horizontal scrolling
- Snaps to closest day after scrolling

## Usage
### 1. WeekView Data Source
Create some subclass of `WeekView`'s data source for creating events, `WeekViewDataSource`. Override the `generateEvents` function. This function should return a list of `WeekViewEvent`s specific to the day of `date`. See [here](malcommac.github.io/SwiftDate/manipulate_dates.html#dateatunit) for [SwiftDate](https://github.com/malcommac/SwiftDate) documentation on creating date objects at specific times. Currently, events rely on a [24-hour clock](https://en.wikipedia.org/wiki/24-hour_clock).

```Swift
class DS: WeekView.WeekViewDataSource {
    override func generateEvents(date: DateInRegion, completion: (([WeekViewEvent]) -> Void)?) -> [WeekViewEvent] {
        // create a WeekViewEvent for the day of date
        let start = date.atTime(hour: 12, minute: 0, second: 0)!
        let end = date.atTime(hour: 13, minute: 0, second: 0)!
        let event: WeekViewEvent = WeekViewEvent(title: "Lunch", startDate: start, endDate: end)
        return [event]
    }
}
```

> #### Note:
> - Events are added to the view asynchronously by default. This means you can make blocking calls in the generateEvents function, and the events will still play nicely with everything else.
> - The optional completion handler is currently `nil`, but in future will provide funcitonality to make non-blocking calls to fetch data for events, since some API calls by nature are non-blocking and don't have the ability to be synchronous. 

### 2. Initialize the instance
Create an instance of `WeekView`, then add it as a subview.

```Swift
let weekView: WeekView = WeekView(frame: frame, dataSource: DS(), visibleDays: 5)
view.addSubview(weekView)
```
> #### Available arguments
> - frame: the frame of the calendar view
> - eventGenerator: an instance of an EventGenerator that overrides the generateEvents function.
> - visibleDays: an instance of a ViewCreator subclass that overrides the createViewSet method.
> - date: (Optional) the day `WeekView` will initially load. Defaults to the current day.
> - startHour: (Optional) the earliest hour that will be displayed. Defaults to 09:00.
> - endHour: (Optional) the latest hour that will be displayed. Defalts to 17:00.

## Dependencies
### [SwiftDate](https://github.com/malcommac/SwiftDate), via [Cocoapods](https://cocoapods.org)
```ruby
pod 'SwiftDate', '~> 4.0'
```

## Example
See the included example for basic implementation. Make sure to open the `.xcworkspace` for it to work properly with CocoaPods.

## Up Next
- Initialize a WeekView within the storyboard
- Ability to scroll vertically through the full hours of the day. 

## Acknowledgements
Inspired by [Android-Week-View](https://github.com/alamkanak/Android-Week-View) after it became a large part of a school project.