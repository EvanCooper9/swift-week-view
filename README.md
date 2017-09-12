# Swift-Week-View
An iOS calendar library for displaying calendar events in a week view.

<p align="center">
	<img src="Media/screen3.png" width="30%" height="auto">
	<img src="Media/screen2.gif" width="30%" height="auto">
</p> 

## Features
- See calendar events in a week view
- Asynchronously load calendar events
- Custom styling
- Infinite horizontal scrolling
- Interface builder preview
- Show a line at the current time

## Usage
### 1. Download [source](https://github.com/EvanCooper9/swift-week-view/tree/master/Source) files and install [dependencies](https://github.com/EvanCooper9/swift-week-view#dependencies)

### 2. Implement the WeekViewDataSource Protocol
Implement the `weekViewGenerateEvents` protocol function. This function should return a list of `WeekViewEvent`s specific to the day of `date`. See [here](malcommac.github.io/SwiftDate/manipulate_dates.html#dateatunit) for SwiftDate documentation on creating date objects at specific times. Currently, events rely on a [24-hour clock](https://en.wikipedia.org/wiki/24-hour_clock).

```Swift
func weekViewGenerateEvents(_ weekView: WeekView, date: DateInRegion) -> [WeekViewEvent] {
	let start: DateInRegion = date.atTime(hour: 12, minute: 0, second: 0)!
	let end: DateInRegion = date.atTime(hour: 13, minute: 30, second: 0)!
	let event: WeekViewEvent = WeekViewEvent(title: "Lunch", start: start, end: end)
	return [event]
}
```
#### Available arguments for `WeekViewEvent`
- `title`: the title of the event
- `start`: the start of the event
- `end`: the end of the event
- `color`: (Optional) the color that the event will be displayed in. Defaults to red.

> #### Note:
> `weekViewGenerateEvents` is already being called asynchronously with a completion handler behind the scenes, so events are added aynchronously, event if they're fetched synchronously.

### 3. Initialize the instance
#### A. Programmatically
Create an instance of `WeekView`, specify it's delegate, and add it as a subview

```Swift
let weekView: WeekView = WeekView(frame: frame, visibleDays: 5)
weekView.dataSource = self
self.view.addSubview(weekView)
```
##### Available arguments for `WeekView`
- `frame`: the frame of the calendar view
- `visibleDays`: amount of days that are visible on one page. Default = 5
- `date`: (Optional) the day `WeekView` will initially load. Default = today
- `startHour`: (Optional) the earliest hour that will be displayed. Default = 09:00
- `endHour`: (Optional) the latest hour that will be displayed. Defalt = 17:00
- `colorTheme`: (Optional) the colors used in the view. Default = `LightTheme`

#### B. Storyboard
Add a view to the storyboard and make it's class `WeekView`. Then connect the view as an outlet to your view contoller and set the data source.
```Swift
@IBOutlet weak var weekView: WeekView!
weekView.dataSource = self
```

## Custom Styling
To use custom styling, implement the `WeekViewStyler` protocol, and any of the included functions. Set the `styler` propery of the `WeekView` to the class that implements the protocol.
Default implementations can be found in `WeekView.swift`. 

```Swift
weekView.UIDataSource = self

// Creates the view for an event
func weekViewStylerEventView(_ weekView: WeekView, eventCoordinate: CGPoint, eventSize: CGSize, event: WeekViewEvent) -> UIView

// Creates the view for a day's header
func weekViewStylerHeaderView(_ weekView: WeekView, containerPosition: Int, containerCoordinate: CGPoint, containerSize: CGSize) -> UIView

// Creates the day's main view where the events are seen
func weekViewStylerDayView(_ weekView: WeekView, containerPosition: Int, containerCoordinate: CGPoint, containerSize: CGSize, header: UIView) -> UIView
```

## Dependencies
### [SwiftDate](https://github.com/malcommac/SwiftDate), via [Cocoapods](https://cocoapods.org)
```ruby
pod 'SwiftDate', '~> 4.0'
```

## Example
See the included example for basic implementation. Make sure to download the *entire* repository, and then open the `.xcworkspace` for it to work properly with the Source files and CocoaPods.

## Up Next
- Add events with touch gestures
- Ability to scroll vertically through the full hours of the day.
- Add completion handler in `weekViewGenerateEvents` to allow non-blocking calls to fetch data for events, since some API calls by nature are non-blocking and don't have the ability to be synchronous. 