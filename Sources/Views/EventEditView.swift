import EventKit
import EventKitUI
import SwiftUI

struct EventEditView: UIViewControllerRepresentable {
    typealias UIViewControllerType = EKEventEditViewController

    let event: EKEvent
    let eventStore: EKEventStore
    let delegate = EventEditViewDelegate()

    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let vc = EKEventEditViewController()
        vc.event = event
        vc.eventStore = eventStore
        vc.editViewDelegate = delegate
        return vc
    }

    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {}
}

final class EventEditViewDelegate: NSObject, EKEventEditViewDelegate {
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        defer { controller.dismiss(animated: true) }
        guard let event = controller.event else { return }

        do {
            switch action {
            case .deleted:
                try controller.eventStore.remove(event, span: .thisEvent)
            case .saved:
                try controller.eventStore.save(event, span: .thisEvent)
            default:
                break
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
