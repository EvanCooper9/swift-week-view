import UIKit
import SwiftDate

final class ECWeekViewFreeTimeTapGestureRecognizer: UITapGestureRecognizer {
    let date: DateInRegion?
    
    init(target: Any?, action: Selector?, date: DateInRegion?) {
        self.date = date
        super.init(target: target, action: action)
    }
}
