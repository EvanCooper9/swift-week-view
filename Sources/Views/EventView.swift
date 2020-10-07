import Foundation
import UIKit

final class EventView: UIView {

    private let boldAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 11)]
    private let regularAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 11)]
    private let colorAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: UIColor.white]

    private lazy var titleAttributes: [NSAttributedString.Key: Any] = {
        var attributes = boldAttribute
        colorAttribute.forEach({ (key: NSAttributedString.Key, value: Any) in
            attributes[key] = value
        })
        return attributes
    }()

    private lazy var subtitleAttributes: [NSAttributedString.Key: Any] = {
        var attributes = regularAttribute
        colorAttribute.forEach({ (key: NSAttributedString.Key, value: Any) in
            attributes[key] = value
        })
        return attributes
    }()

    var event: WeekViewEvent? {
        didSet {
            let titleAttributed = NSAttributedString(string: event!.title, attributes: titleAttributes)
            let lineBreak = NSAttributedString(string: "\n", attributes: nil)
            let subtitleAttributed = NSAttributedString(string: event!.subtitle, attributes: subtitleAttributes)

            let labelText = NSMutableAttributedString()
            labelText.append(titleAttributed)
            labelText.append(lineBreak)
            labelText.append(subtitleAttributed)

            textView.textColor = .white
            textView.attributedText = labelText
        }
    }

    @IBOutlet weak var textView: UITextView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = backgroundColor?.withAlphaComponent(0.75)
    }
}
