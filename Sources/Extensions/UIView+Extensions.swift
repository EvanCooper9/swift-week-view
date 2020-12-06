import UIKit

extension UIView {
    class func fromNib<T: UIView>() -> T {
        Bundle.module.loadNibNamed(String(describing: T.self), owner: nil, options: nil)?.first as! T
    }
}
