import UIKit

final class WeekViewEventTapGestureRecognizer: UITapGestureRecognizer {
    let event: WeekViewEvent
    let eventView: UIView

    init(target: Any?, action: Selector?, event: WeekViewEvent, eventView: UIView) {
        self.event = event
        self.eventView = eventView
        super.init(target: target, action: action)
    }
}
