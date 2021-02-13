import CoreGraphics
import XCTest

@testable import ECWeekView

final class CGFloatTest: XCTestCase {
    func testRoundToNearest() {
        XCTAssertEqual(2.0.cgFloat.roundToNearest(10), 0)
        XCTAssertEqual(4.9.cgFloat.roundToNearest(10), 0)
        XCTAssertEqual(5.0.cgFloat.roundToNearest(10), 10)
        XCTAssertEqual(6.0.cgFloat.roundToNearest(10), 10)
        XCTAssertEqual(13.0.cgFloat.roundToNearest(10), 10)
        XCTAssertEqual(17.0.cgFloat.roundToNearest(10), 20)
    }
}

private extension Double {
    var cgFloat: CGFloat { CGFloat(self) }
}
