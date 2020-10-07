import UIKit

final class DayCell: UICollectionViewCell {
    override func prepareForReuse() {
        subviews.forEach { subview in
            subview.removeFromSuperview()
        }
    }
}
