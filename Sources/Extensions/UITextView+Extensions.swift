import UIKit

extension UITextView {
    func centerTextVertically() {
        var topCorrect = (self.bounds.size.height - self.contentSize.height * self.zoomScale) / 2
        topCorrect = (topCorrect < 0.0) ? 0.0 : topCorrect
        self.contentInset.top = topCorrect
    }

    func pushTextToTop() {
        self.contentInset.top = 0.0
    }

    func removeTextInsets() {
        textContainerInset = .init(top: 0, left: 5, bottom: 0, right: 5)
        textContainer.lineFragmentPadding = 0
    }
}

