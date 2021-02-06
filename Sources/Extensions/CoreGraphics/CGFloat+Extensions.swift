import CoreGraphics

public extension CGFloat {
    func roundToNearest(_ nearest: CGFloat) -> CGFloat {
        (self / nearest).rounded() * nearest
    }
}
