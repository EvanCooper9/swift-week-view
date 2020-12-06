import ECWeekView
import SwiftDate
import UIKit

class ViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private var weekView: ECWeekView!
    
    // MARK: - Private Properties
    
    private let eventDetailLauncher = EventDetailLauncher()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        weekView.dataSource = self
        weekView.delegate = self
    }
}

// MARK: - ECWeekViewDataSource

extension ViewController: ECWeekViewDataSource {
    func weekViewGenerateEvents(_ weekView: ECWeekView, date: DateInRegion, eventCompletion: @escaping ([ECWeekViewEvent]?) -> Void) -> [ECWeekViewEvent]? {
//        let start1 = date.dateBySet(hour: (date.day % 5) + 9, min: 0, secs: 0)!
//        let end1 = date.dateBySet(hour: start1.hour + (date.day % 3) + 1, min: 30 * (date.day % 2), secs: 0)!
//        let event = ECWeekViewEvent(title: "Title \(date.day)", subtitle: "Subtitle \(date.day)", start: start1, end: end1)

        let lunchStart = date.dateBySet(hour: 12, min: 0, secs: 0)!
        let lunchEnd = date.dateBySet(hour: 13, min: 0, secs: 0)!
        let lunch = ECWeekViewEvent(title: "Lunch", subtitle: "lunch", start: lunchStart, end: lunchEnd)

        DispatchQueue.global(qos: .background).async {
            eventCompletion([lunch])
        }
        
        return nil
    }
}

// MARK: - ECWeekViewDelegate

extension ViewController: ECWeekViewDelegate {
    func weekViewDidClickOnEvent(_ weekView: ECWeekView, event: ECWeekViewEvent, view: UIView) {
        eventDetailLauncher.event = event
        eventDetailLauncher.present()
    }

    func weekViewDidClickOnFreeTime(_ weekView: ECWeekView, date: DateInRegion) {
        print(#function, "date:", date.toString())
    }
}
