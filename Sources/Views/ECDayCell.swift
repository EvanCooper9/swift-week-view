import UIKit

final class ECDayCell: UICollectionViewCell {
    override func prepareForReuse() {
        subviews.forEach { subview in
            subview.removeFromSuperview()
        }
    }
}
