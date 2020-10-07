import UIKit
import SwiftDate

/**
 Used to delegate events and actions that occur.
 */
protocol ECWeekViewDelegate: class {
    /**
     Fires when a calendar event is touched on
     
     - parameters:
        - weekView: the WeekView that is calling this function
        - event: the event that was clicked
        - view: the view that was clicked
     */
    func weekViewDidClickOnEvent(_ weekView: ECWeekView, event: WeekViewEvent, view: UIView)

    /**
     Fires when a space without an event is tapped

     - parameters:
        - weekView: the WeekView that was tapped
        - date: the date that was clicked. Accurate down to the minute.
     */
    func weekViewDidClickOnFreeTime(_ weekView: ECWeekView, date: DateInRegion)
}
