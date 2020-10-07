import UIKit

final class ECWeekViewEventTapGestureRecognizer: UITapGestureRecognizer {
    let event: ECWeekViewEvent
    let eventView: UIView

    init(target: Any?, action: Selector?, event: ECWeekViewEvent, eventView: UIView) {
        self.event = event
        self.eventView = eventView
        super.init(target: target, action: action)
    }
}
