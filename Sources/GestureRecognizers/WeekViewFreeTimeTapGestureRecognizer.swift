import UIKit
import SwiftDate

final class WeekViewFreeTimeTapGestureRecognizer: UITapGestureRecognizer {
    let date: DateInRegion?
    
    init(target: Any?, action: Selector?, date: DateInRegion?) {
        self.date = date
        super.init(target: target, action: action)
    }
}
